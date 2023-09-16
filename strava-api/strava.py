import subprocess
import sys
import json
import requests
import psycopg2
from flask import Flask, request

CONFIG_FILE = "app_config.json"
TOKEN_FILE = "strava_api_token.json"

app = Flask(__name__)

def get_conf():
    client_creds = json.loads(open(CONFIG_FILE, "r").read())
    return client_creds

def get_auth_headers():
    creds = json.loads(open(TOKEN_FILE, "r").read())
    headers = {'Authorization': 'Bearer %s' % creds['access_token']}
    return headers

@app.route("/")
def home():
    conf = get_conf()
    url = "https://www.strava.com/oauth/mobile/authorize" \
          + "?client_id=%s" % conf['strava_client_id'] \
          + "&redirect_uri=http://localhost:%s/auth" % conf["flask_port"] \
          + "&response_type=code" \
          + "&approval_prompt=auto" \
          + "&scope=activity:write,activity:read"
    return "<a href='%s'>Create new auth token</a><br /><a href='/refresh'>Refresh token</a>" % (url, )

@app.route("/auth")
def auth_callback():
    conf = get_conf()
    code = request.args.get('code')
    r = requests.post("https://www.strava.com/oauth/token", data = {
                'client_id': conf['strava_client_id'],
                'client_secret': conf['strava_client_secret'],
                'code': code,
                'grant_type': 'authorization_code'})
    fw = open(TOKEN_FILE, "w")
    fw.write(r.text)
    fw.close()
    return r.text

@app.route("/refresh")
def refresh_token():
    current_token = json.loads(open(TOKEN_FILE, "r").read())
    conf = get_conf()
    r = requests.post("https://www.strava.com/oauth/token", data = {
                'client_id': conf['strava_client_id'],
                'client_secret': conf['strava_client_secret'],
                'refresh_token': current_token['refresh_token'],
                'grant_type': 'refresh_token'})
    fw = open(TOKEN_FILE, "w")
    fw.write(r.text)
    fw.close()
    return "Refreshed!<br /><a href='/'>Go back home</a>"

if __name__ == '__main__':
    conf = get_conf()
    print('Go to http://localhost:%s/' % conf["flask_port"])
    app.run(port=conf["flask_port"])
