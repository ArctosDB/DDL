-- These scripts are roughly drawn from arctos_table_names and arctos_keys.
-- They should be exported as guides.
-- They should be updated if any questions arise, anything funky is detected here

-- SQL to extract a collection
-- order is important.

-- IMPORTANT NOTE: 
--    This does not get "all data"; it excludes some related data including
--      agents related to agents not otherwise involved in a collection are not (quite) "collection data" and so are not included here, for example.
--      search terms are not data
--      authorities
--      cached webservice data

-- cleanup from any previous runs

drop table tco_COLLECTION;
drop table tco_CATALOGED_ITEM;
drop table tco_ATTRIBUTES;
drop table tco_COLL_OBJ_OTHER_ID_NUM;
drop table tco_SPECIMEN_EVENT;
drop table tco_COLLECTING_EVENT;
drop table tco_LOCALITY;
drop table tco_GEOG_AUTH_REC;
drop table tco_CITATION;
drop table tco_PUBLICATION;
drop table tco_PUBLICATION_AGENT;
drop table tco_MEDIA_RELATIONS;
drop table tco_MEDIA;
drop table tco_MEDIA_LABELS;
drop table tco_IDENTIFICATION;
drop table tco_IDENTIFICATION_AGENT;
drop table tco_IDENTIFICATION_TAXONOMY;
drop table tco_TAXON_NAME;
drop table tco_TAXON_TERM;
drop table tco_TRANS;
drop table tco_TRANS_AGENT;
drop table tco_ACCN;
drop table tco_LOAN;
drop table tco_LOAN_ITEM;
drop table tco_BORROW;
drop table tco_SHIPMENT;
drop table tco_PERMIT_TRANS;
drop table tco_PERMIT;
drop table tco_PROJECT_TRANS;
drop table tco_PROJECT;
drop table tco_PROJECT_AGENT;
drop table tco_PROJECT_PUBLICATION;
drop table tco_COLLECTOR;
drop table tco_SPECIMEN_PART;
drop table tco_SPECIMEN_PART_ATTRIBUTE;
drop table tco_COLL_OBJECT;
drop table tco_COLL_OBJECT_REMARK;
drop table tco_OBJECT_CONDITION;
drop table tco_AGENT;
drop table tco_ADDRESS;
drop table tco_AGENT_NAME;
drop table tco_AGENT_RELATIONS;




--COLLECTION
 create table tco_COLLECTION as select * from collection where guid_prefix like 'YOURTHINGHERE';
 
 --CATALOGED_ITEM
 create table tco_CATALOGED_ITEM as select * from CATALOGED_ITEM where collection_id in (select collection_id from tco_COLLECTION);

 -- ATTRIBUTES
 create table tco_ATTRIBUTES as select * from ATTRIBUTES where collection_object_id in (select collection_object_id from tco_CATALOGED_ITEM);

-- COLL_OBJ_OTHER_ID_NUM
 create table tco_COLL_OBJ_OTHER_ID_NUM as select * from COLL_OBJ_OTHER_ID_NUM where collection_object_id in (select collection_object_id from tco_CATALOGED_ITEM);

-- SPECIMEN_EVENT
 create table tco_SPECIMEN_EVENT as select * from SPECIMEN_EVENT where collection_object_id in (select collection_object_id from tco_CATALOGED_ITEM);
-- COLLECTING_EVENT
 create table tco_COLLECTING_EVENT as select * from COLLECTING_EVENT where COLLECTING_EVENT_ID in (select COLLECTING_EVENT_ID from tco_SPECIMEN_EVENT);

-- LOCALITY
 create table tco_LOCALITY as select * from LOCALITY where LOCALITY_ID in (select LOCALITY_ID from tco_COLLECTING_EVENT);
 
-- GEOG_AUTH_REC
 create table tco_GEOG_AUTH_REC as select * from GEOG_AUTH_REC where GEOG_AUTH_REC_ID in (select GEOG_AUTH_REC_ID from tco_LOCALITY);

--CITATION
 create table tco_CITATION as select * from CITATION where collection_object_id in (select collection_object_id from tco_CATALOGED_ITEM);


-- MEDIA_RELATIONS
 create table tco_MEDIA_RELATIONS as select * from MEDIA_RELATIONS where MEDIA_RELATIONSHIP='shows cataloged_item' and RELATED_PRIMARY_KEY in (select collection_object_id from tco_CATALOGED_ITEM);
--MEDIA
 create table tco_MEDIA as select * from MEDIA where MEDIA_ID in (select MEDIA_ID from tco_MEDIA_RELATIONS);
