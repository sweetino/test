-- 1. PostgreSQL 11 이상을 설치하고 csv로 제공된 데이터를 테이블로 입력합니다.
select version();
--"PostgreSQL 12.6, compiled by Visual C++ build 1914, 64-bit"
-- CREATE SCHEMA kis;
-- -- SQL shell (psql)
-- psql -U postgres -d postgres -a -f OMOP\ CDM\ ddl\ -\ PostgreSQL.sql
-- --
-- SET search_path to kis;
--
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
-- 2. visit_occurrence 테이블은 병원에 방문한 환자들의 방문식별번호(id), 병원 방문
-- 시작일자, 종료일자, 방문 타입(내원, 외래 등) 등 병원 방문과 관련된 정보를 포함하고
-- 있습니다. 내원일수는 환자가 요양기관을 방문하여 진료를 받은 일수이며, `내원일수
-- = 방문종료일자 - 방문시작일자 + 1` 으로 계산합니다. 모든 환자에 대해 총
-- 내원일수를 구하고 총 내원일수의 최대값과 총 내원일수 최대값을 가지는 환자수를
-- 찾는 쿼리를 작성합니다.
-- a. 방문시작일자는 visit_start_date, 방문종료일자는 visit_end_date 를
-- 사용합니다.
create temp table los as
select person_id, sum(los) as total_los from (select person_id, visit_occurrence_id, (visit_end_date - visit_start_date + 1) as los from visit_occurrence)z group by person_id;
-- 116496	22
-- 886110	574
-- 397813	16
-- 2165610	6
-- 1358074	27
-- 225206	10
-- 2348101	38
-- 1658282	26
-- 386051	14
-- 1691806	127
select * from los;
select max(total_los) from los;
-- 18873
select count(person_id) from los where total_los = (select max(total_los) from los);
-- 1
--
-- 3. 환자들이 진단 받은 상병 내역 중 첫글자는 (a,b,c,d,e) 문자로 시작하고 중간에 “heart”
-- 단어가 포함된 상병 이름을 찾으려고 합니다. condition_occurrence 테이블은 환자가
-- 병원 방문시 진단 받은 질환이 담겨있습니다. 상병코드는 condition_concept_id이고,
-- concept 테이블의 concept_id와 조인하여 상병 이름을 찾을 수 있습니다.
-- (concept_name 컬럼 사용)
-- a. 문자 검색시 대소문자를 구분하지 않습니다.
-- b. 상병 이름을 중복없이 나열합니다.
select dx.concept_name from
(select * from condition_occurrence) co
inner join
(select * from concept where lower(concept_name) like any (array['a%', 'b%', 'c%', 'd%']) and lower(concept_name) like '%heart%' and domain_id = 'Condition') dx
ON co.condition_concept_id = dx.concept_id;
--
-- 4. drug_exposure 테이블은 환자가 병원에서 처방받은 약의 종류와 처방시작일과
-- 종료일에 대한 정보를 포함하고 있습니다. 환자번호 ‘1891866’ 환자의 약 처방
-- 데이터에서 처방된 약의 종류별로 처음 시작일, 마지막 종료일, 복용일(마지막
-- 종료일과 처음시작일의 차이)을 구하고 복용일이 긴 순으로 정렬하여 테이블을
-- 생성합니다.
-- a. 환자번호 : person_id, 약의 종류 : drug_concept_id, 처방시작일 :
-- drug_exposure_start_date, 처방종료일 : drug_exposure_end_date
select drug_concept_id, start_date, end_date, end_date - start_date as duration from 
(select drug_concept_id, min(drug_exposure_start_date) as start_date, max(drug_exposure_end_date) as end_date from drug_exposure where person_id = 1891866 group by drug_concept_id)z order by duration desc;
-- 19009384	"1959-12-01"	"1998-10-06"	14189
-- 19030765	"1988-10-18"	"1998-10-05"	3639
-- 40213154	"1989-09-12"	"1998-07-07"	3220
-- 1539463	"1990-03-13"	"1998-03-11"	2920
-- 40213227	"1993-01-05"	"1993-01-05"	0
-- 
-- 5. drug_exposure 테이블은 환자가 병원에서 처방받은 약의 종류와 처방시작일과
-- 종료일에 대한 정보를 포함하고 있습니다. drug_exposure 테이블로부터 선택된
-- 15가지의 약 번호와 약품명이 저장된 첫번째 drugs 테이블이 있으며, 15가지 약 별로
-- drug_exposure에 저장된 처방건수가 저장된 두번째 prescription_count 테이블이
-- 있습니다. 마지막으로 drugs 테이블에 해당되는 15가지 약별로 가장 많이 처방되는
-- 약을 짝지어 놓은 drug_pair 테이블이 있습니다. 3개의 테이블을 사용하여 짝지어진
-- 두번째 약의 처방 건수가 첫번째 약의 처방 건수보다 더 많은 첫번째 약의 약품명을
-- 처방건수 순으로 출력합니다.
-- a. drugs : drug_concept_id(첫번째약 번호), concept_name(약품명)
-- b. prescription_count : drug_concept_id(첫번째약 번호), cnt(처방건수)
-- c. drug_pair : drug_concept_id1(첫번째약 번호), drug_concept_id2(두번째약
-- 번호)
-- d. 아래 쿼리를 활용하세요
create temp table drug_list as 
select drg.drug_concept_id, drg.concept_name, pct.cnt from drugs drg, prescription_count pct where drg.drug_concept_id = pct.drug_concept_id;

