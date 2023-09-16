import os
import logging
logging.basicConfig(
    level=logging.DEBUG, 
    format='[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s',
)
import urllib.request as req
import zipfile
import re
import csv
import subprocess
from urllib.parse import urlparse
import ssl
ssl._create_default_https_context = ssl._create_unverified_context


def run_command(cmd):
    result_text = subprocess.check_output(cmd, 
                                     shell=True, 
                                     stderr=subprocess.STDOUT)
    logging.info(result_text[0:100])

class ImportUtils:
    def __init__(self, db_url):
        self.db_url = db_url
        url_parts = urlparse(db_url)
        self.db_host = url_parts.hostname
        self.db_name = url_parts.path[1:]
        self.db_user = url_parts.username
        self.db_pass = url_parts.password

    def download_and_unzip_file(self, file_url):
        logging.info("downloading file %s" % file_url)
        req.urlretrieve(file_url, "download.zip")
        logging.info("unzipping file %s" % file_url)
        with zipfile.ZipFile('download.zip', 'r') as zip_ref:
            zip_ref.extractall(path = 'data/')
        logging.info("done %s" % file_url)

    def run_sql_to_file(self, sql, to_file):
        logging.info(f"running sql to file {to_file}")
        cmd = "psql \"%s\" --tuples-only -c \"%s\" > \"%s\"" % (self.db_url, re.sub('[\r\n\t ]+', ' ', sql), to_file)
        run_command(cmd)
        logging.info("done running sql")

    def run_sql(self, sql):
        logging.info("running sql")
        cmd = "psql \"%s\" -c \"%s\"" % (self.db_url, re.sub('[\r\n\t ]+', ' ', sql))
        run_command(cmd)
        logging.info("done running sql")

    def load_data_from_file(self, db_table, file_name, delim=','):
        cmd = "cat %s | psql \"%s\" -c \"SET CLIENT_ENCODING='LATIN1'; COPY %s FROM STDIN WITH CSV DELIMITER '%s' QUOTE '\\\"'\"" % (
                            file_name, self.db_url,
                            db_table, delim)
        run_command(cmd)

    def load_csv_to_postgres(self, table_name, file_name):
        cols = []
        logging.info("start load_csv_to_postgres %s" % table_name)
        with open(file_name, newline='') as csvfile:
            rdr = csv.reader(csvfile, delimiter=',', quotechar='"')
            for line in rdr:
                for col in line:
                    col_name = re.sub('([a-z])([A-Z])', '\\1_\\2', col).lower()
                    cols.append(col_name)
                break
        table_name = "import.%s" % table_name
        logging.info("create table: %s" % table_name)
        self.run_sql('DROP TABLE IF EXISTS %s; CREATE TABLE %s(%s)' % (table_name, 
                                                                  table_name, 
                                                                  ', '.join(['\\"' + d + '\\" TEXT' for d in cols])))
        logging.info("load data")
        self.load_data_from_file(table_name, file_name)
        logging.info("trim data")
        self.run_sql("UPDATE %s SET %s" % (table_name, ', '.join(['\\"%s\\"=trim(\\"%s\\")' % (d, d) for d in cols])))
        logging.info("empty to null")
        self.run_sql("UPDATE %s SET %s" % (table_name, 
                                    ', '.join(['\\"%s\\"=CASE WHEN \\"%s\\" = \'\' THEN NULL ELSE \\"%s\\" END' % (d, d, d) for d in cols])))
        logging.info("done load_csv_to_postgres %s" % table_name)


