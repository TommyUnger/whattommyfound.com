import libs.utils as utils
import json
import pandas
import geopandas
import re
import os
import pickle
import logging
import time
from google.cloud import bigquery

log = logging.getLogger(__name__)

class Imdb:
    def __init__(self, local_path="local-files"):
        self.project = "dw-realdata"
        self.dataset = "imdb"
        self.project_dataset = f"{self.project}.{self.dataset}"
        self.local_path = local_path
        self.imdb_files = ["name.basics.tsv", "title.akas.tsv", "title.basics.tsv", "title.crew.tsv",
                         "title.episode.tsv", "title.principals.tsv", "title.ratings.tsv"]
    
    def download_files(self):
        for imdb_file in self.imdb_files:
            utils.download_file(f"https://datasets.imdbws.com/{imdb_file}.gz", imdb_file, gz=True, local_path=self.local_path)

    def delete_all_tables(self):
        client = bigquery.Client()
        for imdb_file in self.imdb_files:
            table = re.sub(r"\.", "_", imdb_file[:-4])
            table_name = f"{self.project}.{self.dataset}.{table}"
            log.info(f"delete table: {table_name}")
            try:
                client.delete_table(table_name)
            except:
                pass

    def title_basics(self):
        table_name = "title.basics"
        log.info(f"read tsv: {table_name}")
        df = pandas.read_csv(f"{self.local_path}/{table_name}.tsv", sep="\t", low_memory=False, na_values="\\N")
        df.columns = utils.list_camel_to_underscore(df.columns)
        df.rename(columns={"tconst": "raw_title_id"}, inplace=True)
        df["title_id"] = df.raw_title_id
        log.info("fix column types")
        df.title_id = df.title_id.str.replace("tt", "").astype(int)
        df.start_year = df.start_year.astype('Int32')
        df.end_year = df.end_year.astype('Int32')
        df.is_adult = df.is_adult.astype('Int32')
        df.runtime_minutes = df.runtime_minutes.apply(
                                    lambda x: None if re.match(r"[^0-9].*", str(x)) else float(x)).astype('Int32')
        log.info("fix genres")
        df['genre_list'] = df.genres.apply(lambda d: str(d).split(","))
        df['genre1'] = df.genre_list.apply(lambda d: d[0])
        df['genre2'] = df.genre_list.apply(lambda d: d[1] if len(d) > 1 else None)
        df['genre3'] = df.genre_list.apply(lambda d: d[2] if len(d) > 2 else None)
        df = df[['title_id', 'raw_title_id', 'title_type', 'primary_title', 'original_title',
                        'is_adult', 'start_year', 'end_year', 'runtime_minutes', 'genre1', 'genre2', 'genre3']]
        utils.df_to_bigquery(df, self.project_dataset + "." + table_name.replace(".", "_"))
        del df

    def title_episode(self):
        table_name = "title.episode"
        log.info(f"read tsv: {table_name}")
        df = pandas.read_csv(f"{self.local_path}/{table_name}.tsv", sep="\t", low_memory=False, na_values="\\N")
        log.info("fix columns")
        df.columns = utils.list_camel_to_underscore(df.columns)
        df.rename(columns={"tconst": "title_id", "parent_tconst": "parent_title_id"}, inplace=True)
        log.info("fix column types")
        df.title_id = df.title_id.str.replace("tt", "").astype(int)
        df.parent_title_id = df.parent_title_id.str.replace("tt", "").astype(int)
        df.season_number = df.season_number.astype('Int32')
        df.episode_number = df.episode_number.astype('Int32')
        log.info("fix column types")
        df = df[["parent_title_id", "title_id", "season_number", "episode_number"]]
        utils.df_to_bigquery(df, self.project_dataset + "." + table_name.replace(".", "_"))
        del df

    def title_ratings(self):
        table_name = "title.ratings"
        log.info(f"read tsv: {table_name}")
        df = pandas.read_csv(f"{self.local_path}/{table_name}.tsv", sep="\t", low_memory=False, na_values="\\N")
        df.columns = utils.list_camel_to_underscore(df.columns)
        df.rename(columns={"tconst": "title_id"}, inplace=True)
        df.title_id = df.title_id.str.replace("tt", "").astype('Int32')
        utils.df_to_bigquery(df, self.project_dataset + "." + table_name.replace(".", "_"))
        del df

    def title_crew(self):
        table_name = "title.crew"
        log.info(f"read tsv: {table_name}")
        df = pandas.read_csv(f"{self.local_path}/{table_name}.tsv", sep="\t", low_memory=False, na_values="\\N")
        df.columns = utils.list_camel_to_underscore(df.columns)
        df.rename(columns={"tconst": "title_id"}, inplace=True)
        log.info("fix column types")
        df.title_id = df.title_id.str.replace("tt", "").astype('Int32')
        df.directors = df.directors.apply(
                            lambda x: None if str(x) == 'nan' else [int(dd) for dd in str(x).replace("nm", "").split(",")])
        df.writers = df.writers.apply(
                            lambda x: None if str(x) == 'nan' else [int(dd) for dd in str(x).replace("nm", "").split(",")])
        utils.df_to_bigquery(df, self.project_dataset + "." + table_name.replace(".", "_"))
        del df

    def title_principals(self):
        table_name = "title.principals"
        log.info(f"read tsv: {table_name}")
        df = pandas.read_csv(f"{self.local_path}/{table_name}.tsv", sep="\t", low_memory=False, na_values="\\N")
        df.columns = utils.list_camel_to_underscore(df.columns)
        df.rename(columns={"tconst": "title_id", "nconst": "name_id"}, inplace=True)
        log.info("fix column types")
        df.title_id = df.title_id.str.replace("tt", "").astype('Int32')
        df.name_id = df.name_id.str.replace("nm", "").astype('Int32')
        df.characters = df.characters.apply(
                                    lambda x: None if str(x) == 'nan' else json.loads(str(x)))
        utils.df_to_bigquery(df, self.project_dataset + "." + table_name.replace(".", "_"))
        del df

    def name_basics(self):
        table_name = "name.basics"
        log.info(f"read tsv: {table_name}")
        df = pandas.read_csv(f"{self.local_path}/{table_name}.tsv", sep="\t", low_memory=False, na_values="\\N")
        df.columns = utils.list_camel_to_underscore(df.columns)
        df.rename(columns={"nconst": "name_id"}, inplace=True)
        log.info("fix column types")
        df.name_id = df.name_id.str.replace("nm", "").astype('Int32')
        df.birth_year = df.birth_year.astype('Int32')
        df.death_year = df.death_year.astype('Int32')
        df.primary_profession = df.primary_profession.apply(
                        lambda x: None if str(x) == 'nan' else str(x).split(","))
        log.info("fix known for titles")
        df.known_for_titles = df.known_for_titles.apply(
                        lambda x: None if str(x) == 'nan' else [int(dd) for dd in str(x).replace("tt", "").split(",")])    
        utils.df_to_bigquery(df, self.project_dataset + "." + table_name.replace(".", "_"))
        del df

    def get_metadata_for_show(self, title_id, raw_title_id):
        url = f"https://www.imdb.com/title/{raw_title_id}/"
        try:
            dom = utils.browser_get(url, local_path=f"{self.local_path}/imdb_data")
        except:
            time.sleep(10)
            return
        lists = {}
        for el in dom.select(".ipc-metadata-list__item"):
            lbl = el.select(".ipc-metadata-list-item__label")
            if len(lbl) == 0:
                continue
            attr_type = lbl[0].text.lower()
            lis = el.select("li")
            if len(lis) > 0:
                lists[attr_type] = []
                for li in lis:
                    lists[attr_type].append(li.text)
            elif len(el.select("button")) > 0:
                attr_type = el.select("button")[0].text.lower()
                lists[attr_type] = []
                lists[attr_type].append(el.select(".ipc-metadata-list-item__content-container")[0].text)
        res = []
        for typ, vals in lists.items():
            for i, val in enumerate(vals):
                res.append([title_id, typ, i+1, val])
        for x in dom.select(".ipc-page-section"):
            cel_id = x.get("cel_widget_id")
            if type(cel_id) == str and 'Story' in cel_id:
                res.append([title_id, "story", 1, utils.bs_el_text(x, ".ipc-html-content-inner-div")])
                for i, kw in enumerate(x.select(".ipc-chip__text")):
                    res.append([title_id, "keyword", i+1, kw.text])            
        return res
        
    def get_more_metadata(self):
        client = bigquery.Client()
        sql = """select
                tb.raw_title_id,
                tb.title_id,
                count(1) as episode_count
                from `dw-realdata.imdb.title_episode` as e
                join `dw-realdata.imdb.title_basics` as tb on tb.title_id = e.parent_title_id
                join `dw-realdata.imdb.title_ratings` as r on r.title_id = e.title_id
                where r.num_votes >= 100
                group by 1, 2
                having count(1) >= 5
                order by tb.title_id desc
                limit 30"""
        log.info("get top shows from bigquery based on votes, and # of episodes")
        df = client.query(sql).to_dataframe()
        all_data = {}
        for d in df.itertuples():
            if d.title_id not in all_data or all_data[d.title_id] == None:
                log.info(f"get more metadata for: {d.title_id}")
                all_data[d.title_id] = self.get_metadata_for_show(d.title_id, d.raw_title_id)
        flattened_data = []
        for show_id, show_d in all_data.items():
            for row in show_d:
                flattened_data.append(row)
        df = pandas.DataFrame(flattened_data, columns=["title_id", "property", "pos", "value"])
        log.info(f"load more medata into bigquery")
        utils.df_to_bigquery(df, "dw-realdata.imdb.title_scraped_details_small")
