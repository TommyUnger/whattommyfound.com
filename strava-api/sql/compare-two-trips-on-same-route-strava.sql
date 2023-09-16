# Compare two trips using the activity ids from strava and giving them short names.
CREATE TEMP TABLE __temp_trips(activity_id BIGINT, trip_name VARCHAR(128));
INSERT INTO __temp_trips VALUES(2410658246, 'Lime');
INSERT INTO __temp_trips VALUES(2408066822, 'Jump');


# created smoothed trip details by skipping 3 points at a time
# this is the basis for must of the subsequent analysis
DROP TABLE IF EXISTS __temp_trip_details;
CREATE TEMP TABLE __temp_trip_details
AS
SELECT *
, percent_rank()over(partition by activity_id ORDER BY speed_meters_per_sec) speed_percentile
FROM
(
SELECT trip_name
, p2.activity_id
, p2.lon
, p2.lat
, p2.time time_seconds
, start_time + INTERVAL '1 SECOND' * p2.time time_time
, (p2.time - p1.time) diff_time
, p2.altitude
, p2.heartrate
, p2.temp
, p2.distance total_distance
, p2.distance - p1.distance diff_distance
, (p2.distance - p1.distance) / (p2.time - p1.time) speed_meters_per_sec
, 2.23694 * (p2.distance - p1.distance) / (p2.time - p1.time) speed_mph
, p2.velocity_smooth
FROM strava_activity_detail p1
JOIN strava_activity_detail p2 
ON p1.activity_id = p2.activity_id
AND p1.point_num = p2.point_num - 3
JOIN __temp_trips ride ON ride.activity_id = p1.activity_id
JOIN strava_activity sa ON sa.id = p1.activity_id
) t
;

# building a table for side-by-side comparison of two trips keying on lat/lon
DROP TABLE IF EXISTS __temp_trip_lat_lons;
CREATE TEMP TABLE __temp_trip_lat_lons
AS
SELECT trip_name
, floor(lon * 1500) / 1500.0 lon
, floor(lat * 1500) / 1500.0 lat
, percentile_disc(0.5) within group (order by speed_mph) speed
, percentile_disc(0.5) within group (order by heartrate) heartrate
, max(time_time) ts
, max(total_distance) dist
, count(1) sample_count
FROM __temp_trip_details d
WHERE speed_mph >= 6
GROUP BY 1, 2, 3
;

# trip details for building two maps and other non-side-by-side approaches
SELECT *
FROM __temp_trip_details
;

# side-by-side comparison of two trips keying on lat/lon
SELECT row_number()over(order by j.ts) order_num
, j.dist
, j.lon
, j.lat
, j.speed "Jump Speed"
, l.speed "Lime Speed"
, j.heartrate "Jump heart rate"
, l.heartrate "Lime heart rate"
, j.speed - l.speed "Jump vs Lime"
FROM __temp_trip_lat_lons j
JOIN __temp_trip_lat_lons l on l.lon = j.lon AND l.lat = j.lat AND l.trip_name = 'Lime'
WHERE j.trip_name = 'Jump'
ORDER BY 1;

# summary stats
SELECT trip_name
, min(time_time) "start time"
, round(10 * sum(speed_mph * diff_distance)::NUMERIC / sum(diff_distance)) / 10.0 "average speed"
, round(max(speed_mph)) "max speed"
, round(avg(heartrate)) "average heart rate"
FROM __temp_trip_details
WHERE speed_mph >= 7
GROUP BY 1
;