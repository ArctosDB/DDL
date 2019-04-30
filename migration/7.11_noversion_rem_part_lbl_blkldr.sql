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











-----------p2
select 
c.institution_acronym,
p.institution_acronym,
c.container_type,
c.container_id from container p, container c where p.parent_container_id=c.container_id and p.container_type='collection object' and 
c.institution_acronym!=p.institution_acronym;
