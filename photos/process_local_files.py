import os
import time
import base64
import pyheif
import whatimage
from datetime import datetime
import multiprocessing
from PIL import Image

OUTPUT_PATH = 'output_file.txt'
THUMBNAIL_DIR = 'thumbnails'
THUMBNAIL_SIZE = (100, 100)

def generate_thumbnail(image_path):
    base_name, ext = os.path.splitext(image_path)
    thumbnail_path = os.path.join(THUMBNAIL_DIR, f'{base_name}_thumbnail{ext}')

    try:
        image = Image.open(image_path)
        image.thumbnail(THUMBNAIL_SIZE)
        os.makedirs(os.path.dirname(thumbnail_path), exist_ok=True)
        image.save(thumbnail_path)

        with open(thumbnail_path, 'rb') as img_f:
            thumbnail_b64 = base64.b64encode(img_f.read()).decode('utf-8')

        return thumbnail_path, thumbnail_b64
    except Exception as e:
        print(f'Error generating thumbnail for {image_path}. Error: {str(e)}')
        return None, None

def process_image(args):
    try:
        image_path, counter = args
        byts = open(image_path, "rb").read()
        fmt = whatimage.identify_image(byts)
        print(fmt)
        thumbnail_path, thumbnail_b64 = generate_thumbnail(image_path)
        if thumbnail_path:
            file_size = os.path.getsize(image_path)
            create_time = datetime.fromtimestamp(os.path.getctime(image_path)).isoformat()
            with open(OUTPUT_PATH, 'a') as f:
                f.write(f'{image_path},{thumbnail_b64},{file_size},{create_time}\n')
        with counter.get_lock():
            counter.value += 1
    except Exception as e:
        print(f'Error processing image. Error: {str(e)}')


def process_directory(directory_path, counter):
    pool = multiprocessing.Pool()
    print(f"walk_directory: {directory_path}")
    for dirpath, _, filenames in os.walk(directory_path):
        for filename in filenames:
            if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.arw', '.heic', '.tif', '.tiff')):
                image_path = os.path.join(dirpath, filename)
                print(f'Processing image: {image_path}')
                pool.apply_async(process_image, args=((image_path, counter),))
    pool.close()
    pool.join()

def print_status(counter):
    while True:
        time.sleep(10)
        with counter.get_lock():
            print(f'Number of images processed: {counter.value}')

if __name__ == "__main__":
    with multiprocessing.Manager() as manager:
        counter = manager.Value('i', 0)
        START_DIR = "/Volumes/One Touch/photos/Lopez Island 2023"
        dir_processor = multiprocessing.Process(target=process_directory, args=(START_DIR, counter))
        status_printer = multiprocessing.Process(target=print_status, args=(counter,))

        dir_processor.start()
        status_printer.start()

        dir_processor.join()
        status_printer.terminate()
