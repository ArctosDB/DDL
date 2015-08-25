-- create mapping table for updating code table data.
CREATE TABLE migratect (
    TableName varchar2(30),
	ColumnName varchar2(30),
	DataTableName varchar2(30),
	CollectionCode varchar2(30),
	UsedByMVZ number(1),
	UsedByUAM number(1),
	ColumnValue varchar2(255),
	NewColumnValue varchar2(255),
    Description varchar2(255),
	NewDescription varchar2(255),
	CC varchar2(1000),
	DLM varchar2(1000),
	Comments varchar2(1000),
	NoChange number(1)
	);

/*
/home/lam/mvzora/mvzlprod/dump/20090121/migratect.ctl
LOAD DATA
INFILE *
INSERT INTO TABLE migratect
FIELDS TERMINATED BY "|"
TRAILING NULLCOLS
(
    TableName,
    ColumnName,
    DataTableName,
    CollectionCode,
    UsedByMVZ integer,
    UsedByUAM integer,
    ColumnValue,
    NewColumnValue,
    Description,
    NewDescription,
    CC char,
    DLM char,
    Comment char(1000),
    NoChange integer
)
begindata

sqlldr uam@mvzlprod control=migratect.ctl direct=true;
*/

create table migratect_mvz as 
	select * from migratect 
	where usedbymvz = 1 and nochange = 0;

select
'update ' || datatablename ||
' set ' ||  columnname || ' = ''' || newcolumnvalue ||
''' where ' || columnname || ' = ''' || columnvalue || ''';'
from migratect_mvz
order by datatablename, columnname

--these are in ct tables  and not in data.
CTACCN_TYPE: 'from USFW'
CTAGENT_RELATIONSHIP: 'bad duplicate of'
CTATTRIBUTE_TYPE: 
Egg     nest description
Egg     reproductive data
       
update ACCN set ACCN_TYPE = 'salvage' where ACCN_TYPE = 'salvaged';
update ACCN set ACCN_TYPE = 'legacy' where ACCN_TYPE = 'recataloged';
update ACCN set ACCN_TYPE = 'expedition' where ACCN_TYPE = 'MVZ expedition';
update ACCN set ACCN_TYPE = 'legacy' where ACCN_TYPE = 'no accession';

update AGENT_NAME set AGENT_NAME_TYPE = 'initials plus last' where AGENT_NAME_TYPE = 'second author';
update AGENT_NAME set AGENT_NAME_TYPE = 'abbreviation' where AGENT_NAME_TYPE = 'acronym';

update AGENT_RELATIONS set AGENT_RELATIONSHIP = 'spouse of' where AGENT_RELATIONSHIP = 'husband of';
update AGENT_RELATIONS set AGENT_RELATIONSHIP = 'spouse of' where AGENT_RELATIONSHIP = 'wife of';
update AGENT_RELATIONS set AGENT_RELATIONSHIP = 'parent of' where AGENT_RELATIONSHIP = 'father of';
update AGENT_RELATIONS set AGENT_RELATIONSHIP = 'parent of' where AGENT_RELATIONSHIP = 'mother of';
update AGENT_RELATIONS set AGENT_RELATIONSHIP = 'child of' where AGENT_RELATIONSHIP = 'daughter of';
update AGENT_RELATIONS set AGENT_RELATIONSHIP = 'child of' where AGENT_RELATIONSHIP = 'son of';

update BIOL_INDIV_RELATIONS set BIOL_INDIV_RELATIONSHIP = 'parent of' where BIOL_INDIV_RELATIONSHIP = 'mother of';
update BIOL_INDIV_RELATIONS set BIOL_INDIV_RELATIONSHIP = 'offspring of' where BIOL_INDIV_RELATIONSHIP = 'embryo of';
update BIOL_INDIV_RELATIONS set BIOL_INDIV_RELATIONSHIP = 'collected with' where BIOL_INDIV_RELATIONSHIP = 'in group with';

update COLLECTING_EVENT set COLLECTING_SOURCE = 'captive' where COLLECTING_SOURCE = 'breeder';
update COLLECTING_EVENT set COLLECTING_SOURCE = 'captive' where COLLECTING_SOURCE = 'lab';
update COLLECTING_EVENT set COLLECTING_SOURCE = 'captive' where COLLECTING_SOURCE = 'zoo';
update COLLECTING_EVENT set COLLECTING_SOURCE = 'captive' where COLLECTING_SOURCE = 'aviary';
update COLLECTING_EVENT set COLLECTING_SOURCE = 'field photo' where COLLECTING_SOURCE = 'photograph';

update COLLECTING_EVENT set COLLECTING_SOURCE = 'captive', COLL_EVENT_REMARKS = 'original collecting_source = ''game farm''; ' || COLL_EVENT_REMARKS where COLLECTING_SOURCE = 'game farm';
update COLLECTING_EVENT set COLLECTING_SOURCE = 'captive', COLL_EVENT_REMARKS = 'original collecting_source = ''supply company''; ' || COLL_EVENT_REMARKS where COLLECTING_SOURCE = 'supply company';
update COLLECTING_EVENT set COLLECTING_SOURCE = 'unknown', COLL_EVENT_REMARKS = 'original collecting_source = ''customs''; '  || COLL_EVENT_REMARKS where COLLECTING_SOURCE = 'customs';
update COLLECTING_EVENT set COLLECTING_SOURCE = 'captive', COLL_EVENT_REMARKS = 'original collecting_source = ''pet shop''; ' || COLL_EVENT_REMARKS where COLLECTING_SOURCE = 'pet shop';
update COLLECTING_EVENT set COLLECTING_SOURCE = 'captive', COLL_EVENT_REMARKS = 'original collecting_source = ''market''; ' || COLL_EVENT_REMARKS where COLLECTING_SOURCE = 'market';

update collecting_event
set coll_event_remarks = regexp_replace(coll_event_remarks,'; ','')                                                 
where coll_event_remarks like 'original collecting_source%; ';

update COLL_OBJECT set COLL_OBJ_DISPOSITION = 'discarded' where COLL_OBJ_DISPOSITION = 'destroyed';
update COLL_OBJECT set COLL_OBJ_DISPOSITION = 'in collection' where COLL_OBJ_DISPOSITION = 'in tissue collection';
update COLL_OBJECT set COLL_OBJ_DISPOSITION = 'in collection' where COLL_OBJ_DISPOSITION = 'archived';
update COLL_OBJECT set COLL_OBJ_DISPOSITION = 'missing' where COLL_OBJ_DISPOSITION = 'never received';
update COLL_OBJECT set COLL_OBJ_DISPOSITION = 'missing' where COLL_OBJ_DISPOSITION = 'lost';
update COLL_OBJECT set COLL_OBJ_DISPOSITION = 'transfer of custody' where COLL_OBJ_DISPOSITION = 'permanent loan';
update COLL_OBJECT set COLL_OBJ_DISPOSITION = 'transfer of custody' where COLL_OBJ_DISPOSITION = 'elsewhere';
update COLL_OBJECT set COLL_OBJ_DISPOSITION = 'unknown' where COLL_OBJ_DISPOSITION = 'not recorded';

update COLL_OBJECT_REMARK set DISPOSITION_REMARKS = 'Kept by collector; ' || DISPOSITION_REMARKS                    
where collection_object_id in (                                                                                     
    select COLLECTION_OBJECT_ID from COLL_OBJECT where COLL_OBJ_DISPOSITION = 'kept by collector');
    
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067054, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067056, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067058, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067062, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067064, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067066, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067068, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067070, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067083, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067088, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067090, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067092, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067094, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067096, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067098, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067100, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067102, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067104, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067106, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067108, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067110, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067112, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067114, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067116, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067118, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067120, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067122, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067124, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067126, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067128, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067130, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067132, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067134, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067136, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067138, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067140, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067148, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067150, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067152, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067154, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067156, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11067432, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11073267, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11087249, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11087251, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11090093, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319252, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319254, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319256, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319258, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319260, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319262, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319264, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319266, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319268, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319270, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319272, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319274, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319276, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319278, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319280, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319401, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319403, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319405, 'Kept by collector.');
insert into coll_object_remark (collection_object_id, disposition_remarks) values (11319409, 'Kept by collector.');

update COLL_OBJECT set COLL_OBJ_DISPOSITION = 'missing' where COLL_OBJ_DISPOSITION = 'kept by collector';

-- no records with flags = 'J' or 'none'
--update COLL_OBJECT set FLAGS = 'NULL' where FLAGS = 'J';
--update COLL_OBJECT set FLAGS = 'NULL' where FLAGS = 'none';
update COLL_OBJECT set FLAGS = 'NULL' where FLAGS = '0';

delete from ctflags where flags in ('0','J','none');
insert into ctflags values ('Tissue Flag');

update GEOG_AUTH_REC set ISLAND_GROUP = 'Aland Islands' where ISLAND_GROUP = 'Aland';

update GEOG_AUTH_REC set SOURCE_AUTHORITY = 'Museum of Vertebrate Zoology' where SOURCE_AUTHORITY = 'MVZ';

update IDENTIFICATION set NATURE_OF_ID = 'field' where NATURE_OF_ID = 'field ID';
update IDENTIFICATION set NATURE_OF_ID = 'geographic distribution' where NATURE_OF_ID = 'ssp. based on geog.';
update IDENTIFICATION set NATURE_OF_ID = 'geographic distribution' where NATURE_OF_ID = 'sp. based on geog.';
update IDENTIFICATION set NATURE_OF_ID = 'type specimen' where NATURE_OF_ID = 'type ID';
update IDENTIFICATION set NATURE_OF_ID = 'expert' where NATURE_OF_ID = 'expert ID';
update IDENTIFICATION set NATURE_OF_ID = 'molecular data' where NATURE_OF_ID = 'ID based on molecular data';
update IDENTIFICATION set NATURE_OF_ID = 'legacy' where NATURE_OF_ID = 'TAXIR';

update LAT_LONG set DATUM = 'North American Datum 1927' where DATUM = 'NAD27';
update LAT_LONG set DATUM = 'North American Datum 1983' where DATUM = 'NAD83';
update LAT_LONG set DATUM = 'unknown' where DATUM = 'not recorded';
update LAT_LONG set DATUM = 'World Geodetic System 1972' where DATUM = 'WGS72';
update LAT_LONG set DATUM = 'World Geodetic System 1984' where DATUM = 'WGS84';

update LAT_LONG set GEOREFMETHOD = 'MaNIS georeferencing guidelines' where GEOREFMETHOD = 'MaNIS Georeferencing Guidelines';

update LAT_LONG set VERIFICATIONSTATUS = 'verified by curator' where VERIFICATIONSTATUS = 'verified by curatorial staff';

--no data, so no changes made for permit_type
--update PERMIT set PERMIT_TYPE = 'take/possess' where PERMIT_TYPE = 'scientific collecting';

update TAXONOMY set INFRASPECIFIC_RANK = 'subsp.' where INFRASPECIFIC_RANK = 'subspecies';

update TAXONOMY set SOURCE_AUTHORITY = 'original description' where SOURCE_AUTHORITY = 'Type Citation';
update TAXONOMY set SOURCE_AUTHORITY = 'Museum of Vertebrate Zoology' where SOURCE_AUTHORITY = 'MVZ';

update ATTRIBUTES set ATTRIBUTE_VALUE = 'not recorded' where ATTRIBUTE_VALUE = 'unrecorded' and ATTRIBUTE_TYPE = 'age class';
update ATTRIBUTES set ATTRIBUTE_VALUE = 'metamorph' where ATTRIBUTE_VALUE = 'toadlet' and ATTRIBUTE_TYPE = 'age class';
update ATTRIBUTES set ATTRIBUTE_VALUE = 'metamorph' where ATTRIBUTE_VALUE = 'Metamorph' and ATTRIBUTE_TYPE = 'age class';
update ATTRIBUTES set ATTRIBUTE_VALUE = 'larva' where ATTRIBUTE_VALUE = 'larvae' and ATTRIBUTE_TYPE = 'age class';
update ATTRIBUTES set ATTRIBUTE_VALUE = 'larva' where ATTRIBUTE_VALUE = 'tadpole' and ATTRIBUTE_TYPE = 'age class';
update ATTRIBUTES set ATTRIBUTE_VALUE = 'juvenile' where ATTRIBUTE_VALUE = 'pup' and ATTRIBUTE_TYPE = 'age class';
--update ATTRIBUTES set ATTRIBUTE_VALUE = 'adult/juvenile' where ATTRIBUTE_VALUE = 'adult/juv.' and ATTRIBUTE_TYPE = 'age class';
update ATTRIBUTES set ATTRIBUTE_VALUE = 'egg' where ATTRIBUTE_VALUE = 'eggs' and ATTRIBUTE_TYPE = 'age class';
update ATTRIBUTES set ATTRIBUTE_VALUE = 'immature' where ATTRIBUTE_VALUE = 'imm' and ATTRIBUTE_TYPE = 'age class';
update ATTRIBUTES set ATTRIBUTE_VALUE = 'adult/juvenile' where ATTRIBUTE_VALUE = 'adult/ juv.' and ATTRIBUTE_TYPE = 'age class';
update ATTRIBUTES set ATTRIBUTE_VALUE = 'adult/juvenile' where ATTRIBUTE_VALUE = 'adult/juv.' and ATTRIBUTE_TYPE = 'age class';

update ATTRIBUTES set ATTRIBUTE_TYPE = 'soft part colors' where ATTRIBUTE_TYPE = 'colors' and collection_object_id in (
	select collection_object_id from cataloged_item where collection_cde = 'Bird');
	
update ATTRIBUTES set ATTRIBUTE_VALUE = 'adult' where ATTRIBUTE_VALUE = 'gravid adult' and ATTRIBUTE_TYPE = 'age class';
-- !!!add attribute value of "gravid" to reproductive data (check to see if values exist)
insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
    max(attribute_id) + 1, 11171167, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171168, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171169, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171421, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171428, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171461, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171120, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171121, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171144, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171146, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171282, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171283, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

insert into attributes (
    ATTRIBUTE_ID, COLLECTION_OBJECT_ID, DETERMINED_BY_AGENT_ID,
    ATTRIBUTE_TYPE, ATTRIBUTE_VALUE, ATTRIBUTE_REMARK, DETERMINED_DATE)
select
	max(attribute_id) + 1, 11171379, 14238,
    'reproductive data', 'gravid','from original age_class = ''gravid adult''', sysdate
from attributes;

