--Merge uam and mvz taxonomy
create table lkv_mvz_taxonomy_happy as
select * from mvz.taxonomy m
where m.scientific_name not in (select scientific_name from uam.taxonomy);
    
select max(taxon_name_id) from uam.taxonomy;
select min(taxon_name_id) from mvz.taxonomy;
select max(taxon_name_id) from mvz.taxonomy;

create table lkv_mvz_taxon_name_id_lookup as select 
	m.taxon_name_id original_id,
	m.taxon_name_id new_id
	from lkv_mvz_taxonomy_happy m;
	
create table lkv_mvz_taxonomy_left as 
select * from mvz.taxonomy
where mvz.taxonomy.scientific_name in (select scientific_name from uam.taxonomy);
	
select count(*) from lkv_mvz_taxonomy_left;

create table lkv_taxamerge as select
 t.TAXON_NAME_ID,
 t.PHYLCLASS,
 t.PHYLORDER,
 t.SUBORDER,
 t.FAMILY,
 t.SUBFAMILY,
 t.GENUS,
 t.SUBGENUS,
 t.SPECIES,
 t.SUBSPECIES,
 t.VALID_CATALOG_TERM_FG,
 t.SOURCE_AUTHORITY,
 t.FULL_TAXON_NAME,
 t.SCIENTIFIC_NAME,
 t.AUTHOR_TEXT,
 t.TRIBE,
 t.INFRASPECIFIC_RANK,
 t.TAXON_REMARKS,
 t.PHYLUM,
 t.KINGDOM,
 t.NOMENCLATURAL_CODE,
 t.INFRASPECIFIC_AUTHOR,
 t.SUBCLASS,
 t.SUPERFAMILY,
 m.TAXON_NAME_ID mTAXON_NAME_ID,
 m.PHYLCLASS mPHYLCLASS,
 m.PHYLORDER mPHYLORDER,
 m.SUBORDER mSUBORDER,
 m.FAMILY mFAMILY,
 m.SUBFAMILY mSUBFAMILY,
 m.GENUS mGENUS,
 m.SUBGENUS  mSUBGENUS,
 m.SPECIES mSPECIES,
 m.SUBSPECIES mSUBSPECIES,
 m.VALID_CATALOG_TERM_FG mVALID_CATALOG_TERM_FG,
 m.SOURCE_AUTHORITY mSOURCE_AUTHORITY, 
 m.FULL_TAXON_NAME mFULL_TAXON_NAME,
 m.SCIENTIFIC_NAME mSCIENTIFIC_NAME,
 m.AUTHOR_TEXT mAUTHOR_TEXT,
 m.TRIBE mTRIBE,
 m.INFRASPECIFIC_RANK mINFRASPECIFIC_RANK,
 m.TAXON_REMARKS mTAXON_REMARKS,
 m.PHYLUM mPHYLUM,
 m.KINGDOM mKINGDOM,
 m.NOMENCLATURAL_CODE mNOMENCLATURAL_CODE,
 m.INFRASPECIFIC_AUTHOR mINFRASPECIFIC_AUTHOR,
 m.SUBCLASS mSUBCLASS,
 m.SUPERFAMILY mSUPERFAMILY
from
 taxonomy t,
 lkv_mvz_taxonomy_left m
where t.scientific_name = m.scientific_name;

select count(*) from lkv_taxamerge;

update lkv_taxamerge set PHYLCLASS = mPHYLCLASS where PHYLCLASS is null;
update lkv_taxamerge set PHYLORDER = mPHYLORDER where PHYLORDER is null;
update lkv_taxamerge set SUBORDER = mSUBORDER where SUBORDER is null;
update lkv_taxamerge set FAMILY = mFAMILY where FAMILY is null;
update lkv_taxamerge set SUBFAMILY = mSUBFAMILY where SUBFAMILY is null;
update lkv_taxamerge set SUBGENUS = mSUBGENUS where SUBGENUS is null;
update lkv_taxamerge set TRIBE = mTRIBE where TRIBE is null;
update lkv_taxamerge set PHYLUM = mPHYLUM where PHYLUM is null;
update lkv_taxamerge set KINGDOM = mKINGDOM where KINGDOM is null;
update lkv_taxamerge set NOMENCLATURAL_CODE= mNOMENCLATURAL_CODE where NOMENCLATURAL_CODE is null;
update lkv_taxamerge set AUTHOR_TEXT= mAUTHOR_TEXT where AUTHOR_TEXT is null;
update lkv_taxamerge set TAXON_REMARKS= mTAXON_REMARKS where TAXON_REMARKS is null;
update lkv_taxamerge set SUBCLASS = mSUBCLASS where SUBCLASS is null;
update lkv_taxamerge set SUPERFAMILY = mSUPERFAMILY where SUPERFAMILY is null;

