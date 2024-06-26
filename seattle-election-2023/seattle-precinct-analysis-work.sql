create index king_county_parcel_geo_mm on import_202309.king_county_parcel_geo(major, minor);
create index king_county_parcel_geo_geom on import_202309.king_county_parcel_geo using gist(geom);

drop table if exists election.king_county_address;

create table election.king_county_address
as
select 
'apartment complex' as address_type
, d.major*10000 + d.minor as pin
, d.address
, d.avg_unit_size as sq_ft
, d.nbr_units as unit_count
, null::float as bedroom_count
, round(st_x(st_centroid(g.geom))::numeric, 6) as longitude
, round(st_y(st_centroid(g.geom))::numeric, 6) as latitude
, g.geom
from import_202309.king_county_apartment_complex d
left join import_202309.king_county_parcel_geo g on trim(to_char(d.major, '000000')) = g.major and trim(to_char(d.minor, '0000')) = g.minor

union

select 
'condo unit' as address_type
, d.major*10000 + d.minor as pin
, trim(regexp_replace(d.building_number || ' ' || d.direction_prefix || ' ' || d.street_name || ' ' || d.street_type || ' ' || d.direction_suffix
, '[ ]+', ' ', 'g')) || ' #' || d.unit_nbr as address
, footage as sq_ft
, 1 as unit_count
, case when nbr_bedrooms = 'S' then 0.5 
when nbr_bedrooms !~* '[0-9]' then null
else nbr_bedrooms::float end as bedroom_count
, round(st_x(st_centroid(g.geom))::numeric, 6) as longitude
, round(st_y(st_centroid(g.geom))::numeric, 6) as latitude
, g.geom
from import_202309.king_county_condo_unit d
left join import_202309.king_county_parcel_geo g on trim(to_char(d.major, '000000')) = g.major
where footage < 10000
and footage > 400

union

select 
'single family home' as address_type
, d.major*10000 + d.minor as pin
, regexp_replace(address, '[ ]+', ' ', 'g') as address
, sq_ft_tot_living as sq_ft
, d.nbr_living_units as unit_count
, bedrooms::float as bedroom_count
, round(st_x(st_centroid(g.geom))::numeric, 6) as longitude
, round(st_y(st_centroid(g.geom))::numeric, 6) as latitude
, g.geom
from import_202309.king_county_residential_building d
left join import_202309.king_county_parcel_geo g on trim(to_char(d.major, '000000')) = g.major and trim(to_char(d.minor, '0000')) = g.minor
;


select *
from election.king_county_address
group by 1
;

create table election.seattle_precinct
as
with d as(
select *, row_number()over(partition by name order by election_year desc) row_num
from election.king_county_precinct
where name like 'SEA %'
)
select name
, sum_voters as voter_count
, gid
, (geom) as geom
, (st_simplify(st_buffer(geom, 0.0007), 0.00005)) as geom_buffered
from d
where row_num = 1;
create index seattle_precinct_geom on election.seattle_precinct using gist(geom_buffered);

drop table if exists election.seattle_precinct_address;
create table election.seattle_precinct_address
as
select distinct gid as precinct_gid, pin as address_pin
from election.king_county_address a
join election.seattle_precinct p on st_intersects(a.geom, p.geom_buffered)
;
create index idx_seattle_precinct_name on election.seattle_precinct(name);

create index idx_election_seattle_precinct_address_precinct on election.seattle_precinct_address(precinct_gid);
create index idx_election_seattle_precinct_address_address_pin on election.seattle_precinct_address(address_pin);





drop table if exists election.seattle_precinct_candidate_result;

create table election.seattle_race_result
as
with race_candidate as(
select election_year, race, candidate
, sum(vote_count) as vote_count
, row_number()over(partition by election_year, race order by sum(vote_count) desc) as race_candidate_rank
from election.seattle_precinct_candidate_result
group by 1, 2, 3
)
, race_total as(
select 
election_year
, race
, sum(vote_count) as vote_count
, count(distinct candidate) as candidate_count
, count(distinct precinct) as precinct_count
from election.seattle_precinct_candidate_result
where vote_count >= 5
group by 1, 2
)
select r.*
, max(case when race_candidate_rank = 1 then candidate end) as candidate1
, max(case when race_candidate_rank = 1 then rc.vote_count::float / r.vote_count end) as canidate1_percent
from race_total as r 
join race_candidate as rc using(election_year, race)
group by 1, 2, 3, 4, 5
;

