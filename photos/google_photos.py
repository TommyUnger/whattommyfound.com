from __future__ import print_function

import re
import os
import json
import pandas as pd
import shutil
import glob
import requests
import logging

logging.basicConfig(
    format='%(asctime)s %(levelname)-8s %(message)s',
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S',
    )

from datetime import date, timedelta
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

from sqlalchemy import create_engine
engine = create_engine('postgresql://%(PGUSER)s:%(PGPASSWORD)s@localhost:5432/work' % os.environ)

SCOPES = ['https://www.googleapis.com/auth/photoslibrary']
USER_DIR = os.path.expanduser('~')
PHOTOS_API = None

def init_api():
    global PHOTOS_API
    creds = None
    creds_file = f"{USER_DIR}/creds/google_api_photos.json"
    token_file = f"{USER_DIR}/creds/google_api_photos_token.json"
    if os.path.exists(token_file):
        creds = Credentials.from_authorized_user_file(token_file, SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(creds_file, SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open(token_file, 'w') as token:
            token.write(creds.to_json())
    PHOTOS_API = build('photoslibrary', 'v1', credentials=creds, static_discovery=False)

def flatten_json(y):
    out = {}
    def flatten(x, name=''):
        if type(x) is dict:
            for a in x:
                flatten(x[a], name + a + '_')
        elif type(x) is list:
            i = 0
            for a in x:
                flatten(a, name + str(i) + '_')
                i += 1
        else:
            out[name[:-1]] = x 
    flatten(y)
    return out
 

def get_takeout_file_metadata():
    files = list(glob.glob("/Volumes/One Touch/GooglePhotos/Takeout/Google Photos/*/*.json"))
    rows = []
    file_count = 0
    logging.info("processing %s files" % len(files))
    for f in files:
        file_count += 1
        if file_count % 1000 == 0:
            logging.info(f"Files processed: {file_count}")
        js = json.loads(open(f, "r").read())
        d = flatten_json(js)
        parts = f.split("/")
        d["directory"] = parts[-2]
        d["filename"] = parts[-1]
        rows.append(d)
    df = pd.DataFrame.from_records(rows)
    logging.info(df.shape)
    df.to_sql('photo_file_google_json_files', con=engine, method="multi", if_exists="fail", index=False)


def get_files():
    request_count = 0
    thumbnail_dir = f"{USER_DIR}/google_photos/thumbnails"
    if not os.path.exists(thumbnail_dir):
        os.makedirs(thumbnail_dir)
    start_date = date(2000, 1, 1)
    end_date = date(2022, 9, 14)
    dates_batch_size = 1
    delta = timedelta(days=dates_batch_size)
    dates = []
    while start_date <= end_date:
        nextpagetoken = 'START'
        dates.append({"day": int(start_date.strftime("%d")), 
                      "month": int(start_date.strftime("%m")),
                      "year": int(start_date.strftime("%Y"))})
        if len(dates) < dates_batch_size:
            continue
        print("start date: %s - requests: %s" % (dates[0], request_count))
        item_count = 0
        while nextpagetoken != '':
            request_count += 1
            nextpagetoken = '' if nextpagetoken == 'START' else nextpagetoken
            results = PHOTOS_API.mediaItems().search(
                        body={"filters": 
                               {"dateFilter": 
                                 {"dates": [dates]}
                               },
                              "pageSize": 100,
                              "pageToken": nextpagetoken}).execute()
            items = results.get('mediaItems', [])
            nextpagetoken = results.get('nextPageToken', '')
            fw = open("google-photos-tommyunger-new.jsonline", "a")
            for item in items:
                img_url = "%(baseUrl)s=w200-h200" % item
                r = requests.get(img_url, stream=True)
                if r.status_code == 200:
                    with open(f"{thumbnail_dir}/{item['id']}.jpg", 'wb') as f:
                        r.raw.decode_content = True
                        shutil.copyfileobj(r.raw, f)
                fw.write(json.dumps(item))
                fw.write("\n")
                item_count += 1
            fw.close()
        start_date += delta
        dates = []
        print("found %s items" % item_count)


def add_ids_to_album(album_id, ids_to_add):
    global PHOTOS_API
    # PHOTOS_API.albums().create(body={"album": {"id":"to-be-deleted", "title": "To Be Deleted"}}).execute()
    # next_page_token = None
    # while next_page_token != "":
    #     results = PHOTOS_API.albums().list(pageSize=50, pageToken=next_page_token).execute()
    #     items = results.get('albums', [])
    #     for item in items:
    #         print(item)
    #     next_page_token = results.get('nextPageToken', '')
    r = PHOTOS_API.albums().batchAddMediaItems(
                    albumId = album_id,
                    body = {"mediaItemIds":ids_to_add}
                    ).execute()


# 
# POST https://photoslibrary.googleapis.com/v1/albums/{albumId}:batchAddMediaItems
def process_files():
    df = pd.read_json("data/google-photos.jsonline", lines=True)
    print(df.shape)


if __name__ == '__main__':
    get_takeout_file_metadata()
    # init_api()
    # ids_to_add = ["AOHKolZrvXYN5q6JdlKiPv3vpVkxU2vXNF2odR2f1nUSCKMKyC67_VtdFy-4veSpFaNEWpCr9BWjVDZZoA1aeOoyUbVcKPDx5Q",
    #               "AOHKolaNwoUXcgEU6t-s9qG3r6UNaL0XHKYz9Lici6mfB7MnPSDJtzvG6AQuBE9sM729ap5-kKiEbulNZO2AqeXPp0MSpJltcg"]
    # add_ids_to_album("AOHKolasw6SEYGWb5_X-QswRJgh3UNNq4QktZPFG2SZF_lhTEtUoUw02Ja2tkZIVxoDXHcLoco7G", ids_to_add)
    # get_files()
    # process_files()
