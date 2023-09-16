import re
import os
import sys
import time
import json
import math
import flask
import datetime
import subprocess
from flask import Flask
from flask import render_template

from qumulo.rest_client import RestClient

app = flask.Flask(__name__)
app.config.update(dict(
    DEBUG=True,
    API_HOSTNAME='product.eng.qumulo.com',
    API_USER='admin',
    API_PASSWORD='',
))


def get_paths(rc, lookup_list, inodes):
    res = rc.fs.resolve_paths(ids = lookup_list)
    for d in res:
        inodes[d['id']] = d['path']


def get_rc():
    rc = RestClient(app.config['API_HOSTNAME'], 8000)
    rc.login(app.config['API_USER'], app.config['API_PASSWORD'])
    return rc    


@app.route('/api-perf-counters')
def api_perf_counters():
    rc = get_rc()
    pc_data = {}
    for n in rc.network.list_network_status_v2(1):
        rc = RestClient(n['network_statuses'][0]['address'], 8000)
        rc.login('admin', app.config['API_PASSWORD'])
        resp = rc.request("GET", "/v1/metrics/")
        pc_data[n['node_id']] = resp
    return json.dumps(pc_data)


@app.route('/api-capacity')
def api_capacity():
    rc = get_rc()
    return json.dumps(rc.fs.read_fs_stats())


@app.route('/api-activity')
def api_activity():
    rc = get_rc()
    act = rc.analytics.current_activity_get()

    inodes = {}
    for e in act["entries"]:
        inodes[e["id"]] = None

    lookup_list = []
    for inode in inodes:
        lookup_list.append(inode)
        if len(lookup_list) > 400:
            get_paths(rc, lookup_list, inodes)
            lookup_list = []
    get_paths(rc, lookup_list, inodes)
    activity = []
    for e in act["entries"]:
        path = "/"
        if e["id"] in inodes:
            path = inodes[e["id"]]
        activity.append({"path": path, "id": e["id"], "ip": e["ip"], "rate": e["rate"], "type": e["type"]})
    return json.dumps(activity)


@app.route('/api-capacity-tree-change')
def api_capacity_tree_change():
    rc = get_rc()
    t = time.time()
    d = []
    d.append(rc.fs.read_dir_aggregates(path="/", max_depth=1))
    d.append(rc.analytics.capacity_history_files_get(int(math.floor(t / 3600-24 * 7)*3600)))
    return json.dumps(d)


@app.route('/api-capacity-tree')
def api_capacity_tree():
    result = subprocess.check_output("python walk_tree_for_map.py %s %s %s" % (
            app.config['API_HOSTNAME'],
            app.config['API_PASSWORD'],
            300)
        , shell=True)
    return os.linesep.join([s for s in result.splitlines() if s])


@app.route('/api-capacity-history')
def api_capacity_history():
    rc = get_rc()
    return json.dumps(
        rc.analytics.capacity_history_get(
                begin_time=int((time.time()- 30*60*60*24) / 3600) * 3600, 
                interval="hourly")
        )


@app.route('/api-network-connections')
def api_network_connections():
    rc = get_rc()
    return json.dumps(rc.network.connections())


@app.route('/api-list-network-status')
def api_list_network_status():
    rc = get_rc()
    return json.dumps(rc.network.list_network_status_v2(1))


@app.route('/')
def home(name=None):
    return render_template('home.html', name=name)


if __name__ == '__main__':
    port = 80
    if len(sys.argv) > 1:
       port = int(sys.argv[1])
    app.run(host='0.0.0.0', port=port, threaded=True)

