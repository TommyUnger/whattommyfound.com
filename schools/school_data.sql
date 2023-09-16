with d as(
select p.name
, pe.name
, p.place_id
, pop_by_age_female_total_female + pop_by_age_male_total_male as total_pop
, pop_by_age_female_total_female_under_5_years
  + pop_by_age_female_total_female_5_to_9_years
  + pop_by_age_female_total_female_10_to_14_years
  + pop_by_age_female_total_female_15_to_17_years
  + pop_by_age_male_total_male_under_5_years
  + pop_by_age_male_total_male_5_to_9_years
  + pop_by_age_male_total_male_10_to_14_years
  + pop_by_age_male_total_male_15_to_17_years as school_age_pop
, pop_by_age_female_white_only_total_female_under_5_years
  + pop_by_age_female_white_only_total_female_5_to_9_years
  + pop_by_age_female_white_only_total_female_10_to_14_years
  + pop_by_age_female_white_only_total_female_15_to_17_years
  + pop_by_age_male_white_only_total_male_under_5_years
  + pop_by_age_male_white_only_total_male_5_to_9_years
  + pop_by_age_male_white_only_total_male_10_to_14_years
  + pop_by_age_male_white_only_total_male_15_to_17_years as school_age_pop_white
, pop_by_age_female_total_female_70_to_74_years
  + pop_by_age_female_total_female_75_to_79_years
  + pop_by_age_female_total_female_80_to_84_years
  + pop_by_age_female_total_female_85_years_and_over
  + pop_by_age_male_total_male_70_to_74_years
  + pop_by_age_male_total_male_75_to_79_years
  + pop_by_age_male_total_male_80_to_84_years
  + pop_by_age_male_total_male_85_years_and_over as over_70_age_pop
, hh_income
, hh_income_50_000_to_59_999 as hh_income_50_60k
, hh_income_60_000_to_74_999
 + hh_income_75_000_to_99_999 as hh_income_60_100k
, hh_income_100_000_to_124_999
 + hh_income_125_000_to_149_999
 + hh_income_150_000_to_199_999 as hh_income_100_200k
, hh_income_200_000_or_more as hh_income_200k_plus
, education
, education_associate_s_degree + education_some_college_no_degree as education_associate
, education_bachelor_s_degree as education_bachelor
, education_graduate_or_professional_degree as education_professional
from census.place_geo p
join census.place_pop_by_age_male pm on pm.place_id = p.place_id
join census.place_pop_by_age_female pf on pf.place_id = p.place_id
join census.place_pop_by_age_female_white_only pfw on pfw.place_id = p.place_id
join census.place_pop_by_age_male_white_only pfm on pfm.place_id = p.place_id
join census.place_income_bracket ib on ib.place_id = p.place_id
join census.place_education pe on pe.place_id = p.place_id
)

select *
, over_70_age_pop / total_pop as over_70_pop
, school_age_pop / total_pop as school_age_pop
, school_age_pop_white / school_age_pop as school_age_white_percent
, hh_income_200k_plus / hh_income as income_200_plus
, hh_income_100_200k / hh_income as income_100_200
, hh_income_60_100k / hh_income as income_060_100
, hh_income_50_60k / hh_income as income_050_060
, (hh_income - (hh_income_200k_plus+hh_income_100_200k+hh_income_60_100k+hh_income_50_60k)) / hh_income as income_050_below
, education_professional / education as college_bachelors_pro
, education_bachelor / education as college_bachelors
, (education - (education_professional + education_bachelor)) / education as no_college_degree
from d
where school_age_pop > 0
and education > 0
and hh_income > 0