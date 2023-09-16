import glob
import re
import time
import exiftool
from io import BytesIO
import pandas as pd
import numpy as np
from PIL import Image, ImageOps
import base64
import whatimage
import pyheif
import rawpy
import subprocess
import os
import sys
import math
import logging
import argparse


def setup_logging():
    global SAMPLE_NUMBER, SAMPLE_DENOM
    logging.basicConfig(
        format='%(asctime)s %(levelname)-8s %(message)s',
        level=logging.INFO,
        datefmt='%Y-%m-%d %H:%M:%S',
        handlers=[
            logging.FileHandler(f"data/work_log_local_photos_{SAMPLE_NUMBER}.log", mode='w'),
            logging.StreamHandler()
            ]
        )


def get_thumb_ints(im, sq_size):
    global SAMPLE_NUMBER, SAMPLE_DENOM
    w, h = im.size
    if w > h:
        new_h = sq_size
        new_w = w * sq_size / h
    else:
        new_w = sq_size
        new_h = h * sq_size / w
    im.thumbnail((new_w, new_h))
    left = (new_w - sq_size)/2
    top = (new_h - sq_size)/2
    right = (new_w + sq_size)/2
    bottom = (new_h + sq_size)/2
    im = im.crop((left, top, right, bottom))
    img_bw = ImageOps.grayscale(im)
    arr = np.ndarray.flatten(np.asarray(img_bw))
    nums = [int(d * 32 / 255) for d in arr]

    im = im.convert('HSV')
    try:
        hues = [int(math.floor(pixel[0] * 32 / 255)) for pixel in im.getdata()]
    except:
        hues = [0]*sq_size*sq_size

    try:
        sats = [int(math.floor(pixel[1] * 32 / 255)) for pixel in im.getdata()]
    except:
        sats = [0]*sq_size*sq_size

    stats = {
        "h": hues,
        "s": sats,
        "b": [int(d) for d in nums]
    }
    return stats


def get_image(f):
    global SAMPLE_NUMBER, SAMPLE_DENOM
    img_orig = None
    try:
        byts = open(f, "rb").read()
        fmt = whatimage.identify_image(byts)
        if fmt in ['heic', 'avif']:
            im = pyheif.read_heif(byts)
            img_orig = Image.frombytes(im.mode, im.size, im.data, "raw", im.mode, im.stride)
        elif f.lower()[-3:] == 'mov' or f[-3:].lower() == 'mp4' or f[-3:].lower() == 'avi':
            cmd = ['ffmpeg', '-hide_banner', '-loglevel', 'error', '-i', f, '-ss', '00:00:00.000', '-vframes', '1', f"work_vid_out_{SAMPLE_NUMBER}.jpg"]
            subprocess.call(cmd)
            img_orig = Image.open(f"work_vid_out_{SAMPLE_NUMBER}.jpg")
            os.remove(f"work_vid_out_{SAMPLE_NUMBER}.jpg")
        elif f[-3:].lower() == 'arw':
            with rawpy.imread(f) as raw:
                img_orig = Image.fromarray(raw.postprocess())
        else:
            img_orig = Image.open(f)
    except Exception as e:
        exc_type, exc_obj, exc_tb = sys.exc_info()
        fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
        logging.error("exception in get_image")
        print(e)
        print(exc_type, fname, exc_tb.tb_lineno)            

    return img_orig


def get_thumb_data(img_orig):
    thumb_color = None
    thumb_ints = {}
    if img_orig.mode == 'RGBA':
        img_orig = img_orig.convert('RGB')
    img_orig.thumbnail((300, 300))
    img_orig = ImageOps.exif_transpose(img_orig)
    img_orig.save(f"data/work_thumb1_{SAMPLE_NUMBER}.jpg")
    buffered = BytesIO()
    img_orig.save(buffered, format="JPEG")
    thumb_color = base64.b64encode(buffered.getvalue()).decode('utf-8')
    img_orig.thumbnail((40, 40))
    for XbyX in [2, 3, 4]:
        stats = get_thumb_ints(img_orig.copy(), XbyX)
        thumb_ints["thumb_hue_%s" % (XbyX*XbyX)] = stats["h"]
        thumb_ints["thumb_sat_%s" % (XbyX*XbyX)] = stats["s"]
        thumb_ints["thumb_light_%s" % (XbyX*XbyX)] = stats["b"]
    return (thumb_color, thumb_ints)


SAMPLE_NUMBER = 0
SAMPLE_DENOM = 0

def main():
    global SAMPLE_NUMBER, SAMPLE_DENOM
    parser = argparse.ArgumentParser()
    parser.add_argument('--sample', default='0/1')
    parser.add_argument('--path')
    parser.add_argument('--start', default=0)
    parser.add_argument('--mod', action='store_true')
    args = parser.parse_args()
    (SAMPLE_NUMBER, SAMPLE_DENOM) = [int(d) for d in args.sample.split('/')]
    setup_logging()
    et = exiftool.ExifToolHelper()
    df = None
    all_files = sorted(list(glob.glob(args.path)))
    logging.info("processing: %s files" % len(all_files))
    for i, f in enumerate(all_files):
        # handle recent modifications of files
        if args.mod:
            if int(time.time() - os.path.getmtime(f)) > 8000:
                continue
        if (i % SAMPLE_DENOM) != SAMPLE_NUMBER or i < int(args.start):
            continue
        logging.info(f"{i:6} - {f}")

        logging.debug("get metadata with exiftool")
        try:
            md = et.get_metadata(f)
            for k in md[0]:
                md[0][k] = re.sub(r'[\x00-\x20]+',' ', str(md[0][k]))
        except Exception as e:
            print(e)
            exc_type, exc_obj, exc_tb = sys.exc_info()
            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
            print(exc_type, fname, exc_tb.tb_lineno)            
            logging.error("unable to get metadata for: %s" % f)

        try:
            img_orig = get_image(f)
            (thumb_color, thumb_ints) = get_thumb_data(img_orig)
            for k, v in thumb_ints.items():
                md[0][k] = v
            df_img = pd.DataFrame.from_records(md)
            df_img["thumb_color"] = thumb_color
            if df is None:
                df = df_img.copy()
            else:
                df = pd.concat([df, df_img], ignore_index=True, sort=False)
        except Exception as e:
            print(e)
            exc_type, exc_obj, exc_tb = sys.exc_info()
            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
            print(exc_type, fname, exc_tb.tb_lineno)            
            logging.error("unable to get metadata for: %s" % f)
            
    if df is not None:
        csv_name = "data/image-metadata-%s-%s-%s.csv" % (
            re.sub(r'[^a-z0-9]+', '_', args.path.lower()),
            SAMPLE_NUMBER,
            time.strftime("%Y%m%d%H%M%S")
            )
        df.to_csv(csv_name)
    else:
        logging.error("No dataframe found to save")

if __name__ == '__main__':
    main()