SELECT dl1.concept_name as drug1 FROM drug_pair dp 
INNER JOIN drug_list dl1 ON dp.drug_concept_id1 = dl1.drug_concept_id 
INNER JOIN drug_list dl2 ON dp.drug_concept_id2 = dl2.drug_concept_id
where dl1.cnt < dl2.cnt order by dl1.cnt desc;
-- "hydrochlorothiazide 25 MG Oral Tablet"
-- "amlodipine 5 MG / hydrochlorothiazide 12.5 MG / olmesartan medoxomil 20 MG Oral Tablet"
-- "atenolol 50 MG / chlorthalidone 25 MG Oral Tablet [Tenoretic]"
-- "120 ACTUAT fluticasone propionate 0.044 MG/ACTUAT Metered Dose Inhaler"
-- "simvastatin 20 MG Oral Tablet"
-- "amlodipine 5 MG Oral Tablet"
-- "24 HR metformin hydrochloride 500 MG Extended Release Oral Tablet"
-- "1 ML epoetin alfa 4000 UNT/ML Injection [Epogen]"
-- "hydrochlorothiazide 12.5 MG Oral Tablet"
-- "clopidogrel 75 MG Oral Tablet"
-- 
-- 6. 아래 조건에 모두 해당하는 환자수를 추출합니다.
-- a. 제 2형 당뇨병을 진단받은 환자 중에
-- i. 당뇨환자의 condition_concept_id 는 다음을 사용합니다.
-- 3191208,36684827,3194332,3193274,43531010,4130162,45766052,
-- 45757474,4099651,4129519,4063043,4230254,4193704,4304377,20
-- 1826,3194082,3192767
-- b. 18세 이상의 환자 중에
-- c. 진단을 받은 이후 Metformin을 90일 이상 복용한 환자수
-- i. drug_concept_id 는 40163924 를 사용합니다.
SELECT count(distinct p.person_id) FROM (select person_id, CAST(year_of_birth || '-'|| month_of_birth|| '-'|| day_of_birth AS DATE) AS birth_date from person) p 
INNER JOIN (select person_id, condition_start_date as dm_date from condition_occurrence where condition_concept_id = any (array[3191208,36684827,3194332,3193274,43531010,4130162,45766052,45757474,4099651,4129519,4063043,4230254,4193704,4304377,201826,3194082,3192767])) dm ON p.person_id = dm.person_id and CAST(dm.dm_date - p.birth_date AS INT)/365 >= 18 
INNER JOIN (select person_id, drug_concept_id, drug_exposure_start_date, days_supply from drug_exposure where drug_concept_id = 40163924) mx ON p.person_id = mx.person_id and days_supply >= 90;
-- 30
-- 6.a 항목(제 2형 당뇨병을 진단받은 환자)에서 추출한 환자군의 의약품 처방이 변경된
-- 패턴을 높은 빈도 순으로 나열합니다.
-- a. 같은 날 처방된 약은 한 그룹으로 묶습니다.
-- b. drug_concept_id는 다음을 사용합니다.
-- i. digoxin: 19018935
-- ii. simvastatin: 1539411,1539463
-- iii. clopidogrel: 19075601
-- iv. naproxen: 1115171
create temp table dm_drug as 
select person_id, drug_concept_id, drug_exposure_start_date, 
CASE WHEN drug_concept_id = 19018935 THEN 'digoxin' 
WHEN drug_concept_id = 19075601 THEN 'clopidogrel' 
WHEN drug_concept_id = 1115171 THEN 'naproxen' 
ELSE 'simvastatin' 
END dm_drug_name 
from drug_exposure where drug_concept_id = any (array[19018935,1539411,1539463,1115171]);

create temp table dm_drug_ord as 
select person_id, dm_drug_name, drug_exposure_start_date, ROW_NUMBER() OVER (PARTITION BY person_id, dm_drug_name order by person_id, drug_exposure_start_date) as ord from
(select person_id, dm_drug_name, drug_exposure_start_date from dm_drug group by person_id, dm_drug_name, drug_exposure_start_date order by person_id, drug_exposure_start_date)z;

create temp table dm_drug_ord_c as 
select * from dm_drug_ord where ord = 1 order by person_id, drug_exposure_start_date;

with dm_drug_ord_c_desc as(
select person_id, dm_drug_name, drug_exposure_start_date, ROW_NUMBER() OVER (PARTITION BY person_id order by person_id, drug_exposure_start_date) as num from dm_drug_ord_c)
select f.* from dm_drug_ord_c_desc f order by num desc;
-- 537462	"simvastatin"	"2020-04-04"	3
-- 1142083	"digoxin"	"2017-09-14"	3
-- 2742641	"naproxen"	"2018-07-02"	3
-- 2369278	"simvastatin"	"1991-04-26"	3
-- 450014	"simvastatin"	"2017-04-14"	3
-- 495905	"naproxen"	"2016-07-15"	3
-- 832694	"digoxin"	"2007-04-21"	3
-- 1944908	"simvastatin"	"2013-06-04"	2
-- 447852	"naproxen"	"2015-12-25"	2
-- 2435436	"simvastatin"	"2018-08-16"	2
-- 
