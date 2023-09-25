import libs.logging_config
import logging
import os
import re
import time
import gzip
import shutil
import requests
import zipfile
import subprocess

logger = logging.getLogger(__name__)

class Utils:
    @staticmethod
    def camel_to_snake(name):
        name = re.sub(r"[^A-Za-z0-9]+", " ", name)
        name = re.sub('(.)([A-Z][a-z]+)', r'\1 \2', name)
        name = re.sub('([a-z0-9])([A-Z])', r'\1 \2', name).lower()
        name = re.sub(r"[ ]+", "_", name.strip())
        return name

    @staticmethod
    def get_session():
        s = requests.Session()
        s.headers.update({
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Encoding': 'gzip, deflate, br',
            'Accept-Language': 'en-US,en;q=0.9',
            'Cache-Control': 'no-cache',
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36'
            })
        return s

    @staticmethod
    def download_file(url, to_file_name=None, dest_folder="downloads", session=None):
        if not os.path.exists(dest_folder):
            os.makedirs(dest_folder)
        if to_file_name is None:
            filename = re.sub(r"[^a-z0-9.]+", "_", url.lower())
        else:
            filename = to_file_name
        logger.info(f"download file {url} to {filename}")
        filename = os.path.join(dest_folder, filename)
        if os.path.exists(filename):
            logger.info(f"File alreaded downloaded at {filename}")
            return filename
        if session is None:
            session = requests.Session()
        r = session.get(url, stream=True)
        last_time = time.time()
        with open(filename, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
                if time.time() > last_time + 5:
                    logger.info(f"downloaded {os.path.getsize(filename)} bytes")
                    last_time = time.time()
        return filename

    @staticmethod
    def unzip_file(file_path, dest_folder=""):
        dest_folder = os.path.join("downloads", dest_folder)
        if file_path.endswith(".gz"):
            logger.info(f'gzip uncompressing file: {file_path}')
            if not os.path.exists(dest_folder):
                os.makedirs(dest_folder)
            # Create output file path (remove .gz extension)
            output_path = os.path.join(dest_folder, os.path.basename(file_path)[:-3])
            with gzip.open(file_path, 'rb') as f_in:
                with open(output_path, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
        else:
            logger.info(f"unzip file {file_path} to: {dest_folder}")
            with zipfile.ZipFile(file_path, 'r') as zip_ref:
                zip_ref.extractall(dest_folder)
        return dest_folder
    
    @staticmethod
    def run(cmd):
        logger.info(f"Run: {cmd}")
        cmd_txt = re.sub(r"[^A-Za-z0-9-]+", "_", cmd)[0:90]
        out_file = open(f"logs/{cmd_txt}_out.log", "w")
        err_file = open(f"logs/{cmd_txt}_err.log", "w")
        subprocess.run(cmd, shell=True, check=True, stdout=out_file, stderr=err_file)
        out_file.close()
        err_file.close()
        return (open(f"logs/{cmd_txt}_out.log", "r").read(),
                open(f"logs/{cmd_txt}_err.log", "r").read())
