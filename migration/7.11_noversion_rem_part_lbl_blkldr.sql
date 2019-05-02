-- https://github.com/ArctosDB/arctos/issues/2048
-- mitigate possible damage: remove container label from bulkloader

-- first find existing data, export as CSV, leave on Issue

-- this is what's posted on GH
-- one more last-minute capture
create table temp_bl_bc_lbl_chg1 as select * from temp_bl_bc_lbl_chg;
drop table temp_bl_bc_lbl_chg;

create table temp_bl_bc_lbl_chg (
  guid_prefix varchar2(255),
  editlink varchar2(255),
  part_barcode varchar2(255),
  part_container_label varchar2(255),
  part_number number)
;

set define off;
insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id,part_barcode_1,part_container_label_1,1 from bulkloader where part_container_label_1 is not null and part_barcode_1!=part_container_label_1);

insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id,part_barcode_2,part_container_label_2,2 from bulkloader where part_container_label_2 is not null and part_barcode_2!=part_container_label_2);

insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id,part_barcode_3,part_container_label_3,3 from bulkloader where part_container_label_3 is not null and part_barcode_3!=part_container_label_3);

insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id, part_barcode_4,part_container_label_4,4 from bulkloader where part_container_label_4 is not null and part_barcode_4!=part_container_label_4);


insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id, part_barcode_5,part_container_label_5,5 from bulkloader where part_container_label_5 is not null and part_barcode_5!=part_container_label_5);


insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id, part_barcode_6,part_container_label_6 ,6 from bulkloader where part_container_label_6 is not null and part_barcode_6!=part_container_label_6);



insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id, part_barcode_7,part_container_label_7,7 from bulkloader where part_container_label_7 is not null and part_barcode_7!=part_container_label_7);


insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id, part_barcode_8,part_container_label_8 ,8 from bulkloader where part_container_label_8 is not null and part_barcode_8!=part_container_label_8);


insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id,  part_barcode_9,part_container_label_9,9 from bulkloader where part_container_label_9 is not null and part_barcode_9!=part_container_label_9);


insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id,  part_barcode_10,part_container_label_10,10 from bulkloader where part_container_label_10 is not null and part_barcode_10!=part_container_label_10);

insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id, part_barcode_11,part_container_label_11,11 from bulkloader where part_container_label_11 is not null and part_barcode_11!=part_container_label_11);

insert into temp_bl_bc_lbl_chg (guid_prefix,editlink,part_barcode,part_container_label,part_number) (select guid_prefix,'http://arctos.database.museum/DataEntry.cfm?action=edit&ImAGod=yes&CFGRIDKEY=' || collection_object_id,  part_barcode_12,part_container_label_12,12 from bulkloader where part_container_label_12 is not null and part_barcode_12!=part_container_label_12);


create table bak_bulkloader20190430 as select * from bulkloader;

update bulkloader set part_container_label_1=null where part_container_label_1 is not null;
update bulkloader_stage set part_container_label_1=null where part_container_label_1 is not null;
alter table bulkloader drop column part_container_label_1;
alter table bulkloader_stage drop column part_container_label_1;

update bulkloader set part_container_label_2=null where part_container_label_2 is not null;
update bulkloader_stage set part_container_label_2=null where part_container_label_2 is not null;
alter table bulkloader drop column part_container_label_2;
alter table bulkloader_stage drop column part_container_label_2;


update bulkloader set part_container_label_3=null where part_container_label_3 is not null;
update bulkloader_stage set part_container_label_3=null where part_container_label_3 is not null;
alter table bulkloader drop column part_container_label_3;
alter table bulkloader_stage drop column part_container_label_3;


update bulkloader set part_container_label_4=null where part_container_label_4 is not null;
update bulkloader_stage set part_container_label_4=null where part_container_label_4 is not null;
alter table bulkloader drop column part_container_label_4;
alter table bulkloader_stage drop column part_container_label_4;


update bulkloader set part_container_label_5=null where part_container_label_5 is not null;
update bulkloader_stage set part_container_label_5=null where part_container_label_5 is not null;
alter table bulkloader drop column part_container_label_5;
alter table bulkloader_stage drop column part_container_label_5;


update bulkloader set part_container_label_6=null where part_container_label_6 is not null;
update bulkloader_stage set part_container_label_6=null where part_container_label_6 is not null;
alter table bulkloader drop column part_container_label_6;
alter table bulkloader_stage drop column part_container_label_6;


update bulkloader set part_container_label_7=null where part_container_label_7 is not null;
update bulkloader_stage set part_container_label_7=null where part_container_label_7 is not null;
alter table bulkloader drop column part_container_label_7;
alter table bulkloader_stage drop column part_container_label_7;


update bulkloader set part_container_label_8=null where part_container_label_8 is not null;
update bulkloader_stage set part_container_label_8=null where part_container_label_8 is not null;
alter table bulkloader drop column part_container_label_8;
alter table bulkloader_stage drop column part_container_label_8;


update bulkloader set part_container_label_9=null where part_container_label_9 is not null;
update bulkloader_stage set part_container_label_9=null where part_container_label_9 is not null;
alter table bulkloader drop column part_container_label_9;
alter table bulkloader_stage drop column part_container_label_9;


update bulkloader set part_container_label_10=null where part_container_label_10 is not null;
update bulkloader_stage set part_container_label_10=null where part_container_label_10 is not null;
alter table bulkloader drop column part_container_label_10;
alter table bulkloader_stage drop column part_container_label_10;