drop table if exists election.seattle_precinct_candidate_result;
create table election.seattle_precinct_candidate_result
as
with d as(
select 
election_year
, race
, precinct
, sum_of_count as vote_count
, counter_type as candidate
, row_number()over(partition by election_year, race, precinct order by sum_of_count desc) as candidate_precinct_race_rank
from election.king_county_precinct_results d
where precinct ~* '^sea '
and counter_type not in ('Write-in', 'Write-In', 'Times Blank Voted', 'Times Over Voted', 'Registered Voters', 'Times Under Voted', 'Registered Voters', 'Times Counted')
)

, s as(
select election_year, race, precinct, sum(vote_count) as vote_count
from d
group by 1, 2, 3
)

select d.*
, case when s.vote_count > 0 then d.vote_count::float / s.vote_count end as vote_percent
from d
join s using(election_year, race, precinct)
;

drop table if exists election.seattle_candidate_result;
create table election.seattle_candidate_result
as
select 
election_year
, race
, candidate
, row_number()over(partition by election_year, race order by sum(pr.vote_count) desc) as candidate_rank
, sum(pr.vote_count) as vote_count
, sum(pr.vote_count) / max(rr.vote_count) as vote_percent
, max(case when candidate = candidate1 then 1 else 0 end) is_winner
, count(case when pr.vote_percent > 0.5 then 1 end) won_precinct_count
, count(case when pr.vote_percent > 0.5 then 1 end)::float / count(1) as won_precinct_percent
from election.seattle_precinct_candidate_result pr
join election.seattle_race_result rr using(race, election_year)
group by 1, 2, 3
;
create index idx_election_seattle_candidate_result on election.seattle_candidate_result(election_year, race, candidate);


create table election.census_tract_stats_raw
as
select m.geo_id
, geom
, sum(case when metric_id in (32, 51) then val end) as pop_total
, sum(case when metric_id in (3) then val end) as hh_total
, sum(case when metric_id in (34, 35, 53, 54) then val end)::float
 /  sum(case when metric_id in (32, 51) then val end) as age_school_age_percent
, max(case when metric_id = 28 then val end) / 100 as edu_bachelors_percent
, max(case when metric_id = 29 then val end) / 100 as edu_graduate_percent
, sum(case when metric_id = 14 then val end) as income_median
, sum(case when metric_id = 15 then val end) as income_mean
, sum(case when metric_id in (11, 12) then val end) / 100.0 as income_100_200k_percent
, sum(case when metric_id = 13 then val end) / 100.0 as income_200k_percent
from census.metric m
join import_202309.census_geo_tract_wa t on t.geoid::bigint = m.geo_id
group by 1, 2
having sum(case when metric_id in (32, 51) then val end) > 0
;

create index idx_election_census_tract_stats_raw_geom on election.census_tract_stats_raw using gist(geom);

drop table election.seattle_precinct_demographics;
create table election.seattle_precinct_demographics
as
select p.name as precinct
, avg(pop_total) as pop_total
, avg(hh_total) as hh_total
, avg(pop_total) / avg(hh_total) as avg_hh_size
, avg(age_school_age_percent) as age_school_age_percent
, avg(edu_bachelors_percent) as edu_bachelors_percent
, avg(edu_graduate_percent) as edu_graduate_percent
, avg(income_median) as income_median
, avg(income_mean) as income_mean
, avg(income_100_200k_percent) as income_100_200k_percent
, avg(income_200k_percent) as income_200k_percent
from election.seattle_precinct p
join election.census_tract_stats_raw cts on st_intersects(p.geom_buffered, cts.geom)
where st_area(st_intersection(p.geom_buffered, cts.geom)) / st_area(p.geom_buffered) > 0.3
and hh_total >= 50
and pop_total >= 100
group by 1
;

create index election_seattle_precinct_demographics on election.seattle_precinct_demographics(precinct);

select election_year, race, candidate
, 'age_school_age_percent' as attribute_type
, corr(vote_percent, age_school_age_percent) correlation
, count(1) sample_count
, avg(vote_percent) avg_vote_percent
from election.seattle_precinct_candidate_result pcr
join election.seattle_precinct_demographics using(precinct)
group by 1, 2, 3
having corr(vote_percent, age_school_age_percent) between 0.01 and 0.99
;


