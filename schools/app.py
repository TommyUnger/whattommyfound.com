from flask import Flask, jsonify, render_template
import psycopg2

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/census_tracts")
def get_census_tracts():
    sql = open("sql/maui_tracts.sql", "r").read()
    conn = psycopg2.connect("postgresql://tommyunger@localhost/work")
    cur = conn.cursor()
    cur.execute(sql)
    result = cur.fetchall()
    return jsonify(result[0][0])

@app.route("/fl_bend")
def fl_bend():
    return render_template("fl_bend.html")

@app.route("/data/fl_bend")
def get_data_fl_bend():
    sql = open("sql/fl_bend_blocks.sql", "r").read()
    conn = psycopg2.connect("postgresql://tommyunger@localhost/work")
    cur = conn.cursor()
    cur.execute(sql)
    result = cur.fetchall()
    return jsonify(result[0][0])

if __name__ == "__main__":
    app.run(debug=True)
