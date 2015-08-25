CREATE TABLE taxonomy20090914 AS SELECT * FROM taxonomy;
--uam> CREATE TABLE taxonomy20090914 AS SELECT * FROM taxonomy;

create table ctnomenclatural_code (nomenclatural_code varchar2(10) not null);
create or replace public synonym ctnomenclatural_code for ctnomenclatural_code;
grant select on ctnomenclatural_code to public;
grant all on ctnomenclatural_code to manage_codetables;

insert into ctnomenclatural_code values ('ICZN');
insert into ctnomenclatural_code values ('ICBN');
insert into ctnomenclatural_code values ('unknown');

ALTER TABLE ctnomenclatural_code ADD constraint pk_ctnomenclatural_code PRIMARY KEY (nomenclatural_code);

revoke insert,update,delete on taxonomy from manage_taxonomy;

drop trigger trg_mk_sci_name;

CREATE TABLE te_tax AS SELECT * FROM taxonomy;

ALTER TABLE te_tax ADD status NUMBER;
UPDATE te_tax SET status=0;
CREATE INDEX idx_te_tax_st ON te_tax(status);
CREATE UNIQUE INDEX idx_te_tax_tnid ON te_tax(taxon_name_id);

ANALYZE TABLE te_tax COMPUTE STATISTICS;

UPDATE te_tax SET nomenclatural_code='unknown' WHERE nomenclatural_code IS null;

ALTER TABLE te_tax MODIFY nomenclatural_code NOT NULL;
    
-- see if we can do better for used taxa
UPDATE te_tax SET nomenclatural_code='ICBN' WHERE nomenclatural_code='unknown' AND taxon_name_id IN (
    SELECT taxon_name_id FROM 
        identification_taxonomy,
        identification,
        cataloged_item,
        collection
    WHERE
        identification_taxonomy.identification_id=identification.identification_id AND
        identification.collection_object_id= cataloged_item.collection_object_id AND
        cataloged_item.collection_id=collection.collection_id AND
        collection.collection_cde = 'Herb'
);
-- once we have plants, we can set everything that's not a plant to animals

UPDATE te_tax SET nomenclatural_code='ICZN' WHERE nomenclatural_code='unknown' AND taxon_name_id IN (
     SELECT taxon_name_id FROM 
        identification_taxonomy
);
-- we've been ignoring subgenus - make a clone of those records

CREATE TABLE tt AS SELECT * FROM te_tax WHERE subgenus IS NOT NULL;

UPDATE tt SET scientific_name='noneyet' || taxon_name_id;
UPDATE te_tax SET subgenus = NULL;

ALTER TABLE tt MODIFY taxon_name_id NULL;
UPDATE tt SET taxon_name_id=NULL;

CREATE OR REPLACE TRIGGER trg_mk_sci_name_temp
BEFORE INSERT OR UPDATE ON te_tax
FOR EACH ROW

BEGIN
if :new.taxon_name_id is null then
	select sq_taxon_name_id.nextval into :new.taxon_name_id from dual;
end if;
end;
/

INSERT INTO te_tax (SELECT * FROM tt);

DROP TRIGGER trg_mk_sci_name_temp;

ALTER TABLE te_tax DROP COLUMN SCI_NAME_WITH_AUTHS;
ALTER TABLE te_tax DROP COLUMN SCI_NAME_NO_IRANK;
ALTER TABLE te_tax ADD display_name VARCHAR2(255);

DECLARE 
    c NUMBER;
    ar_t VARCHAR2(255);
BEGIN
    FOR r IN (SELECT taxon_name_id,genus,species,author_text,subspecies,infraspecific_author
        FROM te_tax
        WHERE
            genus IS NOT NULL AND 
            species IS NOT NULL AND
            subspecies IS NOT NULL AND
            species!=subspecies AND
            infraspecific_author IS NULL AND
            author_text IS NOT NULL AND
            nomenclatural_code='ICBN'
    ) LOOP
        SELECT COUNT(DISTINCT(author_text)) INTO c FROM te_tax WHERE genus=r.genus AND species=r.species AND subspecies IS NULL;
        IF c = 1 THEN
            SELECT author_text INTO ar_t FROM te_tax WHERE genus=r.genus AND species=r.species AND subspecies IS NULL;
            UPDATE te_tax SET infraspecific_author=author_text,author_text=ar_t WHERE taxon_name_id=r.taxon_name_id;
        END IF;
    END LOOP;
END;
/


CREATE OR REPLACE PROCEDURE p_temp_taxonomy IS
	nScientificName varchar2(4000);
	nFullTaxonomy varchar2(4000);
	nDisplayName varchar2(4000);
	c NUMBER;
