import os
import re
import sys
import csv
import time
import gzip
import tempfile
import requests
import logging
import shutil
import pandas
from dotenv import load_dotenv
from bs4 import BeautifulSoup
from selenium import webdriver
from google.cloud import bigquery
from google.cloud.exceptions import NotFound

load_dotenv()
log = logging.getLogger(__name__)
BR = None

class DataSchema:
    tables = {}
    def __init__(self, file_name):
        df = pandas.read_csv(file_name)
        for d in df.itertuples():
            if d.table not in self.tables:
                self.tables[d.table] = []
            self.tables[d.table].append(bigquery.SchemaField(d.field, d.data_type))


def download_file(url, file_name, gz = False, local_path="local-files"):
    global log
    gz_ext = ""
    if gz == True:
        gz_ext = ".gz"
    file_path = f'{local_path}/{file_name}{gz_ext}'
    if os.path.exists(file_path):
        log.info(f'File {file_path} already exists.')
        return file_path
    if not os.path.exists(local_path):
        log.info(f'Creating directory: {local_path}')
        os.makedirs(local_path)
    response = requests.get(url, stream=True)
    file_size = float(response.headers.get('Content-length'))
    file_size_mb = int(file_size / 1000000)
    perc_5 = file_size * 0.05
    perc_downloaded = 0
    chunk_size = 1024*1024
    log.info(f'Downloading file {file_name} - size: {file_size_mb}MB')
    with open(file_path, 'wb') as f:
        for chunk in response.iter_content(chunk_size=1024*1024):
            f.write(chunk)
            perc_downloaded += chunk_size / file_size
            if perc_downloaded > perc_5:
                perc_5 += file_size * 0.05
    if gz == True:
        log.info(f'gzip uncompressing file: {file_name}')
        with gzip.open(file_path, 'rb') as f_in:
            with open(f'{local_path}/{file_name}', 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
    log.info(f'Completed downloading file {file_name}')
    return file_path

def camel_to_underscore(s):
    return re.sub(r'([a-z])([A-Z])', r'\1_\2', s).lower()

def list_camel_to_underscore(ss):
    return [camel_to_underscore(s) for s in ss]

def bs_el_text(el, sel):
    d = ""
    try:
        d = el.select(sel)[0].text
    except:
        pass
    return d

def browser_get(url, html=False, local_path="local-files"):
    global BR
    file_name = re.sub(r"[^a-z0-9]+", "_", re.sub(r"(http[s]*://|www[.])", "", url))
    file_path = f"{local_path}/{file_name}"
    if not os.path.exists(file_path):
        log.info(f"download url: {url}")
        try:
            old_url = BR.current_url
        except:
            log.error("chrome driver not active")
            BR = None
        if BR is None:
            log.info("start chrome driver")
            BR = webdriver.Chrome('chromedriver')
        BR.get(url)
        BR.execute_script("window.scrollTo(0, 2000)") 
        time.sleep(0.1)
        BR.execute_script("window.scrollTo(0, 4000)") 
        time.sleep(1)
        fw = open(file_path, "w")
        fw.write(BR.page_source)
        fw.close()
    if html:
        return open(file_path, "r").read()
    bs = BeautifulSoup(open(file_path, "r").read(), features="html.parser")
    return bs

def file_to_bigquery(file_name, table, schema_fields, delim="\t"):
    (project, schema, name) = table.split(".")
    client = bigquery.Client(project=project)
    try:
        client.get_dataset(schema)
        log.info(f"Dataset exists: {schema}")
    except NotFound:
        log.info("Dataset {} is not found".format(schema))
        dataset = bigquery.Dataset(f"{project}.{schema}")
        dataset.location = "us-west1"
        dataset = client.create_dataset(dataset, timeout=30)  # Make an API request.
        log.info("Created dataset {}.{}".format(client.project, dataset.dataset_id))
    job_config = bigquery.LoadJobConfig(
        source_format = bigquery.SourceFormat.CSV,
        field_delimiter = delim,
        quote_character = '',
        encoding = 'UTF-8',
        schema = schema_fields+[
                    bigquery.SchemaField("source_file","STRING"),
                    bigquery.SchemaField("source_date","DATE")],
    )
    log.info(f"load data into table: {table}")
    with open(file_name, "rb") as source_file:
        job = client.load_table_from_file(source_file, destination=table, job_config=job_config)
    log.info(f"wait for job to complete")
    job.result()
    table_result = client.get_table(table)
    log.info("Loaded {} rows and {} columns to {}".format(table_result.num_rows, len(table_result.schema), table))

def df_to_bigquery(df, table):
    client = bigquery.Client()
    (project, schema, name) = table.split(".")
    try:
        client.get_dataset(schema)
    except NotFound:
        log.info("Dataset {} is not found".format(schema))
        dataset = bigquery.Dataset(schema)
        dataset.location = "us-west1"
        dataset = client.create_dataset(dataset, timeout=30)  # Make an API request.
        log.info("Created dataset {}.{}".format(client.project, dataset.dataset_id))
    log.info("configure job")
    (_, temp_file_name) = tempfile.mkstemp(dir='/tmp')
    log.info("create temp parquet file")
    df.to_parquet(temp_file_name, index=False)
    parquet_options = bigquery.format_options.ParquetOptions()
    parquet_options.enable_list_inference = True
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.PARQUET,
        write_disposition=bigquery.WriteDisposition.WRITE_EMPTY,
        parquet_options=parquet_options
    )
    log.info(f"created temp parquet file {temp_file_name}")
    with open(temp_file_name, "rb") as source_file:
        job = client.load_table_from_file(source_file, table, job_config=job_config)
    log.info(f"wait for job to complete")
    job.result()
    table_result = client.get_table(table)
    log.info("Loaded {} rows and {} columns to {}".format(table_result.num_rows, len(table_result.schema), table))

