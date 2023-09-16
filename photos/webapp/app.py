import os
import sys
from flask import Flask, render_template, request
from sqlalchemy.sql import text as sql_text
from sqlalchemy import create_engine
engine = create_engine('postgresql://%(PGUSER)s:%(PGPASSWORD)s@localhost:5432/work' % os.environ)

class TableCell():
	__slots__ = ['name', 'value']
	name: str
	value: str

	def __init__(self, _name, _value):
		self.name = _name
		self.value = _value

app = Flask(__name__,
            static_url_path='/static')


@app.route('/', methods=['GET', 'POST'])
def index():
	sql = ''
	rows = []
	headers = []
	grid = False
	if request.method == 'POST':
		sql = request.form.get('sql', '')
		selected_photos_str = request.form.get('selected_photos', '')
		if selected_photos_str != '':
			app.logger.info("selected_photos: %s" % selected_photos_str)
			selected_photos = selected_photos_str.split(",")
			tags = request.form.get('tags', '')
			date = request.form.get('date', '')
			if tags != '':
				tags = tags.split(",")
				app.logger.info("tags: %s" % tags)
				inserts = []
				for tag in tags:
					tag = tag.strip()
					for photo_id in selected_photos:
						inserts.append(f"insert into photos.photo_file_tag(photo_id,tag)values({photo_id}, '{tag}');")
				with engine.connect() as cn:
					cn.execute("\n".join(inserts))

			if date != '':
				upd_sql = f"update photo_file set create_date='{date}', update_date=now() where photo_id in ({selected_photos_str})"
				app.logger.info(f"sql: {upd_sql}")
				with engine.connect() as cn:
					cn.execute(upd_sql)

		if '--grid--' in sql:
			grid = True
		with engine.connect() as cn:
			rs = cn.execute(sql)
			if grid:
				for row in rs:
					table_row = {}
					for col, val in row._mapping.items():
						table_row[col] = val
					rows.append(table_row)
			else:
				for col in rs.keys():
					headers.append(col)
				for row in rs:
					table_row = []
					for col, val in row._mapping.items():
						table_row.append(TableCell(col, val))
					rows.append(table_row)
	return render_template('index.html', sql=sql, headers=headers, rows=rows, grid=grid)

@app.route('/<photo_id>', methods=['DELETE'])
def delete(photo_id):
	with engine.connect() as cn:
		sql = f"update photo_file set dup_status='deleted', update_date=now() where photo_id={photo_id}"
		print(sql)
		cn.execute(sql)
		return '', 200

if __name__ == '__main__':
	app.run(debug=True)