update bulkloader set part_container_label_11=null where part_container_label_11 is not null;
update bulkloader_stage set part_container_label_11=null where part_container_label_11 is not null;
alter table bulkloader drop column part_container_label_11;
alter table bulkloader_stage drop column part_container_label_11;


update bulkloader set part_container_label_12=null where part_container_label_12 is not null;
update bulkloader_stage set part_container_label_12=null where part_container_label_12 is not null;
alter table bulkloader drop column part_container_label_12;
alter table bulkloader_stage drop column part_container_label_12;


alter table pre_bulkloader drop column part_container_label_1;
alter table pre_bulkloader drop column part_container_label_2;
alter table pre_bulkloader drop column part_container_label_3;
alter table pre_bulkloader drop column part_container_label_4;
alter table pre_bulkloader drop column part_container_label_5;
alter table pre_bulkloader drop column part_container_label_6;
alter table pre_bulkloader drop column part_container_label_7;
alter table pre_bulkloader drop column part_container_label_8;
alter table pre_bulkloader drop column part_container_label_9;
alter table pre_bulkloader drop column part_container_label_10;
alter table pre_bulkloader drop column part_container_label_11;
alter table pre_bulkloader drop column part_container_label_12;









-----------p2
select 
	part_inst || '-->' || ctr_inst
from (
	select 
		p.institution_acronym part_inst,
		c.institution_acronym ctr_inst,
		c.container_type,
		c.container_id 
	from 
		container p, 
		container c 
	where 
		p.parent_container_id=c.container_id and 
		p.container_type='collection object' and 
	c.institution_acronym!=p.institution_acronym
)
group by
	part_inst,
	ctr_inst
;

PART_INST||'-->'||CTR_INST
------------------------------------------------------------------------------------------------------------------------
KWP-->UAM
DMNS-->MSB
DMNS-->UAM


--- DMNS parts in UAM containers
create table temp_dmns_p_uam_c as
select
	flat.guid,
	c.barcode,
	getContainerParentage(c.container_id) partCtrStk,
	specimen_part.collection_object_id partID,
	c.container_id part_container_id,
	specimen_part.part_name
from
	flat,
	specimen_part,
	coll_obj_cont_hist,
	container p,
	container c
where
	flat.collection_object_id=specimen_part.derived_from_cat_item and
	specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
	coll_obj_cont_hist.container_id=p.container_id and
	p.parent_container_id=c.container_id and
	c.institution_acronym='UAM' and
	p.institution_acronym='DMNS' 
;
	

--- MSB parts in MVZ containers
create table temp_msb_p_mvz_c as
select
	flat.guid,
	c.barcode,
	getContainerParentage(c.container_id) partCtrStk,
	specimen_part.collection_object_id partID,
	c.container_id part_container_id,
	specimen_part.part_name
from
	flat,
	specimen_part,
	coll_obj_cont_hist,
	container p,
	container c
where
	flat.collection_object_id=specimen_part.derived_from_cat_item and
	specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
	coll_obj_cont_hist.container_id=p.container_id and
	p.parent_container_id=c.container_id and
	c.institution_acronym='MVZ' and
	p.institution_acronym='MSB' 
;
	


--- UAM parts in MSB containers
create table temp_uam_p_msb_c as
select
	flat.guid,
	c.barcode,
	getContainerParentage(c.container_id) partCtrStk,
	specimen_part.collection_object_id partID,
	c.container_id part_container_id,
	specimen_part.part_name
from
	flat,
	specimen_part,
	coll_obj_cont_hist,
	container p,
	container c
where
	flat.collection_object_id=specimen_part.derived_from_cat_item and
	specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
	coll_obj_cont_hist.container_id=p.container_id and
	p.parent_container_id=c.container_id and
	c.institution_acronym='MSB' and
	p.institution_acronym='UAM' 
;
	


--- UAM parts in MVZ containers
create table temp_uam_p_mvz_c as
select
	flat.guid,
	c.barcode,
	getContainerParentage(c.container_id) partCtrStk,
	specimen_part.collection_object_id partID,
	c.container_id part_container_id,
	specimen_part.part_name
from
	flat,
	specimen_part,
	coll_obj_cont_hist,
	container p,
	container c
where
	flat.collection_object_id=specimen_part.derived_from_cat_item and
	specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
	coll_obj_cont_hist.container_id=p.container_id and
	p.parent_container_id=c.container_id and
	c.institution_acronym='MVZ' and
	p.institution_acronym='UAM' 
;
	
--- MVZ parts in UAM containers
create table temp_mvz_p_uam_c as
select
	flat.guid,
	c.barcode,
	getContainerParentage(c.container_id) partCtrStk,
	specimen_part.collection_object_id partID,
	c.container_id part_container_id,
	specimen_part.part_name
from
	flat,
	specimen_part,
	coll_obj_cont_hist,
	container p,
	container c
where
	flat.collection_object_id=specimen_part.derived_from_cat_item and
	specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
	coll_obj_cont_hist.container_id=p.container_id and
	p.parent_container_id=c.container_id and
	c.institution_acronym='UAM' and
	p.institution_acronym='MVZ' 
;
	
 and
(
	c.institution_acronym!='UAM' and p.institution_acronym!='KWP' or
	c.institution_acronym!='MSB' and p.institution_acronym!='DGR' or
	c.institution_acronym!='UAM' and p.institution_acronym!='UAMb' or
	c.institution_acronym!='UAM' and p.institution_acronym!='KNWR'
);