with d as(
select pcr.precinct
, count(distinct rr.election_year || rr.race) race_count
, count(case when pcr.candidate_precinct_race_rank = 1 and rr.candidate1 = pcr.candidate then 1 end)::float 
	/ count(distinct rr.election_year || rr.race) as voted_for_winner_percent
, avg(case when pcr.candidate_precinct_race_rank = 1 then pcr.vote_count end)::int avg_vote_count_for_winner
, avg(case when pcr.candidate_precinct_race_rank = 1 then pcr.vote_percent end) avg_vote_percent_for_winner
from election.seattle_precinct_candidate_result pcr
join election.seattle_race_result rr using(election_year, race)
group by 1
having avg(case when pcr.candidate_precinct_race_rank = 1 then pcr.vote_count end) > 10
)

, precinct_housing as(
select spa.precinct_gid
, sum(kca.unit_count) as total_housing_unit_count
, sum(case when kca.address_type = 'apartment complex' then kca.unit_count else 0 end) apartment_count
, sum(case when kca.address_type = 'condo unit' then kca.unit_count else 0 end) as condo_count
, sum(case when kca.address_type = 'single family home' then kca.unit_count else 0 end) as single_family_count
from election.seattle_precinct_address spa
join election.king_county_address kca on spa.address_pin = kca.pin
group by 1
)

select power(voted_for_winner_percent, 2) * avg_vote_count_for_winner * avg_vote_percent_for_winner as precinct_score
, ntile(20)over(order by  power(voted_for_winner_percent, 2) * avg_vote_count_for_winner * avg_vote_percent_for_winner) as precinct_score_twentile
, d.*
, geom
, sp.voter_count as precinct_voter_count
, ph.*
, st_x(st_centroid(geom)) as longitude
, st_y(st_centroid(geom)) as latitude
from d
join election.seattle_precinct sp on sp.name = d.precinct 
left join precinct_housing ph on ph.precinct_gid = sp.gid
;

select election_year
, race
, min(case when candidate ~* '^(approv|maint|yes|prop)' then 'initiative/prop/etc' else 'people' end) election_type
, case when max(case when cr.candidate_rank = 2 then candidate end) is null then 'unopposed' else 'regular' end competitor
, max(case when cr.candidate_rank = 1 then candidate end) as winner
, max(case when cr.candidate_rank = 2 then candidate end) as loser
, max(case when cr.candidate_rank = 1 then cr.vote_percent end) as winner_percent
, max(case when cr.candidate_rank = 2 then cr.vote_percent end) as loser_percent
, corr(pcr.vote_percent, cr.vote_percent) as "precinct similarity"
, sum(pcr.vote_count) as "total vote count"
, count(distinct pcr.precinct) "precincts count"
from election.seattle_precinct_candidate_result pcr
join election.seattle_candidate_result cr using(election_year, race, candidate)
--where race ~* 'school'
group by 1, 2
having count(distinct pcr.precinct) >= 300
;


select d.election_year
, d.race
, d.precinct
, d.vote_count
, cr.candidate_rank || '. ' || d.candidate as candidate
, d.candidate_precinct_race_rank
, d.vote_percent
, d.election_year || ' ' || d.race as election_year_race
, st_x(st_centroid(geom)) as longitude
, st_y(st_centroid(geom)) as latitude
from election.seattle_precinct_candidate_result d
join election.seattle_candidate_result cr on cr.election_year = d.election_year and cr.race = d.race and cr.candidate = d.candidate
join election.seattle_precinct sp on sp.name = d.precinct
;



select case when rr.candidate1 is not null then 'Winner' else 'Loser' end as candidate_status
, d.election_year || d.race || d.candidate as row_id
, d.*
from election.seattle_demographic_correlation d
left join election.seattle_race_result rr on rr.election_year = d.election_year and rr.race = d.race and d.candidate = rr.candidate1 
;



drop table if exists election.seattle_demographic_correlation;

DO $$ 
DECLARE
    attribute text;
    sql_query text;
    attributes text[] := ARRAY[
		'pop_total'
		,'hh_total'
		,'age_school_age_percent'
		,'edu_bachelors_percent'
		,'edu_graduate_percent'
		,'income_median'
		,'income_mean'
		,'income_100_200k_percent'
		,'income_200k_percent'
    ];