-- MEDIA_LABELS
 create table tco_MEDIA_LABELS as select * from MEDIA_LABELS where MEDIA_ID in (select MEDIA_ID from tco_MEDIA_RELATIONS);




-- IDENTIFICATION
 create table tco_IDENTIFICATION as select * from IDENTIFICATION where collection_object_id in (select collection_object_id from tco_CATALOGED_ITEM);
-- IDENTIFICATION_AGENT
 create table tco_IDENTIFICATION_AGENT as select * from IDENTIFICATION_AGENT where IDENTIFICATION_ID in (select IDENTIFICATION_ID from tco_IDENTIFICATION);
-- IDENTIFICATION_TAXONOMY
 create table tco_IDENTIFICATION_TAXONOMY as select * from IDENTIFICATION_TAXONOMY where IDENTIFICATION_ID in (select IDENTIFICATION_ID from tco_IDENTIFICATION);
-- TAXON_NAME
 create table tco_TAXON_NAME as select * from TAXON_NAME where TAXON_NAME_ID in (select TAXON_NAME_ID from tco_IDENTIFICATION_TAXONOMY);
-- TAXON_TERM
 create table tco_TAXON_TERM as select * from TAXON_TERM where source='Arctos' and TAXON_NAME_ID in (select TAXON_NAME_ID from tco_IDENTIFICATION_TAXONOMY);
-- ^ that is slow look into better join



-- TRANS
 create table tco_TRANS as select * from TRANS where collection_id in (select collection_id from tco_COLLECTION);

 -- TRANS_AGENT
  create table tco_TRANS_AGENT as select * from TRANS_AGENT where transaction_id in (select transaction_id from tco_TRANS);



 -- ACCN
 create table tco_ACCN as select * from ACCN where transaction_id in (select transaction_id from tco_TRANS);


-- LOAN
 create table tco_LOAN as select * from LOAN where transaction_id in (select transaction_id from tco_TRANS);

alter table tco_LOAN drop column LOAN_NUM_PREFIX;
alter table tco_LOAN drop column LOAN_NUM;
alter table tco_LOAN drop column LOAN_NUM_SUFFIX;

-- LOAN_ITEM
create table tco_LOAN_ITEM as select * from LOAN_ITEM where transaction_id in (select transaction_id from tco_LOAN);


-- BORROW
create table tco_BORROW as select * from BORROW where transaction_id in (select transaction_id from tco_TRANS);

-- SHIPMENT
create table tco_SHIPMENT as select * from SHIPMENT where transaction_id in (select transaction_id from tco_TRANS);

-- PERMIT_TRANS
 create table tco_PERMIT_TRANS as select * from PERMIT_TRANS where transaction_id in (select transaction_id from tco_TRANS);

-- PERMIT
create table tco_PERMIT as select * from PERMIT where PERMIT_ID in (select PERMIT_ID from tco_PERMIT_TRANS);




-- PROJECT_TRANS
create table tco_PROJECT_TRANS as select * from PROJECT_TRANS where transaction_id in (select transaction_id from tco_TRANS);
-- PROJECT
create table tco_PROJECT as select * from PROJECT where PROJECT_ID in (select PROJECT_ID from tco_PROJECT_TRANS);



-- PROJECT_AGENT
create table tco_PROJECT_AGENT as select * from PROJECT_AGENT where PROJECT_ID in (select PROJECT_ID from tco_PROJECT);
-- PROJECT_PUBLICATION
create table tco_PROJECT_PUBLICATION as select * from PROJECT_PUBLICATION where PROJECT_ID in (select PROJECT_ID from tco_PROJECT);

create table tco_PUBLICATION as select * from PUBLICATION where PUBLICATION_ID in (
	select PUBLICATION_ID from tco_CITATION
 	union
 	select PUBLICATION_ID from tco_PROJECT_PUBLICATION
);

-- PUBLICATION

create table tco_PUBLICATION_AGENT as select * from PUBLICATION_AGENT where PUBLICATION_ID in (select PUBLICATION_ID from tco_PUBLICATION);

-- COLLECTOR
create table tco_COLLECTOR as select * from COLLECTOR where collection_object_id in (select collection_object_id from tco_CATALOGED_ITEM);