BEGIN
    FOR r IN (SELECT * FROM te_tax WHERE status=0 AND ROWNUM < 500000) LOOP
        nScientificName:='';
        nFullTaxonomy:='';
        nDisplayName:='';
        c:=0;
        if r.nomenclatural_code='ICBN' then
        	nDisplayName:=prependTaxonomy(nDisplayName, r.INFRASPECIFIC_AUTHOR);
        end if;
        if r.nomenclatural_code='ICZN' then
        	nDisplayName:=prependTaxonomy(nDisplayName, r.AUTHOR_TEXT);
        end if;
        nScientificName:=prependTaxonomy(nScientificName, r.subspecies);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.subspecies);
        nDisplayName:=prependTaxonomy(nDisplayName, r.subspecies,1);
        
        if r.nomenclatural_code='ICBN' then
        	nScientificName:=prependTaxonomy(nScientificName, r.infraspecific_rank);
        	nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.infraspecific_rank);
        	nDisplayName:=prependTaxonomy(nDisplayName, r.infraspecific_rank);
        end if;
        if r.nomenclatural_code='ICBN' then
        	nDisplayName:=prependTaxonomy(nDisplayName, r.AUTHOR_TEXT);
        end if;
        
        nScientificName:=prependTaxonomy(nScientificName, r.species);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.species);
        nDisplayName:=prependTaxonomy(nDisplayName, r.species,1);
        
        if r.subgenus is not null then
        	nScientificName:=prependTaxonomy(nScientificName, '(' || r.subgenus || ')');
        	nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, '(' || r.subgenus || ')');
        	nDisplayName:=prependTaxonomy(nDisplayName, '(' || r.subgenus || ')',1);
        end if;
        
        nScientificName:=prependTaxonomy(nScientificName, r.genus);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.genus);
        nDisplayName:=prependTaxonomy(nDisplayName, r.genus,1);
        
        nScientificName:=prependTaxonomy(nScientificName, r.tribe,0,1);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.tribe);
        nDisplayName:=prependTaxonomy(nDisplayName, r.tribe,0,1);
        
        nScientificName:=prependTaxonomy(nScientificName, r.subfamily,0,1);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.subfamily);
        nDisplayName:=prependTaxonomy(nDisplayName, r.subfamily,0,1);
        
        nScientificName:=prependTaxonomy(nScientificName, r.family,0,1);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.family);
        nDisplayName:=prependTaxonomy(nDisplayName, r.family,0,1);
        
        nScientificName:=prependTaxonomy(nScientificName, r.superfamily,0,1);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.superfamily);
        nDisplayName:=prependTaxonomy(nDisplayName, r.superfamily,0,1);
        
        nScientificName:=prependTaxonomy(nScientificName, r.suborder,0,1);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.suborder);
        nDisplayName:=prependTaxonomy(nDisplayName, r.suborder,0,1);
        
        nScientificName:=prependTaxonomy(nScientificName, r.phylorder,0,1);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.phylorder);
        nDisplayName:=prependTaxonomy(nDisplayName, r.phylorder,0,1);
        
        nScientificName:=prependTaxonomy(nScientificName, r.subclass,0,1);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.subclass);
        nDisplayName:=prependTaxonomy(nDisplayName, r.subclass,0,1);
        
        nScientificName:=prependTaxonomy(nScientificName, r.phylclass,0,1);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.phylclass);
        nDisplayName:=prependTaxonomy(nDisplayName, r.phylclass,0,1);
        
        nScientificName:=prependTaxonomy(nScientificName, r.phylum,0,1);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.phylum);
        nDisplayName:=prependTaxonomy(nDisplayName, r.phylum,0,1);
        
        nScientificName:=prependTaxonomy(nScientificName, r.kingdom,0,1);
        nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, r.kingdom);
        nDisplayName:=prependTaxonomy(nDisplayName, r.kingdom,0,1);
         
        IF r.scientific_name != nScientificName THEN
            SELECT COUNT(*) INTO c FROM identification_taxonomy WHERE taxon_name_id=r.taxon_name_id;
            IF c != 0 THEN
                UPDATE te_tax SET status=2 WHERE taxon_name_id=r.taxon_name_id;
            END IF;
        END IF;
        UPDATE te_tax SET 
            scientific_name=nScientificName,
            full_taxon_name=nFullTaxonomy,
            display_name=nDisplayName,
            status=1
        WHERE
            taxon_name_id=r.taxon_name_id
        ;
    END LOOP;
END;
/
sho err
-- dammit....
UPDATE te_tax SET status=0 WHERE status != 0;

exec p_temp_taxonomy;

SELECT status,COUNT(*) FROM te_tax GROUP BY status;



-- in test, there are duplicate scientific_names.
-- CAREFULLY CHECK THE DELETES BELOW!!!!
--