-- no records vor collection_cde='Img' and attribute_type = 'sex'
--update ATTRIBUTES set ATTRIBUTE_TYPE = 'NULL' where ATTRIBUTE_TYPE = 'sex' and collection_object_id in (
--	select collection_object_id from cataloged_item where collection_cde = 'Img';
delete from ctattribute_type where collection_cde = 'Img' and attribute_type = 'sex';

-- bring data over and then move title data into media
delete from ctattribute_type where collection_cde IN ('Img', 'Page') and attribute_type = 'title';
	
delete from ATTRIBUTES where ATTRIBUTE_TYPE = 'karyotype slides flag';
delete from ctATTRIBUTE_TYPE where ATTRIBUTE_TYPE = 'karyotype slides flag';
	
update coll_obj_other_id_num
    set other_id_type = 'ACVC: Alameda County Vector Control'
    where other_id_type = 'Alameda County Vector Control (ACVC)';
update coll_obj_other_id_num
    set other_id_type = 'ADFG: Alaska Department of Fish and Game'
    where other_id_type = 'Alaska Department of Fish and Game Certification Number';
-- do not update ALAAC per DLM
--update coll_obj_other_id_num
--    set other_id_type = 'ALAAC: University of Alaska Museum Herbarium'
--    where other_id_type = 'ALAAC';
update coll_obj_other_id_num
    set other_id_type = 'AMMTAP: Alaska Marine Mammal Tissue Archival Project'
    where other_id_type = 'AMMTAP';
update coll_obj_other_id_num
    set other_id_type = 'AMNH: American Museum of Natural History'
    where other_id_type = 'American Museum of Natural History';
update coll_obj_other_id_num
    set other_id_type = 'AMNH: American Museum of Natural History'
    where other_id_type = 'AMNH';                                                                             
update coll_obj_other_id_num
    set other_id_type = 'Black Mountain Experimental Forest'
    where other_id_type = 'Black Mountain Experimental Forest ear tag';
update coll_obj_other_id_num
    set other_id_type = 'BMNH: Bell Museum of Natural History'
    where other_id_type = 'BMNH';
update coll_obj_other_id_num
    set other_id_type = 'BYU: Monte L. Bean Life Science Museum, Brigham Young University'
    where other_id_type = 'Monte L. Bean Life Science Museum, Brigham Young University';
update coll_obj_other_id_num
    set other_id_type = 'CAS: California Academy of Sciences (Stanford University), San Francisco'
    where other_id_type = 'California Academy of Sciences (Stanford University), San Francisco';
update coll_obj_other_id_num
    set other_id_type = 'CAS: California Academy of Sciences, San Francisco'
    where other_id_type = 'California Academy of Sciences, San Francisco';
update coll_obj_other_id_num
    set other_id_type = 'CAS: California Academy of Sciences, San Francisco'
    where other_id_type = 'CAS';
update coll_obj_other_id_num
    set other_id_type = 'CMNH: Carnegie Museum of Natural History'
    where other_id_type = 'Carnegie Museum of Natural History';
update coll_obj_other_id_num
    set other_id_type = 'CMNH: Carnegie Museum of Natural History'
    where other_id_type = 'CMNH';
update coll_obj_other_id_num
    set other_id_type = 'DNHM: Delaware Natural History Museum'
    where other_id_type = 'DNHM';
update coll_obj_other_id_num
    set other_id_type = 'ESRP: Endangered Species Recovery Program, California State University Stanislaus'
    where other_id_type = 'Endangered Species Recovery Program, CSU Stanislaus';
update coll_obj_other_id_num
    set other_id_type = 'ESRP: Endangered Species Recovery Program, California State University Stanislaus'
    where other_id_type = 'Kit Fox Recovery Project, ESRP, CSU Stanislaus';
update coll_obj_other_id_num
    set other_id_type = 'CNHM: Chicago Natural History Museum'
    where other_id_type = 'Chicago Natural History Museum';
update coll_obj_other_id_num
    set other_id_type = 'FMNH: Field Museum of Natural History'
    where other_id_type = 'Field Museum of Natural History';
update coll_obj_other_id_num
    set other_id_type = 'GenBank: GenBank DNA-sequence accession'
    where other_id_type = 'GenBank';
update coll_obj_other_id_num
    set other_id_type = 'IF: Idaho Frozen Tissue Collection'
    where other_id_type = 'IF';
update coll_obj_other_id_num
    set other_id_type = 'instititutional catalog number'
    where other_id_type = 'institutional catalog number';
update coll_obj_other_id_num
    set other_id_type = 'instititutional catalog number'
    where other_id_type = 'voucher catalog number';
update coll_obj_other_id_num
    set other_id_type = 'KSU: Kansas State University'
    where other_id_type = 'KSU';
update coll_obj_other_id_num
    set other_id_type = 'KUMNH: University of Kansas Museum of Natural History'
    where other_id_type = 'KU';
update coll_obj_other_id_num
    set other_id_type = 'KUMNH: University of Kansas Museum of Natural History'
    where other_id_type = 'KUMNH';
update coll_obj_other_id_num
    set other_id_type = 'KUMNH: University of Kansas Museum of Natural History'
    where other_id_type = 'University of Kansas Museum of Natural History';
update coll_obj_other_id_num
    set other_id_type = 'KUMNH: University of Kansas Museum of Natural History'
    where other_id_type = 'University of Kansas NHM';
update coll_obj_other_id_num
    set other_id_type = 'LACM: Los Angeles County Museum'
    where other_id_type = 'LACM';
update coll_obj_other_id_num
    set other_id_type = 'LACM: Los Angeles County Museum'
    where other_id_type = 'Los Angeles County Museum of Natural History';
update coll_obj_other_id_num
    set other_id_type = 'LMNM: Landesmuseum Natur und Mensch, Oldenburg, Germany'
    where other_id_type = 'LMNM';
update coll_obj_other_id_num
    set other_id_type = 'LSU: Louisiana State University Museum of Natural Science'
    where other_id_type = 'Louisiana State University Museum of Natural Science';
update coll_obj_other_id_num
    set other_id_type = 'LSU: Louisiana State University Museum of Natural Science'
    where other_id_type = 'LSU';
update coll_obj_other_id_num
    set other_id_type = 'LVNP: Lassen Volcanic National Park'
    where other_id_type = 'Lassen Volcanic National Park';
update coll_obj_other_id_num
    set other_id_type = 'LWH: Lindsay Wildlife Hospital'
    where other_id_type = 'Lindsay Wildlife Hospital';
update coll_obj_other_id_num
    set other_id_type = 'LWH: Lindsay Wildlife Hospital'
    where other_id_type = 'Lindsay Wildlife Museum';
update coll_obj_other_id_num
    set other_id_type = 'MCZ: Museum of Comparative Zoology, Harvard University'
    where other_id_type = 'Museum of Comparative Zoology, Harvard University';
update coll_obj_other_id_num
    set other_id_type = 'MSB: Museum of Southwestern Biology'
    where other_id_type = 'MSB';
update coll_obj_other_id_num
    set other_id_type = 'MSB: Museum of Southwestern Biology'
    where other_id_type = 'Museum of Southwestern Biology, University of New Mexico';
update coll_obj_other_id_num
    set other_id_type = 'Museum Zoologicum Bogoriense, Bogor, Indonesia: '
    where other_id_type = 'Museum Zoologicum Bogoriense, Bogor, Indonesia';
update coll_obj_other_id_num
    set other_id_type = 'MVZ: Museum of Vertebrate Zoology'
    where other_id_type = 'MVZ';
update coll_obj_other_id_num
    set other_id_type = 'NBSB: National Biomonitoring Specimen Bank'
    where other_id_type = 'NBSB';
update coll_obj_other_id_num
    set other_id_type = 'NCSM: North Carolina State Museum'
    where other_id_type = 'NCSM';
update coll_obj_other_id_num
    set other_id_type = 'New Mexico Museum of Natural History'
    where other_id_type = 'NMMNH';
update coll_obj_other_id_num
    set other_id_type = 'NMFS: United States National Marine Fisheries Service'
    where other_id_type = 'NMFS';
update coll_obj_other_id_num
    set other_id_type = 'NMSU: New Mexico State University'
    where other_id_type = 'NMSU';
update coll_obj_other_id_num
    set other_id_type = 'OMNH: Oklahoma Museum of Natural History'
    where other_id_type = 'Oklahoma Museum of Natural History';
update coll_obj_other_id_num
    set other_id_type = 'original identifier'
    where other_id_type = 'ear tag number';
update coll_obj_other_id_num
    set other_id_type = 'original identifier'
    where other_id_type = 'Hide Seal Number';
update coll_obj_other_id_num
    set other_id_type = 'original identifier'
    where other_id_type = 'Skull Seal Number';
update coll_obj_other_id_num
    set other_id_type = 'OSUM: Oregon State University Museum'
    where other_id_type = 'OSUM';
update coll_obj_other_id_num
    set other_id_type = 'OWMZ: Ohio Wesleyan Museum of Zoology'
    where other_id_type = 'OWMZ';
update coll_obj_other_id_num
    set other_id_type = 'PRBO: Point Reyes Bird Observatory'
    where other_id_type = 'Point Reyes Bird Observatory';
update coll_obj_other_id_num
    set other_id_type = 'RBCM: Royal British Columbia Museum, Victoria, BC, Canada.'
    where other_id_type = 'RBCM';
update coll_obj_other_id_num
    set other_id_type = 'ROM: Royal Ontario Museum Field Catalog Series'
    where other_id_type = 'Royal Ontario Museum Field Catalog Series';
update coll_obj_other_id_num
    set other_id_type = 'Rotterdam Zoo'
    where other_id_type = 'Rotterdam Zoo post-mortem number';
update coll_obj_other_id_num
    set other_id_type = 'San Diego Zoo'
    where other_id_type = 'San Diego Zoo, Dept. of Conservation and Research for Endangered  Species';
update coll_obj_other_id_num
    set other_id_type = 'SBMNH: Santa Barbara Museum of Natural History'
    where other_id_type = 'Santa Barbara Museum of Natural History';
update coll_obj_other_id_num
    set other_id_type = 'SDMNH: San Diego Musuem of Natural History'
    where other_id_type = 'San Diego Museum of Natural History (SDMNH)';
update coll_obj_other_id_num
    set other_id_type = 'SDSU: San Diego State University'
    where other_id_type = 'San Diego State University, Dept. Biology collection';
update coll_obj_other_id_num
    set other_id_type = 'NTU: National Taiwan University, Taipei'
    where other_id_type = 'Taiwan National University, Taipei';
update coll_obj_other_id_num
    set other_id_type = 'TCWC: Texas Cooperative Wildlife Collection, Texas A & M University'
    where other_id_type = 'Texas Cooperative Wildlife Collection, Texas A & M University';
update coll_obj_other_id_num
    set other_id_type = 'Texas Department of Fish and Game'
    where other_id_type = 'Department of Fish and Game';
update coll_obj_other_id_num
    set other_id_type = 'TTU: Texas Tech University'
    where other_id_type = 'Texas Tech University';
update coll_obj_other_id_num
    set other_id_type = 'UAM: University of Alaska Museum'
    where other_id_type = 'UAM';
update coll_obj_other_id_num
    set other_id_type = 'UAM: University of Alaska Museum'
    where other_id_type = 'UAM';
update coll_obj_other_id_num
    set other_id_type = 'UAM: University of Alaska Museum'
    where other_id_type = 'UAM Bryo ';
update coll_obj_other_id_num
    set other_id_type = 'UAZ: University of Arizona'
    where other_id_type = 'UAZ';
update coll_obj_other_id_num
    set other_id_type = 'UCB (ESPM): University of California Berkeley'
    where other_id_type = 'University of California Berkeley, Dept. ESPM Teaching Collection';
update coll_obj_other_id_num
    set other_id_type = 'UCLA: University of California Los Angeles'
    where other_id_type = 'Department of Biology, University of California, Los Angeles';
update coll_obj_other_id_num
    set other_id_type = 'UCMP: University of California Museum of Paleontology'
    where other_id_type = 'University of California Museum of Paleontology';
update coll_obj_other_id_num
    set other_id_type = 'UCSB: University of California Santa Barbara'
    where other_id_type = 'University of California Santa Barbara';
update coll_obj_other_id_num
    set other_id_type = 'UFC: University of Florida Collections'
    where other_id_type = 'UFC';
update coll_obj_other_id_num
    set other_id_type = 'UIMNH: University of Illinois Museum of Natural History'
    where other_id_type = 'UIMNH';
update coll_obj_other_id_num
    set other_id_type = 'UMMZ: University of Michigan Museum of Zoology'
    where other_id_type = 'UMMZ';
update coll_obj_other_id_num
    set other_id_type = 'UMMZ: University of Michigan Museum of Zoology'
    where other_id_type = 'Univ. Mich. Mus. Zool. Temporary Catalog';
update coll_obj_other_id_num
    set other_id_type = 'UMMZ: University of Michigan Museum of Zoology'
    where other_id_type = 'University of Michigan Museum of Zoology';
update coll_obj_other_id_num
    set other_id_type = 'UNAM: Universidad Nacional Autonoma de Mexico'
    where other_id_type = 'Universidad Nacional Autonoma de Mexico';
update coll_obj_other_id_num
    set other_id_type = 'UPS: University of Puget Sound, Tacoma, Washington'
    where other_id_type = 'University of Puget Sound, Tacoma, Washington';
update coll_obj_other_id_num
    set other_id_type = 'USFWS: U.S. Fish and Wildlife Service'
    where other_id_type = 'U.S. Fish and Wildlife Service Band No.';
update coll_obj_other_id_num
    set other_id_type = 'USGS: U.S. Geological Survey'
    where other_id_type = 'U.S. Geological Survey Palila Project';
update coll_obj_other_id_num
    set other_id_type = 'USGS: U.S. Geological Survey'
    where other_id_type = 'USGS catalog';
update coll_obj_other_id_num
    set other_id_type = 'USNM: National Museum of Natural History, Smithsonian Institution'
    where other_id_type = 'USNM';
update coll_obj_other_id_num
    set other_id_type = 'USNM: National Museum of Natural History, Smithsonian Institution'
    where other_id_type = 'National Museum of Natural History, Smithsonian Institution';
update coll_obj_other_id_num
    set other_id_type = 'USNM: National Museum of Natural History, Smithsonian Institution'
    where other_id_type = 'National Zoological Park, Smithsonian Institution';
update coll_obj_other_id_num
    set other_id_type = 'USNM: National Museum of Natural History, Smithsonian Institution'
    where other_id_type = 'NMNH';
update coll_obj_other_id_num
    set other_id_type = 'USNPC: United States National Parasite Collection'
    where other_id_type = 'USNPC';
update coll_obj_other_id_num
    set other_id_type = 'UWZM: University of Wisconsin Zoological Museum'
    where other_id_type = 'UWZM';
update coll_obj_other_id_num
    set other_id_type = 'WNMU: Western New Mexico University'
    where other_id_type = 'WNMU';
update coll_obj_other_id_num
    set other_id_type = 'YPM: Yale Peabody Museum'
    where other_id_type = 'YPM';
update coll_obj_other_id_num
    set other_id_type = 'ZIN: Zoological Institute, Russian Academy of Science'
    where other_id_type = 'ZIN';
update coll_obj_other_id_num
    set other_id_type = 'ZIN: Zoological Institute, Russian Academy of Science'
    where other_id_type = 'Zoological Institute St. Petersburg, Russia';
    
    
update ctcoll_other_id_type
    set description = 'Alameda County Vector Control'
    where other_id_type = 'ACVC: Alameda County Vector Control';
update ctcoll_other_id_type
    set description = 'Alaska Department of Fish and Game'
    where other_id_type = 'ADFG: Alaska Department of Fish and Game';
update ctcoll_other_id_type
    set description = 'University of Alaska Museum Herbarium'
    where other_id_type = 'ALAAC: University of Alaska Museum Herbarium';
update ctcoll_other_id_type
    set description = 'Alaska Marine Mammal Tissue Archival Project'
    where other_id_type = 'AMMTAP: Alaska Marine Mammal Tissue Archival Project';
update ctcoll_other_id_type
    set description = 'American Museum of Natural History'
    where other_id_type = 'AMNH: American Museum of Natural History';
update ctcoll_other_id_type
    set description = 'Bell Museum of Natural History'
    where other_id_type = 'BMNH: Bell Museum of Natural History';
update ctcoll_other_id_type
    set description = 'Monte L. Bean Life Science Museum, Brigham Young University'                           
    where other_id_type = 'BYU: Monte L. Bean Life Science Museum, Brigham Young University';
update ctcoll_other_id_type
    set description = 'California Academy of Sciences, San Francisco'
    where other_id_type = 'CAS: California Academy of Sciences, San Francisco';
update ctcoll_other_id_type
    set description = 'Carnegie Museum of Natural History'
    where other_id_type = 'CMNH: Carnegie Museum of Natural History';
update ctcoll_other_id_type
    set description = 'Old name for Field Museum of Natural History'
    where other_id_type = 'CNHM: Chicago Natural History Museum';
update ctcoll_other_id_type
    set description = 'Delaware Natural History Museum'
    where other_id_type = 'DNHM: Delaware Natural History Museum';
update ctcoll_other_id_type
    set description = 'Endangered Species Recovery Program, California State University Stanislaus'
    where other_id_type = 'ESRP: Endangered Species Recovery Program, California State University Stanislaus';
update ctcoll_other_id_type
    set description = 'Field Museum of Natural History'
    where other_id_type = 'FMNH: Field Museum of Natural History';
update ctcoll_other_id_type
    set description = 'GenBank DNA-sequence accession'
    where other_id_type = 'GenBank: GenBank DNA-sequence accession';
update ctcoll_other_id_type
    set description = 'Idaho Frozen Tissue Collection, University of Idaho at Pocatello.'
    where other_id_type = 'IF: Idaho Frozen Tissue Collection';
update ctcoll_other_id_type
    set description = 'Original catalog number assigned by the owning institution.'
    where other_id_type = 'instititutional catalog number';
update ctcoll_other_id_type
    set description = 'Kansas State University'
    where other_id_type = 'KSU: Kansas State University';
update ctcoll_other_id_type
    set description = 'University of Kansas Museum of Natural History'
    where other_id_type = 'KUMNH: University of Kansas Museum of Natural History';
update ctcoll_other_id_type
    set description = 'Landesmuseum Natur und Mensch, Oldenburg, Germany'
    where other_id_type = 'LMNM: Landesmuseum Natur und Mensch, Oldenburg, Germany';
update ctcoll_other_id_type
    set description = 'Los Angeles County Museum'
    where other_id_type = 'LACM: Los Angeles County Museum'
update ctcoll_other_id_type
    set description = 'Louisiana State University Museum of Natural Science'
    where other_id_type = 'LSU: Louisiana State University Museum of Natural Science';
update ctcoll_other_id_type
    set description = 'Lassen Volcanic National Park'
    where other_id_type = 'LVNP: Lassen Volcanic National Park';
update ctcoll_other_id_type
    set description = 'Lindsay Wildlife Hospital'
    where other_id_type = 'LWH: Lindsay Wildlife Hospital';
update ctcoll_other_id_type
    set description = 'Museum of Comparative Zoology, Harvard University'
    where other_id_type = 'MCZ: Museum of Comparative Zoology, Harvard University';
update ctcoll_other_id_type
    set description = 'Museum of Southwestern Biology, Albuquerque, New Mexico.'
    where other_id_type = 'MSB: Museum of Southwestern Biology';
update ctcoll_other_id_type
    set description = 'Museum of Vertebrate Zoology, University of California at Berkeley.'
    where other_id_type = 'MVZ: Museum of Vertebrate Zoology';
update ctcoll_other_id_type
    set description = 'National Biomonitoring Specimen Bank'
    where other_id_type = 'NBSB: National Biomonitoring Specimen Bank';
update ctcoll_other_id_type
    set description = 'North Carolina State Museum'
    where other_id_type = 'NCSM: North Carolina State Museum';
update ctcoll_other_id_type
    set description = 'New Mexico Museum of Natural History'
    where other_id_type = 'New Mexico Museum of Natural History';
update ctcoll_other_id_type
    set description = 'United States National Marine Fisheries Service.'
    where other_id_type = 'NMFS: United States National Marine Fisheries Service';
update ctcoll_other_id_type
    set description = 'New Mexico State University'
    where other_id_type = 'NMSU: New Mexico State University';
update ctcoll_other_id_type
    set description = 'Oklahoma Museum of Natural History'
    where other_id_type = 'OMNH: Oklahoma Museum of Natural History';
update ctcoll_other_id_type
    set description = 'Other values that link a specimen with its data. For example, label values applied by an agency project, or
 various values that are not known to be of a more defined identifier type.'
    where other_id_type = 'original identifier';
update ctcoll_other_id_type
    set description = 'Oregon State University Museum'
    where other_id_type = 'OSUM: Oregon State University Museum';
update ctcoll_other_id_type
    set description = 'Ohio Wesleyan Museum of Zoology'
    where other_id_type = 'OWMZ: Ohio Wesleyan Museum of Zoology';
update ctcoll_other_id_type
    set description = 'Point Reyes Bird Observatory'
    where other_id_type = 'PRBO: Point Reyes Bird Observatory';
update ctcoll_other_id_type
    set description = 'Royal British Columbia Museum, Victoria, BC, Canada.'
    where other_id_type = 'RBCM: Royal British Columbia Museum, Victoria, BC, Canada.';
update ctcoll_other_id_type
    set description = 'Royal Ontario Museum'
    where other_id_type = 'ROM: Royal Ontario Museum Field Catalog Series';
update ctcoll_other_id_type
    set description = 'Santa Barbara Museum of Natural History'
    where other_id_type = 'SBMNH: Santa Barbara Museum of Natural History';
update ctcoll_other_id_type
    set description = 'San Diego Musuem of Natural History'
    where other_id_type = 'SDMNH: San Diego Musuem of Natural History';
update ctcoll_other_id_type
    set description = 'San Diego State University'
    where other_id_type = 'SDSU: San Diego State University';
update ctcoll_other_id_type
    set description = 'Texas Cooperative Wildlife Collection, Texas A & M University'
    where other_id_type = 'TCWC: Texas Cooperative Wildlife Collection, Texas A & M University';
update ctcoll_other_id_type
    set description = 'Texas Tech University'
    where other_id_type = 'TTU: Texas Tech University';
update ctcoll_other_id_type
    set description = 'University of Alaska Museum'
    where other_id_type = 'UAM: University of Alaska Museum';
update ctcoll_other_id_type
    set description = 'University of Arizona'
    where other_id_type = 'UAZ: University of Arizona';
update ctcoll_other_id_type
    set description = 'University of California Berkeley, Dept. ESPM Teaching Collection'
    where other_id_type = 'UCB (ESPM): University of California Berkeley';
update ctcoll_other_id_type
    set description = 'University of California Los Angeles'
    where other_id_type = 'UCLA: University of California Los Angeles';
update ctcoll_other_id_type
    set description = 'University of California Museum of Paleontology'
    where other_id_type = 'UCMP: University of California Museum of Paleontology';
update ctcoll_other_id_type
    set description = 'University of California Santa Barbara'
    where other_id_type = 'UCSB: University of California Santa Barbara';
update ctcoll_other_id_type
    set description = 'University of Florida Collections'
    where other_id_type = 'UFC: University of Florida Collections';
update ctcoll_other_id_type
    set description = 'University of Illinois Museum of Natural History'
    where other_id_type = 'UIMNH: University of Illinois Museum of Natural History';
update ctcoll_other_id_type
    set description = 'University of Michigan Museum of Zoology'
    where other_id_type = 'UMMZ: University of Michigan Museum of Zoology';
update ctcoll_other_id_type
    set description = 'Universidad Nacional Autonoma de Mexico'
    where other_id_type = 'UNAM: Universidad Nacional Autonoma de Mexico';
update ctcoll_other_id_type
    set description = 'U.S. Fish and Wildlife Service Band No.'
    where other_id_type = 'USFWS: U.S. Fish and Wildlife Service';
update ctcoll_other_id_type
    set description = 'U.S. Geological Survey'
    where other_id_type = 'USGS: U.S. Geological Survey';
update ctcoll_other_id_type
    set description = 'National Museum of Natural History, Smithsonian Institution'
    where other_id_type = 'USNM: National Museum of Natural History, Smithsonian Institution';
update ctcoll_other_id_type
    set description = 'United States National Parasite Collection, U. S. Department of Agriculture, Beltsville, Maryland.'
    where other_id_type = 'USNPC: United States National Parasite Collection';
update ctcoll_other_id_type
    set description = 'University of Wisconsin Zoological Museum'
    where other_id_type = 'UWZM: University of Wisconsin Zoological Museum';
update ctcoll_other_id_type
    set description = 'Western New Mexico University'
    where other_id_type = 'WNMU: Western New Mexico University';
update ctcoll_other_id_type
    set description = 'Yale Peabody Museum'
    where other_id_type = 'YPM: Yale Peabody Museum';
update ctcoll_other_id_type
    set description = 'Zoological Institute, Russian Academy of Science, Saint Petersburg.'
    where other_id_type = 'ZIN: Zoological Institute, Russian Academy of Science';
 
DELETE FROM ctcoll_other_id_type 
WHERE collection_cde = 'Img' AND other_id_type = 'Original Image Number';

-- !!! ask Carla about ctcoll_other_id_type = 'Original Image Number'. 
-- note says to delete and bring over to media.

--UAM
update accn set ACCN_TYPE = 'salvage' where ACCN_TYPE = 'salvaged';

select count(*), accn_type from accn group by accn_type order by accn_type;
select accn_type from ctaccn_type order by accn_type;

update ctaccn_type set ACCN_TYPE = 'salvage' where ACCN_TYPE = 'salvaged';

update agent_name set AGENT_NAME_TYPE = 'abbreviation' where AGENT_NAME_TYPE = 'acronym';
update agent_name set AGENT_NAME_TYPE = 'full' where AGENT_NAME_TYPE = 'expanded';

select count(*), agent_name_type from agent_name group by agent_name_type order by agent_name_type;
select agent_name_type from ctagent_name_type group by agent_name_type order by agent_name_type;
delete from ctagent_name_type where AGENT_NAME_TYPE in ('acronym', 'expanded');

select agent_id, agent_name, agent_name_type from agent_name
group by agent_id, agent_name, agent_name_type
having count(*) > 1;

alter trigger ATTRIBUTE_DATA_CHECK disable;
alter trigger ATTRIBUTE_CT_CHECK disable;
alter trigger UP_FLAT_SEX disable;

update attributes set ATTRIBUTE_VALUE = 'juvenile' where ATTRIBUTE_TYPE = 'age class' and ATTRIBUTE_VALUE = 'pup';

update attributes set ATTRIBUTE_TYPE = 'bursa' where ATTRIBUTE_TYPE = 'bursa length' and collection_object_id in (select collection_object_id from cataloged_item where collection_cde = 'Bird');
update attributes set ATTRIBUTE_TYPE = 'soft part colors' where ATTRIBUTE_TYPE = 'colors' and collection_object_id in (select collection_object_id from cataloged_item where collection_cde = 'Bird');
update attributes set ATTRIBUTE_TYPE = 'weight' where ATTRIBUTE_TYPE = 'embryo weight' and collection_object_id in (select collection_object_id from cataloged_item where collection_cde = 'Bird');
update attributes set ATTRIBUTE_TYPE = 'wing span' where ATTRIBUTE_TYPE = 'extension' and collection_object_id in (select collection_object_id from cataloged_item where collection_cde = 'Bird');
update attributes set ATTRIBUTE_TYPE = 'soft part colors' where ATTRIBUTE_TYPE = 'soft parts' and collection_object_id in (select collection_object_id from cataloged_item where collection_cde = 'Bird');

alter trigger ATTRIBUTE_DATA_CHECK enable;
alter trigger ATTRIBUTE_CT_CHECK enable;
alter trigger UP_FLAT_SEX enable;

-- triggers not at uam prod
--alter trigger TI_BIOL_INDIV_RELATIONS disable;
--alter trigger TU_BIOL_INDIV_RELATIONS disable;
alter trigger RELATIONSHIP_CT_CHECK disable;
alter trigger UP_FLAT_RELN disable;

update biol_indiv_relations set BIOL_INDIV_RELATIONSHIP = 'offspring of' where BIOL_INDIV_RELATIONSHIP = 'embryo of';
update biol_indiv_relations set BIOL_INDIV_RELATIONSHIP = 'same individual as' where BIOL_INDIV_RELATIONSHIP = 'duplicate of';

--alter trigger TI_BIOL_INDIV_RELATIONS enable;
--alter trigger TU_BIOL_INDIV_RELATIONS enable;
alter trigger RELATIONSHIP_CT_CHECK enable;
alter trigger UP_FLAT_RELN enable;

select count(*), biol_indiv_relationship from biol_indiv_relations group by biol_indiv_relationship order by biol_indiv_relationship;
select biol_indiv_relationship from ctbiol_relations group by biol_indiv_relationship order by biol_indiv_relationship;

delete from ctbiol_relations where biol_indiv_relationship in ('embryo of', 'duplicate of')
insert into ctbiol_relations (BIOL_INDIV_RELATIONSHIP) values ('same individual as')

alter trigger A_FLAT_COLLEVNT disable;
alter trigger COLLECTING_EVENT_CT_CHECK enable;

update collecting_event set COLLECTING_SOURCE = 'captive' where COLLECTING_SOURCE = 'zoo';
update collecting_event set COLLECTING_SOURCE = 'captive' where COLLECTING_SOURCE = 'breeder';
update collecting_event set COLLECTING_SOURCE = 'captive' where COLLECTING_SOURCE = 'lab';

alter trigger A_FLAT_COLLEVNT enable;
alter trigger COLLECTING_EVENT_CT_CHECK enable;

select count(*), collecting_source from collecting_event group by collecting_source order by collecting_source;
select collecting_source from ctcollecting_source group by collecting_source order by collecting_source;

delete from ctcollecting_source where COLLECTING_SOURCE in ('breeder', 'lab', 'zoo');

insert into ctflags values ('Tissue Flag');

--alter trigger TD_GEOG_AUTH_REC disable;
--alter trigger TU_GEOG_AUTH_REC disable;
alter trigger UP_FLAT_GEOG disable;
alter trigger TRG_MK_HIGHER_GEOG disable;

update geog_auth_rec set SOURCE_AUTHORITY = 'University of Alaska Museum' where SOURCE_AUTHORITY = 'UAM';
update geog_auth_rec set SOURCE_AUTHORITY = 'Museum of Southwestern Biology' where SOURCE_AUTHORITY = 'MSB';

--alter trigger TD_GEOG_AUTH_REC enable;
--alter trigger TU_GEOG_AUTH_REC enable;
alter trigger UP_FLAT_GEOG enable;
alter trigger TRG_MK_HIGHER_GEOG enable;

select count(*), source_authority from geog_auth_rec group by source_authority order by source_authority;
select source_authority from ctgeog_source_authority group by source_authority order by source_authority;

update ctgeog_source_authority set SOURCE_AUTHORITY = 'University of Alaska Museum' where SOURCE_AUTHORITY = 'UAM';
insert into ctgeog_source_authority values ('Museum of Southwestern Biology');

alter trigger UP_FLAT_ID disable;
alter trigger IDENTIFICATION_CT_CHECK disable;

update identification set NATURE_OF_ID = 'type specimen' where NATURE_OF_ID = 'type ID';
update identification set NATURE_OF_ID = 'molecular data' where NATURE_OF_ID = 'ID based on molecular data';
update identification set NATURE_OF_ID = 'geographic distribution' where NATURE_OF_ID = 'ssp. based on geog.';
update identification set NATURE_OF_ID = 'legacy' where NATURE_OF_ID = 'ID to species group';
update identification set NATURE_OF_ID = 'legacy' where NATURE_OF_ID = 'student ID';
update identification set NATURE_OF_ID = 'expert' where NATURE_OF_ID = 'expert ID';
update identification set NATURE_OF_ID = 'field' where NATURE_OF_ID = 'field ID';
update identification set NATURE_OF_ID = 'geographic distribution' where NATURE_OF_ID = 'sp. based on geog.';

alter trigger UP_FLAT_ID enable;
alter trigger IDENTIFICATION_CT_CHECK enable;

select count(*), nature_of_id from identification group by nature_of_id order by nature_of_id;
select nature_of_id from ctnature_of_id order by nature_of_id;
delete from ctnature_of_id where nature_of_id in (
'type ID',
'ID based on molecular data',
'ssp. based on geog.',
'ID to species group',
'student ID',
'expert ID',
'field ID',
'sp. based on geog.');

insert into ctnature_of_id values ('type specimen','This particular specimen has been described in the literature by this name. The specimen record should contain a citation of the appropriate literature.');
insert into ctnature_of_id values ('molecular data','An identification made by a laboratory analysis comparing the specimen to related taxa by molecular criteria, generally DNA sequences.');
insert into ctnature_of_id values ('geographic distribution','Specimen has been identified to genus or species and is assumed, on the basis of known geographic ranges, to be the species or subspecies expected at the collecting locality. The specimen has not been identified to species or subspecies by comparing it to other subspecies within the genus or species.');
insert into ctnature_of_id values ('expert','The determiner is a person recognized by other experts working with the taxa in question, or the regional biota.');
insert into ctnature_of_id values ('field','A determination made by the collector or preparator without access to specialized equipment or references.');

--alter trigger TU_LAT_LONG disable;
alter trigger UPDATECOORDINATES disable;
alter trigger UP_FLAT_LAT_LONG disable;
alter trigger LAT_LONG_CT_CHECK disable;

update lat_long set DATUM = 'North American Datum 1927' where DATUM = 'North American 1927';

update lat_long set VERIFICATIONSTATUS = 'unverified' where VERIFICATIONSTATUS = 'incomplete';
update lat_long set VERIFICATIONSTATUS = 'unverified' where VERIFICATIONSTATUS = 'requires verification';

--alter trigger TU_LAT_LONG enable;
alter trigger UPDATECOORDINATES enable;
alter trigger UP_FLAT_LAT_LONG enable;
alter trigger LAT_LONG_CT_CHECK enable;

select count(*), datum from lat_long group by datum order by datum;
select datum from ctdatum group by datum order by datum;

select datum from lat_long where datum not in (select datum from ctdatum);
delete from ctdatum where DATUM = 'North American 1927';
-- !!! there are a number of datum values in the ct table that are not in data.

select count(*), verificationstatus from lat_long group by verificationstatus order by verificationstatus;
select verificationstatus from ctverificationstatus group by verificationstatus order by verificationstatus;

delete from ctVERIFICATIONSTATUS where VERIFICATIONSTATUS = 'incomplete';
delete from ctVERIFICATIONSTATUS where VERIFICATIONSTATUS = 'requires verification';
insert into ctverificationstatus (verificationstatus) values ('unverified');

--alter trigger TU_LOAN disable;
--alter trigger TD_LOAN disable;

update loan set LOAN_STATUS = 'open' where LOAN_STATUS = 'open in-house';
update loan set LOAN_STATUS = 'open' where LOAN_STATUS = 'partially returned';

--alter trigger TU_LOAN enable;
--alter trigger TD_LOAN enable;

select count(*), loan_status from loan group by loan_status order by loan_status;
select loan_status from ctloan_status group by loan_status order by loan_status;

delete from ctloan_status where loan_status in ('open in-house','partially returned');

alter trigger UP_FLAT_LOCALITY disable;
alter trigger LOCALITY_CT_CHECK disable;
--alter trigger TI_LOCALITY disable;

update locality set DEPTH_UNITS = 'meters' where DEPTH_UNITS = 'm';
update locality set DEPTH_UNITS = 'feet' where DEPTH_UNITS = 'ft';

alter trigger UP_FLAT_LOCALITY enable;
alter trigger LOCALITY_CT_CHECK enable;
--alter trigger TI_LOCALITY enable;

select count(*), depth_units from locality group by depth_units order by depth_units;
select depth_units from ctdepth_units group by depth_units order by depth_units;

update ctdepth_units set DEPTH_UNITS = 'meters' where DEPTH_UNITS = 'm';
update ctdepth_units set DEPTH_UNITS = 'feet' where DEPTH_UNITS = 'ft';

--alter trigger TD_PERMIT disable;
--alter trigger TI_PERMIT disable;

update permit set PERMIT_TYPE = 'transport' where PERMIT_TYPE = 'import/export';
update permit set PERMIT_TYPE = 'take/possess' where PERMIT_TYPE = 'collector''s hunt/fish/trap';
update permit set PERMIT_TYPE = 'take/possess' where PERMIT_TYPE = 'scientific collecting';

--alter trigger TD_PERMIT enable;
--alter trigger TI_PERMIT enable;

select count(*), permit_type from permit group by permit_type order by permit_type;
select permit_type from ctpermit_type group by permit_type order by permit_type;

update ctpermit_type set PERMIT_TYPE = 'transport' where PERMIT_TYPE = 'import/export';
update ctpermit_type set PERMIT_TYPE = 'take/possess' where PERMIT_TYPE = 'collector''s hunt/fish/trap';
delete from ctpermit_type where PERMIT_TYPE = 'scientific collecting';

update project_agent set PROJECT_AGENT_ROLE = 'Academic Advisor' where PROJECT_AGENT_ROLE = 'Major  Academic Advisor';

select count(*), project_agent_role from project_agent group by project_agent_role order by project_agent_role;
select project_agent_role from ctproject_agent_role group by project_agent_role order by project_agent_role;

update ctproject_agent_role set PROJECT_AGENT_ROLE = 'Academic Advisor' where PROJECT_AGENT_ROLE = 'Major  Academic Advisor';

alter table shipment modify SHIPPED_CARRIER_METHOD varchar2(25);

update shipment set SHIPPED_CARRIER_METHOD = 'Federal Express' where SHIPPED_CARRIER_METHOD = 'FedEx';
update shipment set SHIPPED_CARRIER_METHOD = 'hand-carried' where SHIPPED_CARRIER_METHOD = 'hand carried';
update shipment set SHIPPED_CARRIER_METHOD = 'U. S. Postal Service' where SHIPPED_CARRIER_METHOD = 'US Postal Service';
update shipment set SHIPPED_CARRIER_METHOD = 'United Parcel Service' where SHIPPED_CARRIER_METHOD = 'UPS';

select count(*), shipped_carrier_method from shipment group by shipped_carrier_method order by shipped_carrier_method;
select shipped_carrier_method from ctshipped_carrier_method order by shipped_carrier_method;

update ctSHIPPED_CARRIER_METHOD set SHIPPED_CARRIER_METHOD = 'Federal Express' where SHIPPED_CARRIER_METHOD = 'FedEx';
update ctSHIPPED_CARRIER_METHOD set SHIPPED_CARRIER_METHOD = 'hand-carried' where SHIPPED_CARRIER_METHOD = 'hand carried';
update ctSHIPPED_CARRIER_METHOD set SHIPPED_CARRIER_METHOD = 'U. S. Postal Service' where SHIPPED_CARRIER_METHOD = 'US Postal Service';
update ctSHIPPED_CARRIER_METHOD set SHIPPED_CARRIER_METHOD = 'United Parcel Service' where SHIPPED_CARRIER_METHOD = 'UPS';

alter trigger UPDATE_ID_AFTER_TAXON_CHANGE disable;
alter trigger TRG_MK_SCI_NAME disable;
alter trigger TRG_UP_TAX disable;
--alter trigger TD_TAXONOMY disable;

update taxonomy set SOURCE_AUTHORITY = 'The TIGR Reptile Database' where SOURCE_AUTHORITY = 'The EMBL Reptile database';
update taxonomy set SOURCE_AUTHORITY = 'University of Alaska Museum' where SOURCE_AUTHORITY = 'UAM';
update taxonomy set SOURCE_AUTHORITY = 'Museum of Southwestern Biology' where SOURCE_AUTHORITY = 'MSB';
update taxonomy set SOURCE_AUTHORITY = 'Flora of North America' where SOURCE_AUTHORITY = 'Flora of N. America';
--update taxonomy set SOURCE_AUTHORITY = 'American Ornithologists'' Union' where SOURCE_AUTHORITY = 'AOU Checklist, 2002';
--in data as 'AOU Checklist 2002' but in ct table as 'AOU Checklist, 2002'
update taxonomy set SOURCE_AUTHORITY = 'American Ornithologists'' Union' where SOURCE_AUTHORITY = 'AOU Checklist 2002';
update taxonomy set SOURCE_AUTHORITY = 'ALA Herbarium' where SOURCE_AUTHORITY = 'ALA';
update taxonomy set SOURCE_AUTHORITY = 'Mammals of North America (Hall 1981)' where SOURCE_AUTHORITY = 'Hall, 1981. Mammals of N. America';
-- source authority = 'MVZ' exists in data, and not in ct table.
update taxonomy set SOURCE_AUTHORITY = 'Museum of Vertebrate Zoology' where SOURCE_AUTHORITY = 'MVZ';


alter trigger UPDATE_ID_AFTER_TAXON_CHANGE enable;
alter trigger TRG_MK_SCI_NAME enable;
alter trigger TRG_UP_TAX enable;
--alter trigger TD_TAXONOMY enable;

select count(*), source_authority from taxonomy group by source_authority order by source_authority;
select source_authority from cttaxonomic_authority order by source_authority;

update cttaxonomic_authority set SOURCE_AUTHORITY = 'The TIGR Reptile Database' where SOURCE_AUTHORITY = 'The EMBL Reptile database';
update cttaxonomic_authority set SOURCE_AUTHORITY = 'University of Alaska Museum' where SOURCE_AUTHORITY = 'UAM';
update cttaxonomic_authority set SOURCE_AUTHORITY = 'Museum of Southwestern Biology' where SOURCE_AUTHORITY = 'MSB';
update cttaxonomic_authority set SOURCE_AUTHORITY = 'Flora of North America' where SOURCE_AUTHORITY = 'Flora of N. America';
update cttaxonomic_authority set SOURCE_AUTHORITY = 'American Ornithologists'' Union' where SOURCE_AUTHORITY = 'AOU Checklist, 2002';
update cttaxonomic_authority set SOURCE_AUTHORITY = 'ALA Herbarium' where SOURCE_AUTHORITY = 'ALA';
update cttaxonomic_authority set SOURCE_AUTHORITY = 'Mammals of North America (Hall 1981)' where SOURCE_AUTHORITY = 'Hall, 1981. Mammals of N. America';
INSERT INTO cttaxonomic_authority (source_authority) VALUES ('Museum of Vertebrate Zoology');

-- 'Flora of North America' exists in ct table, but not in data.

-- ignore for now.
--update trans_agent set TRANS_AGENT_ROLE = 'NULL' where TRANS_AGENT_ROLE = 'contact agent';

select count(*), trans_agent_role from trans_agent group by trans_agent_role order by trans_agent_role;
select trans_agent_role from cttrans_agent_role group by trans_agent_role order by trans_agent_role;

select count(*) || chr(9) || ci.collection_cde || chr(9) || co.other_id_type 
from coll_obj_other_id_num  co, cataloged_item ci
WHERE co.collection_object_id = ci.collection_object_id
group by ci.collection_cde, other_id_type order by ci.collection_cde, other_id_type

select collection_cde || chr(9) || other_id_type from ctcoll_other_id_type order by other_id_type;

select trigger_name from user_triggers 
where status = 'ENABLED' and table_name = 'COLL_OBJ_OTHER_ID_NUM';

--alter trigger TR_COLL_OBJ_OTHER_ID_NUM_SQ disable;
alter trigger COLL_OBJ_DISP_VAL disable;
alter trigger COLL_OBJ_DATA_CHECK disable;
alter trigger OTHER_ID_CT_CHECK disable;
alter trigger UP_FLAT_OTHERIDS disable;

update coll_obj_other_id_num
set other_id_type = 'ADFG: Alaska Department of Fish and Game'
where other_id_type = 'Alaska Department of Fish and Game Certification Number';

-- do not implement sez dusty
--update coll_obj_other_id_num
--set other_id_type = 'ALAAC: University of Alaska Museum Herbarium'
--where other_id_type = 'ALAAC';

update coll_obj_other_id_num
set other_id_type = 'AMMTAP: Alaska Marine Mammal Tissue Archival Project'
where other_id_type = 'AMMTAP';

update coll_obj_other_id_num
set other_id_type = 'AMNH: American Museum of Natural History'
where other_id_type = 'AMNH';

update coll_obj_other_id_num
set other_id_type = 'BMNH: Bell Museum of Natural History'
where other_id_type = 'BMNH';

update coll_obj_other_id_num
set other_id_type = 'CAS: California Academy of Sciences, San Francisco'
where other_id_type = 'CAS';

update coll_obj_other_id_num
set other_id_type = 'CMNH: Carnegie Museum of Natural History'
where other_id_type = 'CMNH';

update coll_obj_other_id_num
set other_id_type = 'DNHM: Delaware Natural History Museum'
where other_id_type = 'DNHM';

update coll_obj_other_id_num
set other_id_type = 'GenBank: GenBank DNA-sequence accession'
where other_id_type = 'GenBank';

update coll_obj_other_id_num
set other_id_type = 'IF: Idaho Frozen Tissue Collection'
where other_id_type = 'IF';

--update coll_obj_other_id_num
--set other_id_type = 'instititutional catalog number'
--where other_id_type = 'institutional catalog number';

update coll_obj_other_id_num
SET other_id_type = 'institutional catalog number'
WHERE other_id_type = 'instititutional catalog number';

update coll_obj_other_id_num
set other_id_type = 'instititutional catalog number'
where other_id_type = 'voucher catalog number';

update coll_obj_other_id_num
set other_id_type = 'KSU: Kansas State University'
where other_id_type = 'KSU';

update coll_obj_other_id_num
set other_id_type = 'KUMNH: University of Kansas Museum of Natural History'
where other_id_type = 'KU';

update coll_obj_other_id_num
set other_id_type = 'KUMNH: University of Kansas Museum of Natural History'
where other_id_type = 'KUMNH';

update coll_obj_other_id_num
set other_id_type = 'KUMNH: University of Kansas Museum of Natural History'
where other_id_type = 'University of Kansas NHM';

update coll_obj_other_id_num
set other_id_type = 'LACM: Los Angeles County Museum'
where other_id_type = 'LACM';

update coll_obj_other_id_num
set other_id_type = 'LMNM: Landesmuseum Natur und Mensch, Oldenburg, Germany'
where other_id_type = 'LMNM';

update coll_obj_other_id_num
set other_id_type = 'LSU: Louisiana State University Museum of Natural Science'
where other_id_type = 'LSU';

update coll_obj_other_id_num
set other_id_type = 'MSB: Museum of Southwestern Biology'
where other_id_type = 'MSB';

update coll_obj_other_id_num
set other_id_type = 'MVZ: Museum of Vertebrate Zoology'
where other_id_type = 'MVZ';

update coll_obj_other_id_num
set other_id_type = 'NBSB: National Biomonitoring Specimen Bank'
where other_id_type = 'NBSB';

update coll_obj_other_id_num
set other_id_type = 'NCSM: North Carolina State Museum'
where other_id_type = 'NCSM';

update coll_obj_other_id_num
set other_id_type = 'New Mexico Museum of Natural History'
where other_id_type = 'NMMNH';

update coll_obj_other_id_num
set other_id_type = 'NMFS: United States National Marine Fisheries Service'
where other_id_type = 'NMFS';

update coll_obj_other_id_num
set other_id_type = 'NMSU: New Mexico State University'
where other_id_type = 'NMSU';

update coll_obj_other_id_num
set other_id_type = 'original identifier'
where other_id_type = 'ear tag number';

update coll_obj_other_id_num
set other_id_type = 'original identifier'
where other_id_type = 'Hide Seal Number';

update coll_obj_other_id_num
set other_id_type = 'original identifier'
where other_id_type = 'Skull Seal Number';

update coll_obj_other_id_num
set other_id_type = 'OSUM: Oregon State University Museum'
where other_id_type = 'OSUM';

update coll_obj_other_id_num
set other_id_type = 'OWMZ: Ohio Wesleyan Museum of Zoology'
where other_id_type = 'OWMZ';

update coll_obj_other_id_num
set other_id_type = 'RBCM: Royal British Columbia Museum, Victoria, BC, Canada.'
where other_id_type = 'RBCM';

update coll_obj_other_id_num
set other_id_type = 'Texas Department of Fish and Game'
where other_id_type = 'Department of Fish and Game';

update coll_obj_other_id_num
set other_id_type = 'UAM: University of Alaska Museum'
where other_id_type = 'UAM';

update coll_obj_other_id_num
set other_id_type = 'UAM: University of Alaska Museum'
where other_id_type = 'UAM Bryo ';

update coll_obj_other_id_num
set other_id_type = 'UAZ: University of Arizona'
where other_id_type = 'UAZ';

update coll_obj_other_id_num
set other_id_type = 'UFC: University of Florida Collections'
where other_id_type = 'UFC';

update coll_obj_other_id_num
set other_id_type = 'UMMZ: University of Michigan Museum of Zoology'
where other_id_type = 'UMMZ';

update coll_obj_other_id_num
set other_id_type = 'USGS: U.S. Geological Survey'
where other_id_type = 'USGS catalog';

update coll_obj_other_id_num
set other_id_type = 'USNM: National Museum of Natural History, Smithsonian Institution'
where other_id_type = 'USNM';

update coll_obj_other_id_num
set other_id_type = 'USNM: National Museum of Natural History, Smithsonian Institution'
where other_id_type = 'NMNH';

update coll_obj_other_id_num
set other_id_type = 'USNPC: United States National Parasite Collection'
where other_id_type = 'USNPC';

update coll_obj_other_id_num
set other_id_type = 'UWZM: University of Wisconsin Zoological Museum'
where other_id_type = 'UWZM';

update coll_obj_other_id_num
set other_id_type = 'WNMU: Western New Mexico University'
where other_id_type = 'WNMU';

update coll_obj_other_id_num
set other_id_type = 'YPM: Yale Peabody Museum'
where other_id_type = 'YPM';

update coll_obj_other_id_num
set other_id_type = 'ZIN: Zoological Institute, Russian Academy of Science'
where other_id_type = 'ZIN';

update ctcoll_other_id_type
set other_id_type = 'ADFG: Alaska Department of Fish and Game'
where other_id_type = 'Alaska Department of Fish and Game Certification Number';

-- do not mess with ALAAC! sez Dusty
--update ctcoll_other_id_type
--set other_id_type = 'ALAAC: University of Alaska Museum Herbarium'set_type = 'ALAAC';

update ctcoll_other_id_type
set other_id_type = 'AMMTAP: Alaska Marine Mammal Tissue Archival Project'
where other_id_type = 'AMMTAP';

update ctcoll_other_id_type
set other_id_type = 'AMNH: American Museum of Natural History'
where other_id_type = 'AMNH';

update ctcoll_other_id_type
set other_id_type = 'BMNH: Bell Museum of Natural History'
where other_id_type = 'BMNH';

update ctcoll_other_id_type
set other_id_type = 'CAS: California Academy of Sciences, San Francisco'
where other_id_type = 'CAS';

update ctcoll_other_id_type
set other_id_type = 'CMNH: Carnegie Museum of Natural History'
where other_id_type = 'CMNH';

update ctcoll_other_id_type
set other_id_type = 'DNHM: Delaware Natural History Museum'
where other_id_type = 'DNHM';

update ctcoll_other_id_type
set other_id_type = 'IF: Idaho Frozen Tissue Collection'
where other_id_type = 'IF';

--update ctcoll_other_id_type
--set other_id_type = 'instititutional catalog number'
--where other_id_type = 'institutional catalog number';

update ctcoll_other_id_type
SET other_id_type = 'institutional catalog number'
set other_id_type = 'instititutional catalog number';

update ctcoll_other_id_type
set other_id_type = 'KSU: Kansas State University'
where other_id_type = 'KSU';

update ctcoll_other_id_type
set other_id_type = 'KUMNH: University of Kansas Museum of Natural History'
where other_id_type = 'KU';

delete from ctcoll_other_id_type where other_id_type = 'KUMNH';

delete from ctcoll_other_id_type where other_id_type = 'University of Kansas NHM';

update ctcoll_other_id_type
set other_id_type = 'LACM: Los Angeles County Museum'
where other_id_type = 'LACM';

update ctcoll_other_id_type
set other_id_type = 'LMNM: Landesmuseum Natur und Mensch, Oldenburg, Germany'
where other_id_type = 'LMNM';

update ctcoll_other_id_type
set other_id_type = 'LSU: Louisiana State University Museum of Natural Science'
where other_id_type = 'LSU';

update ctcoll_other_id_type
set other_id_type = 'MSB: Museum of Southwestern Biology'
where other_id_type = 'MSB';

update ctcoll_other_id_type
set other_id_type = 'MVZ: Museum of Vertebrate Zoology'
where other_id_type = 'MVZ';

update ctcoll_other_id_type
set other_id_type = 'NBSB: National Biomonitoring Specimen Bank'
where other_id_type = 'NBSB';

update ctcoll_other_id_type
set other_id_type = 'NCSM: North Carolina State Museum'
where other_id_type = 'NCSM';

update ctcoll_other_id_type
set other_id_type = 'New Mexico Museum of Natural History'
where other_id_type = 'NMMNH';

update ctcoll_other_id_type
set other_id_type = 'NMFS: United States National Marine Fisheries Service'
where other_id_type = 'NMFS';

update ctcoll_other_id_type
set other_id_type = 'NMSU: New Mexico State University'
where other_id_type = 'NMSU';

update ctcoll_other_id_type
set other_id_type = 'original identifier'
where other_id_type = 'ear tag number';

delete from ctcoll_other_id_type where other_id_type = 'Hide Seal Number';

delete from ctcoll_other_id_type where other_id_type = 'Skull Seal Number';

update ctcoll_other_id_type
set other_id_type = 'OSUM: Oregon State University Museum'
where other_id_type = 'OSUM';

update ctcoll_other_id_type
set other_id_type = 'OWMZ: Ohio Wesleyan Museum of Zoology'
where other_id_type = 'OWMZ';

update ctcoll_other_id_type
set other_id_type = 'RBCM: Royal British Columbia Museum, Victoria, BC, Canada.'
where other_id_type = 'RBCM';

update ctcoll_other_id_type
set other_id_type = 'Texas Department of Fish and Game'
where other_id_type = 'Department of Fish and Game';

update ctcoll_other_id_type
set other_id_type = 'UAM: University of Alaska Museum'
where other_id_type = 'UAM';

delete from ctcoll_other_id_type where other_id_type = 'UAM Bryo ';

update ctcoll_other_id_type
set other_id_type = 'UAZ: University of Arizona'
where other_id_type = 'UAZ';

update ctcoll_other_id_type
set other_id_type = 'UFC: University of Florida Collections'
where other_id_type = 'UFC';

update ctcoll_other_id_type
set other_id_type = 'UMMZ: University of Michigan Museum of Zoology'
where other_id_type = 'UMMZ';

update ctcoll_other_id_type
set other_id_type = 'USGS: U.S. Geological Survey'
where other_id_type = 'USGS catalog';

update ctcoll_other_id_type
set other_id_type = 'USNM: National Museum of Natural History, Smithsonian Institution'
where other_id_type = 'USNM';

delete from ctcoll_other_id_type where other_id_type = 'NMNH';

update ctcoll_other_id_type
set other_id_type = 'USNPC: United States National Parasite Collection'
where other_id_type = 'USNPC';

update ctcoll_other_id_type
set other_id_type = 'UWZM: University of Wisconsin Zoological Museum'
where other_id_type = 'UWZM';

update ctcoll_other_id_type
set other_id_type = 'WNMU: Western New Mexico University'
where other_id_type = 'WNMU';

update ctcoll_other_id_type
set other_id_type = 'YPM: Yale Peabody Museum'
where other_id_type = 'YPM';

update ctcoll_other_id_type
set other_id_type = 'ZIN: Zoological Institute, Russian Academy of Science'
where other_id_type = 'ZIN';

update ctcoll_other_id_type
set description = 'Alaska Department of Fish and Game'
where other_id_type = 'ADFG: Alaska Department of Fish and Game';

update ctcoll_other_id_type
set description = 'University of Alaska Museum Herbarium'
where other_id_type = 'ALAAC: University of Alaska Museum Herbarium';

update ctcoll_other_id_type
set description = 'Alaska Marine Mammal Tissue Archival Project'
where other_id_type = 'AMMTAP: Alaska Marine Mammal Tissue Archival Project';

update ctcoll_other_id_type
set description = 'American Museum of Natural History'
where other_id_type = 'AMNH: American Museum of Natural History';

update ctcoll_other_id_type
set description = 'Bell Museum of Natural History'
where other_id_type = 'BMNH: Bell Museum of Natural History';

update ctcoll_other_id_type
set description = 'California Academy of Sciences, San Francisco'
where other_id_type = 'CAS: California Academy of Sciences, San Francisco';

update ctcoll_other_id_type
set description = 'Carnegie Museum of Natural History'
where other_id_type = 'CMNH: Carnegie Museum of Natural History';

update ctcoll_other_id_type
set description = 'Delaware Natural History Museum'
where other_id_type = 'DNHM: Delaware Natural History Museum';

update ctcoll_other_id_type
set description = 'Idaho Frozen Tissue Collection, University of Idaho at Pocatello.'
where other_id_type = 'IF: Idaho Frozen Tissue Collection';

update ctcoll_other_id_type
set description = 'Original catalog number assigned by the owning institution.'
where other_id_type = 'instititutional catalog number';

update ctcoll_other_id_type
set description = 'Kansas State University'
where other_id_type = 'KSU: Kansas State University';

update ctcoll_other_id_type
set description = 'University of Kansas Museum of Natural History'
where other_id_type = 'KUMNH: University of Kansas Museum of Natural History';

update ctcoll_other_id_type
set description = 'Landesmuseum Natur und Mensch, Oldenburg, Germany'
where other_id_type = 'LMNM: Landesmuseum Natur und Mensch, Oldenburg, Germany';

update ctcoll_other_id_type
set description = 'Los Angeles County Museum'
where other_id_type = 'LACM: Los Angeles County Museum'

update ctcoll_other_id_type
set description = 'Louisiana State University Museum of Natural Science'
where other_id_type = 'LSU: Louisiana State University Museum of Natural Science';

update ctcoll_other_id_type
set description = 'Museum of Southwestern Biology, Albuquerque, New Mexico.'
where other_id_type = 'MSB: Museum of Southwestern Biology';

update ctcoll_other_id_type
set description = 'Museum of Vertebrate Zoology, University of California at Berkeley.'
where other_id_type = 'MVZ: Museum of Vertebrate Zoology';

update ctcoll_other_id_type
set description = 'National Biomonitoring Specimen Bank'
where other_id_type = 'NBSB: National Biomonitoring Specimen Bank';

update ctcoll_other_id_type
set description = 'North Carolina State Museum'
where other_id_type = 'NCSM: North Carolina State Museum';

update ctcoll_other_id_type
set description = 'New Mexico Museum of Natural History'
where other_id_type = 'New Mexico Museum of Natural History';

update ctcoll_other_id_type
set description = 'United States National Marine Fisheries Service.'
where other_id_type = 'NMFS: United States National Marine Fisheries Service';

update ctcoll_other_id_type
set description = 'New Mexico State University'
where other_id_type = 'NMSU: New Mexico State University';

update ctcoll_other_id_type
set description = 'Other values that link a specimen with its data. For example, label values applied by an agency project, or
various values that are not known to be of a more defined identifier type.'
where other_id_type = 'original identifier';

update ctcoll_other_id_type
set description = 'Oregon State University Museum'
where other_id_type = 'OSUM: Oregon State University Museum';

update ctcoll_other_id_type
set description = 'Ohio Wesleyan Museum of Zoology'
where other_id_type = 'OWMZ: Ohio Wesleyan Museum of Zoology';

update ctcoll_other_id_type
set description = 'Royal British Columbia Museum, Victoria, BC, Canada.'
where other_id_type = 'RBCM: Royal British Columbia Museum, Victoria, BC, Canada.';

update ctcoll_other_id_type
set description = 'University of Alaska Museum'
where other_id_type = 'UAM: University of Alaska Museum';

update ctcoll_other_id_type
set description = 'University of Arizona'
where other_id_type = 'UAZ: University of Arizona';

update ctcoll_other_id_type
set description = 'University of Florida Collections'
where other_id_type = 'UFC: University of Florida Collections';

update ctcoll_other_id_type
set description = 'University of Michigan Museum of Zoology'
where other_id_type = 'UMMZ: University of Michigan Museum of Zoology';

update ctcoll_other_id_type
set description = 'U.S. Geological Survey'
where other_id_type = 'USGS: U.S. Geological Survey';

update ctcoll_other_id_type
set description = 'National Museum of Natural History, Smithsonian Institution'
where other_id_type = 'USNM: National Museum of Natural History, Smithsonian Institution';

update ctcoll_other_id_type
set description = 'United States National Parasite Collection, U. S. Department of Agriculture, Beltsville, Maryland.'
where other_id_type = 'USNPC: United States National Parasite Collection';

update ctcoll_other_id_type
set description = 'University of Wisconsin Zoological Museum'
where other_id_type = 'UWZM: University of Wisconsin Zoological Museum';

update ctcoll_other_id_type
set description = 'Western New Mexico University'
where other_id_type = 'WNMU: Western New Mexico University';

update ctcoll_other_id_type
set description = 'Yale Peabody Museum'
where other_id_type = 'YPM: Yale Peabody Museum';

update ctcoll_other_id_type
set description = 'Zoological Institute, Russian Academy of Science, Saint Petersburg.'
where other_id_type = 'ZIN: Zoological Institute, Russian Academy of Science';

delete from  ctcoll_other_id_type where other_id_type = 'UIMNH';

insert into ctcoll_other_id_type values ('UIMNH: University of Illinois Museum of Natural History', 'Mamm', 'University of Illinois Museum of Natural History');

--alter trigger TR_COLL_OBJ_OTHER_ID_NUM_SQ enable;
alter trigger UP_FLAT_OTHERIDS enable;
alter trigger OTHER_ID_CT_CHECK enable;
alter trigger COLL_OBJ_DATA_CHECK enable;
alter trigger COLL_OBJ_DISP_VAL enable;

alter table CTCOLL_OTHER_ID_TYPE drop constraint PK_CTCOLL_OTHER_ID_TYPE;
ALTER TABLE ctcoll_other_id_type DROP COLUMN collection_cde;
alter table CTCOLL_OTHER_ID_TYPE 
    add constraint PK_CTCOLL_OTHER_ID_TYPE 
    primary key (OTHER_ID_TYPE);
    
select count(*)|| chr(9) || other_id_type 
from coll_obj_other_id_num
group by other_id_type 
order by other_id_type;

select other_id_type from ctcoll_other_id_type order by other_id_type;

select DISTINCT other_id_type 
from coll_obj_other_id_num
WHERE other_id_type NOT IN ( select other_id_type from ctcoll_other_id_type)
ORDER BY other_id_type;
    
update ctcoll_other_id_type 
set OTHER_ID_TYPE = 'GenBank: GenBank DNA-sequence accession' 
where OTHER_ID_TYPE = 'GenBank';

select DISTINCT other_id_type
from ctcoll_other_id_type
WHERE other_id_type NOT IN ( select other_id_type from coll_obj_other_id_num)
ORDER BY other_id_type;

DELETE FROM ctcoll_other_id_type
WHERE other_id_type IN (
'CBF: Coleccion Boliviana de Fauna',
'ear tag number',
'field number',
'secondary idenifier',
'voucher catalog number');

-- CT PKEYS
select 'alter table uam.' || table_name ||
chr(10) || chr(9) || ' add constraint PK_' || table_name ||
chr(10) || chr(9) || ' primary key (' || column_name || ')' ||chr(10) || chr(9) || ' tablespace uam_idx_1;'
    from user_tab_columns
    where table_name like 'CT%'
    and column_id = 1
    and table_name not in (
        select table_name
        from user_tab_columns
        where table_name like 'CT%'
        and column_id = 2)
    ORDER BY table_name, column_name

alter table uam.CTACCN_STATUS
         add constraint PK_CTACCN_STATUS
         primary key (ACCN_STATUS)
         using index tablespace uam_idx_1;

alter table uam.CTACCN_TYPE
         add constraint PK_CTACCN_TYPE
         primary key (ACCN_TYPE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTADDR_TYPE
         add constraint PK_CTADDR_TYPE
         primary key (ADDR_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTADDR_USE
         add constraint PK_CTADDR_USE
         primary key (ADDR_USE)
         using index tablespace uam_idx_1;

alter table uam.CTAGENT_ADDR_JOB_TITLE
         add constraint PK_CTAGENT_ADDR_JOB_TITLE
         primary key (JOB_TITLE)
         using index tablespace uam_idx_1;

alter table uam.CTAGENT_ADDR_TYPE
         add constraint PK_CTAGENT_ADDR_TYPE
         primary key (AGENT_ADDR_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTAGENT_NAME_TYPE
         add constraint PK_CTAGENT_NAME_TYPE
         primary key (AGENT_NAME_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTAGENT_RELATIONSHIP
         add constraint PK_CTAGENT_RELATIONSHIP
         primary key (AGENT_RELATIONSHIP)
         using index tablespace uam_idx_1;

alter table uam.CTAGENT_ROLE
         add constraint PK_CTAGENT_ROLE
         primary key (AGENT_ROLE)
         using index tablespace uam_idx_1;

alter table uam.CTAGENT_TYPE
         add constraint PK_CTAGENT_TYPE
         primary key (AGENT_TYPE)
         using index tablespace uam_idx_1;
         
-- this added specially after complaints from DLM.
--did not exist at prod
alter table ctattribute_code_tables 
    add constraint PK_ctattribute_code_tables
	primary key (ATTRIBUTE_TYPE)
	using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTBIN_OBJ_ASPECT
         add constraint PK_CTBIN_OBJ_ASPECT
         primary key (ASPECT)
         using index tablespace uam_idx_1;

alter table uam.CTBIOL_RELATIONS
         add constraint PK_CTBIOL_RELATIONS
         primary key (BIOL_INDIV_RELATIONSHIP)
         using index tablespace uam_idx_1;

alter table uam.CTBORROW_STATUS
         add constraint PK_CTBORROW_STATUS
         primary key (BORROW_STATUS)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTCF_LOAN_USE_TYPE
         add constraint PK_CTCF_LOAN_USE_TYPE
         primary key (USE_TYPE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTCOLLECTING_METHOD
         add constraint PK_CTCOLLECTING_METHOD
         primary key (COLLECTING_METHOD)
         using index tablespace uam_idx_1;

alter table uam.CTCOLLECTING_SOURCE
         add constraint PK_CTCOLLECTING_SOURCE
         primary key (COLLECTING_SOURCE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTCOLLECTION_CDE
         add constraint PK_CTCOLLECTION_CDE
         primary key (COLLECTION_CDE)
         using index tablespace uam_idx_1;

alter table uam.CTCOLLECTOR_ROLE
         add constraint PK_CTCOLLECTOR_ROLE
         primary key (COLLECTOR_ROLE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTCOLL_CONTACT_ROLE
         add constraint PK_CTCOLL_CONTACT_ROLE
         primary key (CONTACT_ROLE)
         using index tablespace uam_idx_1;

alter table uam.CTCOLL_OBJECT_TYPE
         add constraint PK_CTCOLL_OBJECT_TYPE
         primary key (COLL_OBJECT_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTCOLL_OBJ_DISP
         add constraint PK_CTCOLL_OBJ_DISP
         primary key (COLL_OBJ_DISPOSITION)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTCOLL_OBJ_FLAGS
         add constraint PK_CTCOLL_OBJ_FLAGS
         primary key (FLAGS)
         using index tablespace uam_idx_1;

alter table uam.CTCONTAINER_TYPE
         add constraint PK_CTCONTAINER_TYPE
         primary key (CONTAINER_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTCONTINENT
         add constraint PK_CTCONTINENT
         primary key (CONTINENT_OCEAN)
         using index tablespace uam_idx_1;

alter table uam.CTCORRESP_TYPE
         add constraint PK_CTCORRESP_TYPE
         primary key (CORRESP_TYPE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTDATUM
         add constraint PK_CTDATUM
         primary key (DATUM)
         using index tablespace uam_idx_1;

alter table uam.CTDEACCN_TYPE
         add constraint PK_CTDEACCN_TYPE
         primary key (DEACCN_TYPE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTDEPTH_UNITS
         add constraint PK_CTDEPTH_UNITS
         primary key (DEPTH_UNITS)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTDOWNLOAD_PURPOSE
         add constraint PK_CTDOWNLOAD_PURPOSE
         primary key (DOWNLOAD_PURPOSE)
         using index tablespace uam_idx_1;

alter table uam.CTEGG_NEST_COMBO
         add constraint PK_CTEGG_NEST_COMBO
         primary key (EGG_NEST_COMBO)
         using index tablespace uam_idx_1;

alter table uam.CTELECTRONIC_ADDR_TYPE
         add constraint PK_CTELECTRONIC_ADDR_TYPE
         primary key (ADDRESS_TYPE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTENCUMBRANCE_ACTION
         add constraint PK_CTENCUMBRANCE_ACTION
         primary key (ENCUMBRANCE_ACTION)
         using index tablespace uam_idx_1;

alter table uam.CTEW
         add constraint PK_CTEW
         primary key (E_OR_W)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTFEATURE
         add constraint PK_CTFEATURE
         primary key (FEATURE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTFLAGS
         add constraint PK_CTFLAGS
         primary key (FLAGS)
         using index tablespace uam_idx_1;

alter table uam.CTFLAG_YES_NO
         add constraint PK_CTFLAG_YES_NO
         primary key (STOREDVALUE)
         using index tablespace uam_idx_1;

alter table uam.CTFLAG_YES_NO_UNKNOWN
         add constraint PK_CTFLAG_YES_NO_UNKNOWN
         primary key (STOREDVALUE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTFLUID_CONCENTRATION
         add constraint PK_CTFLUID_CONCENTRATION
         primary key (CONCENTRATION)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTFLUID_TYPE
         add constraint PK_CTFLUID_TYPE
         primary key (FLUID_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTGEOG_SOURCE_AUTHORITY
         add constraint PK_CTGEOG_SOURCE_AUTHORITY
         primary key (SOURCE_AUTHORITY)
         using index tablespace uam_idx_1;

--!! this is view!
alter table uam.CTGEOLOGY_ATTRIBUTE
         add constraint PK_CTGEOLOGY_ATTRIBUTE
         primary key (GEOLOGY_ATTRIBUTE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTGEOREFMETHOD
         add constraint PK_CTGEOREFMETHOD
         primary key (GEOREFMETHOD)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTHABITAT_DESC
         add constraint PK_CTHABITAT_DESC
         primary key (HABITAT_DESC)
         using index tablespace uam_idx_1;

alter table uam.CTID_MODIFIER
         add constraint PK_CTID_MODIFIER
         primary key (IDENTIFICATION_MODIFIER)
         using index tablespace uam_idx_1;

alter table uam.CTIMAGE_CONTENT_TYPE
         add constraint PK_CTIMAGE_CONTENT_TYPE
         primary key (IMAGE_CONTENT_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTIMAGE_OBJECT_TYPE
         add constraint PK_CTIMAGE_OBJECT_TYPE
         primary key (IMAGE_TYPE)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTINFRASPECIFIC_RANK
         add constraint PK_CTINFRASPECIFIC_RANK
         primary key (INFRASPECIFIC_RANK)
         using index tablespace uam_idx_1;

alter table uam.CTISLAND_GROUP
         add constraint PK_CTISLAND_GROUP
         primary key (ISLAND_GROUP)
         using index tablespace uam_idx_1;

alter table uam.CTKARYO_STAIN_PROC
         add constraint PK_CTKARYO_STAIN_PROC
         primary key (KARYO_STAIN_PROC)
         using index tablespace uam_idx_1;

alter table uam.CTLAT_LONG_ERROR_UNITS
         add constraint PK_CTLAT_LONG_ERROR_UNITS
         primary key (LAT_LONG_ERROR_UNITS)
         using index tablespace uam_idx_1;

alter table uam.CTLAT_LONG_REF_SOURCE
         add constraint PK_CTLAT_LONG_REF_SOURCE
         primary key (LAT_LONG_REF_SOURCE)
         using index tablespace uam_idx_1;

alter table uam.CTLAT_LONG_UNITS
         add constraint PK_CTLAT_LONG_UNITS
         primary key (ORIG_LAT_LONG_UNITS)
         using index tablespace uam_idx_1;

alter table uam.CTLENGTH_UNITS
         add constraint PK_CTLENGTH_UNITS
         primary key (LENGTH_UNITS)
         using index tablespace uam_idx_1;

alter table uam.CTLEXICAL_RELATIONSHIP
         add constraint PK_CTLEXICAL_RELATIONSHIP
         primary key (LEXICAL_RELATIONSHIP)
         using index tablespace uam_idx_1;

--did not exist at prod
alter table uam.CTLOAN_INSTALLMENT_STATUS
         add constraint PK_CTLOAN_INSTALLMENT_STATUS
         primary key (LOAN_INSTALLMENT_STATUS)
         using index tablespace uam_idx_1;

alter table uam.CTLOAN_ITEM_STATUS
         add constraint PK_CTLOAN_ITEM_STATUS
         primary key (LOAN_ITEM_STATUS)
         using index tablespace uam_idx_1;

alter table uam.CTLOAN_STATUS
         add constraint PK_CTLOAN_STATUS
         primary key (LOAN_STATUS)
         using index tablespace uam_idx_1;

alter table uam.CTLOAN_TYPE
         add constraint PK_CTLOAN_TYPE
         primary key (LOAN_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTLOCALITY_SECTION_PART
         add constraint PK_CTLOCALITY_SECTION_PART
         primary key (SECTION_PART)
         using index tablespace uam_idx_1;

alter table uam.CTMEDIA_RELATIONSHIP
         add constraint PK_CTMEDIA_RELATIONSHIP
         primary key (MEDIA_RELATIONSHIP)
         using index tablespace uam_idx_1;

alter table uam.CTNS
         add constraint PK_CTNS
         primary key (N_OR_S)
         using index tablespace uam_idx_1;

alter table uam.CTNUMERIC_AGE_UNITS
         add constraint PK_CTNUMERIC_AGE_UNITS
         primary key (NUMERIC_AGE_UNITS)
         using index tablespace uam_idx_1;

alter table uam.CTORIG_ELEV_UNITS
         add constraint PK_CTORIG_ELEV_UNITS
         primary key (ORIG_ELEV_UNITS)
         using index tablespace uam_idx_1;

alter table uam.CTPERMIT_TYPE
         add constraint PK_CTPERMIT_TYPE
         primary key (PERMIT_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTPREFIX
         add constraint PK_CTPREFIX
         primary key (PREFIX)
         using index tablespace uam_idx_1;

alter table uam.CTPROJECT_AGENT_ROLE
         add constraint PK_CTPROJECT_AGENT_ROLE
         primary key (PROJECT_AGENT_ROLE)
         using index tablespace uam_idx_1;

alter table uam.CTPUBLICATION_TYPE
         add constraint PK_CTPUBLICATION_TYPE
         primary key (PUBLICATION_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTREFERENCERELATION
         add constraint PK_CTREFERENCERELATION
         primary key (RELATIONSHIP)
         using index tablespace uam_idx_1;

----did not exist at prod
alter table uam.CTREQUEST_STATUS
         add constraint PK_CTREQUEST_STATUS
         primary key (REQUEST_STATUS)
         using index tablespace uam_idx_1;

alter table uam.CTSECTION_TYPE
         add constraint PK_CTSECTION_TYPE
         primary key (FIELD_NOTE_SECT_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTSHIPMENT_CARRIER
         add constraint PK_CTSHIPMENT_CARRIER
         primary key (SHIPMENT_CARRIER_CDE)
         using index tablespace uam_idx_1;

alter table uam.CTSHIPMENT_STATUS
         add constraint PK_CTSHIPMENT_STATUS
         primary key (SHIPMENT_STATUS)
         using index tablespace uam_idx_1;

alter table uam.CTSHIPPED_CARRIER_METHOD
         add constraint PK_CTSHIPPED_CARRIER_METHOD
         primary key (SHIPPED_CARRIER_METHOD)
         using index tablespace uam_idx_1;

----did not exist at prod
alter table uam.CTSPECIMEN_PART_MODIFIER
         add constraint PK_CTSPECIMEN_PART_MODIFIER
         primary key (PART_MODIFIER)
         using index tablespace uam_idx_1;

alter table uam.CTSUFFIX
         add constraint PK_CTSUFFIX
         primary key (SUFFIX)
         using index tablespace uam_idx_1;
         
--did not exist at prod
alter table uam.CTTAXA_ROLE
         add constraint PK_CTTAXA_ROLE
         primary key (TAXA_ROLE)
         using index tablespace uam_idx_1;
         
--did not exist at prod
alter table uam.CTTAXON_VARIABLE
         add constraint PK_CTTAXON_VARIABLE
         primary key (TAXON_VARIABLE)
         using index tablespace uam_idx_1;

alter table uam.CTTRANSACTION_TYPE
         add constraint PK_CTTRANSACTION_TYPE
         primary key (TRANSACTION_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTURL_TYPE
         add constraint PK_CTURL_TYPE
         primary key (URL_TYPE)
         using index tablespace uam_idx_1;

alter table uam.CTWEIGHT_UNITS
         add constraint PK_CTWEIGHT_UNITS
         primary key (WEIGHT_UNITS)
         using index tablespace uam_idx_1;


begin
for tn in (
    select table_name
    from user_tables
    where table_name like 'CT%'
    and table_name in (
        select table_name
        from user_tab_columns
        where column_id = 2)
    order by table_name
) loop
    dbms_output.put_line ('alter table uam.' || tn.table_name ||
chr(10) || chr(9) || 'add constraint PK_' || tn.table_name ||
chr(10) || chr(9) || 'primary key (');
    for cn in (
        select column_name
        from user_tab_columns
        where table_name = tn.table_name
        order by column_name
    ) loop
        dbms_output.put_line (chr(9) || cn.column_name || ',');
    end loop;
    dbms_output.put_line (chr(9) || 'tablespace uam_idx_1;');
end loop;
end;
/

-- must manually edit results to remove extra comma.

--did not exist at prod
alter table uam.CTABUNDANCE
    add constraint PK_CTABUNDANCE
    primary key (COLLECTION_CDE, ABUNDANCE)
    using index tablespace uam_idx_1;

alter table uam.CTAGE_CLASS
    add constraint PK_CTAGE_CLASS
    primary key (AGE_CLASS, COLLECTION_CDE)
    using index tablespace uam_idx_1;

alter table uam.CTAGE_DET_METHOD
    add constraint PK_CTAGE_DET_METHOD
    primary key (AGE_DET_METH, COLLECTION_CDE)
    using index tablespace uam_idx_1;

--do not implement
--alter table uam.CTATTRIBUTE_CODE_TABLES
--    add constraint PK_CTATTRIBUTE_CODE_TABLES
--    primary key (ATTRIBUTE_TYPE, VALUE_CODE_TABLE, UNITS_CODE_TABLE)
--    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTATTRIBUTE_TYPE
    add constraint PK_CTATTRIBUTE_TYPE
    primary key (ATTRIBUTE_TYPE, COLLECTION_CDE)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTBIN_OBJ_SUBJECT
    add constraint PK_CTBIN_OBJ_SUBJECT
    primary key (SUBJECT)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTCASTE
    add constraint PK_CTCASTE
    primary key (COLLECTION_CDE, CASTE)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTCATALOGED_ITEM_TYPE
    add constraint PK_CTCATALOGED_ITEM_TYPE
    primary key (CATALOGED_ITEM_TYPE)
    using index tablespace uam_idx_1;

alter table uam.CTCITATION_TYPE_STATUS
    add constraint PK_CTCITATION_TYPE_STATUS
    primary key (TYPE_STATUS)
    using index tablespace uam_idx_1;

alter table uam.CTCLASS
    add constraint PK_CTCLASS
    primary key (PHYLCLASS)
    using index tablespace uam_idx_1;

alter table uam.CTCOLL_OTHER_ID_TYPE
    add constraint PK_CTCOLL_OTHER_ID_TYPE
    primary key (OTHER_ID_TYPE)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTCONTAINER_TYPE_SIZE
    add constraint PK_CTCONTAINER_TYPE_SIZE
    primary key (CONTAINER_TYPE, CONTAINER_SIZE)
    using index tablespace uam_idx_1;

alter table uam.CTHISTO_SECTION_ORIENT
    add constraint PK_CTHISTO_SECTION_ORIENT
    primary key (SECTION_ORIENTATION, COLLECTION_CDE)
    using index tablespace uam_idx_1;

alter table uam.CTHISTO_STAIN_PROC
    add constraint PK_CTHISTO_STAIN_PROC
    primary key (HISTO_STAIN_PROC, COLLECTION_CDE)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTKILL_METHOD
    add constraint PK_CTKILL_METHOD
    primary key (KILL_METHOD, COLLECTION_CDE)
    using index tablespace uam_idx_1;

-- table does not exist at prod.
alter table uam.CTL
    add constraint PK_CTL
    primary key (BARCODE, LABEL)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTMEDIA_LABEL
    add constraint PK_CTMEDIA_LABEL
    primary key (MEDIA_LABEL)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTMEDIA_TYPE
    add constraint PK_CTMEDIA_TYPE
    primary key (MEDIA_TYPE)
    using index tablespace uam_idx_1;

alter table uam.CTMIME_TYPE
    add constraint PK_CTMIME_TYPE
    primary key (MIME_TYPE)
    using index tablespace uam_idx_1;

alter table uam.CTNATURE_OF_ID
    add constraint PK_CTNATURE_OF_ID
    primary key (NATURE_OF_ID)
    using index tablespace uam_idx_1;

alter table uam.CTSEX_CDE
    add constraint PK_CTSEX_CDE
    primary key (SEX_CDE, COLLECTION_CDE)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTSPECIMEN_PART_LIST_ORDER
    add constraint PK_CTSPECIMEN_PART_LIST_ORDER
    primary key (PARTNAME, LIST_ORDER)
    using index tablespace uam_idx_1;

alter table uam.CTSPECIMEN_PART_NAME
    add constraint PK_CTSPECIMEN_PART_NAME
    primary key (PART_NAME, COLLECTION_CDE)
    using index tablespace uam_idx_1;

alter table uam.CTSPECIMEN_PRESERV_METHOD
    add constraint PK_CTSPECIMEN_PRESERV_METHOD
    primary key (PRESERVE_METHOD, COLLECTION_CDE)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTTAXA_FORMULA
    add constraint PK_CTTAXA_FORMULA
    primary key (TAXA_FORMULA)
    using index tablespace uam_idx_1;

alter table uam.CTTAXONOMIC_AUTHORITY
    add constraint PK_CTTAXONOMIC_AUTHORITY
    primary key (SOURCE_AUTHORITY)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTTAXON_RELATION
    add constraint PK_CTTAXON_RELATION
    primary key (TAXON_RELATIONSHIP)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTTRANS_AGENT_ROLE
    add constraint PK_CTTRANS_AGENT_ROLE
    primary key (TRANS_AGENT_ROLE)
    using index tablespace uam_idx_1;

-- not at prod
alter table uam.CTVERIFICATIONSTATUS
    add constraint PK_CTVERIFICATIONSTATUS
    primary key (VERIFICATIONSTATUS)
    using index tablespace uam_idx_1;

-- empty table. ctattribute_code_tables also exists with data.
drop table CT_ATTRIBUTE_CODE_TABLES;

select table_name
from user_tables
where table_name like 'CT%'
and table_name not in (
select table_name
from user_constraints where constraint_type = 'P')

TABLE_NAME
------------------------------
CTAGENT_ADDR_TYPE
CTLOAN_TYPE
CTYES_NO

ALTER TABLE CTAGENT_ADDR_TYPE
ADD CONSTRAINT PK_CTAGENT_ADDR_TYPE
PRIMARY KEY (AGENT_ADDR_TYPE);

ALTER TABLE CTLOAN_TYPE
ADD CONSTRAINT PK_CTLOAN_TYPE
PRIMARY KEY (LOAN_TYPE);

ALTER TABLE CTYES_NO
ADD CONSTRAINT PK_CTYES_NO
PRIMARY KEY (YES_OR_NO);

/* current pkeys on ct tables with only one column.
alter table CTACCN_STATUS drop constraint PKEY_CTACCN_STATUS;
alter table CTACCN_TYPE drop constraint PKEY_CTACCN_TYPE;
alter table CTADDR_USE drop constraint PKEY_CTADDR_USE;
alter table CTAGENT_ADDR_JOB_TITLE drop constraint PKEY_CTAGENT_ADDR_JOB_TITLE;
alter table CTAGENT_NAME_TYPE drop constraint PKEY_CTAGENT_NAME_TYPE;
alter table CTAGENT_RELATIONSHIP drop constraint PKEY_CTAGENT_RELATIONSHIP;
alter table CTAGENT_ROLE drop constraint PKEY_CTAGENT_ROLE;
alter table CTAGENT_TYPE drop constraint PKEY_CTAGENT_TYPE;
alter table CTAGE_CLASS drop constraint SYS_C0019302;
alter table CTAGE_DET_METHOD drop constraint SYS_C0019303;
alter table CTBIOL_RELATIONS drop constraint PKEY_CTBIOL_RELATIONS;
alter table CTBORROW_STATUS drop constraint PKEY_CTBORROW_STATUS;
alter table CTCITATION_TYPE_STATUS drop constraint PKEY_CTCITATION_TYPE_STATUS;
alter table CTCLASS drop constraint PKEY_CTCLASS;
alter table CTCOLLECTING_SOURCE drop constraint PKEY_CTCOLLECTING_SOURCE;
alter table CTCOLLECTOR_ROLE drop constraint PKEY_CTCOLLECTOR_ROLE;
alter table CTCOLL_OBJECT_TYPE drop constraint PKEY_CTCOLL_OBJECT_TYPE;
alter table CTCOLL_OBJ_DISP drop constraint PKEY_CTCOLL_OBJ_DISP;
alter table CTCONTAINER_TYPE drop constraint PKEY_CTCONTAINER_TYPE;
alter table CTCONTINENT drop constraint PKEY_CTCONTINENT;
alter table CTCORRESP_TYPE drop constraint PKEY_CTCORRESP_TYPE;
alter table CTDEACCN_TYPE drop constraint PKEY_CTDEACCN_TYPE;
alter table CTEGG_NEST_COMBO drop constraint PKEY_CTEGG_NEST_COMBO;
alter table CTELECTRONIC_ADDR_TYPE drop constraint PKEY_CTELECTRONIC_ADDR_TYPE;
alter table CTEW drop constraint PKEY_CTEW;
alter table CTFLAG_YES_NO drop constraint PKEY_CTFLAG_YES_NO;
alter table CTFLAG_YES_NO_UNKNOWN drop constraint PKEY_CTFLAG_YES_NO_UNKNOWN;
alter table CTGEOG_SOURCE_AUTHORITY drop constraint PKEY_CTGEOG_SOURCE_AUTHORITY;
alter table CTHISTO_SECTION_ORIENT drop constraint SYS_C0019323;
alter table CTHISTO_STAIN_PROC drop constraint SYS_C0019324;
alter table CTID_MODIFIER drop constraint PKEY_CTID_MODIFIER;
alter table CTIMAGE_CONTENT_TYPE drop constraint PKEY_CTIMAGE_CONTENT_TYPE;
alter table CTIMAGE_OBJECT_TYPE drop constraint PKEY_CTIMAGE_OBJECT_TYPE;
alter table CTISLAND_GROUP drop constraint PKEY_CTISLAND_GROUP;
alter table CTKARYO_STAIN_PROC drop constraint PKEY_CTKARYO_STAIN_PROC;
alter table CTLAT_LONG_ERROR_UNITS drop constraint PKEY_CTLAT_LONG_ERROR_UNITS;
alter table CTLAT_LONG_REF_SOURCE drop constraint PKEY_CTLAT_LONG_REF_SOURCE;
alter table CTLAT_LONG_UNITS drop constraint PKEY_CTLAT_LONG_UNITS;
alter table CTLENGTH_UNITS drop constraint PKEY_CTLENGTH_UNITS;
alter table CTLEXICAL_RELATIONSHIP drop constraint PKEY_CTLEXICAL_RELATIONSHIP;
alter table CTLOAN_ITEM_STATUS drop constraint PKEY_CTLOAN_ITEM_STATUS;
alter table CTLOAN_STATUS drop constraint PKEY_CTLOAN_STATUS;
alter table CTLOCALITY_SECTION_PART drop constraint PKEY_CTLOCALITY_SECTION_PART;
alter table CTMEDIA_RELATIONSHIP drop constraint PK_CTMEDIA_RELATIONSHIP;
alter table CTMIME_TYPE drop constraint PK_CTMIME_TYPE;
alter table CTNATURE_OF_ID drop constraint PKEY_CTNATURE_OF_ID;
alter table CTNS drop constraint PKEY_CTNS;
alter table CTNUMERIC_AGE_UNITS drop constraint PKEY_CTNUMERIC_AGE_UNITS;
alter table CTORIG_ELEV_UNITS drop constraint PKEY_CTORIG_ELEV_UNITS;
alter table CTPERMIT_TYPE drop constraint PKEY_CTPERMIT_TYPE;
alter table CTPREFIX drop constraint PKEY_CTPREFIX;
alter table CTPROJECT_AGENT_ROLE drop constraint PKEY_CTPROJECT_AGENT_ROLE;
alter table CTPUBLICATION_TYPE drop constraint PKEY_CTPUBLICATION_TYPE;
alter table CTREFERENCERELATION drop constraint PKEY_CTREFERENCERELATION;
alter table CTSECTION_TYPE drop constraint PKEY_CTSECTION_TYPE;
alter table CTSEX_CDE drop constraint SYS_C0019348;
alter table CTSHIPMENT_CARRIER drop constraint PKEY_CTSHIPMENT_CARRIER;
alter table CTSHIPMENT_STATUS drop constraint PKEY_CTSHIPMENT_STATUS;
alter table CTSHIPPED_CARRIER_METHOD drop constraint PKEY_CTSHIPPED_CARRIER_METHOD;
alter table CTSPECIMEN_PART_NAME drop constraint SYS_C0019352;
alter table CTSPECIMEN_PRESERV_METHOD drop constraint SYS_C0019353;
alter table CTSUFFIX drop constraint PKEY_CTSUFFIX;
alter table CTTAXONOMIC_AUTHORITY drop constraint PKEY_CTTAXONOMIC_AUTHORITY;
alter table CTTRANSACTION_TYPE drop constraint PKEY_CTTRANSACTION_TYPE;
alter table CTURL_TYPE drop constraint PKEY_CTURL_TYPE;
alter table CTWEIGHT_UNITS drop constraint PKEY_CTWEIGHT_UNITS;

ALTER TABLE UAM.CTACCN_STATUS
    ADD CONSTRAINT PKEY_CTACCN_STATUS
    PRIMARY KEY (ACCN_STATUS)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTACCN_TYPE
    ADD CONSTRAINT PKEY_CTACCN_TYPE
    PRIMARY KEY (ACCN_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTADDR_USE
    ADD CONSTRAINT PKEY_CTADDR_USE
    PRIMARY KEY (ADDR_USE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTAGENT_ADDR_JOB_TITLE
    ADD CONSTRAINT PKEY_CTAGENT_ADDR_JOB_TITLE
    PRIMARY KEY (JOB_TITLE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTAGENT_NAME_TYPE
    ADD CONSTRAINT PKEY_CTAGENT_NAME_TYPE
    PRIMARY KEY (AGENT_NAME_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTAGENT_RELATIONSHIP
    ADD CONSTRAINT PKEY_CTAGENT_RELATIONSHIP
    PRIMARY KEY (AGENT_RELATIONSHIP)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTAGENT_ROLE
    ADD CONSTRAINT PKEY_CTAGENT_ROLE
    PRIMARY KEY (AGENT_ROLE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTAGENT_TYPE
    ADD CONSTRAINT PKEY_CTAGENT_TYPE
    PRIMARY KEY (AGENT_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTBIOL_RELATIONS
    ADD CONSTRAINT PKEY_CTBIOL_RELATIONS
    PRIMARY KEY (BIOL_INDIV_RELATIONSHIP)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTBORROW_STATUS
    ADD CONSTRAINT PKEY_CTBORROW_STATUS
    PRIMARY KEY (BORROW_STATUS)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTCOLLECTING_SOURCE
    ADD CONSTRAINT PKEY_CTCOLLECTING_SOURCE
    PRIMARY KEY (COLLECTING_SOURCE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTCOLLECTOR_ROLE
    ADD CONSTRAINT PKEY_CTCOLLECTOR_ROLE
    PRIMARY KEY (COLLECTOR_ROLE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTCOLL_OBJECT_TYPE
    ADD CONSTRAINT PKEY_CTCOLL_OBJECT_TYPE
    PRIMARY KEY (COLL_OBJECT_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTCOLL_OBJ_DISP
    ADD CONSTRAINT PKEY_CTCOLL_OBJ_DISP
    PRIMARY KEY (COLL_OBJ_DISPOSITION)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTCONTAINER_TYPE
    ADD CONSTRAINT PKEY_CTCONTAINER_TYPE
    PRIMARY KEY (CONTAINER_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTCONTINENT
    ADD CONSTRAINT PKEY_CTCONTINENT
    PRIMARY KEY (CONTINENT_OCEAN)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTCORRESP_TYPE
    ADD CONSTRAINT PKEY_CTCORRESP_TYPE
    PRIMARY KEY (CORRESP_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTDEACCN_TYPE
    ADD CONSTRAINT PKEY_CTDEACCN_TYPE
    PRIMARY KEY (DEACCN_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTEGG_NEST_COMBO
    ADD CONSTRAINT PKEY_CTEGG_NEST_COMBO
    PRIMARY KEY (EGG_NEST_COMBO)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTELECTRONIC_ADDR_TYPE
    ADD CONSTRAINT PKEY_CTELECTRONIC_ADDR_TYPE
    PRIMARY KEY (ADDRESS_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTEW
    ADD CONSTRAINT PKEY_CTEW
    PRIMARY KEY (E_OR_W)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTFLAG_YES_NO
    ADD CONSTRAINT PKEY_CTFLAG_YES_NO
    PRIMARY KEY (STOREDVALUE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTFLAG_YES_NO_UNKNOWN
    ADD CONSTRAINT PKEY_CTFLAG_YES_NO_UNKNOWN
    PRIMARY KEY (STOREDVALUE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTGEOG_SOURCE_AUTHORITY
    ADD CONSTRAINT PKEY_CTGEOG_SOURCE_AUTHORITY
    PRIMARY KEY (SOURCE_AUTHORITY)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTID_MODIFIER
    ADD CONSTRAINT PKEY_CTID_MODIFIER
    PRIMARY KEY (IDENTIFICATION_MODIFIER)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTIMAGE_CONTENT_TYPE
    ADD CONSTRAINT PKEY_CTIMAGE_CONTENT_TYPE
    PRIMARY KEY (IMAGE_CONTENT_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTIMAGE_OBJECT_TYPE
    ADD CONSTRAINT PKEY_CTIMAGE_OBJECT_TYPE
    PRIMARY KEY (IMAGE_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTISLAND_GROUP
    ADD CONSTRAINT PKEY_CTISLAND_GROUP
    PRIMARY KEY (ISLAND_GROUP)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTKARYO_STAIN_PROC
    ADD CONSTRAINT PKEY_CTKARYO_STAIN_PROC
    PRIMARY KEY (KARYO_STAIN_PROC)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTLAT_LONG_ERROR_UNITS
    ADD CONSTRAINT PKEY_CTLAT_LONG_ERROR_UNITS
    PRIMARY KEY (LAT_LONG_ERROR_UNITS)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTLAT_LONG_REF_SOURCE
    ADD CONSTRAINT PKEY_CTLAT_LONG_REF_SOURCE
    PRIMARY KEY (LAT_LONG_REF_SOURCE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTLAT_LONG_UNITS
    ADD CONSTRAINT PKEY_CTLAT_LONG_UNITS
    PRIMARY KEY (ORIG_LAT_LONG_UNITS)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTLENGTH_UNITS
    ADD CONSTRAINT PKEY_CTLENGTH_UNITS
    PRIMARY KEY (LENGTH_UNITS)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTLEXICAL_RELATIONSHIP
    ADD CONSTRAINT PKEY_CTLEXICAL_RELATIONSHIP
    PRIMARY KEY (LEXICAL_RELATIONSHIP)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTLOAN_ITEM_STATUS
    ADD CONSTRAINT PKEY_CTLOAN_ITEM_STATUS
    PRIMARY KEY (LOAN_ITEM_STATUS)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTLOAN_STATUS
    ADD CONSTRAINT PKEY_CTLOAN_STATUS
    PRIMARY KEY (LOAN_STATUS)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTLOCALITY_SECTION_PART
    ADD CONSTRAINT PKEY_CTLOCALITY_SECTION_PART
    PRIMARY KEY (SECTION_PART)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTMEDIA_RELATIONSHIP
    ADD CONSTRAINT PK_CTMEDIA_RELATIONSHIP
    PRIMARY KEY (MEDIA_RELATIONSHIP)
    TABLESPACE USERS

ALTER TABLE UAM.CTNS
    ADD CONSTRAINT PKEY_CTNS
    PRIMARY KEY (N_OR_S)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTNUMERIC_AGE_UNITS
    ADD CONSTRAINT PKEY_CTNUMERIC_AGE_UNITS
    PRIMARY KEY (NUMERIC_AGE_UNITS)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTORIG_ELEV_UNITS
    ADD CONSTRAINT PKEY_CTORIG_ELEV_UNITS
    PRIMARY KEY (ORIG_ELEV_UNITS)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTPERMIT_TYPE
    ADD CONSTRAINT PKEY_CTPERMIT_TYPE
    PRIMARY KEY (PERMIT_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTPREFIX
    ADD CONSTRAINT PKEY_CTPREFIX
    PRIMARY KEY (PREFIX)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTPROJECT_AGENT_ROLE
    ADD CONSTRAINT PKEY_CTPROJECT_AGENT_ROLE
    PRIMARY KEY (PROJECT_AGENT_ROLE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTPUBLICATION_TYPE
    ADD CONSTRAINT PKEY_CTPUBLICATION_TYPE
    PRIMARY KEY (PUBLICATION_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTREFERENCERELATION
    ADD CONSTRAINT PKEY_CTREFERENCERELATION
    PRIMARY KEY (RELATIONSHIP)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTSECTION_TYPE
    ADD CONSTRAINT PKEY_CTSECTION_TYPE
    PRIMARY KEY (FIELD_NOTE_SECT_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTSHIPMENT_CARRIER
    ADD CONSTRAINT PKEY_CTSHIPMENT_CARRIER
    PRIMARY KEY (SHIPMENT_CARRIER_CDE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTSHIPMENT_STATUS
    ADD CONSTRAINT PKEY_CTSHIPMENT_STATUS
    PRIMARY KEY (SHIPMENT_STATUS)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTSHIPPED_CARRIER_METHOD
    ADD CONSTRAINT PKEY_CTSHIPPED_CARRIER_METHOD
    PRIMARY KEY (SHIPPED_CARRIER_METHOD)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTSUFFIX
    ADD CONSTRAINT PKEY_CTSUFFIX
    PRIMARY KEY (SUFFIX)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTTRANSACTION_TYPE
    ADD CONSTRAINT PKEY_CTTRANSACTION_TYPE
    PRIMARY KEY (TRANSACTION_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTURL_TYPE
    ADD CONSTRAINT PKEY_CTURL_TYPE
    PRIMARY KEY (URL_TYPE)
    TABLESPACE UAM_IDX_1;

ALTER TABLE UAM.CTWEIGHT_UNITS
    ADD CONSTRAINT PKEY_CTWEIGHT_UNITS
    PRIMARY KEY (WEIGHT_UNITS)
    TABLESPACE UAM_IDX_1;
    
    
-- foreign keys

PK_CTMEDIA_RELATIONSHIP 
alter table MEDIA_RELATIONS drop constraint FK_MEDIARELNS_CTMEDIARELNS;

alter table MEDIA_RELATIONS                                                   
    add constraint FK_MEDIARELNS_CTMEDIARELNS foreign key (MEDIA_RELATIONSHIP)
    references CTMEDIA_RELATIONSHIP (MEDIA_RELATIONSHIP);


PK_CTMIME_TYPE  
alter table MEDIA drop constraint FK_MEDIA_CTMIMETYPE;

alter table MEDIA
    add constraint FK_MEDIA_CTMIMETYPE foreign key (MIME_TYPE)
    references CTMIME_TYPE (MIME_TYPE);

*/

grant select on CTACCN_STATUS to uam;
grant select on CTACCN_TYPE to uam;
grant select on CTADDR_TYPE to uam;
grant select on CTAGENT_NAME_TYPE to uam;
grant select on CTAGENT_RELATIONSHIP to uam;
grant select on CTAGENT_TYPE to uam;
grant select on CTAGE_CLASS to uam;
grant select on CTATTRIBUTE_CODE_TABLES to uam;
grant select on CTATTRIBUTE_TYPE to uam;
grant select on CTBIN_OBJ_ASPECT to uam;
grant select on CTBIN_OBJ_SUBJECT to uam;
grant select on CTBIOL_RELATIONS to uam;
grant select on CTBORROW_STATUS to uam;
grant select on CTCF_LOAN_USE_TYPE to uam;
grant select on CTCITATION_TYPE_STATUS to uam;
grant select on CTCLASS to uam;
grant select on CTCOLLECTING_SOURCE to uam;
grant select on CTCOLLECTION_CDE to uam;
grant select on CTCOLLECTOR_ROLE to uam;
grant select on CTCOLL_CONTACT_ROLE to uam;
grant select on CTCOLL_OBJ_DISP to uam;
grant select on CTCOLL_OBJ_FLAGS to uam;
grant select on CTCOLL_OTHER_ID_TYPE to uam;
grant select on CTCONTAINER_TYPE to uam;
grant select on CTCONTINENT to uam;
grant select on CTDATUM to uam;
grant select on CTDEPTH_UNITS to uam;
grant select on CTDOWNLOAD_PURPOSE to uam;
grant select on CTELECTRONIC_ADDR_TYPE to uam;
grant select on CTENCUMBRANCE_ACTION to uam;
grant select on CTEW to uam;
grant select on CTFEATURE to uam;
grant select on CTFLAGS to uam;
grant select on CTFLUID_CONCENTRATION to uam;
grant select on CTFLUID_TYPE to uam;
grant select on CTGEOG_SOURCE_AUTHORITY to uam;
grant select on CTGEOREFMETHOD to uam;
grant select on CTINFRASPECIFIC_RANK to uam;
grant select on CTISLAND_GROUP to uam;
grant select on CTLAT_LONG_ERROR_UNITS to uam;
grant select on CTLAT_LONG_REF_SOURCE to uam;
grant select on CTLAT_LONG_UNITS to uam;
grant select on CTLENGTH_UNITS to uam;
grant select on CTLOAN_STATUS to uam;
grant select on CTLOAN_TYPE to uam;
grant select on CTMEDIA_LABEL to uam;
grant select on CTMEDIA_RELATIONSHIP to uam;
grant select on CTMEDIA_TYPE to uam;
grant select on CTMIME_TYPE to uam;
grant select on CTNATURE_OF_ID to uam;
grant select on CTNS to uam;
grant select on CTNUMERIC_AGE_UNITS to uam;
grant select on CTORIG_ELEV_UNITS to uam;
grant select on CTPERMIT_TYPE to uam;
grant select on CTPREFIX to uam;
grant select on CTPROJECT_AGENT_ROLE to uam;
grant select on CTPUBLICATION_TYPE to uam;
grant select on CTSEX_CDE to uam;
grant select on CTSHIPPED_CARRIER_METHOD to uam;
grant select on CTSPECIMEN_PART_LIST_ORDER to uam;
grant select on CTSPECIMEN_PART_MODIFIER to uam;
grant select on CTSPECIMEN_PART_NAME to uam;
grant select on CTSPECIMEN_PRESERV_METHOD to uam;
grant select on CTSUFFIX to uam;
grant select on CTTAXA_FORMULA to uam;
grant select on CTTAXONOMIC_AUTHORITY to uam;
grant select on CTTAXON_RELATION to uam;
grant select on CTTRANS_AGENT_ROLE to uam;
grant select on CTVERIFICATIONSTATUS to uam;
grant select on CTWEIGHT_UNITS to uam;
grant select on CTYES_NO to uam;


select
'begin' ||
chr(10) ||
'    for tn in (select ' || column_name || ' a from vpd_test.' || table_name || ') loop' ||
chr(10) ||
'        begin' ||
chr(10) || 
'            insert into uam.' || table_name || ' ('|| column_name || ') values (tn.a);' ||
chr(10) || 
'            dbms_output.put_line(''inserted into ' || table_name || ': '' || tn.a );' ||
chr(10) || 
'        exception when dup_val_on_index then' ||
chr(10) || 
'            dbms_output.put_line(''dup value on ' || table_name || ': '' || tn.a );' ||
chr(10) || 
'        end; ' ||
chr(10) || 
'    end loop; ' ||
chr(10) || 
'end; ' ||
chr(10) || 
'/'
from user_tab_columns where table_name like 'CT%'
AND table_name NOT IN (
    SELECT table_name FROM user_tab_columns WHERE column_id = 2)
and table_name IN (
    'CTACCN_STATUS',
	'CTACCN_TYPE',
	'CTADDR_TYPE',
	'CTAGENT_NAME_TYPE',
	'CTAGENT_RELATIONSHIP',
	'CTAGENT_TYPE',
	'CTAGE_CLASS',
	'CTATTRIBUTE_CODE_TABLES',
	'CTATTRIBUTE_TYPE',
	'CTBIN_OBJ_ASPECT',
	'CTBIN_OBJ_SUBJECT',
	'CTBIOL_RELATIONS',
	'CTBORROW_STATUS',
	'CTCF_LOAN_USE_TYPE',
	'CTCITATION_TYPE_STATUS',
	'CTCLASS',
	'CTCOLLECTING_SOURCE',
	'CTCOLLECTION_CDE',
	'CTCOLLECTOR_ROLE',
	'CTCOLL_CONTACT_ROLE',
	'CTCOLL_OBJ_DISP',
	'CTCOLL_OBJ_FLAGS',
	'CTCOLL_OTHER_ID_TYPE',
	'CTCONTAINER_TYPE',
	'CTCONTINENT',
	'CTDATUM',
	'CTDEPTH_UNITS',
	'CTDOWNLOAD_PURPOSE',
	'CTELECTRONIC_ADDR_TYPE',
	'CTENCUMBRANCE_ACTION',
	'CTEW',
	'CTFEATURE',
	'CTFLAGS',
	'CTFLUID_CONCENTRATION',
	'CTFLUID_TYPE',
	'CTGEOG_SOURCE_AUTHORITY',
	'CTGEOREFMETHOD',
	'CTINFRASPECIFIC_RANK',
	'CTISLAND_GROUP',
	'CTLAT_LONG_ERROR_UNITS',
	'CTLAT_LONG_REF_SOURCE',
	'CTLAT_LONG_UNITS',
	'CTLENGTH_UNITS',
	'CTLOAN_STATUS',
	'CTLOAN_TYPE',
	'CTMEDIA_LABEL',
	'CTMEDIA_RELATIONSHIP',
	'CTMEDIA_TYPE',
	'CTMIME_TYPE',
	'CTNATURE_OF_ID',
	'CTNS',
	'CTNUMERIC_AGE_UNITS',
	'CTORIG_ELEV_UNITS',
	'CTPERMIT_TYPE',
	'CTPREFIX',
	'CTPROJECT_AGENT_ROLE',
	'CTPUBLICATION_TYPE',
	'CTSEX_CDE',
	'CTSHIPPED_CARRIER_METHOD',
	'CTSPECIMEN_PART_LIST_ORDER',
	'CTSPECIMEN_PART_MODIFIER',
	'CTSPECIMEN_PART_NAME',
	'CTSPECIMEN_PRESERV_METHOD',
	'CTSUFFIX',
	'CTTAXA_FORMULA',
	'CTTAXONOMIC_AUTHORITY',
	'CTTAXON_RELATION',
	'CTTRANS_AGENT_ROLE',
	'CTVERIFICATIONSTATUS',
	'CTWEIGHT_UNITS',
	'CTYES_NO');

begin
    for tn in (select ACCN_STATUS a from mvz.CTACCN_STATUS) loop
        begin
            insert into uam.CTACCN_STATUS (ACCN_STATUS) values (tn.a);
            dbms_output.put_line('inserted into CTACCN_STATUS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTACCN_STATUS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select ACCN_TYPE a from mvz.CTACCN_TYPE) loop
        begin
            insert into uam.CTACCN_TYPE (ACCN_TYPE) values (tn.a);
            dbms_output.put_line('inserted into CTACCN_TYPE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTACCN_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select ADDR_TYPE a from mvz.CTADDR_TYPE) loop
        begin
            insert into uam.CTADDR_TYPE (ADDR_TYPE) values (tn.a);
            dbms_output.put_line('inserted into CTADDR_TYPE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTADDR_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select AGENT_NAME_TYPE a from mvz.CTAGENT_NAME_TYPE) loop
        begin
            insert into uam.CTAGENT_NAME_TYPE (AGENT_NAME_TYPE) values (tn.a);
            dbms_output.put_line('inserted into CTAGENT_NAME_TYPE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTAGENT_NAME_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select AGENT_RELATIONSHIP a from mvz.CTAGENT_RELATIONSHIP) loop
        begin
            insert into uam.CTAGENT_RELATIONSHIP (AGENT_RELATIONSHIP) values (tn.a);
            dbms_output.put_line('inserted into CTAGENT_RELATIONSHIP: ' || tn.a);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTAGENT_RELATIONSHIP: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select AGENT_TYPE a from mvz.CTAGENT_TYPE) loop
        begin
            insert into uam.CTAGENT_TYPE (AGENT_TYPE) values (tn.a);
            dbms_output.put_line('inserted into CTAGENT_TYPE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTAGENT_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select ASPECT a from mvz.CTBIN_OBJ_ASPECT) loop
        begin
            insert into uam.CTBIN_OBJ_ASPECT (ASPECT) values (tn.a);
            dbms_output.put_line('inserted into CTBIN_OBJ_ASPECT: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTBIN_OBJ_ASPECT: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select BORROW_STATUS a from mvz.CTBORROW_STATUS) loop
        begin
            insert into uam.CTBORROW_STATUS (BORROW_STATUS) values (tn.a);
            dbms_output.put_line('inserted into CTBORROW_STATUS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTBORROW_STATUS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select USE_TYPE a from mvz.CTCF_LOAN_USE_TYPE) loop
        begin
            insert into uam.CTCF_LOAN_USE_TYPE (USE_TYPE) values (tn.a);
            dbms_output.put_line('inserted into CTCF_LOAN_USE_TYPE: ' || tn.a );

        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCF_LOAN_USE_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select COLLECTING_SOURCE a from mvz.CTCOLLECTING_SOURCE) loop
        begin
            insert into uam.CTCOLLECTING_SOURCE (COLLECTING_SOURCE) values (tn.a);
            dbms_output.put_line('inserted into CTCOLLECTING_SOURCE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCOLLECTING_SOURCE: ' || tn.a );

        end;
    end loop;
end;
/

begin
    for tn in (select COLLECTION_CDE a from mvz.CTCOLLECTION_CDE) loop
        begin
            insert into uam.CTCOLLECTION_CDE (COLLECTION_CDE) values (tn.a);
            dbms_output.put_line('inserted into CTCOLLECTION_CDE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCOLLECTION_CDE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select COLLECTOR_ROLE a from mvz.CTCOLLECTOR_ROLE) loop
        begin
            insert into uam.CTCOLLECTOR_ROLE (COLLECTOR_ROLE) values (tn.a);
            dbms_output.put_line('inserted into CTCOLLECTOR_ROLE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCOLLECTOR_ROLE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select CONTACT_ROLE a from mvz.CTCOLL_CONTACT_ROLE) loop
        begin
            insert into uam.CTCOLL_CONTACT_ROLE (CONTACT_ROLE) values (tn.a);
            dbms_output.put_line('inserted into CTCOLL_CONTACT_ROLE: ' || tn.a);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCOLL_CONTACT_ROLE: ' || tn.a);

        end;
    end loop;
end;
/

begin
    for tn in (select COLL_OBJ_DISPOSITION a from mvz.CTCOLL_OBJ_DISP) loop

        begin
            insert into uam.CTCOLL_OBJ_DISP (COLL_OBJ_DISPOSITION) values (tn.a)
;
            dbms_output.put_line('inserted into CTCOLL_OBJ_DISP: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCOLL_OBJ_DISP: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select FLAGS a from mvz.CTCOLL_OBJ_FLAGS) loop
        begin
            insert into uam.CTCOLL_OBJ_FLAGS (FLAGS) values (tn.a);
            dbms_output.put_line('inserted into CTCOLL_OBJ_FLAGS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCOLL_OBJ_FLAGS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select CONTAINER_TYPE a from mvz.CTCONTAINER_TYPE) loop
        begin
            insert into uam.CTCONTAINER_TYPE (CONTAINER_TYPE) values (tn.a);
            dbms_output.put_line('inserted into CTCONTAINER_TYPE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCONTAINER_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select CONTINENT_OCEAN a from mvz.CTCONTINENT) loop
        begin
            insert into uam.CTCONTINENT (CONTINENT_OCEAN) values (tn.a);
            dbms_output.put_line('inserted into CTCONTINENT: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCONTINENT: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select DATUM a from mvz.CTDATUM) loop
        begin
            insert into uam.CTDATUM (DATUM) values (tn.a);
            dbms_output.put_line('inserted into CTDATUM: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTDATUM: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select DEPTH_UNITS a from mvz.CTDEPTH_UNITS) loop
        begin
            insert into uam.CTDEPTH_UNITS (DEPTH_UNITS) values (tn.a);
            dbms_output.put_line('inserted into CTDEPTH_UNITS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTDEPTH_UNITS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select DOWNLOAD_PURPOSE a from mvz.CTDOWNLOAD_PURPOSE) loop
        begin
            insert into uam.CTDOWNLOAD_PURPOSE (DOWNLOAD_PURPOSE) values (tn.a);

            dbms_output.put_line('inserted into CTDOWNLOAD_PURPOSE: ' || tn.a );

        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTDOWNLOAD_PURPOSE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select ADDRESS_TYPE a from mvz.CTELECTRONIC_ADDR_TYPE) loop
        begin
            insert into uam.CTELECTRONIC_ADDR_TYPE (ADDRESS_TYPE) values (tn.a);
            dbms_output.put_line('inserted into CTELECTRONIC_ADDR_TYPE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTELECTRONIC_ADDR_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select ENCUMBRANCE_ACTION a from mvz.CTENCUMBRANCE_ACTION) loop
        begin
            insert into uam.CTENCUMBRANCE_ACTION (ENCUMBRANCE_ACTION) values (tn.a);
            dbms_output.put_line('inserted into CTENCUMBRANCE_ACTION: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTENCUMBRANCE_ACTION: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select E_OR_W a from mvz.CTEW) loop
        begin
            insert into uam.CTEW (E_OR_W) values (tn.a);
            dbms_output.put_line('inserted into CTEW: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTEW: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select FEATURE a from mvz.CTFEATURE) loop
        begin
            insert into uam.CTFEATURE (FEATURE) values (tn.a);
            dbms_output.put_line('inserted into CTFEATURE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTFEATURE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select FLAGS a from mvz.CTFLAGS) loop
        begin
            insert into uam.CTFLAGS (FLAGS) values (tn.a);
            dbms_output.put_line('inserted into CTFLAGS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTFLAGS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select CONCENTRATION a from mvz.CTFLUID_CONCENTRATION) loop
        begin
            insert into uam.CTFLUID_CONCENTRATION (CONCENTRATION) values (tn.a);

            dbms_output.put_line('inserted into CTFLUID_CONCENTRATION: ' || tn.a
 );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTFLUID_CONCENTRATION: ' || tn.a
);
        end;
    end loop;
end;
/

begin
    for tn in (select FLUID_TYPE a from mvz.CTFLUID_TYPE) loop
        begin
            insert into uam.CTFLUID_TYPE (FLUID_TYPE) values (tn.a);
            dbms_output.put_line('inserted into CTFLUID_TYPE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTFLUID_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select SOURCE_AUTHORITY a from mvz.CTGEOG_SOURCE_AUTHORITY)
loop
        begin
            insert into uam.CTGEOG_SOURCE_AUTHORITY (SOURCE_AUTHORITY) values (tn.a);
            dbms_output.put_line('inserted into CTGEOG_SOURCE_AUTHORITY: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTGEOG_SOURCE_AUTHORITY: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select GEOREFMETHOD a from mvz.CTGEOREFMETHOD) loop
        begin
            insert into uam.CTGEOREFMETHOD (GEOREFMETHOD) values (tn.a);
            dbms_output.put_line('inserted into CTGEOREFMETHOD: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTGEOREFMETHOD: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select INFRASPECIFIC_RANK a from mvz.CTINFRASPECIFIC_RANK) loop
        begin
            insert into uam.CTINFRASPECIFIC_RANK (INFRASPECIFIC_RANK) values (tn.a);
            dbms_output.put_line('inserted into CTINFRASPECIFIC_RANK: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTINFRASPECIFIC_RANK: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select ISLAND_GROUP a from mvz.CTISLAND_GROUP) loop
        begin
            insert into uam.CTISLAND_GROUP (ISLAND_GROUP) values (tn.a);
            dbms_output.put_line('inserted into CTISLAND_GROUP: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTISLAND_GROUP: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select LAT_LONG_ERROR_UNITS a from mvz.CTLAT_LONG_ERROR_UNITS) loop
        begin
            insert into uam.CTLAT_LONG_ERROR_UNITS (LAT_LONG_ERROR_UNITS) values (tn.a);
            dbms_output.put_line('inserted into CTLAT_LONG_ERROR_UNITS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTLAT_LONG_ERROR_UNITS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select LAT_LONG_REF_SOURCE a from mvz.CTLAT_LONG_REF_SOURCE)
 loop
        begin
            insert into uam.CTLAT_LONG_REF_SOURCE (LAT_LONG_REF_SOURCE) values (tn.a);
            dbms_output.put_line('inserted into CTLAT_LONG_REF_SOURCE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTLAT_LONG_REF_SOURCE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select ORIG_LAT_LONG_UNITS a from mvz.CTLAT_LONG_UNITS) loop

        begin
            insert into uam.CTLAT_LONG_UNITS (ORIG_LAT_LONG_UNITS) values (tn.a);
            dbms_output.put_line('inserted into CTLAT_LONG_UNITS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTLAT_LONG_UNITS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select LENGTH_UNITS a from mvz.CTLENGTH_UNITS) loop
        begin
            insert into uam.CTLENGTH_UNITS (LENGTH_UNITS) values (tn.a);
            dbms_output.put_line('inserted into CTLENGTH_UNITS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTLENGTH_UNITS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select LOAN_STATUS a from mvz.CTLOAN_STATUS) loop
        begin
            insert into uam.CTLOAN_STATUS (LOAN_STATUS) values (tn.a);
            dbms_output.put_line('inserted into CTLOAN_STATUS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTLOAN_STATUS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select LOAN_TYPE a from mvz.CTLOAN_TYPE) loop
        begin
            insert into uam.CTLOAN_TYPE (LOAN_TYPE) values (tn.a);
            dbms_output.put_line('inserted into CTLOAN_TYPE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTLOAN_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select MEDIA_RELATIONSHIP a from mvz.CTMEDIA_RELATIONSHIP) loop
        begin
            insert into uam.CTMEDIA_RELATIONSHIP (MEDIA_RELATIONSHIP) values (tn.a);
            dbms_output.put_line('inserted into CTMEDIA_RELATIONSHIP: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTMEDIA_RELATIONSHIP: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select N_OR_S a from mvz.CTNS) loop
        begin
            insert into uam.CTNS (N_OR_S) values (tn.a);
            dbms_output.put_line('inserted into CTNS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTNS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select NUMERIC_AGE_UNITS a from mvz.CTNUMERIC_AGE_UNITS) loop
        begin
            insert into uam.CTNUMERIC_AGE_UNITS (NUMERIC_AGE_UNITS) values (tn.a );
            dbms_output.put_line('inserted into CTNUMERIC_AGE_UNITS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTNUMERIC_AGE_UNITS: ' || tn.a );

        end;
    end loop;
end;
/

begin
    for tn in (select ORIG_ELEV_UNITS a from mvz.CTORIG_ELEV_UNITS) loop
        begin
            insert into uam.CTORIG_ELEV_UNITS (ORIG_ELEV_UNITS) values (tn.a);
            dbms_output.put_line('inserted into CTORIG_ELEV_UNITS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTORIG_ELEV_UNITS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select PERMIT_TYPE a from mvz.CTPERMIT_TYPE) loop
        begin
            insert into uam.CTPERMIT_TYPE (PERMIT_TYPE) values (tn.a);
            dbms_output.put_line('inserted into CTPERMIT_TYPE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTPERMIT_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select PREFIX a from mvz.CTPREFIX) loop
        begin
            insert into uam.CTPREFIX (PREFIX) values (tn.a);
            dbms_output.put_line('inserted into CTPREFIX: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTPREFIX: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select PROJECT_AGENT_ROLE a from mvz.CTPROJECT_AGENT_ROLE) loop
        begin
            insert into uam.CTPROJECT_AGENT_ROLE (PROJECT_AGENT_ROLE) values (tn.a);
            dbms_output.put_line('inserted into CTPROJECT_AGENT_ROLE: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTPROJECT_AGENT_ROLE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select PUBLICATION_TYPE a from mvz.CTPUBLICATION_TYPE) loop
        begin
            insert into uam.CTPUBLICATION_TYPE (PUBLICATION_TYPE) values (tn.a);

            dbms_output.put_line('inserted into CTPUBLICATION_TYPE: ' || tn.a );

        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTPUBLICATION_TYPE: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select SHIPPED_CARRIER_METHOD a from mvz.CTSHIPPED_CARRIER_METHOD) loop
        begin
            insert into uam.CTSHIPPED_CARRIER_METHOD (SHIPPED_CARRIER_METHOD) values (tn.a);
            dbms_output.put_line('inserted into CTSHIPPED_CARRIER_METHOD: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTSHIPPED_CARRIER_METHOD: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select PART_MODIFIER a from mvz.CTSPECIMEN_PART_MODIFIER) loop
        begin
            insert into uam.CTSPECIMEN_PART_MODIFIER (PART_MODIFIER) values (tn.a);
            dbms_output.put_line('inserted into CTSPECIMEN_PART_MODIFIER: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTSPECIMEN_PART_MODIFIER: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select SUFFIX a from mvz.CTSUFFIX) loop
        begin
            insert into uam.CTSUFFIX (SUFFIX) values (tn.a);
            dbms_output.put_line('inserted into CTSUFFIX: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTSUFFIX: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select WEIGHT_UNITS a from mvz.CTWEIGHT_UNITS) loop
        begin
            insert into uam.CTWEIGHT_UNITS (WEIGHT_UNITS) values (tn.a);
            dbms_output.put_line('inserted into CTWEIGHT_UNITS: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTWEIGHT_UNITS: ' || tn.a );
        end;
    end loop;
end;
/

begin
    for tn in (select YES_OR_NO a from mvz.CTYES_NO) loop
        begin
            insert into uam.CTYES_NO (YES_OR_NO) values (tn.a);
            dbms_output.put_line('inserted into CTYES_NO: ' || tn.a );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTYES_NO: ' || tn.a );
        end;
    end loop;
end;
/
-- single columns.
'CTACCN_STATUS',
'CTACCN_TYPE',
'CTADDR_TYPE',
'CTAGENT_NAME_TYPE',
'CTAGENT_RELATIONSHIP',
'CTAGENT_TYPE',
'CTBIN_OBJ_ASPECT',
'CTBORROW_STATUS',
'CTCF_LOAN_USE_TYPE',
'CTCOLLECTING_SOURCE',
'CTCOLLECTION_CDE',
'CTCOLLECTOR_ROLE',
'CTCOLL_CONTACT_ROLE',
'CTCOLL_OBJ_DISP',
'CTCOLL_OBJ_FLAGS',
'CTCONTAINER_TYPE',
'CTCONTINENT',
'CTDATUM',
'CTDEPTH_UNITS',
'CTDOWNLOAD_PURPOSE',
'CTELECTRONIC_ADDR_TYPE',
'CTENCUMBRANCE_ACTION',
'CTEW',
'CTFEATURE',
'CTFLAGS',
'CTFLUID_CONCENTRATION',
'CTFLUID_TYPE',
'CTGEOG_SOURCE_AUTHORITY',
'CTGEOREFMETHOD',
'CTINFRASPECIFIC_RANK',
'CTISLAND_GROUP',
'CTLAT_LONG_ERROR_UNITS',
'CTLAT_LONG_REF_SOURCE',
'CTLAT_LONG_UNITS',
'CTLENGTH_UNITS',
'CTLOAN_STATUS',
'CTLOAN_TYPE',
'CTMEDIA_RELATIONSHIP',
'CTNS',
'CTNUMERIC_AGE_UNITS',
'CTORIG_ELEV_UNITS',
'CTPERMIT_TYPE',
'CTPREFIX',
'CTPROJECT_AGENT_ROLE',
'CTPUBLICATION_TYPE',
'CTSHIPPED_CARRIER_METHOD',
'CTSPECIMEN_PART_MODIFIER',
'CTSUFFIX',
'CTWEIGHT_UNITS',
'CTYES_NO');

-- multiple columns
	'CTAGE_CLASS',
	'CTATTRIBUTE_CODE_TABLES',
	'CTATTRIBUTE_TYPE',
	'CTBIN_OBJ_SUBJECT',
	'CTBIOL_RELATIONS',
	'CTCITATION_TYPE_STATUS',
	'CTCLASS',
	'CTCOLL_OTHER_ID_TYPE',
	'CTMEDIA_LABEL',
	'CTMEDIA_TYPE',
	'CTMIME_TYPE',
	'CTNATURE_OF_ID',
	'CTSEX_CDE',
	'CTSPECIMEN_PART_LIST_ORDER',
	'CTSPECIMEN_PART_NAME',
	'CTSPECIMEN_PRESERV_METHOD',
	'CTTAXA_FORMULA',
	'CTTAXONOMIC_AUTHORITY',
	'CTTAXON_RELATION',
	'CTTRANS_AGENT_ROLE',
	'CTVERIFICATIONSTATUS',

DESC uam.CTAGE_CLASS;
DESC mvz.CTAGE_CLASS;

begin
    for tn in (select COLLECTION_CDE, AGE_CLASS from mvz.CTAGE_CLASS) loop
        begin
            insert into uam.CTAGE_CLASS (COLLECTION_CDE, AGE_CLASS)
            values (tn.COLLECTION_CDE, tn.AGE_CLASS);
            dbms_output.put_line('inserted into CTAGE_CLASS: ' || tn.COLLECTION_CDE || chr(9) || tn.AGE_CLASS );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTAGE_CLASS: ' || tn.COLLECTION_CDE || chr(9) || tn.AGE_CLASS );
        end;
    end loop;
end;
/

desc uam.CTATTRIBUTE_CODE_TABLES;
desc mvz.CTATTRIBUTE_CODE_TABLES;

begin
    for tn in (select * from mvz.CTATTRIBUTE_CODE_TABLES) loop
        begin
            insert into uam.CTATTRIBUTE_CODE_TABLES 
            values (tn.ATTRIBUTE_TYPE, tn.VALUE_CODE_TABLE, tn.UNITS_CODE_TABLE);
            dbms_output.put_line('inserted into CTATTRIBUTE_CODE_TABLES: ' || 
            tn.ATTRIBUTE_TYPE || chr(9) || tn.VALUE_CODE_TABLE || chr(9) || tn.UNITS_CODE_TABLE);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTATTRIBUTE_CODE_TABLES: ' || 
            tn.ATTRIBUTE_TYPE || chr(9) || tn.VALUE_CODE_TABLE || chr(9) || tn.UNITS_CODE_TABLE);
        end;
    end loop;
end;
/

DESC uam.CTATTRIBUTE_TYPE;
DESC mvz.CTATTRIBUTE_TYPE;
begin
    for tn in (select COLLECTION_CDE, ATTRIBUTE_TYPE from mvz.CTATTRIBUTE_TYPE) loop
        begin
            insert into uam.CTATTRIBUTE_TYPE (COLLECTION_CDE, ATTRIBUTE_TYPE)
            values (tn.COLLECTION_CDE, tn.ATTRIBUTE_TYPE);
            dbms_output.put_line('inserted into CTATTRIBUTE_TYPE: ' || tn.COLLECTION_CDE || chr(9) || tn.ATTRIBUTE_TYPE );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTATTRIBUTE_TYPE: ' || tn.COLLECTION_CDE || chr(9) || tn.ATTRIBUTE_TYPE );
        end;
    end loop;
end;
/

desc uam.CTBIN_OBJ_SUBJECT;
desc mvz.CTBIN_OBJ_SUBJECT;

begin
    for tn in (select SUBJECT from mvz.CTBIN_OBJ_SUBJECT) loop
        begin
            insert into uam.CTBIN_OBJ_SUBJECT (SUBJECT)
            values (tn.SUBJECT);
            dbms_output.put_line('inserted into CTBIN_OBJ_SUBJECT: ' || tn.SUBJECT);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTBIN_OBJ_SUBJECT: ' || tn.SUBJECT);
        end;
    end loop;
end;
/

desc uam.CTBIOL_RELATIONS;
desc mvz.CTBIOL_RELATIONS;

begin
    for tn in (select BIOL_INDIV_RELATIONSHIP from mvz.CTBIOL_RELATIONS) loop
        begin
            insert into uam.CTBIOL_RELATIONS (BIOL_INDIV_RELATIONSHIP)
            values (tn.BIOL_INDIV_RELATIONSHIP);
            dbms_output.put_line('inserted into CTBIOL_RELATIONS: ' || tn.BIOL_INDIV_RELATIONSHIP);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTBIOL_RELATIONS: ' || tn.BIOL_INDIV_RELATIONSHIP);
        end;
    end loop;
end;
/

desc uam.CTCITATION_TYPE_STATUS;
desc mvz.CTCITATION_TYPE_STATUS;

begin
    for tn in (select TYPE_STATUS from mvz.CTCITATION_TYPE_STATUS) loop
        begin
            insert into uam.CTCITATION_TYPE_STATUS (TYPE_STATUS)
            values (tn.TYPE_STATUS);
            dbms_output.put_line('inserted into CTCITATION_TYPE_STATUS: ' || tn.TYPE_STATUS);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCITATION_TYPE_STATUS: ' || tn.TYPE_STATUS);
        end;
    end loop;
end;
/

desc uam.CTCLASS;
desc mvz.CTCLASS;
begin
    for tn in (select PHYLCLASS from mvz.CTCLASS) loop
        begin
            insert into uam.CTCLASS (PHYLCLASS)
            values (tn.PHYLCLASS);
            dbms_output.put_line('inserted into CTCLASS: ' || tn.PHYLCLASS);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCLASS: ' || tn.PHYLCLASS);
        end;
    end loop;
end;
/

desc uam.CTCOLL_OTHER_ID_TYPE;
desc mvz.CTCOLL_OTHER_ID_TYPE;
begin
    for tn in (select OTHER_ID_TYPE, DESCRIPTION from mvz.CTCOLL_OTHER_ID_TYPE) loop
        begin
            insert into uam.CTCOLL_OTHER_ID_TYPE (OTHER_ID_TYPE, DESCRIPTION)
            values (tn.OTHER_ID_TYPE, tn.DESCRIPTION);
            dbms_output.put_line('inserted into CTCOLL_OTHER_ID_TYPE: ' || tn.OTHER_ID_TYPE || chr(9) || tn.DESCRIPTION );
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTCOLL_OTHER_ID_TYPE: ' || tn.OTHER_ID_TYPE || chr(9) || tn.DESCRIPTION );
        end;
    end loop;
end;
/

desc uam.CTMEDIA_LABEL;
desc mvz.CTMEDIA_LABEL;
begin
    for tn in (select MEDIA_LABEL from mvz.CTMEDIA_LABEL) loop
        begin
            insert into uam.CTMEDIA_LABEL (MEDIA_LABEL)
            values (tn.MEDIA_LABEL);
            dbms_output.put_line('inserted into CTMEDIA_LABEL: ' || tn.MEDIA_LABEL);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTMEDIA_LABEL: ' || tn.MEDIA_LABEL);
        end;
    end loop;
end;
/

desc uam.CTMEDIA_TYPE;
desc mvz.CTMEDIA_TYPE;
begin
    for tn in (select MEDIA_TYPE, DESCRIPTION from mvz.CTMEDIA_TYPE) loop
        begin
            insert into uam.CTMEDIA_TYPE (MEDIA_TYPE, DESCRIPTION)
            values (tn.MEDIA_TYPE, tn.DESCRIPTION);
            dbms_output.put_line('inserted into CTMEDIA_TYPE: ' || tn.MEDIA_TYPE || chr(9) || tn.DESCRIPTION);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTMEDIA_TYPE: ' || tn.MEDIA_TYPE || chr(9) || tn.DESCRIPTION);
        end;
    end loop;
end;
/

desc uam.CTMIME_TYPE;
desc mvz.CTMIME_TYPE;
begin
    for tn in (select MIME_TYPE, DESCRIPTION from mvz.CTMIME_TYPE) loop
        begin
            insert into uam.CTMIME_TYPE (MIME_TYPE, DESCRIPTION)
            values (tn.MIME_TYPE, tn.DESCRIPTION);
            dbms_output.put_line('inserted into CTMIME_TYPE: ' || tn.MIME_TYPE || chr(9) || tn.DESCRIPTION);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTMIME_TYPE: ' || tn.MIME_TYPE || chr(9) || tn.DESCRIPTION);
        end;
    end loop;
end;
/

desc uam.CTNATURE_OF_ID;
desc mvz.CTNATURE_OF_ID;
begin
    for tn in (select NATURE_OF_ID from mvz.CTNATURE_OF_ID) loop
        begin
            insert into uam.CTNATURE_OF_ID (NATURE_OF_ID)
            values (tn.NATURE_OF_ID);
            dbms_output.put_line('inserted into CTNATURE_OF_ID: ' || tn.NATURE_OF_ID);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTNATURE_OF_ID: ' || tn.NATURE_OF_ID);
        end;
    end loop;
end;
/

desc uam.CTSEX_CDE;
desc mvz.CTSEX_CDE;
alter table CTSEX_CDE modify sex_cde varchar2(20);
    
begin
    for tn in (select COLLECTION_CDE, SEX_CDE from mvz.CTSEX_CDE) loop
        begin
            insert into uam.CTSEX_CDE (COLLECTION_CDE, SEX_CDE)
            values (tn.COLLECTION_CDE, tn.SEX_CDE);
            dbms_output.put_line('inserted into CTSEX_CDE: ' || tn.COLLECTION_CDE || chr(9) || tn.SEX_CDE);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTSEX_CDE: ' || tn.COLLECTION_CDE || chr(9) || tn.SEX_CDE);
        end;
    end loop;
end;
/

desc uam.CTSPECIMEN_PART_LIST_ORDER;
desc mvz.CTSPECIMEN_PART_LIST_ORDER;
begin
    for tn in (select PARTNAME, LIST_ORDER from mvz.CTSPECIMEN_PART_LIST_ORDER) loop
        begin
            insert into uam.CTSPECIMEN_PART_LIST_ORDER (PARTNAME, LIST_ORDER)
            values (tn.PARTNAME, tn.LIST_ORDER);
            dbms_output.put_line('inserted into CTSPECIMEN_PART_LIST_ORDER: ' || tn.PARTNAME || chr(9) || tn.LIST_ORDER);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTSPECIMEN_PART_LIST_ORDER: ' || tn.PARTNAME || chr(9) || tn.LIST_ORDER);
        end;
    end loop;
end;
/

---!!! still need to fix part names.
desc uam.CTSPECIMEN_PART_NAME;
desc mvz.CTSPECIMEN_PART_NAME;

begin
    for tn in (select COLLECTION_CDE, PART_NAME from mvz.CTSPECIMEN_PART_NAME) loop
        begin
            insert into uam.CTSPECIMEN_PART_NAME (COLLECTION_CDE, PART_NAME)
            values (tn.COLLECTION_CDE, tn.PART_NAME);
            dbms_output.put_line('inserted into CTSPECIMEN_PART_NAME: ' || tn.COLLECTION_CDE || chr(9) || tn.PART_NAME);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTSPECIMEN_PART_NAME: ' || tn.COLLECTION_CDE || chr(9) || tn.PART_NAME);
        end;
    end loop;
end;
/

desc uam.CTSPECIMEN_PRESERV_METHOD;
desc mvz.CTSPECIMEN_PRESERV_METHOD;
begin
    for tn in (select COLLECTION_CDE, PRESERVE_METHOD from mvz.CTSPECIMEN_PRESERV_METHOD) loop
        begin
            insert into uam.CTSPECIMEN_PRESERV_METHOD (COLLECTION_CDE, PRESERVE_METHOD)
            values (tn.COLLECTION_CDE, tn.PRESERVE_METHOD);
            dbms_output.put_line('inserted into CTSPECIMEN_PRESERV_METHOD: ' || tn.COLLECTION_CDE || chr(9) || tn.PRESERVE_METHOD);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTSPECIMEN_PRESERV_METHOD: ' || tn.COLLECTION_CDE || chr(9) || tn.PRESERVE_METHOD);
        end;
    end loop;
end;
/

desc uam.CTTAXA_FORMULA;
desc mvz.CTTAXA_FORMULA;
begin
    for tn in (select TAXA_FORMULA from mvz.CTTAXA_FORMULA) loop
        begin
            insert into uam.CTTAXA_FORMULA (TAXA_FORMULA)
            values (tn.TAXA_FORMULA);
            dbms_output.put_line('inserted into CTTAXA_FORMULA: ' || tn.TAXA_FORMULA);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTTAXA_FORMULA: ' || tn.TAXA_FORMULA);
        end;
    end loop;
end;
/
    
desc uam.CTTAXONOMIC_AUTHORITY;
desc mvz.CTTAXONOMIC_AUTHORITY;
begin
    for tn in (select SOURCE_AUTHORITY from mvz.CTTAXONOMIC_AUTHORITY) loop
        begin
            insert into uam.CTTAXONOMIC_AUTHORITY (SOURCE_AUTHORITY)
            values (tn.SOURCE_AUTHORITY);
            dbms_output.put_line('inserted into CTTAXONOMIC_AUTHORITY: ' || tn.SOURCE_AUTHORITY);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTTAXONOMIC_AUTHORITY: ' || tn.SOURCE_AUTHORITY);
        end;
    end loop;
end;
/

desc uam.CTTAXON_RELATION;
desc mvz.CTTAXON_RELATION;
begin
    for tn in (select TAXON_RELATIONSHIP from mvz.CTTAXON_RELATION) loop
        begin
            insert into uam.CTTAXON_RELATION (TAXON_RELATIONSHIP)
            values (tn.TAXON_RELATIONSHIP);
            dbms_output.put_line('inserted into CTTAXON_RELATION: ' || tn.TAXON_RELATIONSHIP);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTTAXON_RELATION: ' || tn.TAXON_RELATIONSHIP);
        end;
    end loop;
end;
/

desc uam.CTTRANS_AGENT_ROLE;
desc mvz.CTTRANS_AGENT_ROLE;
begin
    for tn in (select TRANS_AGENT_ROLE, DESCRIPTION from mvz.CTTRANS_AGENT_ROLE) loop
        begin
            insert into uam.CTTRANS_AGENT_ROLE (TRANS_AGENT_ROLE, DESCRIPTION)
            values (tn.TRANS_AGENT_ROLE, tn.DESCRIPTION);
            dbms_output.put_line('inserted into CTTRANS_AGENT_ROLE: ' || tn.TRANS_AGENT_ROLE || chr(9) || tn.DESCRIPTION);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTTRANS_AGENT_ROLE: ' || tn.TRANS_AGENT_ROLE || chr(9) || tn.DESCRIPTION);
        end;
    end loop;
end;
/

desc uam.CTVERIFICATIONSTATUS;
desc mvz.CTVERIFICATIONSTATUS;
begin
    for tn in (select VERIFICATIONSTATUS from mvz.CTVERIFICATIONSTATUS) loop
        begin
            insert into uam.CTVERIFICATIONSTATUS (VERIFICATIONSTATUS)
            values (tn.VERIFICATIONSTATUS);
            dbms_output.put_line('inserted into CTVERIFICATIONSTATUS: ' || tn.VERIFICATIONSTATUS);
        exception when dup_val_on_index then
            dbms_output.put_line('dup value on CTVERIFICATIONSTATUS: ' || tn.VERIFICATIONSTATUS);
        end;
    end loop;
end;
/
    