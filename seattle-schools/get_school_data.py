import libs.logging_config
import logging
import requests
import re
from libs.data.king_county import KingCounty
from libs.data.arcgis import Arcgis
from libs.data.census import Census
from libs.data.schools import Schools
from libs.db import Db
from libs.utils import Utils

logger = logging.getLogger(__name__)

def get_data():
    db = Db()
    kc = KingCounty()
    kc.get_data("https://aqua.kingcounty.gov/extranet/assessor/Parcel.zip", {"EXTR_Parcel.csv": "king_county_parcel"})
    kc.get_data("https://aqua.kingcounty.gov/extranet/assessor/Condo%20Complex%20and%20Units.zip", 
                {"EXTR_CondoComplex.csv": "king_county_condo_complex",
                    "EXTR_CondoUnit2.csv": "king_county_condo_unit"})
    kc.get_data("https://aqua.kingcounty.gov/extranet/assessor/Residential%20Building.zip",
                {"EXTR_ResBldg.csv": "king_county_residential_building"})
    kc.get_data("https://aqua.kingcounty.gov/extranet/assessor/Apartment%20Complex.zip",
                {"EXTR_AptComplex.csv": "king_county_apartment_complex"})
    kc.get_data("https://aqua.kingcounty.gov/extranet/assessor/Real%20Property%20Sales.zip",
                {"EXTR_RPSale.csv": "king_county_property_sale"})
    arc = Arcgis()
    arc.get_shape("king_county_parcel_geo", "8058a0c540434dadbe3ea0ade6565143_439", "4326")
    arc.get_shape("king_county_election_precinct_2014", "f572716d0608465989bc9ff620de0dd8_4182014", "4326")
    arc.get_shape("king_county_election_precinct_2015", "aff7e4bfecf54bbcade6ac954392d491_4182015", "4326")
    arc.get_shape("king_county_election_precinct_2016", "ea9769bfb88643ccba6837d112ed0a8e_4182016", "4326")
    arc.get_shape("king_county_election_precinct_2017", "2efe03663be44261ab774b30c4333fac_4182017", "4326")
    arc.get_shape("king_county_election_precinct_2018", "134a4cde6bec401bb6b158f96d280aad_4182018", "4326")
    arc.get_shape("king_county_election_precinct_2019", "598725b21e2f4879bd387f29c5971696_4182019", "4326")
    arc.get_shape("king_county_election_precinct_2021", "4f402331643f467db5dcf31783703d60_4182021", "4326")
    sch = Schools()
    sch.get_schools("public_school", "87376bdb0cb3490cbda39935626f6604_0", "3857")
    sch.get_schools("private_school", "0dfe37d2a68545a699b999804354dacf_0", "4326")

    s = Utils.get_session()
    for election_year in [2022, 2020, 2018, 2016, 2014]:
        if db.import_table_exists(f"king_county_election_{election_year}"):
            logger.info(f"Table king_county_election_{election_year} already exists")
            continue
        res = s.get(f"https://kingcounty.gov/en/legacy/depts/elections/results/{election_year}/{election_year}11.aspx")
        for m in re.findall(r'href="(.*?final-precinct-results.ashx[^"]*)"', res.text):
            url = str(m)
        f = Utils.download_file(url, f"king_county_election_results_{election_year}.csv", session=s)
        db.csv2db(f, f"king_county_election_{election_year}", encoding='latin1')

    cen = Census()
    cen.get_geo_data('state')
    cen.get_geo_data('block', 'wa')
    cen.get_geo_data('tract', 'wa')

    # income data
    fields = ["S1901_C01_0{:02d}E".format(i) for i in range(1, 15)]
    cen.get_census_data('2021/acs/acs5/subject', fields, 'tract', 'wa')

    #education 
    fields = ["S1501_C02_0{:02d}E".format(i) for i in range(1, 16)]
    cen.get_census_data('2021/acs/acs5/subject', fields, 'tract', 'wa')

    #sex and age 
    fields = ["S0101_C03_0{:02d}E".format(i) for i in range(1, 20)] # male
    cen.get_census_data('2021/acs/acs5/subject', fields, 'tract', 'wa')
    fields = ["S0101_C05_0{:02d}E".format(i) for i in range(1, 20)] # female
    cen.get_census_data('2021/acs/acs5/subject', fields, 'tract', 'wa')

if __name__ == "__main__":
    get_data()
