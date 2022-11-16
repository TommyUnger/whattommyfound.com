import json
import psycopg2
import psycopg2.extras
import os

conn = psycopg2.connect(os.environ("PGDB"))

cur = conn.cursor(cursor_factory = psycopg2.extras.RealDictCursor)
sql = """
with points as(
select activity_id, json_agg(array[lat, lon]) as ll
from strava.activity_detail
group by 1
)

, d as(
select id, distance, moving_time, elapsed_time, total_elevation_gain
, type, sport_type, start_date_local, achievement_count, average_speed
, max_speed, average_temp, average_heartrate, elev_high, elev_low
, trim(a.name) as letter, ll
from strava.activity a
join points p on a.id = p.activity_id
where length(a.name) <= 2
)

select *
from d
order by "letter"
"""
cur.execute(sql)
row = cur.fetchone()
letters = {}
fw = open("letters.json", "w")
fw.write("{")
while row is not None:
    fw.write("%s:%s" % (json.dumps(row["letter"]), json.dumps(row)))
    row = cur.fetchone()
    if row is not None:
        fw.write(",\n")
fw.write("}")
fw.close()
