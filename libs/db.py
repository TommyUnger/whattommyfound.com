import libs.logging_config
import logging
import os
import time
import psycopg2
import pandas as pd
from psycopg2.extras import DictCursor
from io import StringIO
from sqlalchemy import create_engine
from libs.utils import Utils
logger = logging.getLogger(__name__)

class Db:
    def __init__(self, db_url=os.environ.get('DBURI')):
        self.db_url = db_url
        self.cn = psycopg2.connect(self.db_url)
        schema_date = os.environ.get("IMPORT_SCHEMA_DATE", time.strftime('%Y%m%d'))
        self.import_schema = f"import_{schema_date}"
        self.exec(f"CREATE SCHEMA IF NOT EXISTS {self.import_schema}")

    def exec(self, sql, params=None):
        with psycopg2.connect(self.db_url) as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql, params)
                conn.commit()

    def import_shp2table(self, table_name, shp_folder, from_srid=4326):
        sql_file_path = self.shp2pg(self.import_schema, table_name, shp_folder, f"{from_srid}:4326")
        psql_cmd = f"psql {self.db_url} -f {sql_file_path}"
        logger.info(psql_cmd)
        out, err = Utils.run(psql_cmd)
        if err != "":
            logger.error(err)

    def sql_to_dicts(self, sql, params=None):
        with psycopg2.connect(self.db_url) as conn:
            with conn.cursor(cursor_factory=DictCursor) as cursor:
                # logger.debug(sql)
                cursor.execute(sql, params)
                results = cursor.fetchall()
                return [dict(row) for row in results]

    def table_exists(self, table_name, schema_name='public'):
        cursor = self.cn.cursor()
        cursor.execute(f"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema='{schema_name}' and table_name='{table_name}')")
        exists = cursor.fetchone()[0]
        cursor.close()
        return exists

    def import_table_exists(self, table_name):
        return self.table_exists(table_name, schema_name=self.import_schema)

    def shp2pg(self, schema_name, table_name, shp_folder, srid):
        logger.info(f"shp2pg {table_name} from {shp_folder}")
        shp_file = next((f for f in os.listdir(shp_folder) if f.endswith('.shp')), None)
        if shp_file is None:
            raise ValueError('No shapefile found in the directory.')
        shp_file_path = os.path.join(shp_folder, shp_file)
        sql_file_path = os.path.join(shp_folder, "output.sql")
        create_table = '-a'
        if not self.table_exists(table_name, schema_name):
            create_table = '-c'
        cmd = f'shp2pgsql -s {srid} -D {create_table} {shp_file_path} {schema_name}.{table_name} > {sql_file_path}'
        out, err = Utils.run(cmd)
        return sql_file_path
    
    def csv2db(self, file_name, table_name, encoding='utf8'):
        logger.info(f"read {file_name} into dataframe")
        df = pd.read_csv(file_name, encoding=encoding, low_memory=False)
        logger.info(f"load to postgres {table_name} from {file_name}")
        self.df2pg(df, table_name)
        logger.info(f"completed load to postgres {table_name} from {file_name}")

    def df2pg(self, df, table_name, append=False):
        schema_name = self.import_schema
        if "." in table_name:
            schema_name, table_name = table_name.split(".")
        if append == False:
            df.columns = [Utils.camel_to_snake(name) for name in df.columns]
            conn = create_engine(self.db_url)
            df[0:10].to_sql(table_name, schema=schema_name, con=conn, if_exists='replace', index=False)
            cursor = self.cn.cursor()
            cursor.execute(f"truncate table {schema_name}.{table_name}")
            self.cn.commit()
            cursor.close()
        conn = psycopg2.connect(self.db_url)
        cur = conn.cursor()
        buffer = StringIO()
        df.to_csv(buffer, index=False, header=False)
        buffer.seek(0)
        logger.info(f"copy {schema_name}.{table_name} from dataframe buffer")
        copy_query = f"COPY {schema_name}.{table_name} FROM stdin WITH CSV"
        cur.copy_expert(copy_query, buffer)
        conn.commit()
        cur.close()
        conn.close()