update lkv_taxamerge set mPHYLCLASS = PHYLCLASS where mPHYLCLASS is null;
update lkv_taxamerge set mPHYLORDER = PHYLORDER where mPHYLORDER is null;
update lkv_taxamerge set mSUBORDER = SUBORDER where mSUBORDER is null;
update lkv_taxamerge set mFAMILY = FAMILY where mFAMILY is null;
update lkv_taxamerge set mSUBFAMILY = SUBFAMILY where mSUBFAMILY is null;
update lkv_taxamerge set mSUBGENUS = SUBGENUS where mSUBGENUS is null;
update lkv_taxamerge set mTRIBE = TRIBE where mTRIBE is null;
update lkv_taxamerge set mPHYLUM = PHYLUM where mPHYLUM is null;
update lkv_taxamerge set mKINGDOM = KINGDOM where mKINGDOM is null;
update lkv_taxamerge set mNOMENCLATURAL_CODE= NOMENCLATURAL_CODE where mNOMENCLATURAL_CODE is null;
update lkv_taxamerge set mAUTHOR_TEXT= AUTHOR_TEXT where mAUTHOR_TEXT is null;
update lkv_taxamerge set mTAXON_REMARKS= TAXON_REMARKS where mTAXON_REMARKS is null;
update lkv_taxamerge set mSUBCLASS = SUBCLASS where mSUBCLASS is null;
update lkv_taxamerge set mSUPERFAMILY = SUPERFAMILY where mSUPERFAMILY is null;

/* !!!! strange error. max length of author_text is only 41.
ERROR at line 1:
ORA-12899: value too large for column "UAM"."LKV_TAXAMERGE"."MAUTHOR_TEXT"
(actual: 68, maximum: 60)
TAXON_NAME_ID AUTHOR_TEXT
------------- ------------------------------------------------------------
     10000008 Savage and Wake, 2001, Copeia 2001:52-64.
uam@arctos> select mAUTHOR_TEXT from lkv_taxamerge where length(mAUTHOR_TEXT)=64;

MAUTHOR_TEXT
----------------------------------------------------------------------
S?nchez-Herra?z, Barbadillo-Escriv?, Machordom and Sanch?z, 2000
*/

ALTER TABLE lkv_taxamerge MODIFY MAUTHOR_TEXT VARCHAR2(70);

alter table lkv_taxamerge add key varchar2(4000);
alter table lkv_taxamerge add mkey varchar2(4000);

update lkv_taxamerge set key =
 PHYLCLASS ||':'||
 PHYLORDER ||':'||
 SUBORDER ||':'||
 FAMILY ||':'||
 SUBFAMILY ||':'||
 GENUS ||':'||
 SUBGENUS ||':'||
 SPECIES ||':'||
 SUBSPECIES ||':'||
 TRIBE ||':'||
 INFRASPECIFIC_RANK ||':'||
 PHYLUM ||':'||
 KINGDOM ||':'||
 SUBCLASS ||':'||
 SUPERFAMILY;

update lkv_taxamerge set mkey =
 mPHYLCLASS ||':'||
 mPHYLORDER ||':'||
 mSUBORDER ||':'||
 mFAMILY ||':'||
 mSUBFAMILY ||':'||
 mGENUS ||':'||
 mSUBGENUS ||':'||
 mSPECIES ||':'||
 mSUBSPECIES ||':'||
 mTRIBE ||':'||
 mINFRASPECIFIC_RANK ||':'||
 mPHYLUM ||':'||
 mKINGDOM ||':'||
 mSUBCLASS ||':'||
 mSUPERFAMILY;

