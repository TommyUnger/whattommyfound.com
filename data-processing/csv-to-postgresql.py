import csv
import re
import sys
import argparse
import random
import dateutil.parser as date_parser
from collections import OrderedDict


class CsvToPostgres:
    delimiter = ','
    quotechar = '"'
    file_name = None
    table_name = None
    host_name = None
    database_name = None
    user_name = None
    header_row_num = 1
    sample_rate = 1
    table_cols = OrderedDict()

    def __init__(self, options):
        self.file_name = options.f
        self.table_name = options.t
        self.host_name = options.s
        self.sample_rate = float(options.sample_rate) / 100
        self.database_name = options.d
        self.user_name = options.user_name
        self.header_row_num = int(options.header_row)
        self.delimiter = options.delim.decode("string_escape")

    def create_sql(self):
        data_file = re.sub("[^A-Za-z0-9]+", "_", self.file_name) + ".txt"
        fw_txt = open(data_file, "w")
        with open(self.file_name, 'rb') as csvfile:
            if self.header_row_num > 1:
                print "Skipping headers"
                for skip_num in range(1, self.header_row_num):
                    next(csvfile, None)
            csvr = csv.DictReader(csvfile, delimiter=self.delimiter, quotechar=self.quotechar)
            for col in csvr.fieldnames:
                self.table_cols[col] = {"int_count":0, "string_count":0, "min_len":999999999, "max_len":0, "null_count":0, "not_null_count":0, "datetime_count":0, "float_count":0, "total_count":0}
            for row_num, row in enumerate(csvr):
                if row_num % 10000 == 0 and row_num > 0:
                    print row_num
                if random.random() > self.sample_rate:
                    continue
                row_data = []
                for col in csvr.fieldnames:
                    self.table_cols[col]["total_count"] += 1
                    if row[col] is None or row[col] == "":
                        self.table_cols[col]["null_count"] += 1
                        row_data.append("")
                    else:
                        self.table_cols[col]["not_null_count"] += 1
                        val = re.sub("[\r\n\t\\\\]+", " ", row[col].strip()).strip()
                        try:
                            if re.search("[/-]", val) is not None and len(val) <= 28 and re.search("[0-9]{2}", val) is not None:
                                date_parser.parse(val)
                                self.table_cols[col]["datetime_count"] += 1
                        except:
                            pass
                        if re.match(".*[^0-9].*", val):
                            self.table_cols[col]["string_count"] += 1
                        if re.match("^[$-]*[0-9,]+[.][0-9].*$", val):
                            self.table_cols[col]["float_count"] += 1
                        if re.match("^[$-]*[0-9,]*$", val):
                            self.table_cols[col]["int_count"] += 1
                        if len(val) > self.table_cols[col]["max_len"]:
                            self.table_cols[col]["max_len"] = len(val)
                        if len(val) < self.table_cols[col]["min_len"]:
                            self.table_cols[col]["min_len"] = len(val)
                        row_data.append(val)

                fw_txt.write("\t".join(row_data) + "\n")
        fw_txt.close()

        sql = "DROP TABLE IF EXISTS " + self.table_name + ";\n"
        sql += "CREATE TABLE " + self.table_name + "(\n"
        col_num = 1
        for col in self.table_cols:
            if col_num > 1:
                sql += ", "
            col_name = re.sub("[^a-z0-9]+", " ", col.lower()).strip().replace(" ", "_")
            col_name = re.sub("united_states", "us", col_name)
            sql += "\"%s\"" % (col_name, )
            col_data = self.table_cols[col]
            data_type = ""
            for dt in ["int", "float", "string", "datetime", "null"]:
                if col_data["not_null_count"] > 0:
                    col_data[dt + "_perc"] = (col_data[dt + "_count"] * 100.0 / col_data["not_null_count"])
                else:
                    col_data[dt + "_perc"] = 0
            if col_data["datetime_perc"] >= 100:
                data_type = "TIMESTAMP"
            elif col_data["float_perc"] >= 99:
                data_type = "FLOAT"
            elif col_data["int_perc"] >= 100 and col_data["max_len"] <= 16:
                data_type = "SMALLINT"
                if col_data["max_len"] >= 10:
                    data_type = "BIGINT"
                elif col_data["max_len"] >= 5:
                    data_type = "INT"
            elif col_data["string_perc"] >= 1:
                data_type = "VARCHAR(%s)" % (col_data["max_len"]*8, )
                if col_data["max_len"] == col_data["min_len"]:
                    data_type = "VARCHAR(%s)" % (col_data["min_len"]*4, )
                elif col_data["max_len"] >= 2000:
                    data_type = "TEXT"
            else:
                data_type = "VARCHAR(128)"
                print "Fall through on: %s - %s" % (col, self.table_cols[col])
            col_num += 1
            sql += " " + data_type + "\n"
        sql += ");\n"

        sql_file_name = "create_" + self.table_name + ".sql"
        fw = open(sql_file_name, "w")
        fw.write(sql)
        fw.close()
        print "File created: %s" % (sql_file_name, )
        print "psql -U %s -h %s -d %s -f %s" % (self.user_name, self.host_name, self.database_name, sql_file_name)
        print "cat %s | psql -U %s -h %s -d %s -c \"SET CLIENT_ENCODING='LATIN1'; COPY %s FROM STDIN NULL ''\"" % (data_file, self.user_name, self.host_name, self.database_name, self.table_name)

# Custom argument parser class to better handle argument errors
class CustomArgParser(argparse.ArgumentParser):
    def error(self, message):
        print("")
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        print("")
        sys.exit(2)


def main():
    parser = CustomArgParser()
    parser.add_argument('-f', default=None, help='File name to analyze and import', required=True)
    parser.add_argument('-t', default=None, help='Tablename for postgresql', required=True)
    parser.add_argument('-s', help='Database server host name', required=True)
    parser.add_argument('-d', help='Database name', required=True)

    parser.add_argument('--user_name', help='Database user name name', default="postgres")
    parser.add_argument('--header_row', default=1, help='Header row number')
    parser.add_argument('--delim', default=",", help='Delimiter')
    parser.add_argument('--sample_rate', default="100", help='Sample rate')
    args = parser.parse_args()
    csv2psql = CsvToPostgres(args)
    csv2psql.create_sql()


if __name__ == '__main__':
    sys.exit(main())

