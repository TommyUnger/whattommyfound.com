from flask import Flask, jsonify, render_template
import psycopg2

app = Flask(__name__)
app.config['DB_URI'] = 'postgresql://localhost/work'

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/data/', methods=['GET'])
def get_shapes():
    query = """

WITH bounding_box AS (
    SELECT ST_Extent(ST_Transform(geom, 2926)) AS geom
    FROM seattle_police_data
)

, geos0 AS (
    SELECT 
        (ST_HexagonGrid(3500, ST_Envelope(b.geom))).*
    FROM 
        bounding_box AS b
)

, geos as(
SELECT ST_Transform(st_setsrid(geom, 2926), 4326) AS geom, i, j
FROM geos0
)


    
        SELECT row_to_json(fc)
        FROM (
            SELECT 'FeatureCollection' AS type, array_to_json(array_agg(f)) AS features
            FROM (
                SELECT 'Feature' AS type, 
                       ST_AsGeoJSON(geom)::json AS geometry,
                       row_to_json(
                            (SELECT l FROM (SELECT i, j, st_astext(st_centroid(geom)) as name) AS l)
                        ) AS properties
                FROM geos
            ) AS f
        ) AS fc;

    """
    connection = psycopg2.connect(app.config['DB_URI'])
    cursor = connection.cursor()
    cursor.execute(query)
    data = cursor.fetchone()[0]    
    cursor.close()
    connection.close()
    return jsonify(data)


if __name__ == "__main__":
    app.run(debug=True)