select count(*) from lkv_taxamerge;
select count(*) from lkv_taxamerge where key = mkey;

update lkv_taxamerge set TAXON_REMARKS = null 
where TAXON_REMARKS = 'Imported from ITIS 6 Feb 2007';

select mauthor_text from lkv_taxamerge 
where author_text is null and mauthor_text is not null;

begin
for r in (select * from lkv_taxamerge where key = mkey) loop
	update uam.taxonomy set
		PHYLCLASS=r.PHYLCLASS,
		PHYLORDER=r.PHYLORDER,
		SUBORDER=r.SUBORDER,
		FAMILY=r.FAMILY,
		SUBFAMILY=r.SUBFAMILY,
		GENUS=r.GENUS,
		SUBGENUS=r.SUBGENUS,
		SPECIES=r.SPECIES,
		SUBSPECIES=r.SUBSPECIES,
		VALID_CATALOG_TERM_FG=r.VALID_CATALOG_TERM_FG,
		SOURCE_AUTHORITY=r.SOURCE_AUTHORITY,
		AUTHOR_TEXT=r.AUTHOR_TEXT,
		TRIBE=r.TRIBE,
		INFRASPECIFIC_RANK=r.INFRASPECIFIC_RANK,
		TAXON_REMARKS=r.TAXON_REMARKS,
		PHYLUM=r.PHYLUM,
		KINGDOM=r.KINGDOM,
		NOMENCLATURAL_CODE=r.NOMENCLATURAL_CODE,
		INFRASPECIFIC_AUTHOR=r.INFRASPECIFIC_AUTHOR,
		SUBCLASS=r.SUBCLASS,
		SUPERFAMILY=r.SUPERFAMILY
	where TAXON_NAME_ID=r.TAXON_NAME_ID;
end loop;
end;
/
--- insert these into the lookup table

begin
for r in (select * from lkv_taxamerge where key = mkey) loop
	insert into lkv_mvz_taxon_name_id_lookup (
		original_id,
		new_id
	) values (
		r.mtaxon_name_id,
		r.taxon_name_id
	);
end loop;
end;
/

-- clean up
delete from lkv_taxamerge where key = mkey;

-- the rest are MVZ's according to our earlier agreement, except they seldom record author and we think that's important, so.....
update lkv_taxamerge set mauthor_text = author_text 
where mauthor_text is null and author_text is not null;

/*
alter table lkv_taxamerge add fg number;
update lkv_taxamerge set fg = 1 where taxon_name_id = 2193852;
*/

begin
for r in (select * from lkv_taxamerge) loop
	begin
		update taxonomy set
			PHYLCLASS=r.mPHYLCLASS,
			PHYLORDER=r.mPHYLORDER,
			SUBORDER=r.mSUBORDER,
			FAMILY=r.mFAMILY,
			SUBFAMILY=r.mSUBFAMILY,
			GENUS=r.mGENUS,
			SUBGENUS=r.mSUBGENUS,
			SPECIES=r.mSPECIES,
			SUBSPECIES=r.mSUBSPECIES,
			VALID_CATALOG_TERM_FG=r.mVALID_CATALOG_TERM_FG,
			SOURCE_AUTHORITY=r.mSOURCE_AUTHORITY,
			AUTHOR_TEXT=r.mAUTHOR_TEXT,
			TRIBE=r.mTRIBE,
			INFRASPECIFIC_RANK=r.mINFRASPECIFIC_RANK,
			TAXON_REMARKS=r.mTAXON_REMARKS,
			PHYLUM=r.mPHYLUM,
			KINGDOM=r.mKINGDOM,
			NOMENCLATURAL_CODE=r.mNOMENCLATURAL_CODE,
			INFRASPECIFIC_AUTHOR=r.mINFRASPECIFIC_AUTHOR,
			SUBCLASS=r.mSUBCLASS,
			SUPERFAMILY=r.mSUPERFAMILY
		where TAXON_NAME_ID=r.TAXON_NAME_ID;
	exception when others then
		dbms_output.put_line('ERROR: ' || SQLERRM || ' for :' || r.taxon_name_id);
	end;
end loop;
end;
/

