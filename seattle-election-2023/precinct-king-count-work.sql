DO $$
DECLARE
    exec_sql TEXT;
BEGIN
	create schema if not exists election;
	drop table if exists election.king_county_precinct_results;
	
	    SELECT 'create table election.king_county_precinct_results as ' || 
    		string_agg('select ' || regexp_replace(table_name, '^[^0-9]+', '') || ' as election_year,' ||
    				 'precinct, race, ' || 
    				  'counter_group, counter_type, sum_of_count ' ||
    				  'from ' || table_schema || '.' || table_name, chr(10) || 'UNION' || chr(10)) 
    INTO exec_sql
    FROM information_schema.tables
    WHERE table_name ~* 'king_county_election_[0-9]+';

    EXECUTE exec_sql;
END $$;


DO $$
DECLARE
    exec_sql TEXT;
BEGIN
	create schema if not exists election;
	drop table if exists election.king_county_precinct;
	
	    SELECT 'create table election.king_county_precinct as ' || 
    		string_agg('select ' || regexp_replace(table_name, '^[^0-9]+', '') || ' as election_year,' ||
    				  'geom, gid, name, objectid, shape_area, shape_leng, sum_voters, votdst ' ||
    				  'from ' || table_schema || '.' || table_name, chr(10) || 'UNION' || chr(10)) 
    INTO exec_sql
    FROM information_schema.tables
    WHERE table_name ~* 'king_county_election_precinct_[0-9]+';

    EXECUTE exec_sql;
END $$;

select table_name, count(1), string_agg(column_name, ', ' order by column_name)
from information_schema.columns
where table_name ~* 'king_county_election_precinct_[0-9]+'
group by 1
;

create index idx_election_king_county_precinct1
on election.king_county_precinct(election_year, name);


with d as(
select 
election_year
, race
, counter_type
, sum(sum_of_count) as votes
, row_number()over(partition by election_year, race order by sum(sum_of_count) desc) as rank
from election.king_county_precinct_results
where race ~* 'Seattle School District'
and precinct ~* 'sea'
and counter_type !~* '^(times |registered )'
group by 1, 2, 3
)

select 
election_year
, race

, max(case when rank = 1 then votes end)
, max(case when rank = 2 then votes end)

, max(case when rank = 1 then counter_type end)
, max(case when rank = 2 then counter_type end)
from d
group by 1, 2
;


with d as(
select p.name as precinct, d.election_year, d.race, d.counter_type as candidate, d.sum_of_count as vote_count
, st_astext(st_simplify(p.geom, 0.0001)) as geometry
, st_x(st_centroid(p.geom)) as longitude
, st_y(st_centroid(p.geom)) as latitude
, row_number()over(partition by p.name, d.election_year, d.race
					order by d.sum_of_count desc) as rank
from election.king_county_precinct_results d
join election.king_county_precinct p on p.election_year = d.election_year and p.name = d.precinct
where d.election_year = 2021
and race ~* 'Seattle School District'
and counter_type !~* '^(times |registered |Write-in)'
)

, s as(
select precinct, election_year, race
, sum(vote_count) as total_vote_count
from d
group by 1, 2, 3
)

select d.*, vote_count::float / total_vote_count as vote_percent
, vote_count - (total_vote_count - vote_count) as vote_margin
from d
join s using(precinct, election_year, race)
where total_vote_count > 0
;

