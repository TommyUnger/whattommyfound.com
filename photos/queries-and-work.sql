alter table photo_file
drop column status;


alter table photo_file
add column status varchar(128);

alter table photo_file
add column file_name varchar(128);

alter table photo_file drop column thumb_bw_print_16_r;
alter table photo_file drop column thumb_bw_print_24_r;
alter table photo_file drop column thumb_bw_print_32_r;
alter table photo_file drop column thumb_bw_print_40_r;
alter table photo_file drop column thumb_bw_print_56_r;
alter table photo_file drop column thumb_bw_print_64_r;

alter table photo_file add column thumb_bw_print_16_r int;
alter table photo_file add column thumb_bw_print_24_r int;
alter table photo_file add column thumb_bw_print_32_r int;
alter table photo_file add column thumb_bw_print_40_r int;
alter table photo_file add column thumb_bw_print_56_r int;
alter table photo_file add column thumb_bw_print_64_r int;


update photo_file
set 
thumb_bw_print_16_r = floor(log(abs(thumb_bw_print_16)+1)*500),
thumb_bw_print_24_r = floor(log(abs(thumb_bw_print_24)+1)*500),
thumb_bw_print_32_r = floor(log(abs(thumb_bw_print_32)+1)*500),
thumb_bw_print_40_r = floor(log(abs(thumb_bw_print_40)+1)*500),
thumb_bw_print_56_r = floor(log(abs(thumb_bw_print_56)+1)*500),
thumb_bw_print_64_r = floor(log(abs(thumb_bw_print_64)+1)*500),
file_name = regexp_replace(lower("File:FileName"), '\(.*|[.][^.]+$', '')
;

create index idx_photo_index
on photo_file("index");

create index idx_photo_index_exif_index
on photo_file( "EXIF:ImageUniqueID");

create index idx_photo_file_thumbs_1_r
on photo_file(thumb_bw_print_16_r, thumb_bw_print_24_r);

create index idx_photo_file_name_1_2
on photo_file(
regexp_replace(lower(photo_file."File:FileName"), '\(.*|[.][^.]+$', '')
, thumb_bw_print_16_r
);

update photo_file
set status = null;

with t as(
select "EXIF:ImageUniqueID"
, file_name
, row_number()over(partition by "EXIF:ImageUniqueID" order by "EXIF:CreateDate") row_num
from photo_file
where "EXIF:ImageUniqueID" is not null
)

update photo_file
set status = 'EXIF:ImageUniqueID dup' || t_dup.row_num || ' of ' || t_primary.file_name
from t as t_primary, t as t_dup
where t_primary."EXIF:ImageUniqueID" = photo_file."EXIF:ImageUniqueID" and t_primary.row_num = 1 
and t_dup."EXIF:ImageUniqueID" = photo_file."EXIF:ImageUniqueID" and t_dup.row_num > 1
;

select file_name, "EXIF:CreateDate", count(1)
from photo_file
where status is null
group by 1, 2
;

select *
from photo_file
where file_name = 'dcp_0004'
;


update photo_file
set "EXIF:CreateDate" = case 
	when "EXIF:CreateDate" ~* '[1-9]' then (replace(left("EXIF:CreateDate", 10), ':', '-') || substr("EXIF:CreateDate", 11)) 
	else null end::timestamp
;



create temp table __temp_t
as
select "index"
, "File:FileName" as file_name,
	thumb_bw_print_16_r,
	thumb_bw_print_24_r,
	thumb_bw_print_32_r,
	thumb_bw_print_40_r,
	thumb_bw_print_56_r,
	thumb_bw_print_64_r
, row_number()over(partition by 
	thumb_bw_print_16_r,
	thumb_bw_print_24_r,
	thumb_bw_print_32_r,
	thumb_bw_print_40_r,
	thumb_bw_print_56_r,
	thumb_bw_print_64_r
		order by "EXIF:CreateDate") row_num
from photo_file
;

update photo_file
set status = 'perfect dup' || td.row_num || ' of ' || regexp_replace(lower(t1.file_name), '\(.*|[.][^.]+$', '')
from __temp_t as td, __temp_t as t1
where td."index" = photo_file."index" 
	and td.row_num > 1
	and t1.thumb_bw_print_16_r = photo_file.thumb_bw_print_16_r
	and t1.thumb_bw_print_24_r = photo_file.thumb_bw_print_24_r
	and t1.thumb_bw_print_32_r = photo_file.thumb_bw_print_32_r
	and t1.thumb_bw_print_40_r = photo_file.thumb_bw_print_40_r
	and t1.thumb_bw_print_56_r = photo_file.thumb_bw_print_56_r
	and t1.thumb_bw_print_64_r = photo_file.thumb_bw_print_64_r
	and t1.row_num = 1
and regexp_replace(lower(t1.file_name), '\(.*|[.][^.]+$', '') = regexp_replace(lower(photo_file."File:FileName"), '\(.*|[.][^.]+$', '')
;







select
	thumb_bw_print_16_r,
	thumb_bw_print_24_r,
	thumb_bw_print_32_r,
	thumb_bw_print_40_r,
	thumb_bw_print_56_r,
	thumb_bw_print_64_r,
	 count(1),
	 min("File:Directory" || '/' || "File:FileName"),
	 max("File:Directory" || '/' || "File:FileName")
from photo_file
group by 1, 2, 3, 4, 5, 6
;

