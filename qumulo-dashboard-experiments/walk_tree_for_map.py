import multiprocessing
import os
import sys
import time
from qumulo.rest_client import RestClient


class Gvars:
    def __init__(self, h, u, p):
        self.QHOST = h
        self.QUSER = u
        self.QPASS = p
        self.the_queue = multiprocessing.Queue()
        self.the_queue_len = multiprocessing.Value('i', 0)
        self.done_queue = multiprocessing.Queue()
        self.done_queue_len = multiprocessing.Value('i', 0)
        self.item_count = multiprocessing.Value('i', 0)


def add_to_queue(d):
    global gvars
    with gvars.the_queue_len.get_lock():
        gvars.the_queue_len.value += 1
    gvars.the_queue.put(d)


def list_dir(rc, d):
    global gvars
    ent = rc.fs.read_dir_aggregates(path=d["path"], max_depth=0, max_entries=5000)
    if int(ent["total_capacity"]) < d["min_sz"]:
        return
    depth = len(d["path"].split('/'))
    if depth > d["max_depth"]+1:
        return
    with gvars.done_queue_len.get_lock():
        gvars.done_queue.put({"path": d["path"], "capacity": int(ent["total_capacity"]), "depth": depth})
        gvars.done_queue_len.value += 1
    ddd = rc.fs.get_attr(path=d["path"])
    if int(ddd["child_count"]) > 50000:
        return
    if len(ent['files']) > 4900 and int(ent["total_directories"]) > 1:
        next_page = "first"
        while next_page != "":
            if next_page == "first":
                r = rc.fs.read_directory(path=d["path"], page_size=1000)
            else:
                r = rc.request("GET", r['paging']['next'])
            next_page = r['paging']['next']
            for ent in r["files"]:
                with gvars.item_count.get_lock():
                    gvars.item_count.value += 1
                if ent["type"] == "FS_FILE_TYPE_DIRECTORY" and int(ent["child_count"]) > 0:
                    add_to_queue({"path": d["path"] + ent["name"] + "/", "min_sz": d["min_sz"], "max_depth": d["max_depth"]})
    else:
        for f in ent['files']:
            with gvars.item_count.get_lock():
                gvars.item_count.value += 1
            if f["type"] == "FS_FILE_TYPE_DIRECTORY" and int(f["capacity_usage"]) > d["min_sz"] and int(f["num_directories"]) > 0:
                add_to_queue({"path": d["path"] + f["name"] + "/", "min_sz": d["min_sz"], "max_depth": d["max_depth"]})


def worker_main():
    global gvars
    rc = RestClient(gvars.QHOST, 8000)
    rc.login(gvars.QUSER, gvars.QPASS)
    while True:
        item = gvars.the_queue.get(True)
        list_dir(rc, item)
        with gvars.the_queue_len.get_lock():
            gvars.the_queue_len.value -= 1


def process_results_for_treemap():
    global gvars
    all_paths = {}
    for i in range(0, gvars.done_queue_len.value):
        dd = gvars.done_queue.get(True)
        the_path = ('[root]' + dd["path"])[:-1]
        parts = the_path.split("/")
        for i in range(1, len(parts)+1):
            p = '/'.join(parts[0:i])
            if p not in all_paths:
                all_paths[p] = 0
            if the_path == p:
                all_paths[p] += dd["capacity"]
            elif len(parts) - i < 2:
                all_paths[p] -= dd["capacity"]

    txt = "id,value\n"
    for k, v in sorted(all_paths.items()):
        txt += "%s,%s\n" % (k, v)
    return txt


def walk_tree(QHOST, QUSER, QPASS, start_path, min_size):
    global gvars
    gvars = Gvars(QHOST, QUSER, QPASS)
    the_pool = multiprocessing.Pool(16, worker_main)
    rc = RestClient(gvars.QHOST, 8000)
    rc.login(gvars.QUSER, gvars.QPASS)
    root = rc.fs.read_dir_aggregates(path=start_path, max_depth=0)
    min_sz = int(root["total_capacity"]) / int(min_size)
    add_to_queue({"path": start_path, "min_sz": min_sz, "max_depth": 5})
    time.sleep(0.1)
    wait_count = 0
    while gvars.the_queue_len.value > 0:
        wait_count += 1
        # every 5 seconds report status
        # if (wait_count % 50) == 0:
        #    print("Queue: %s  -  Items looked at: %s" % (gvars.the_queue_len.value, gvars.item_count.value))
        time.sleep(0.1)
    # print("Queue: %s  -  Items looked at: %s" % (gvars.the_queue_len.value, gvars.item_count.value))
    r = process_results_for_treemap()
    the_pool.terminate()
    del gvars
    return r


if __name__ == '__main__':
    r = walk_tree(sys.argv[1], "admin", sys.argv[2], "/", sys.argv[3])
    print(r)