BEGIN
    -- Check if table exists, and if not, create it
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'election' AND tablename = 'seattle_demographic_correlation') THEN
        EXECUTE $q$
            CREATE TABLE election.seattle_demographic_correlation (
                election_year INTEGER,
                race TEXT,
                candidate TEXT,
                attribute_type TEXT,
                correlation FLOAT,
                sample_count INTEGER,
                avg_vote_percent FLOAT,
                avg_val FLOAT
            )
        $q$;
    END IF;

    FOREACH attribute IN ARRAY attributes
    LOOP
        -- Construct dynamic SQL based on the current attribute
        sql_query := format($q$
            INSERT INTO election.seattle_demographic_correlation 
            (election_year, race, candidate, attribute_type, correlation, sample_count, avg_vote_percent, avg_val)
            SELECT 
                election_year, 
                race, 
                candidate,
                %L as attribute_type,
                corr(vote_percent, %I) as correlation,
                count(1) as sample_count,
                avg(vote_percent) as avg_vote_percent,
                avg(%I) as avg_val
            FROM election.seattle_precinct_candidate_result pcr
            JOIN election.seattle_precinct_demographics USING(precinct)
            GROUP BY 1, 2, 3
            HAVING corr(vote_percent, %I) BETWEEN -0.99 AND 0.99
        $q$, attribute, attribute, attribute, attribute);

        -- Execute the dynamic SQL
        EXECUTE sql_query;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

create table election.seattle_precinct_demographics_age_sex
as
with sa as(
select 
m.geo_id
, m.val
, case when name ~* 'female' then 'female' else 'male' end as sex
, 
case
when name ~* 'age and sex estimate.* total population age 15 to 19 years' then '18-30'
when name ~* 'age and sex estimate.* total population age 20 to 24 years' then '18-30'
when name ~* 'age and sex estimate.* total population age 25 to 29 years' then '18-30'
when name ~* 'age and sex estimate.* total population age 30 to 34 years' then '30-50'
when name ~* 'age and sex estimate.* total population age 35 to 39 years' then '30-50'
when name ~* 'age and sex estimate.* total population age 40 to 44 years' then '30-50'
when name ~* 'age and sex estimate.* total population age 45 to 49 years' then '30-50'
when name ~* 'age and sex estimate.* total population age 50 to 54 years' then '50-70'
when name ~* 'age and sex estimate.* total population age 55 to 59 years' then '50-70'
when name ~* 'age and sex estimate.* total population age 60 to 64 years' then '50-70'
when name ~* 'age and sex estimate.* total population age 65 to 69 years' then '50-70'
when name ~* 'age and sex estimate.* total population age 70 to 74 years' then '70+'
when name ~* 'age and sex estimate.* total population age 75 to 79 years' then '70+'
when name ~* 'age and sex estimate.* total population age 80 to 84 years' then '70+'
when name ~* 'age and sex estimate.* total population age 85 years and over' then '70+'
end age
from census.metric_detail md
join census.metric m on m.metric_id = md.metric_id
where name ~* 'age and sex'
)

, s as(
select geo_id, sum(val) as total_pop
from sa
where age is not null
group by 1
)

, d as(
select geo_id, sex, age, sum(val) pop
from sa
where age is not null
group by 1, 2, 3
)

, fd as(
select geo_id, geom, sex, age, pop, pop::float/total_pop as pop_perc
from d
join s using(geo_id)
join import_202309.census_geo_tract_wa t on t.geoid::bigint = geo_id
where total_pop >= 100
)

select 
p.name as precinct
, sum(pop) as pop_total
, sum(case when sex = 'male' then pop end) m
, sum(case when sex = 'female' then pop end) f

, sum(case when age = '18-30' then pop end) "18-30"
, sum(case when age = '30-50' then pop end) "30-50"
, sum(case when age = '50-70' then pop end) "50-70"
, sum(case when age = '70+' then pop end) "70+"

, sum(case when age = '18-30' and sex = 'male' then pop end)::Float / sum(pop) "m 18-30"
, sum(case when age = '30-50' and sex = 'male' then pop end)::Float / sum(pop)  "m 30-50"
, sum(case when age = '50-70' and sex = 'male' then pop end)::Float / sum(pop)  "m 50-70"
, sum(case when age = '70+' and sex = 'male' then pop end)::Float / sum(pop)  "m 70+"

, sum(case when age = '18-30' and sex = 'female' then pop end)::Float / sum(pop)  "f 18-30"
, sum(case when age = '30-50' and sex = 'female' then pop end)::Float / sum(pop)  "f 30-50"
, sum(case when age = '50-70' and sex = 'female' then pop end)::Float / sum(pop)  "f 50-70"
, sum(case when age = '70+' and sex = 'female' then pop end)::Float / sum(pop)  "f 70+"

from election.seattle_precinct p
join fd on st_intersects(p.geom_buffered, fd.geom)
where st_area(st_intersection(p.geom_buffered, fd.geom)) / st_area(p.geom_buffered) > 0.3
and pop >= 100
group by 1