select scientific_name,count(*) from te_tax having count(*) > 1 group by scientific_name;
    
SELECT DISTINCT(source_authority) FROM (
    select scientific_name,source_authority,count(*) from te_tax having count(*) > 1 group by scientific_name,source_authority
);
    
SELECT scientific_name FROM (
 select scientific_name,source_authority,count(*) from te_tax having count(*) > 1 group by scientific_name,source_authority
) WHERE source_authority='SACC';
UPDATE identification_taxonomy SET taxon_name_id=1106003 WHERE taxon_name_id=10021680;
UPDATE citation SET CITED_TAXON_NAME_ID=1106003 WHERE CITED_TAXON_NAME_ID=10021680;
DELETE FROM te_tax WHERE taxon_name_id=10021680;

SELECT scientific_name FROM (
 select scientific_name,source_authority,count(*) from te_tax having count(*) > 1 group by scientific_name,source_authority
) WHERE source_authority='Mammal Species of the World';
  
UPDATE identification_taxonomy SET taxon_name_id=425 WHERE taxon_name_id=10020727;
UPDATE citation SET CITED_TAXON_NAME_ID=425 WHERE CITED_TAXON_NAME_ID=10020727;
DELETE FROM te_tax WHERE taxon_name_id=10020727;
  
   

UPDATE te_tax SET nomenclatural_code='ICBN',status=0 WHERE scientific_name IN (
 select scientific_name from te_tax WHERE source_authority='IPNI' having count(*) > 1  group by scientific_name
) ;

exec p_temp_taxonomy;
SELECT status,COUNT(*) FROM te_tax GROUP BY status;

                           
select scientific_name from te_tax having count(*) > 1 group by scientific_name;
-- still 4K left over - randomly whack one of them
     
CREATE INDEX temp_idx_te_tax_name ON te_tax(scientific_name) TABLESPACE uam_idx_1;
   
DECLARE 
    mit NUMBER;
    mat NUMBER;
    c NUMBER;
BEGIN
    FOR r IN (SELECT * FROM (select scientific_name from te_tax having count(*) > 1 group by scientific_name) WHERE ROWNUM<500) LOOP
         dbms_output.put_line(r.scientific_name);
         SELECT MIN(taxon_name_id) INTO mit FROM te_tax WHERE scientific_name=r.scientific_name;
         SELECT MAX(taxon_name_id) INTO mat FROM te_tax WHERE scientific_name=r.scientific_name;
         --dbms_output.put_line(mit);
         --dbms_output.put_line(mat);
         --dbms_output.put_line('-----------------------------');
         UPDATE identification_taxonomy SET taxon_name_id=mit WHERE taxon_name_id=mat;
         UPDATE citation SET CITED_TAXON_NAME_ID=mit WHERE CITED_TAXON_NAME_ID=mat;
         DELETE FROM common_name WHERE taxon_name_id=mat;
         DELETE FROM taxon_relations WHERE taxon_name_id=mat OR related_taxon_name_id=mat;
         DELETE FROM te_tax WHERE taxon_name_id=mat;
    END LOOP;
END;
/
     

-- run this as many times as necessary to update all taxonomy records

--kill our status column
ALTER TABLE te_tax DROP COLUMN status;
DROP INDEX temp_idx_te_tax_name;

-- and once it's all done, drop everything related to taxonomy
DROP TRIGGER TRG_MK_SCI_NAME;
DROP TRIGGER UPDATE_ID_AFTER_TAXON_CHANGE;
DROP TRIGGER TRG_UP_TAX;

DROP INDEX IU_TAXON_SCINAME;
DROP INDEX IX_TAXONOMY_SCINAME_U;
DROP INDEX IX_TAXON_FULLTAXONNAME;
DROP INDEX IX_TAXON_PHYLCLASS;
DROP INDEX IX_TAXON_PHYLORDER;
DROP INDEX IX_TAXON_SOURCEAUTHORITY;



alter table citation drop CONSTRAINT FK_CITATION_TAXONOMY;
alter table common_name drop CONSTRAINT FK_COMMONNAME_TAXONOMY;
alter table identification_taxonomy drop CONSTRAINT FK_IDTAXONOMY_TAXONOMY;
alter table taxon_relations drop CONSTRAINT FK_TAXONRELN_TAXONOMY_RTNID;
alter table taxon_relations drop CONSTRAINT FK_TAXONRELN_TAXONOMY_TNID;

ALTER TABLE taxonomy DROP CONSTRAINT pk_taxonomy;





DROP INDEX IX_TAXON_TNID_SCINAME_FULLNAME;
DROP INDEX IX_TAXON_VALIDCATALOGTERMFG;
DROP INDEX PK_TAXONOMY;

