import libs.logging_config
import logging
import time
from libs.utils import Utils
from libs.db import Db

logger = logging.getLogger(__name__)

class Arcgis:
    def __init__(self):
        self.db = Db()

    def get_shape(self, table_name, data_id, from_srid):
        if self.db.import_table_exists(table_name):
            logger.info(f"Table {table_name} already exists")
            return
        logger.info(f"get {table_name} from arcgis {data_id}")
        downloaded_file = Utils.download_file(f"https://opendata.arcgis.com/api/v3/datasets/{data_id}/downloads/data?format=shp&spatialRefId={from_srid}&where=1%3D1",
                                              to_file_name=f"{table_name}.zip")
        logger.info(f"unzip file {downloaded_file}")
        unzipped_folder = Utils.unzip_file(downloaded_file, table_name)
        logger.info(f"import to pg {unzipped_folder}")
        sql_file_path = self.db.import_shp2table(table_name, unzipped_folder, from_srid)
