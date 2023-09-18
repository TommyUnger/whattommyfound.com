import libs.logging_config
import logging
import re
import json
import os
import time
import requests
import subprocess
import shutil
from libs.utils import Utils
from libs.db import Db
import pandas as pd

logger = logging.getLogger(__name__)

CENSUS_API_KEY = os.environ.get('CENSUS_API_KEY')
BASE_URL = 'https://api.census.gov/data'

class Census:
    def __init__(self):
        self.db = Db()

    def init_db(self):
        sql = """
            drop schema if exists census cascade;
            CREATE SCHEMA IF NOT EXISTS census;
            create table census.metric
            (
                geo_state smallint,
                geo_id BIGINT,
                metric_id INT,
                val NUMERIC
            );
            create index idx_census_metric_data_metric_geo
            ON census.metric(metric_id, geo_id);
            create index idx_census_metric_data_state_metric
            ON census.metric(geo_state, metric_id);

            create table census.metric_detail(
                metric_id serial,
                data_set VARCHAR(32),
                census_id VARCHAR(16),
                name VARCHAR(512),
                details VARCHAR(512)
            );
            create index idx_census_metric_id on census.metric_detail(metric_id);
        """
        self.db.exec(sql)

    def get_states(self):
        sql = f"""select statefp, stusps, name
                from census.geo_state
                order by 1"""
        return self.db.sql_to_dicts(sql)
        
    def get_geos(self, geo_type):
        res = requests.get(f"https://www2.census.gov/geo/tiger/TIGER_RD18/LAYER/{geo_type}/")
        for file_name in re.findall(r'href="([^.]+.zip)"', res.text):
            print(f"Process: {file_name}")
            url = f"https://www2.census.gov/geo/tiger/TIGER_RD18/LAYER/{geo_type}/{file_name}"
            downloaded_file = Utils.download_file(url, file_name)
            try:
                unzipped_folder = Utils.unzip_file(downloaded_file)
            except:
                print(f"deleting bad file: {downloaded_file}")
                os.remove(downloaded_file)
                continue
            sql_file_path = self.db.shp2pgsql("census", f"geo_{geo_type.lower()}", unzipped_folder, "4326")
            print(f"Load: {sql_file_path}")
            subprocess.run(f"psql -d work -f {sql_file_path}", shell=True, check=True, 
                        stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
            shutil.rmtree(unzipped_folder)

    def get_metric_details(self, data_set, variable):
        ENDPOINT = f"{BASE_URL}/{data_set}/variables/{variable}.json"
        response = requests.get(ENDPOINT)
        if response.status_code == 200:
            data = response.json()
            return data
        else:
            return None

    def get_or_insert_metric_detail(self, data_set, census_id):
        check_sql = """SELECT metric_id FROM census.metric_detail WHERE census_id = %s"""
        insert_sql = """
            INSERT INTO census.metric_detail (data_set, census_id, name, details) 
            VALUES (%s, %s, %s, %s)
            RETURNING metric_id;
        """
        logger.info(f"Get metric detail: {data_set} {census_id}")
        with self.db.cn.cursor() as cursor:
            cursor.execute(check_sql, (census_id,))
            result = cursor.fetchone()
            if result:
                return result[0]
            else:
                dets = self.get_metric_details(data_set, census_id)
                name = re.sub(r"[^a-z0-9]+", " ", (dets['concept'] + ' ' + dets['label']).lower()).strip()
                details = str(dets)
                cursor.execute(insert_sql, (data_set, census_id, name, details))
                new_metric_id = cursor.fetchone()[0]
                self.db.cn.commit()
                return new_metric_id

    def get_census_data(self, data_set, original_data_names, geo, state=""):
        where_in = ",".join([f"'{d}'" for d in original_data_names])
        rows = self.db.sql_to_dicts(f"""
                    select geo_state, census_id, count(1) 
                    from census.metric d
                    join census.metric_detail m on m.metric_id = d.metric_id
                    where m.census_id in ({where_in})
                    group by 1, 2
                             """)
        geo_census_ids = {}
        for row in rows:
            geo_census_ids[f"{row['geo_state']}_{row['census_id']}"] = row['count']

        states = self.db.sql_to_dicts(f"select statefp, stusps, name from {self.db.import_schema}.census_geo_state where stusps ~* '{state.upper()}'")
        for st in states:
            data_names = original_data_names.copy()
            for data_name in original_data_names:
                if f"{st['statefp']}_{data_name}" in geo_census_ids:
                    data_names.remove(data_name)
            if len(data_names) == 0:
                logger.info(f"All data already loaded for {st['statefp']}_{data_name}")
                continue
            variables = ",".join(data_names)
            logger.info(f"Get date for state: {st}")
            ENDPOINT = f"{BASE_URL}/{data_set}?get=NAME,{variables}&for={geo}:*&in=state:{st['statefp']}&key={CENSUS_API_KEY}"
            logger.info(f"Request: {ENDPOINT}")
            response = requests.get(ENDPOINT)
            logger.info(f"Response: {response.status_code} bytes: {len(response.content)}")
            if response.status_code == 200:
                data = response.json()
            else:
                logger.error(f"Error {response.status_code}: {response.text}")
                return None
            df = pd.DataFrame(data[1:], columns = data[0])
            for col_num, col in enumerate(df.columns):
                if col_num >= 1 and col_num <= len(data_names):
                    df[col] = df[col].astype(float)
            geo_id_cols = df.columns[len(data_names)+1:len(df.columns)]
            df["geo_id"] = df[geo_id_cols].astype(str).apply(''.join, axis=1)
            df["geo_state"] = st['statefp']
            for col in data_names:
                df["metric_id"] = self.get_or_insert_metric_detail(data_set, col)
                new_df = df[["geo_state", "geo_id", "metric_id", col]].copy()
                self.db.df2pg(new_df, "census.metric", append=True)

    def get_geo_data(self, geo_type, state=None):
        if geo_type == "block" or geo_type == "tract":
            census_name = geo_type
            if geo_type == "block":
                census_name = "tabblock20"
            geo_type = f"{geo_type}_{state}"
            rows = self.db.sql_to_dicts(f"select name, stusps, statefp from {self.db.import_schema}.census_geo_state where stusps = '{state.upper()}'")
            st = rows[0]
            url = f"https://www2.census.gov/geo/tiger/TIGER_RD18/STATE/{st['statefp']}_{st['name'].upper()}/{st['statefp']}/tl_rd22_{st['statefp']}_{census_name}.zip"
        else:
            url = f"https://www2.census.gov/geo/tiger/TIGER_RD18/LAYER/{geo_type.upper()}/tl_rd22_us_{geo_type.lower()}.zip"
        table_name = f"census_geo_{geo_type}"
        if self.db.import_table_exists(table_name):
            logger.info(f"Table {table_name} already exists")
            return
        downloaded_file = Utils.download_file(url, to_file_name=f"{table_name}.zip")
        logger.info(f"unzip file {downloaded_file}")
        unzipped_folder = Utils.unzip_file(downloaded_file, table_name)
        logger.info(f"import to pg {unzipped_folder}")
        sql_file_path = self.db.import_shp2table(table_name, unzipped_folder)

    def get_all_tables(self, data_set):
        url = f"https://api.census.gov/data/{data_set}/subject/variables.json"
        js_file = Utils.download_file(url, to_file_name=f"{data_set.replace('/', '_')}.json")
        js = json.loads(open(js_file).read())
        data = []
        for k, v in js.get("variables").items():
            if "group" in v and v["group"] != "N/A":
                v["col_id"] = k
                data.append(v)
        df = pd.DataFrame(data)
        self.db.df2pg(df, "census_metric_detail")
