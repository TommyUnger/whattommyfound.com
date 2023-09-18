import os
import json
from utils import Utils

def test_run():
    out, err = Utils.run("ls -l")
    assert "drwx" in out
    assert err == ""

def test_download_file():
    file_path = Utils.download_file("https://api.ipify.org?format=json", to_file_name="ip.json")
    assert file_path == "downloads/ip.json"
    assert os.path.exists(file_path)
    js = json.loads(open(file_path, "r").read())
    assert js.get("ip") is not None
