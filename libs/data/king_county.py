import libs.logging_config
import logging
import os
import time
from libs.utils import Utils
from libs.db import Db
logger = logging.getLogger(__name__)

class KingCounty:
    def __init__(self):
        self.db = Db()

    def get_data(self, data_url, table_names):
        first_table_name = list(table_names.values())[0]
        if self.db.import_table_exists(first_table_name):
            logger.info(f"Table {first_table_name} already exists")
            return
        downloaded_file = Utils.download_file(data_url)
        unzipped_folder = Utils.unzip_file(downloaded_file, "king_county_data")
        for file_name, table_name in table_names.items():
            file_path = os.path.join(unzipped_folder, file_name)
            logger.info(f"Importing {file_path} to {table_name}")            
            self.db.csv2db(file_path, table_name, encoding='latin1')