--- insert these into the lookup table
begin
for r in (select * from lkv_taxamerge) loop
	insert into lkv_mvz_taxon_name_id_lookup (
		original_id,
		new_id
	) values (
		r.mtaxon_name_id,
		r.taxon_name_id
	);
end loop;
end;
/

-- confirm that lookup table contains the correct number of records....
select count(*) from lkv_mvz_taxon_name_id_lookup;
select count(*) from mvz.taxonomy;

alter trigger TRG_MK_SCI_NAME enable;

INSERT INTO uam.taxonomy (
 TAXON_NAME_ID,
 PHYLCLASS,
 PHYLORDER,
 SUBORDER,
 FAMILY,
 SUBFAMILY,
 GENUS,
 SUBGENUS,
 SPECIES,
 SUBSPECIES,
 VALID_CATALOG_TERM_FG,
 SOURCE_AUTHORITY,
 AUTHOR_TEXT,
 TRIBE,
 INFRASPECIFIC_RANK,
 TAXON_REMARKS,
 PHYLUM,
 KINGDOM,
 NOMENCLATURAL_CODE,
 INFRASPECIFIC_AUTHOR,
 SUBCLASS,
 SUPERFAMILY)
SELECT
 TAXON_NAME_ID,
 PHYLCLASS,
 PHYLORDER,
 SUBORDER,
 FAMILY,
 SUBFAMILY,
 GENUS,
 SUBGENUS,
 SPECIES,
 SUBSPECIES,
 VALID_CATALOG_TERM_FG,
 SOURCE_AUTHORITY,
 AUTHOR_TEXT,
 TRIBE,
 INFRASPECIFIC_RANK,
 TAXON_REMARKS,
 PHYLUM,
 KINGDOM,
 NOMENCLATURAL_CODE,
 INFRASPECIFIC_AUTHOR,
 SUBCLASS,
 SUPERFAMILY
FROM lkv_mvz_taxonomy_happy;

alter trigger TRG_MK_SCI_NAME DISABLE;

-- UPDATE fkeys TO taxon_name_id FROM lookup table.
--CITATION

select count(*) from uam.citation 
where cited_taxon_name_id >= 10000000 
and cited_taxon_name_id not in (select original_id from lkv_mvz_taxon_name_id_lookup);
select count(*) from uam.citation; 
select count(*) from mvz.citation;
select count(*) from uam.citation where cited_taxon_name_id >= 10000000;
select count(*) from uam.citation where cited_taxon_name_id IN (
    select original_id from lkv_mvz_taxon_name_id_lookup);

UPDATE uam.citation u
SET u.cited_taxon_name_id = (
    SELECT m.new_id FROM lkv_mvz_taxon_name_id_lookup m
    WHERE u.cited_taxon_name_id = m.original_id)
WHERE u.cited_taxon_name_id IN (
    SELECT original_id FROM lkv_mvz_taxon_name_id_lookup);

--COMMON_NAME
select count(*) from uam.common_name 
where taxon_name_id >= 10000000 
and taxon_name_id not in (select original_id from lkv_mvz_taxon_name_id_lookup);
select count(*) from uam.common_name; 
select count(*) from mvz.common_name;
select count(*) from uam.common_name where taxon_name_id >= 10000000;
select count(*) from uam.common_name where taxon_name_id IN (
    select original_id from lkv_mvz_taxon_name_id_lookup);

CREATE TABLE lkv_comname AS SELECT * FROM uam.common_name;
CREATE TABLE common_name_bak AS SELECT * FROM uam.common_name;

UPDATE uam.lkv_comname u
SET u.taxon_name_id = (
    SELECT m.new_id FROM lkv_mvz_taxon_name_id_lookup m
    WHERE u.taxon_name_id = m.original_id)
WHERE u.taxon_name_id IN (
    SELECT original_id FROM lkv_mvz_taxon_name_id_lookup);

select count(*) from (
    select count(*), taxon_name_id, common_name 
    from lkv_comname group by taxon_name_id, common_name having count(*) > 1
);

truncate table common_name;
insert into common_name 
select distinct taxon_name_id, common_name from lkv_comname;