-- SPECIMEN_PART
create table tco_SPECIMEN_PART as select * from SPECIMEN_PART where derived_from_cat_item in (select collection_object_id from tco_CATALOGED_ITEM);
-- SPECIMEN_PART_ATTRIBUTE
create table tco_SPECIMEN_PART_ATTRIBUTE as select * from SPECIMEN_PART_ATTRIBUTE where collection_object_id in (select collection_object_id from tco_SPECIMEN_PART);

-- COLL_OBJECT
create table tco_COLL_OBJECT as select * from COLL_OBJECT where collection_object_id in (select collection_object_id from tco_SPECIMEN_PART union select collection_object_id from tco_CATALOGED_ITEM);

-- COLL_OBJECT_REMARK
create table tco_COLL_OBJECT_REMARK as select * from COLL_OBJECT_REMARK where collection_object_id in (select collection_object_id from tco_COLL_OBJECT);


-- OBJECT_CONDITION
create table tco_OBJECT_CONDITION as select * from OBJECT_CONDITION where collection_object_id in (select collection_object_id from tco_COLL_OBJECT);


-- AGENT
create table tco_AGENT as select * from AGENT where AGENT_ID in (
	select DETERMINED_BY_AGENT_ID from tco_ATTRIBUTES
	union
	select ASSIGNED_BY_AGENT_ID from tco_SPECIMEN_EVENT
	union
	select CREATED_BY_AGENT_ID from tco_MEDIA_RELATIONS
	union
	select ASSIGNED_BY_AGENT_ID from tco_MEDIA_LABELS
	union
	select AGENT_ID from tco_PUBLICATION_AGENT
	union
	select AGENT_ID from tco_IDENTIFICATION_AGENT
	union
	select AGENT_ID from tco_TRANS_AGENT
	union
	select RECONCILED_BY_PERSON_ID from tco_LOAN_ITEM
	union
	select ISSUED_BY_AGENT_ID from tco_PERMIT
	union
	select ISSUED_TO_AGENT_ID from tco_PERMIT
	union
	select CONTACT_AGENT_ID from tco_PERMIT
	union
	select AGENT_ID from tco_PROJECT_AGENT
	union
	select AGENT_ID from tco_COLLECTOR
	union
	select ENTERED_PERSON_ID from tco_COLL_OBJECT
	union
	select LAST_EDITED_PERSON_ID from tco_COLL_OBJECT
	union
	select DETERMINED_AGENT_ID from tco_OBJECT_CONDITION
	union
	select PACKED_BY_AGENT_ID from tco_SHIPMENT
	union
	select DETERMINED_BY_AGENT_ID from tco_SPECIMEN_PART_ATTRIBUTE
);


-- ADDRESS
create table tco_ADDRESS as select * from ADDRESS where AGENT_ID in (select AGENT_ID from tco_AGENT);
-- AGENT_NAME
create table tco_AGENT_NAME as select * from AGENT_NAME where AGENT_ID in (select AGENT_ID from tco_AGENT);
-- AGENT_RELATIONS
create table tco_AGENT_RELATIONS as select * from AGENT_RELATIONS where AGENT_ID in (select AGENT_ID from tco_AGENT);


-- download
-- just do this through CF until given a reason to do something fancier
-- links removed because github
-- copypasta download URL or whatever


tco_COLLECTION
tco_CATALOGED_ITEM
tco_ATTRIBUTES
tco_COLL_OBJ_OTHER_ID_NUM
tco_SPECIMEN_EVENT
tco_COLLECTING_EVENT
tco_LOCALITY
tco_GEOG_AUTH_REC
tco_CITATION
tco_PUBLICATION
tco_PUBLICATION_AGENT
tco_MEDIA_RELATIONS
tco_MEDIA
tco_MEDIA_LABELS
tco_IDENTIFICATION
tco_IDENTIFICATION_AGENT
tco_IDENTIFICATION_TAXONOMY
tco_TAXON_NAME
tco_TAXON_TERM
tco_TRANS
tco_TRANS_AGENT
tco_ACCN
tco_LOAN
tco_LOAN_ITEM
tco_BORROW
tco_SHIPMENT
tco_PERMIT_TRANS
tco_PERMIT
tco_PROJECT_TRANS
tco_PROJECT
tco_PROJECT_AGENT
tco_PROJECT_PUBLICATION
tco_COLLECTOR
tco_SPECIMEN_PART
tco_SPECIMEN_PART_ATTRIBUTE
tco_COLL_OBJECT
tco_COLL_OBJECT_REMARK
tco_OBJECT_CONDITION
tco_AGENT
tco_ADDRESS
tco_AGENT_NAME
tco_AGENT_RELATIONS
arctos_table_names
arctos_keys