drop public synonym taxonomy;

--- lock tables with relationships to taxonomy
LOCK TABLE citation IN EXCLUSIVE MODE;
LOCK TABLE common_name IN EXCLUSIVE MODE;
LOCK TABLE identification_taxonomy IN EXCLUSIVE MODE;
LOCK TABLE taxon_relations IN EXCLUSIVE MODE;

-- then.....

-- move taxonomy table out of the way
ALTER TABLE taxonomy RENAME TO taxonomy_old;
-- move the new table in
ALTER TABLE te_tax RENAME TO taxonomy;
-- recreate everything related to taxonomy

ALTER TABLE taxonomy MODIFY scientific_name VARCHAR2(255);
ALTER TABLE taxonomy MODIFY display_name VARCHAR2(255);







alter table taxonomy
add constraint PK_TAXONOMY
PRIMARY KEY (TAXON_NAME_ID)
using index
TABLESPACE UAM_IDX_1;

-- create foreign key constraints
alter table citation
add CONSTRAINT FK_CITATION_TAXONOMY
FOREIGN KEY (CITED_TAXON_NAME_ID)
REFERENCES TAXONOMY (TAXON_NAME_ID);

alter table common_name
add CONSTRAINT FK_COMMONNAME_TAXONOMY
FOREIGN KEY (TAXON_NAME_ID)
REFERENCES TAXONOMY (TAXON_NAME_ID);

alter table identification_taxonomy
add CONSTRAINT FK_IDTAXONOMY_TAXONOMY
FOREIGN KEY (TAXON_NAME_ID)
REFERENCES TAXONOMY (TAXON_NAME_ID);

alter table taxon_relations
add CONSTRAINT FK_TAXONRELN_TAXONOMY_RTNID
FOREIGN KEY (RELATED_TAXON_NAME_ID)
REFERENCES TAXONOMY (TAXON_NAME_ID);

alter table taxon_relations
add CONSTRAINT FK_TAXONRELN_TAXONOMY_TNID
FOREIGN KEY (TAXON_NAME_ID)
REFERENCES TAXONOMY (TAXON_NAME_ID);

alter table taxonomy
add CONSTRAINT FK_CTINFRASPECIFIC_RANK
FOREIGN KEY (INFRASPECIFIC_RANK)
REFERENCES CTINFRASPECIFIC_RANK (INFRASPECIFIC_RANK);

alter table taxonomy
add CONSTRAINT FK_CTTAXONOMIC_AUTHORITY
FOREIGN KEY (SOURCE_AUTHORITY)
REFERENCES CTTAXONOMIC_AUTHORITY (SOURCE_AUTHORITY);

ALTER TABLE taxonomy
add CONSTRAINT fk_ctnomenclatural_code
FOREIGN KEY (nomenclatural_code)
REFERENCES ctnomenclatural_code(nomenclatural_code);

----------------------------------- fail -----------------------------
CREATE UNIQUE INDEX IU_TAXON_SCINAME
ON TAXONOMY (SCIENTIFIC_NAME)
TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXONOMY_SCINAME_U
ON TAXONOMY (UPPER(SCIENTIFIC_NAME))
TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXON_FULLTAXONNAME
ON TAXONOMY (FULL_TAXON_NAME)
TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXON_PHYLCLASS
ON TAXONOMY (PHYLCLASS)
TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXON_PHYLORDER
ON TAXONOMY (PHYLORDER)
TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXON_SOURCEAUTHORITY
ON TAXONOMY (SOURCE_AUTHORITY)
TABLESPACE UAM_IDX_1;
        
----------------------------------- fail ------------------------------------
CREATE INDEX IX_TAXON_TNID_SCINAME_FULLNAME
ON TAXONOMY (TAXON_NAME_ID, SCIENTIFIC_NAME, FULL_TAXON_NAME)
TABLESPACE UAM_IDX_1;

CREATE INDEX IX_TAXON_VALIDCATALOGTERMFG
ON TAXONOMY (VALID_CATALOG_TERM_FG)
TABLESPACE UAM_IDX_1;

run functions/prependTaxonomy.sql
run TRIGGERS/trg_taxo _names.sql

-- give rights back
CREATE OR REPLACE PUBLIC SYNONYM taxonomy FOR taxonomy;
GRANT insert,update,delete on taxonomy TO manage_taxonomy;
GRANT SELECT ON taxonomy TO PUBLIC;
-- unlock everythign
COMMIT;

ANALYZE TABLE taxonomy COMPUTE STATISTICS;

-- clean up
DROP INDEX idx_te_tax_st;
DROP INDEX idx_te_tax_tnid;
DROP PROCEDURE p_temp_taxonomy;
DROP TABLE te_tax;