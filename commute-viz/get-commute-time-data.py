import os
import csv
import math
import time
import datetime
import requests
import json
import urllib
import polyline


API_KEY = os.environ["GOOGLE_MAPS_API_KEY"]
BASE_DIRECTIONS_URL = "https://maps.googleapis.com/maps/api/directions/json"
DAY_SECONDS = 60 * 60 * 24

"""
valid modes: "walking", "bicycling", "transit", "driving"
start_time: needs to be an epoch int
"""
def get_directions(loc_from, loc_to, mode, start_time):
    base_url = "%(base_url)s?key=%(api_key)s&origin=%(loc_from)s" \
               "&destination=%(loc_to)s&mode=%(mode)s&departure_time=%(start_time)s"
    directions_params = {
        "api_key": API_KEY
        , "base_url": BASE_DIRECTIONS_URL
        , "mode": mode
        , "loc_from": urllib.quote_plus(loc_from) # locations need to be url encoded
        , "loc_to": urllib.quote_plus(loc_to) # locations need to be url encoded
        , "start_time": start_time
    }
    url = base_url % directions_params
    directions = json.loads(requests.get(url).text)
    # Not a fant of deeply nested loops and conditionals, by google's structure necessitates
    for route in directions["routes"]:
        op = route["overview_polyline"]
        op["points"]  = polyline.decode(op["points"])
        for leg in route["legs"]:
            for step in leg["steps"]:
                if "polyline" in step:
                    sp = step["polyline"]
                    sp["points"] = polyline.decode(sp["points"])
                if "steps" in step:
                    for sub_step in step["steps"]:
                        if "polyline" in sub_step:
                            ssp = sub_step["polyline"]
                            ssp["points"] = polyline.decode(ssp["points"])
    return directions


def main():
    start_time = int(math.floor(time.time() / DAY_SECONDS) * DAY_SECONDS + DAY_SECONDS - 60 * 60 * 2)

    directions_list = []

    # got this list of for-sale homes with addresses from Redfin.
    with open('redfin_2018-10-03-22-22-44.csv') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        line_count = 0
        for row in csv_reader:
            try:
                to_addr = "%(ADDRESS)s, %(ZIP)s" % row
                print(to_addr)
                dirs = get_directions("Qumulo, Inc", to_addr, "transit", start_time)
                directions_list.append(dirs)
                line_count += 1
            except:
                pass

    fw = open("locations.json", "w")
    fw.write(json.dumps(directions_list, sort_keys=True, indent=4))
    fw.close()


if __name__== "__main__":
    main()