import re
import os
import gzip
import time
import logging
import zipfile
import requests
import shutil
import warnings
import unittest
from google.cloud import bigquery
import libs.utils as utils

log = logging.getLogger(__name__)

class Fec:
    def __init__(self, local_path="local-files"):
        self.host = "https://www.fec.gov"
        self.local_path = local_path
        self.project = "dw-realdata"
        self.dataset = "fec"
        self.project_dataset = f"{self.project}.{self.dataset}"
        self.bq = bigquery.Client()
        this_path = os.path.dirname(os.path.abspath(__file__))
        self.ds = utils.DataSchema(f'{this_path}/fec_schema.csv')

    def unzip_clean_save(self, zipped_file_name, from_file, to_file, source_file):
        log.info(f"unzipping: {zipped_file_name}")
        date = time.strftime("%Y-%m-%d")
        to_dir = f"{self.local_path}/unzipped_files"
        extracted_files = []
        with zipfile.ZipFile(zipped_file_name, 'r') as zo:
            file_names = zo.namelist()
            for file_name in file_names:
                log.info(f"found file: {file_name}")
                if from_file in file_name:
                    log.info(f"extracting: {file_name}")
                    zo.extract(file_name, to_dir)
        log.info(f"done unzipping: {zipped_file_name}")
        log.info(f"saving file(s) in {to_dir}")
        f_read = open(f"{to_dir}/{from_file}", 'r', errors='replace')
        file_num = 1
        f_write = gzip.open(f"{to_file}.{file_num}", mode='wb', compresslevel=1)
        done_file_names = [f"{to_file}.{file_num}"]
        bytes_count = 0
        while True:
            line = f_read.readline()
            if not line:
                break
            bytes_count += len(line)
            if bytes_count >= 500000000:
                f_write.close()
                file_num += 1
                f_write = gzip.open(f"{to_file}.{file_num}", mode='wb', compresslevel=1)
                done_file_names.append(f"{to_file}.{file_num}")
                bytes_count = 0
            f_write.write(line.replace("\n", "").replace('\\', "").replace('\x00', "").encode("utf-8") + (f"|{source_file}|{date}\n").encode("utf-8"))
        f_write.close()
        f_read.close()
        log.info(f"done saving file: {to_file}")
        return done_file_names
        
    def indiv_get(self, url, file_name, test_name = ""):
        log.info(f"working on file: {file_name}")
        local_file_name = utils.download_file(url, file_name)
        to_file = f"{self.local_path}/{file_name}".replace(".zip", ".gz")
        to_files = self.unzip_clean_save(local_file_name, "itcont.txt", to_file, file_name)
        for to_file in to_files:
            log.info(f"load {to_file} in bigquery")
            utils.file_to_bigquery(to_file, f"{self.project_dataset}.donation{test_name}",
                                   schema_fields=self.ds.tables["donation"], delim="|")
            os.remove(to_file)
        log.info("remove files")
        shutil.rmtree(f"{self.local_path}/unzipped_files")
        os.remove(local_file_name)
        return to_files

    def cm_cn_get(self, c_type, c_name, url, file_name, test_name = ""):
        log.info(f"url: {url} - {file_name}")
        local_file_name = utils.download_file(url, file_name)
        to_file = f"{self.local_path}/{file_name}".replace(".zip", ".gz")
        to_files = self.unzip_clean_save(local_file_name, f"{c_type}.txt", to_file, file_name)
        for to_file in to_files:
            log.info(f"load {to_file} in bigquery")
            utils.file_to_bigquery(to_file, f"{self.project_dataset}.{c_name}{test_name}",
                               schema_fields=self.ds.tables[c_name], delim="|")
            os.remove(to_file)
        shutil.rmtree(f"{self.local_path}/unzipped_files")
        os.remove(local_file_name)
        return to_file

    def indiv_files(self):
        resp = requests.get(f"{self.host}/data/browse-data/?tab=bulk-data")
        files = re.findall("<a.*?href=\"([^\"]+)\"", resp.text, re.M)
        for m in sorted(files):
            fm = re.match(r".*(indiv.*[.]zip)", m)
            # TODO: check bigquery for existing data
            if fm:
                file_name = fm.groups(0)[0]
                url = f"{self.host}{m}"
                self.indiv_get(url, file_name)

    def cm_cn_files(self, c_type, c_name):
        resp = requests.get(f"{self.host}/data/browse-data/?tab=bulk-data")
        files = re.findall("<a.*?href=\"([^\"]+)\"", resp.text, re.M)
        for m in sorted(files):
            fm = re.match(f".*({c_type}.*[.]zip)", m)
            # TODO: check bigquery for existing data
            if fm:
                file_name = fm.groups(0)[0]
                url = f"{self.host}{m}"
                log.info(url)
                self.cm_cn_get(c_type, c_name, url, file_name)

    def load_all_data(self):
        self.cm_cn_files("cn", "candidate")
        self.cm_cn_files("cm", "committee")
        self.indiv_files()


class TestFec(unittest.TestCase):
    def setUp(self):
        warnings.filterwarnings(action="ignore", message="unclosed", category=ResourceWarning)
        logging.basicConfig(format='%(asctime)s|%(levelname)s %(funcName)s: %(message)s',
                            level=logging.INFO,
                            datefmt="%H:%M:%S")
    def tearDown(self):
        fec = Fec()
        client = bigquery.Client()
        for table in client.list_tables(fec.dataset):
            if table.full_table_id[-5:] == "_test":
                log.info(f"delete table {table.full_table_id}")
                client.delete_table(table.full_table_id.replace(":", "."))
        del fec

    def test_all(self):
        fec = Fec()
        to_file = fec.cm_cn_get("cm", "committee",
                                "https://www.fec.gov/files/bulk-downloads/1994/cm94.zip",
                                "committee94.zip",
                                test_name="_test")
        # self.assertEqual(to_file, f'{fec.local_path}/committee94.gz')
        to_file = fec.cm_cn_get("cm", "committee",
                                "https://www.fec.gov/files/bulk-downloads/2000/cm00.zip",
                                "committee00.zip",
                                test_name="_test")
        # self.assertEqual(to_file, f'{fec.local_path}/committee00.gz')

        # to_file = fec.cm_cn_get("cn", "candidate",
        #                         "https://www.fec.gov/files/bulk-downloads/1994/cn94.zip",
        #                         "candidate94.zip",
        #                         test_name="_test")
        # self.assertEqual(to_file, f'{fec.local_path}/candidate94.gz')
        # to_file = fec.cm_cn_get("cn", "candidate",
        #                         "https://www.fec.gov/files/bulk-downloads/2000/cn00.zip",
        #                         "candidate00.zip",
        #                         test_name="_test")
        # self.assertEqual(to_file, f'{fec.local_path}/candidate00.gz')
        # to_files = fec.indiv_get(url = "https://www.fec.gov/files/bulk-downloads/2010/indiv10.zip",
        #                         file_name = "indiv.zip",
        #                         test_name = "_test")
        # log.info(to_files)
        # self.assertEqual(to_file, f'{fec.local_path}/indiv.gz')
        del fec
