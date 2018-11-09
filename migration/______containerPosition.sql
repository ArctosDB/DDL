-- from https://github.com/ArctosDB/arctos/issues/1743

-- files using position






/Users/dlm/git/DDL/procedures/updateAllChildrenContainer.sql:




CREATE OR REPLACE procedure createContainer (....

CREATE OR REPLACE procedure updateContainer (....

CREATE OR REPLACE procedure containerContentCheck (


CREATE OR REPLACE procedure bulkUpdateContainer is ....

CREATE OR REPLACE procedure moveContainerByBarcode (

CREATE OR REPLACE procedure moveManyPartToContainer (


--- files calling createContainer
select barcode from container where container_type='freezer box' and POSITIONS_HOLD_CONTAINER_TYPE='cryovial';
select barcode from container where container_type='freezer box' and container_id not in (select parent_container_id from container);


/Users/dlm/git/arctos/EditContainer.cfm:

/Users/dlm/git/arctos/containerPositions.cfm:

/Users/dlm/git/arctos/EditContainer.cfm:
  

--- END files calling createContainer



update CTCONTAINER_TYPE set DESCRIPTION='Grid-mapped area. Cannot have barcode. Created only by position-handling forms from parent position data.' where container_type='position';

insert into CTCONTAINER_TYPE (container_type,DESCRIPTION) values ('')


-- clean up
select 
  c.container_type,
  decode(p.barcode,NULL,'no','yes') posnhasbarcode,
  count(*) c
from
  container c,
  container p
where
  p.parent_container_id=c.container_id and
  p.container_type='position'
group by
   c.container_type,
  decode(p.barcode,NULL,'no','yes')
order by
  c.container_type ;
  
  CONTAINER_TYPE						     POSNHASBA		C
------------------------------------------------------------ --------- ----------
cabinet 						     yes	       26
freezer 						     no 	      114
freezer 						     yes	      854
freezer box						     no 	   904360
freezer box						     yes	       14
freezer rack						     no 	       81
freezer rack						     yes	    10280
microplate						     yes	       96
range case						     yes	     1744
shelf							     yes	       64
slide box						     no 	    44999

insert into CTCONTAINER_TYPE (container_type,DESCRIPTION) values ('cabinet position','Area in/on a cabinet.');
update container set container_type='cabinet position' where container_type='position' and parent_container_id in (select container_id from container where container_type='cabinet');

insert into CTCONTAINER_TYPE (container_type,DESCRIPTION) values ('freezer position','Area in a freezer.');
update container set container_type='freezer position' where barcode is not null and container_type='position' and parent_container_id in (select container_id from container where container_type='freezer');

alter table CTCONTAINER_TYPE modify container_type varchar2(30);
alter table LOG_CTCONTAINER_TYPE modify n_container_type varchar2(30);
alter table LOG_CTCONTAINER_TYPE modify o_container_type varchar2(30);
alter table CONTAINER modify container_type varchar2(30);


insert into CTCONTAINER_TYPE (container_type,DESCRIPTION) values ('freezer rack position','Area (slot) in a freezer rack.');

update container set container_type='freezer rack position' where barcode is not null and container_type='position' and parent_container_id in (select container_id from container where container_type='freezer rack');

insert into CTCONTAINER_TYPE (container_type,DESCRIPTION) values ('microplate position','Area in a microplate.');
update container set container_type='microplate position' where barcode is not null and container_type='position' and parent_container_id in (select container_id from container where container_type='microplate');

insert into CTCONTAINER_TYPE (container_type,DESCRIPTION) values ('range case position','Area in/on a range case.');
update container set container_type='range case position' where barcode is not null and container_type='position' and parent_container_id in (select container_id from container where container_type='range case');

insert into CTCONTAINER_TYPE (container_type,DESCRIPTION) values ('shelf position','Area in/on a shelf.');
update container set container_type='shelf position' where barcode is not null and container_type='position' and parent_container_id in (select container_id from container where container_type='shelf');

update container set container_type='unknown' where barcode is not null and container_type='position' and parent_container_id in (select container_id from container where container_type='freezer box');

---
update container set container_type='unknown' where  container_type='position' and parent_container_id in (select container_id from container where container_type='bag');

alter table container add number_rows NUMBER;
alter table container add number_columns NUMBER;
alter table container add orientation varchar2(25);
alter table container add positions_hold_container_type varchar2(25);


alter table cf_temp_lbl2contr add number_rows NUMBER;
alter table cf_temp_lbl2contr add number_columns NUMBER;
alter table cf_temp_lbl2contr add orientation varchar2(25);
alter table cf_temp_lbl2contr add positions_hold_container_type varchar2(25);



ALTER TABLE container add CONSTRAINT fk_psn_hld_ctr_typ FOREIGN KEY (positions_hold_container_type) REFERENCES ctcontainer_type(container_type); 


CREATE OR REPLACE TRIGGER trg_cont_defdate BEFORE UPDATE OR INSERT ON CONTAINER ....


select distinct p.container_type from container p, container c where 
p.container_id=c.parent_container_id and
c.container_type='position';

create table temp_frzr_to_convert as
select * from (
select distinct 	
	p.container_id,
	p.barcode,
	p.institution_acronym,
	p.NUMBER_POSITIONS,
	count(c.container_id) numberActualPositions
from
	container p, 
	container c 
where 
	p.container_id=c.parent_container_id and
	c.container_type='position' and
	p.container_type='freezer'
group by
	p.container_id,
	p.NUMBER_POSITIONS,
	p.barcode,
	p.institution_acronym
)
where NUMBER_POSITIONS = numberActualPositions
;
	
update container set number_rows=11,number_columns=3,orientation='vertical' where container_id in (
	select container_id from temp_frzr_to_convert where NUMBER_POSITIONS=33
);
	
update container set positions_hold_container_type='freezer rack' where container_id in (
	select container_id from temp_frzr_to_convert 
);
	



update container set number_rows=12,number_columns=4,orientation='vertical' where container_id in (
	select container_id from temp_frzr_to_convert where NUMBER_POSITIONS=48
);
 

select * from (
  select distinct 	
	p.container_id,
	p.barcode,
	p.institution_acronym,
	p.NUMBER_POSITIONS,
	count(c.container_id) numberActualPositions
from
	container p, 
	container c 
where 
	p.container_id=c.parent_container_id and
	c.container_type='position' and
	p.container_type='slide box'
group by
	p.container_id,
	p.NUMBER_POSITIONS,
	p.barcode,
	p.institution_acronym  
)
where NUMBER_POSITIONS != numberActualPositions
;
    
-- fix the one...
select label from container where parent_container_id=14301169 order by to_number(label);

insert into container (
	CONTAINER_ID,
	PARENT_CONTAINER_ID,
	CONTAINER_TYPE,
	LABEL,
	WIDTH,
	HEIGHT,
	LENGTH,
	INSTITUTION_ACRONYM
) values (
	sq_container_id.nextval,
	14301169,
	'position',
	'1',
	3,
	27,
	78,
	'MSB'
);

create table temp_sb_to_convert as
select * from (
select distinct 	
	p.container_id,
	p.barcode,
	p.institution_acronym,
	p.NUMBER_POSITIONS,
	count(c.container_id) numberActualPositions
from
	container p, 
	container c 
where 
	p.container_id=c.parent_container_id and
	c.container_type='position' and
	p.container_type='slide box'
group by
	p.container_id,
	p.NUMBER_POSITIONS,
	p.barcode,
	p.institution_acronym
)
where NUMBER_POSITIONS = numberActualPositions
;

update container set number_rows=50,number_columns=2,orientation='vertical' where container_id in (
	select container_id from temp_sb_to_convert where NUMBER_POSITIONS=100
);

update container set positions_hold_container_type='slide' where container_id in (
	select container_id from temp_sb_to_convert 
);
	
-- freezer rack

create table temp_frzrk_to_convert as
select * from (
select distinct 	
	p.container_id,
	p.barcode,
	p.institution_acronym,
	p.NUMBER_POSITIONS,
	count(c.container_id) numberActualPositions
from
	container p, 
	container c 
where 
	p.container_id=c.parent_container_id and
	c.container_type='position' and
	p.container_type='freezer rack'
group by
	p.container_id,
	p.NUMBER_POSITIONS,
	p.barcode,
	p.institution_acronym
)
where NUMBER_POSITIONS = numberActualPositions
;

select distinct number_positions from temp_frzrk_to_convert;
-- oh, nevermind

-- freezer box

create table temp_frzbx_to_convert as
select * from (
select distinct 	
	p.container_id,
	p.barcode,
	p.institution_acronym,
	p.NUMBER_POSITIONS,
	count(c.container_id) numberActualPositions
from
	container p, 
	container c 
where 
	p.container_id=c.parent_container_id and
	c.container_type='position' and
	p.container_type='freezer box'
group by
	p.container_id,
	p.NUMBER_POSITIONS,
	p.barcode,
	p.institution_acronym
)
where NUMBER_POSITIONS = numberActualPositions
;

update container set number_rows=10,number_columns=10,orientation='horizontal' where container_id in (
	select container_id from temp_frzbx_to_convert where NUMBER_POSITIONS=100
);



update container set number_rows=5,number_columns=5,orientation='horizontal' where container_id in (
	select container_id from temp_frzbx_to_convert where NUMBER_POSITIONS=25
);


update container set number_rows=9,number_columns=9,orientation='horizontal' where container_id in (
	select container_id from temp_frzbx_to_convert where NUMBER_POSITIONS=81
);


update container set positions_hold_container_type='cryovial' where container_id in (
	select container_id from temp_frzbx_to_convert 
);