--TAXON_RELATIONS
select count(*) from uam.taxon_relations 
where taxon_name_id >= 10000000 
and taxon_name_id not in (select original_id from lkv_mvz_taxon_name_id_lookup);
select count(*) from uam.taxon_relations; 
select count(*) from mvz.taxon_relations;
select count(*) from uam.taxon_relations where taxon_name_id >= 10000000;
select count(*) from uam.taxon_relations where taxon_name_id IN (
    select original_id from lkv_mvz_taxon_name_id_lookup);

UPDATE uam.taxon_relations u
SET u.taxon_name_id = (
    SELECT m.new_id FROM lkv_mvz_taxon_name_id_lookup m
    WHERE u.taxon_name_id = m.original_id)
WHERE u.taxon_name_id IN (
    SELECT original_id FROM lkv_mvz_taxon_name_id_lookup);
    
select count(*) from uam.taxon_relations 
where related_taxon_name_id >= 10000000 
and related_taxon_name_id not in (select original_id from lkv_mvz_taxon_name_id_lookup);
select count(*) from uam.taxon_relations; 
select count(*) from mvz.taxon_relations;
select count(*) from uam.taxon_relations where related_taxon_name_id >= 10000000;
select count(*) from uam.taxon_relations where related_taxon_name_id IN (
    select original_id from lkv_mvz_taxon_name_id_lookup);
    
create table lkv_taxon_rel as select * from taxon_relations;

UPDATE lkv_taxon_rel u
SET u.related_taxon_name_id = (
    SELECT m.new_id FROM lkv_mvz_taxon_name_id_lookup m
    WHERE u.related_taxon_name_id = m.original_id)
WHERE u.related_taxon_name_id IN (
    SELECT original_id FROM lkv_mvz_taxon_name_id_lookup);
    
select count(*), taxon_name_id, related_taxon_name_id, taxon_relationship 
from lkv_taxon_rel 
group by taxon_name_id, related_taxon_name_id, taxon_relationship 
having count(*) > 1;
/*
  COUNT(*) TAXON_NAME_ID RELATED_TAXON_NAME_ID
---------- ------------- ---------------------
TAXON_RELATIONSHIP
--------------------------------------------------
         2         58944                   448
synonym of

         2         72677                 70872
synonym of

         2       1075017               2080117
synonym of

select * from lkv_taxon_rel where taxon_name_id = 1075017 
and related_taxon_name_id = 2080117 and taxon_relationship = 'synonym of';

TAXON_NAME_ID RELATED_TAXON_NAME_ID
------------- ---------------------
TAXON_RELATIONSHIP
--------------------------------------------------
RELATION_AUTHORITY
---------------------------------------------
      1075017               2080117
synonym of
Massoia, E. and U. F. Pardinas, 1993

      1075017               2080117
synonym of
*/

CREATE TABLE taxon_relations_bak AS SELECT * FROM taxon_relations;

TRUNCATE TABLE taxon_relations;

DELETE FROM lkv_taxon_rel 
WHERE taxon_name_id = 1075017 
and related_taxon_name_id = 2080117 
and taxon_relationship = 'synonym of'
AND relation_authority IS NULL;

INSERT INTO taxon_relations (
    taxon_name_id, related_taxon_name_id, taxon_relationship, relation_authority)
SELECT DISTINCT 
    taxon_name_id, related_taxon_name_id, taxon_relationship, relation_authority
FROM lkv_taxon_rel;

--IDENTIFICATION_TAXONOMY
select count(*) from uam.identification_taxonomy 
where taxon_name_id >= 10000000 
and taxon_name_id not in (select original_id from lkv_mvz_taxon_name_id_lookup);
select count(*) from uam.identification_taxonomy; 
select count(*) from mvz.identification_taxonomy;
select count(*) from uam.identification_taxonomy where taxon_name_id >= 10000000;
select count(*) from uam.identification_taxonomy where taxon_name_id IN (
    select original_id from lkv_mvz_taxon_name_id_lookup);
    
UPDATE uam.identification_taxonomy u
SET u.taxon_name_id = (
    SELECT m.new_id FROM lkv_mvz_taxon_name_id_lookup m
    WHERE u.taxon_name_id = m.original_id)
WHERE u.taxon_name_id IN (
    SELECT original_id FROM lkv_mvz_taxon_name_id_lookup);
    