with t as(
select "index"
, "EXIF:ImageUniqueID"
, "status"
, row_number()over(partition by "EXIF:ImageUniqueID"
		order by "EXIF:CreateDate", "File:FileSize" desc) row_num
from photo_file
where "EXIF:ImageUniqueID" is not null
)

select *
from t
where row_num > 1
;

select status, "File:FileName", "File:Directory" || '/' || "File:FileName", split_part("File:MIMEType", '/', 1)
, floor(log(abs(thumb_bw_print_0))*10)
, *
from photo_file
--where status ~* 'dup'
where status ~* 'img_5743'
or "File:FileName" ~* 'img_5743'
;


alter table photo_file
add column id int;

update photo_file
set id = row_number()over(order by lower(file_name))
;



select p."EXIF:CreateDate"
from photo_file p
;
select 
thumb_bw_print_0
, thumb_bw_print_24
, thumb_bw_print_32
, thumb_bw_print_40
, count(1)
, min("File:Directory" || '/' || "File:FileName"), max("File:Directory" || '/' ||"File:FileName")
from photo_file
--where thumb ~* 'binary'
group by 1, 2, 3, 4
having count(1) > 1
--having min(regexp_replace(lower("File:FileName"), '\(.*|[.].*', '')) <> max(regexp_replace(lower("File:FileName"), '\(.*|[.].*', ''))
--and min(thumb_bw_print_0) <> max(thumb_bw_print_0)
;

select case when thumb_bw_print_0 < 0 then '-' else '+' end, round(log(abs(thumb_bw_print_0)+1))
, count(1) as img_count
, count(distinct thumb_bw_print_0) as distinct1
, count(distinct thumb_bw_print_24) distinct2
, (count(1)::float - count(distinct thumb_bw_print_0)) / count(1) dup_ratio
from photo_file
group by 1, 2
order by 1, 2
;

drop table if exists photo_file;
;

update photo_file 
set creation_time = case when creation_time ~* '[0-9]' then (replace(left(creation_time, 10), ':', '-') || substr(creation_time, 11)) else null end::timestamp
;

select left(creation_time, 10), count(1)
from photo_file
group by 1
;
select date_trunc('year', creation_time::timestamp), count(1), min(creation_time), max(creation_time)
from photo_file
group by 1
;

select '2021:12:20 14:52:17'::date
;

select *
from photo_file
where lower(file_name) = 'pict0014.jpg'
;

select source, count(1)
from photo_file
group by 1
;

with d as(
select *
, row_number()over(partition by lower(file_name), creation_time order by case when width = '' then 0 else width::float end desc) row_num
from photo_file
)

, summary as (
select lower(file_name), creation_time, count(1)
, max(Case when row_num = 1 then file_name || ' - ' || width || ' - ' || google_id end)
, max(Case when row_num = 2 then file_name || ' - ' || width || ' - ' || google_id end)
from d
where source = 'google photos'
and creation_time >= '2002-01-01'
group by 1, 2
having count(1) > 1
order by 2 desc
)
select *
from summary
;

select creation_time::date, count(1)
from photo_file
group by 1
order by 1 desc;


select *
from photo_google
;

select index, "EXIF:ImageDescription", "File:Directory" || '/' ||"File:FileName"
from photo_file
where length("EXIF:ImageDescription") > 1
and "EXIF:ImageDescription" !~* 'olympus|dcf'
;

select thumb_bw, thumb_color
from photo_file
order by random()
limit 10
;

drop table photo_file;

DROP TABLE photo_file;

selecT *
from information_Schema.columns
where table_name = 'photo_file'
and column_name ~* 'rotate'
;

select *
from photo_file
;

select 
floor(thumb_bw_print_4/100000000000)::varchar || floor(thumb_bw_print_5/100000000000)::varchar || floor(thumb_bw_print_6/100000000000)::varchar
, count(1)
, array_to_string(array_agg('<img src="data:image/png;base64,' || thumb_color || '">'), ' ')
, "EXIF:ExifImageWidth"
from photo_file
group by 1
order by 2 desc
limit 20
;


select *
from photo_file
where "File:FileName" ~* '.heic'
limit 10



with d as(
select photo_id as photo_id 
, dup_photo_id || '-' || dup_status as "header"
, file_path
, thumb_color
, thumb_light_9
, thumb_hue_9
, exif_createdate::timestamp as createdate
, row_number()over(partition by 
  exif_createdate::date,
  floor(thumb_hue_9[5] / 4.0),
  floor(thumb_light_9[5] / 4.0)
  order by total_complexity desc) row_num
from photos.photo_file
where exif_createdate::date >= '2021-12-15'
--and dup_status is null
)

select *
from d
--where row_num <=2
order by createdate::date, thumb_light_9[5], thumb_hue_9[5]
--grid--
;


select 'cp "' || file_path || '" /Users/tommy/Desktop/2022-Top-Photos/'
from photos.photo_file_tag t
join photos.photo_file p on p.photo_id = t.photo_id
where tag ~* '2022'



select *
from information_schema.columns
where table_name = 'photo_file'
and column_name ~* 'dup'
;


with d as(
select photo_id as photo_id 
, dup_photo_id || '-' || dup_status as "header"
, file_path
, thumb_color
, row_number()over(partition by 
exif_createdate::date,
floor(thumb_hue_9[5] / 4.0),
floor(thumb_light_9[5] / 4.0), random()
order by total_complexity desc) row_num
from photos.photo_file
where exif_createdate::date >= '2021-12-15'
and dup_status is null
)

select *
from d
where row_num = 1
order by random()
--grid--
