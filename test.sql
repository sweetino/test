-- 1.
-- 버전 체크
select version();
--"PostgreSQL 12.6, compiled by Visual C++ build 1914, 64-bit"
-- CREATE SCHEMA kis;
-- -- SQL shell (psql)
-- psql -U postgres -d postgres -a -f OMOP\ CDM\ ddl\ -\ PostgreSQL.sql
-- --
-- SET search_path to kis;
-- 테이블 생성
CREATE TABLE concept (
  concept_id INTEGER NOT NULL ,
  concept_name VARCHAR(255) NOT NULL ,
  domain_id VARCHAR(20) NOT NULL ,
  vocabulary_id VARCHAR(20) NOT NULL ,
  concept_class_id VARCHAR(20) NOT NULL ,
  standard_concept VARCHAR(1) NULL ,
  concept_code VARCHAR(50) NOT NULL ,
  valid_start_date DATE NOT NULL ,
  valid_end_date DATE NOT NULL ,
  invalid_reason VARCHAR(1) NULL
);
COPY concept FROM 'C:/Users/USER/Downloads/synthea_cdm_csv/concept.csv' WITH DELIMITER E',' CSV HEADER;
-- select * from concept limit 10;
-- DROP TABLE condition_occurrence;
CREATE TABLE condition_occurrence
(
  condition_occurrence_id BIGINT NOT NULL ,
  person_id BIGINT NOT NULL ,
  condition_concept_id INTEGER NOT NULL ,
  condition_start_date DATE NULL ,
  condition_start_datetime TIMESTAMP NOT NULL ,
  condition_end_date DATE NULL ,
  condition_end_datetime TIMESTAMP NULL ,
  condition_type_concept_id INTEGER NOT NULL ,
  condition_status_concept_id INTEGER NULL ,
  stop_reason VARCHAR(20) NULL ,
  provider_id BIGINT NULL ,
  visit_occurrence_id BIGINT NULL ,
  visit_detail_id               BIGINT     NULL ,
  condition_source_value VARCHAR(50) NULL ,
  condition_source_concept_id INTEGER NULL ,
  condition_status_source_value VARCHAR(50) NULL
);
COPY condition_occurrence FROM 'C:/Users/USER/Downloads/synthea_cdm_csv/condition_occurrence.csv' WITH DELIMITER E',' CSV HEADER;
-- select * from condition_occurrence limit 10;
CREATE TABLE death
(
  person_id BIGINT   NOT NULL ,
  death_date    DATE NOT NULL ,
  death_datetime TIMESTAMP NULL,
  death_type_concept_id INTEGER   NOT NULL,
  cause_concept_id   INTEGER   NULL,
  cause_source_value VARCHAR(50) NULL,
  cause_source_concept_id INTEGER NULL
);
COPY death FROM 'C:/Users/USER/Downloads/synthea_cdm_csv/death.csv' WITH DELIMITER E',' CSV HEADER;
-- select * from death limit 10;
CREATE TABLE drug_exposure
(
  drug_exposure_id BIGINT NOT NULL ,
  person_id BIGINT NOT NULL ,
  drug_concept_id INTEGER   NOT NULL ,
  drug_exposure_start_date DATE    NULL ,
  drug_exposure_start_datetime TIMESTAMP NOT NULL ,
  drug_exposure_end_date DATE    NULL ,
  drug_exposure_end_datetime TIMESTAMP   NOT NULL ,
  verbatim_end_date DATE    NULL ,
  drug_type_concept_id INTEGER   NOT NULL ,
  stop_reason VARCHAR(20) NULL ,
  refills INTEGER   NULL ,
  quantity NUMERIC    NULL ,
  days_supply INTEGER   NULL ,
  sig TEXT NULL ,
  route_concept_id INTEGER NOT NULL ,
  lot_number VARCHAR(50) NULL ,
  provider_id BIGINT   NULL ,
  visit_occurrence_id BIGINT   NULL ,
  visit_detail_id               BIGINT       NULL ,
  drug_source_value VARCHAR(50)   NULL ,
  drug_source_concept_id INTEGER   NOT NULL ,
  route_source_value VARCHAR(50)   NULL ,
  dose_unit_source_value VARCHAR(50)   NULL
);
COPY drug_exposure FROM 'C:/Users/USER/Downloads/synthea_cdm_csv/drug_exposure.csv' WITH DELIMITER E',' CSV HEADER;
-- select * from drug_exposure limit 10;
-- DROP TABLE person;
CREATE TABLE person
(
  person_id BIGINT   NOT NULL ,
  gender_concept_id INTEGER   NOT NULL ,
  year_of_birth INTEGER   NOT NULL ,
  month_of_birth INTEGER   NULL,
  day_of_birth INTEGER   NULL,
  birth_datetime TIMESTAMP NULL,
--   death_datetime TIMESTAMP NULL,
  race_concept_id INTEGER NOT NULL,
  ethnicity_concept_id INTEGER   NOT NULL,
  location_id BIGINT NULL,
  provider_id BIGINT NULL,
  care_site_id BIGINT NULL,
  person_source_value VARCHAR(50) NULL,
  gender_source_value VARCHAR(50) NULL,
  gender_source_concept_id   INTEGER NOT NULL,
  race_source_value VARCHAR(50) NULL,
  race_source_concept_id INTEGER NOT NULL,
  ethnicity_source_value VARCHAR(50) NULL,
  ethnicity_source_concept_id INTEGER NOT NULL
);
COPY person FROM 'C:/Users/USER/Downloads/synthea_cdm_csv/person.csv' WITH DELIMITER E',' CSV HEADER;
-- select * from person limit 10;
-- DROP TABLE visit_occurrence;
CREATE TABLE visit_occurrence
(
  visit_occurrence_id BIGINT NOT NULL ,
  person_id BIGINT NOT NULL ,
  visit_concept_id INTEGER NOT NULL ,
  visit_start_date DATE NULL ,
  visit_start_datetime TIMESTAMP NOT NULL ,
  visit_end_date DATE NULL ,
  visit_end_datetime TIMESTAMP NOT NULL ,
  visit_type_concept_id INTEGER NOT NULL ,
  provider_id BIGINT NULL,
  care_site_id BIGINT NULL,
  visit_source_value VARCHAR(50) NULL,
  visit_source_concept_id INTEGER NOT NULL ,
  admitted_from_concept_id      INTEGER     NOT NULL ,  
  admitted_from_source_value    VARCHAR(50) NULL ,
  discharge_to_source_value VARCHAR(50) NULL ,
  discharge_to_concept_id INTEGER   NULL ,
  preceding_visit_occurrence_id BIGINT NULL
);
COPY visit_occurrence FROM 'C:/Users/USER/Downloads/synthea_cdm_csv/visit_occurrence.csv' WITH DELIMITER E',' CSV HEADER;
-- select * from visit_occurrence limit 10;
--
-- 2.
-- 총 내원일수
create temp table los as
select person_id, sum(los) as total_los from (select person_id, visit_occurrence_id, (visit_end_date - visit_start_date + 1) as los from visit_occurrence)z group by person_id;
-- select * from los;
-- 최대값
select max(total_los) from los;
-- 최대값 환자수
select count(person_id) from los where total_los = (select max(total_los) from los);
--
-- 3.
-- 상병 이름
select dx.concept_name from
(select * from condition_occurrence) co
inner join
(select * from concept where lower(concept_name) like any (array['a%', 'b%', 'c%', 'd%']) and lower(concept_name) like '%heart%' and domain_id = 'Condition') dx
ON co.condition_concept_id = dx.concept_id;
--
-- 4. 
-- 복용일 긴 순으로 정렬
select drug_concept_id, start_date, end_date, end_date - start_date as duration from 
(select drug_concept_id, min(drug_exposure_start_date) as start_date, max(drug_exposure_end_date) as end_date from drug_exposure where person_id = 1891866 group by drug_concept_id)z 
order by duration desc;
-- 
-- 5. 
-- 약물 테이블 생성
create temp table drug_list as 
select drg.drug_concept_id, drg.concept_name, pct.cnt from drugs drg, prescription_count pct where drg.drug_concept_id = pct.drug_concept_id;
-- 두번째 약의 처방 건수가 첫번째 약의 처방 건수보다 더 많은 첫번째 약의 약품명을 처방건수 순으로 정렬
SELECT dl1.concept_name as drug1 FROM drug_pair dp 
INNER JOIN drug_list dl1 ON dp.drug_concept_id1 = dl1.drug_concept_id 
INNER JOIN drug_list dl2 ON dp.drug_concept_id2 = dl2.drug_concept_id
where dl1.cnt < dl2.cnt order by dl1.cnt desc;
-- 
-- 6.
-- 해당 환자수
SELECT count(distinct p.person_id) FROM (select person_id, CAST(year_of_birth || '-'|| month_of_birth|| '-'|| day_of_birth AS DATE) AS birth_date from person) p 
INNER JOIN (select person_id, condition_start_date as dm_date from condition_occurrence where condition_concept_id = any (array[3191208,36684827,3194332,3193274,43531010,4130162,45766052,45757474,4099651,4129519,4063043,4230254,4193704,4304377,201826,3194082,3192767])) dm ON p.person_id = dm.person_id and CAST(dm.dm_date - p.birth_date AS INT)/365 >= 18 
INNER JOIN (select person_id, drug_concept_id, drug_exposure_start_date, days_supply from drug_exposure where drug_concept_id = 40163924) mx ON p.person_id = mx.person_id and days_supply >= 90;
-- 
-- 7
-- 당뇨 약물 테이블 생성
create temp table dm_drug as 
select person_id, drug_concept_id, drug_exposure_start_date, 
CASE WHEN drug_concept_id = 19018935 THEN 'digoxin' 
WHEN drug_concept_id = 19075601 THEN 'clopidogrel' 
WHEN drug_concept_id = 1115171 THEN 'naproxen' 
ELSE 'simvastatin' 
END dm_drug_name 
from drug_exposure where drug_concept_id = any (array[19018935,1539411,1539463,1115171]);
-- 약물 처방 순서 테이블 생성
create temp table dm_drug_ord as 
select person_id, dm_drug_name, drug_exposure_start_date, ROW_NUMBER() OVER (PARTITION BY person_id, dm_drug_name order by person_id, drug_exposure_start_date) as ord from
(select person_id, dm_drug_name, drug_exposure_start_date from dm_drug group by person_id, dm_drug_name, drug_exposure_start_date order by person_id, drug_exposure_start_date)z;
-- 최초 약물 테이블 생성
create temp table dm_drug_ord_c as 
select * from dm_drug_ord where ord = 1 order by person_id, drug_exposure_start_date;
-- 의약품 처방이 변경된 패턴을 높은 빈도 순으로 나열
with dm_drug_ord_c_desc as(
select person_id, dm_drug_name, drug_exposure_start_date, ROW_NUMBER() OVER (PARTITION BY person_id order by person_id, drug_exposure_start_date) as num from dm_drug_ord_c)
select f.* from dm_drug_ord_c_desc f order by num desc;
-- 
