WITH geojson as (
    SELECT
        json_build_object(
            'type', 'Feature',
            'id', row_number() over(),
            'geometry', ST_AsGeoJSON(geom)::json,
            'properties', json_build_object(
                'name', name,
                '   ', population,
                'density', 1000000 * population / area_land,
                'area_land', area_land,
                'area_water', area_water,
                'geo_id', geo_id
            )
        ) as feature
    FROM
        census.geo
   where geom && st_expand(st_geomfromewkt('POINT(-156.3319 20.7984)'), 0.4)
   and area_land > 0
   and geom_type = 'tract'
   and geo_id not in (15009031700, 15009980000)
)
SELECT 
    json_build_object(
        'type', 'FeatureCollection',
        'features', json_agg(feature)
    ) as geojson
FROM 
    geojson;