import re
import os
import csv
import threading
import time
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor
from PIL import Image
from pillow_heif import register_heif_opener
register_heif_opener()
import imagehash

# shared variable among threads
file_counter = 0
processed_files = {}
most_recent_file = None

def read_tsv_into_dict():
    print("read_tsv_into_dict")
    global processed_files
    try:
        with open('output.tsv', 'r', newline='') as f:
            reader = csv.DictReader(f, delimiter='\t')
            for row in reader:
                file_path = os.path.join(row['Directory_Path'], row['File_Name'])
                processed_files[file_path] = row
    except FileNotFoundError:
        pass  # File doesn't exist yet, that's fine
    print(f"Done read_tsv_into_dict - entries: {len(processed_files)}")

def write_to_csv(file_info):
    global most_recent_file
    with open('output.tsv', 'a', newline='') as f:
        most_recent_file = file_info
        writer = csv.writer(f, delimiter='\t')
        writer.writerow(file_info)


def get_hashes(img_path):
    try:
        im = Image.open(img_path)
        im.thumbnail((150, 150))
        p_hash = str(imagehash.phash(im))
        cr_hash = str(imagehash.crop_resistant_hash(im))
        color_hash = str(imagehash.colorhash(im))
        w_hash = str(imagehash.whash(im))
        d_hash = str(imagehash.dhash(im))
        a_hash = str(imagehash.average_hash(im))
    except Exception as e:
        print(e)
        p_hash = ''
        cr_hash = ''
        color_hash = ''
        w_hash = ''
        d_hash = ''
        a_hash = ''
    return p_hash, cr_hash, color_hash, w_hash, d_hash, a_hash

def walk_directory(path):
    global file_counter
    for dirpath, dirnames, filenames in os.walk(path):
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            file_counter += 1
            if filename[0] == ".":
                continue
            if file_path in processed_files and 'heic' not in filename.lower():
                continue
            file_size = os.path.getsize(file_path)
            file_extension = os.path.splitext(filename)[1].lower()
            p_hash = ''
            cr_hash = ''
            color_hash = ''
            w_hash = ''
            d_hash = ''
            a_hash = ''
            try:
                if file_size > 10000 and re.match(r'\.(jpg|jpeg|png|bmp|gif|heic)$', file_extension):
                    (p_hash, cr_hash, color_hash, w_hash, d_hash, a_hash) = get_hashes(file_path)
            except Exception as e:
                print(e)
            write_to_csv([dirpath, filename, file_size, file_extension, p_hash, cr_hash, color_hash, w_hash, d_hash, a_hash])
    print(f"+++ done process directory: {path}")


def print_status():
    global file_counter, most_recent_file
    time.sleep(3)
    while True:
        print(f"{datetime.now().isoformat()} - {file_counter} files processed. {most_recent_file}")
        time.sleep(10)


def main(path):
    read_tsv_into_dict()
    # Initial CSV file with headers
    if not os.path.exists('output.tsv'):
        with open('output.tsv', 'w', newline='') as f:
            writer = csv.writer(f, delimiter='\t')
            writer.writerow(['Directory_Path', 'File_Name', 'File_Size', 'File_Extension', 'P_Hash', 'CR_Hash', 'Color_Hash', 'Wave_Hash', 'Diff_Hash', 'Avg_Hash'])

    # start the status printing thread
    threading.Thread(target=print_status, daemon=True).start()
    print("start working")
    with ThreadPoolExecutor(max_workers=1) as executor:
        for root, dirs, _ in os.walk(path):
            for dir in dirs:
                executor.submit(walk_directory, os.path.join(root, dir))

if __name__ == "__main__":
    # replace 'your_path' with the directory you want to walk
    # print(get_hashes('/Volumes/One Touch/photos/Granite Mountain Hike/P1010130.JPG'))
    # phash = imagehash.phash(Image.open('/Volumes/One Touch/photos/Photos from 2017/IMG_5062.HEIC'))
    # print(str(phash))
    main('/Volumes/One Touch')

"""
drop table photos;
create table photos(
    directory_path varchar(2550), 
    file_name varchar(2550),
    file_size bigint,
    file_extension varchar(255),
    p_hash varchar(2550),
    cr_hash varchar(2550),
    color_hash varchar(2550),
    wave_hash varchar(2550),
    diff_hash varchar(2550),
    avg_hash varchar(2550)
)
"""