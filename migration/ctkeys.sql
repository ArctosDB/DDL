
select 
    user_tab_cols.table_name || chr(9) || 
    user_tab_cols.column_name  || chr(9) || 
    user_constraints.CONSTRAINT_NAME || chr(9) ||
    user_constraints.CONSTRAINT_TYPE
from 
    user_tab_cols,
    user_constraints,
    user_cons_columns
where 
    user_tab_cols.table_name like 'CT%' and 
    user_tab_cols.column_name !='DESCRIPTION' AND
    user_tab_cols.table_name=user_constraints.table_name AND
    user_constraints.constraint_name=user_cons_columns.constraint_name AND
    user_cons_columns.column_name=user_tab_cols.column_name
order by user_tab_cols.table_name, user_tab_cols.column_name;


select 
    user_tab_cols.table_name || chr(9) || 
    user_tab_cols.column_name  || chr(9) || 
    user_constraints.CONSTRAINT_NAME || chr(9) ||
    user_constraints.CONSTRAINT_TYPE
from 
    user_tab_cols,
    user_constraints,
    user_cons_columns
where 
    user_tab_cols.table_name=user_constraints.table_name AND
    user_constraints.constraint_name=user_cons_columns.constraint_name AND
    user_cons_columns.column_name=user_tab_cols.column_name AND
    user_tab_cols.table_name = 'MEDIA_LABELS';



CREATE OR REPLACE TRIGGER tr_ctjournal_name_ud
BEFORE UPDATE OR DELETE ON ctjournal_name
FOR EACH ROW
BEGIN
    FOR r IN (SELECT COUNT(*) c FROM publication_attributes
                 WHERE 
                 PUBLICATION_ATTRIBUTE='journal name' AND
                 PUB_ATT_VALUE=:old.journal_name) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		:OLD.journal_name || ' is used.');
        END IF;
    END LOOP;
END;
/
show err;



ALTER TABLE CTABUNDANCE
    add CONSTRAINT fk_CTABUNDANCE
    FOREIGN KEY (COLLECTION_CDE)
    REFERENCES CTCOLLECTION_CDE(COLLECTION_CDE);
    


ALTER TABLE accn
    add CONSTRAINT fk_CTACCN_STATUS
    FOREIGN KEY (ACCN_STATUS)
    REFERENCES CTACCN_STATUS(ACCN_STATUS);
    
ALTER TABLE accn
    add CONSTRAINT fk_CTACCN_TYPE
    FOREIGN KEY (ACCN_TYPE)
    REFERENCES CTACCN_TYPE(ACCN_TYPE);

ALTER TABLE addr
    add CONSTRAINT fk_CTADDR_TYPE
    FOREIGN KEY (ADDR_TYPE)
    REFERENCES CTADDR_TYPE(ADDR_TYPE);
    
DROP TABLE CTADDR_USE;

DROP TABLE CTAGENT_ADDR_JOB_TITLE;

DROP TABLE CTAGENT_ADDR_TYPE;

ALTER TABLE agent_name
    add CONSTRAINT fk_CTAGENT_NAME_TYPE
    FOREIGN KEY (AGENT_NAME_TYPE)
    REFERENCES CTAGENT_NAME_TYPE(AGENT_NAME_TYPE);
 
ALTER TABLE agent_relations
    add CONSTRAINT fk_CTAGENT_RELATIONSHIP
    FOREIGN KEY (AGENT_RELATIONSHIP)
    REFERENCES CTAGENT_RELATIONSHIP(AGENT_RELATIONSHIP);
      
DROP TABLE CTAGENT_ROLE;

INSERT INTO ctagent_type (agent_type) (
 select distinct(agent_type) from agent
 WHERE agent_type NOT IN (SELECT agent_type FROM ctagent_type))
 ;
 
ALTER TABLE agent
    add CONSTRAINT fk_CTAGENT_TYPE
    FOREIGN KEY (AGENT_TYPE)
    REFERENCES CTAGENT_TYPE(AGENT_TYPE);

CREATE OR REPLACE TRIGGER trg_ctabundance_ud
BEFORE UPDATE OR DELETE ON ctabundance
FOR EACH ROW
DECLARE
    c number;
    v attributes.attribute_value%TYPE;
    o collection.collection_cde%TYPE;
BEGIN
    v:=:old.abundance;
    o:=:OLD.COLLECTION_CDE;
    FOR r IN (SELECT COUNT(*) c FROM attributes,cataloged_item,collection
                 WHERE 
                 attributes.collection_object_id=cataloged_item.collection_object_id AND
                 cataloged_item.collection_id=collection.collection_id AND
                 attribute_type='abundance' AND 
                 attribute_value=v AND
                 collection.collection_cde=o) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		v || ' (c=' || r.c || ') is used in attributes for collection type ' || o);
        END IF;
    END LOOP;
END;
/
show err;


CREATE OR REPLACE TRIGGER trg_CTAGE_CLASS_ud
BEFORE UPDATE OR DELETE ON CTAGE_CLASS
FOR EACH ROW
DECLARE
    c number;
    v attributes.attribute_value%TYPE;
    o collection.collection_cde%TYPE;
BEGIN
    v:=:old.AGE_CLASS;
    o:=:OLD.COLLECTION_CDE;
    FOR r IN (SELECT COUNT(*) c FROM attributes,cataloged_item,collection
                 WHERE 
                 attributes.collection_object_id=cataloged_item.collection_object_id AND
                 cataloged_item.collection_id=collection.collection_id AND
                 attribute_type='age class' AND 
                 attribute_value=v AND
                 collection.collection_cde=o) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		v || ' (c=' || r.c || ') is used in attributes for collection type ' || o);
        END IF;
    END LOOP;
END;
/
show err;

DROP TABLE CTAGE_DET_METHOD;

DROP TABLE CTBIN_OBJ_ASPECT;
DROP TABLE CTBIN_OBJ_SUBJECT;
 
 
ALTER TABLE biol_indiv_relations
    add CONSTRAINT fk_CTBIOL_RELATIONS
    FOREIGN KEY (BIOL_INDIV_RELATIONSHIP)
    REFERENCES CTBIOL_RELATIONS(BIOL_INDIV_RELATIONSHIP);
 
ALTER TABLE borrow
    add CONSTRAINT fk_CTBORROW_STATUS
    FOREIGN KEY (BORROW_STATUS)
    REFERENCES CTBORROW_STATUS(BORROW_STATUS);
 
CREATE OR REPLACE TRIGGER trg_CTCASTE_ud
BEFORE UPDATE OR DELETE ON CTCASTE
FOR EACH ROW
BEGIN
    FOR r IN (SELECT COUNT(*) c FROM attributes,cataloged_item,collection
                 WHERE 
                 attributes.collection_object_id=cataloged_item.collection_object_id AND
                 cataloged_item.collection_id=collection.collection_id AND
                 attribute_type='caste' AND 
                 attribute_value=:OLD.caste AND
                 collection.collection_cde=:OLD.collection_cde) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		:OLD.caste || ' is used in attributes for collection type ' || :OLD.collection_cde);
        END IF;
    END LOOP;
END;
/
show err;

ALTER TABLE CTCATALOGED_ITEM_TYPE MODIFY CATALOGED_ITEM_TYPE CHAR(2);
   
INSERT INTO CTCATALOGED_ITEM_TYPE (CATALOGED_ITEM_TYPE) (
 select distinct(CATALOGED_ITEM_TYPE) from cataloged_item
 WHERE CATALOGED_ITEM_TYPE NOT IN (SELECT CATALOGED_ITEM_TYPE FROM CTCATALOGED_ITEM_TYPE))
 ;
 
ALTER TABLE cataloged_item
    add CONSTRAINT fk_CTCATALOGED_ITEM_TYPE
    FOREIGN KEY (CATALOGED_ITEM_TYPE)
    REFERENCES CTCATALOGED_ITEM_TYPE(CATALOGED_ITEM_TYPE);

ALTER TABLE citation
    add CONSTRAINT fk_CTCITATION_TYPE_STATUS
    FOREIGN KEY (TYPE_STATUS)
    REFERENCES CTCITATION_TYPE_STATUS(TYPE_STATUS);

DROP TABLE CTCOLLECTING_METHOD;
       	
ALTER TABLE collecting_event
    add CONSTRAINT fk_CTCOLLECTING_SOURCE
    FOREIGN KEY (COLLECTING_SOURCE)
    REFERENCES CTCOLLECTING_SOURCE(COLLECTING_SOURCE);

CREATE OR REPLACE TRIGGER trg_CTCASTE_ud
BEFORE UPDATE OR DELETE ON CTCASTE
FOR EACH ROW
BEGIN
    FOR r IN (SELECT COUNT(*) c FROM attributes,cataloged_item,collection
                 WHERE 
                 attributes.collection_object_id=cataloged_item.collection_object_id AND
                 cataloged_item.collection_id=collection.collection_id AND
                 attribute_type='caste' AND 
                 attribute_value=:OLD.caste AND
                 collection.collection_cde=:OLD.collection_cde) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		:OLD.caste || ' is used in attributes for collection type ' || :OLD.collection_cde);
        END IF;
    END LOOP;
END;
/
show err;

CREATE OR REPLACE TRIGGER tr_CTSPECIMEN_PART_NAME_ud
BEFORE UPDATE OR DELETE ON CTSPECIMEN_PART_NAME
FOR EACH ROW
BEGIN
    FOR r IN (SELECT COUNT(*) c FROM specimen_part,cataloged_item,collection
                 WHERE 
                 specimen_part.derived_from_cat_item=cataloged_item.collection_object_id AND
                 cataloged_item.collection_id=collection.collection_id AND
                 part_name=:OLD.part_name AND
                 collection.collection_cde=:OLD.collection_cde) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		:OLD.part_name || ' is used for collection type ' || :OLD.collection_cde);
        END IF;
    END LOOP;
END;
/
show err;

DROP TABLE CTSPECIMEN_PART_NAME_UAM;
DROP TABLE CTSPECIMEN_PART_NAME_090219;
DROP TABLE CTSPECIMEN_PART_NAME_090225;

ALTER TABLE CTCOLLECTOR_ROLE MODIFY COLLECTOR_ROLE CHAR(1);
    
ALTER TABLE collector
    add CONSTRAINT fk_CTCOLLECTOR_ROLE
    FOREIGN KEY (COLLECTOR_ROLE)
    REFERENCES CTCOLLECTOR_ROLE(COLLECTOR_ROLE);

ALTER TABLE collection_contacts
    add CONSTRAINT fk_CTCOLL_CONTACT_ROLE
    FOREIGN KEY (CONTACT_ROLE)
    REFERENCES CTCOLL_CONTACT_ROLE(CONTACT_ROLE);

ALTER TABLE CTCOLL_OBJECT_TYPE MODIFY COLL_OBJECT_TYPE CHAR(2);
 
INSERT INTO CTCOLL_OBJECT_TYPE (COLL_OBJECT_TYPE) (
 select distinct(COLL_OBJECT_TYPE) from coll_object
 WHERE COLL_OBJECT_TYPE NOT IN (SELECT COLL_OBJECT_TYPE FROM CTCOLL_OBJECT_TYPE))
 ;
 
ALTER TABLE coll_object
    add CONSTRAINT fk_CTCOLL_OBJECT_TYPE
    FOREIGN KEY (COLL_OBJECT_TYPE)
    REFERENCES CTCOLL_OBJECT_TYPE(COLL_OBJECT_TYPE);

INSERT INTO CTCOLL_OBJ_DISP (COLL_OBJ_DISPOSITION) (
 select distinct(COLL_OBJ_DISPOSITION) from coll_object
 WHERE COLL_OBJ_DISPOSITION NOT IN (SELECT COLL_OBJ_DISPOSITION FROM CTCOLL_OBJ_DISP))
 ;
 
ALTER TABLE coll_object
    add CONSTRAINT fk_CTCOLL_OBJ_DISP
    FOREIGN KEY (COLL_OBJ_DISPOSITION)
    REFERENCES CTCOLL_OBJ_DISP(COLL_OBJ_DISPOSITION);
 
INSERT INTO CTFLAGS (FLAGS) (
 select distinct(FLAGS) from coll_object
 WHERE FLAGS NOT IN (SELECT FLAGS FROM CTFLAGS))
;

ALTER TABLE coll_object
    add CONSTRAINT fk_CTFLAGS
    FOREIGN KEY (FLAGS)
    REFERENCES CTFLAGS(FLAGS);

DROP TABLE CTCOLL_OBJ_FLAGS;

INSERT INTO CTCOLL_OTHER_ID_TYPE (OTHER_ID_TYPE) (
 select distinct(OTHER_ID_TYPE) from coll_obj_other_id_num
 WHERE OTHER_ID_TYPE NOT IN (SELECT OTHER_ID_TYPE FROM CTCOLL_OTHER_ID_TYPE))
;

ALTER TABLE coll_obj_other_id_num
    add CONSTRAINT fk_CTCOLL_OTHER_ID_TYPE
    FOREIGN KEY (OTHER_ID_TYPE)
    REFERENCES CTCOLL_OTHER_ID_TYPE(OTHER_ID_TYPE);

ALTER TABLE container
    add CONSTRAINT fk_CTCONTAINER_TYPE
    FOREIGN KEY (CONTAINER_TYPE)
    REFERENCES CTCONTAINER_TYPE(CONTAINER_TYPE);

INSERT INTO CTCONTINENT (CONTINENT_OCEAN) (
 select distinct(CONTINENT_OCEAN) from geog_auth_rec
 WHERE CONTINENT_OCEAN NOT IN (SELECT CONTINENT_OCEAN FROM CTCONTINENT))
;

ALTER TABLE geog_auth_rec
    add CONSTRAINT fk_CTCONTINENT
    FOREIGN KEY (CONTINENT_OCEAN)
    REFERENCES CTCONTINENT(CONTINENT_OCEAN);
    
DROP TABLE CTCORRESP_TYPE;

ALTER TABLE lat_long
    add CONSTRAINT fk_CTDATUM
    FOREIGN KEY (DATUM)
    REFERENCES CTDATUM(DATUM);
    
DROP TABLE CTDEACCN_TYPE;
  
ALTER TABLE locality
    add CONSTRAINT fk_CTDEPTH_UNITS
    FOREIGN KEY (DEPTH_UNITS)
    REFERENCES CTDEPTH_UNITS(DEPTH_UNITS);

INSERT INTO CTDOWNLOAD_PURPOSE (DOWNLOAD_PURPOSE) (
 select distinct(DOWNLOAD_PURPOSE) from cf_download
 WHERE DOWNLOAD_PURPOSE NOT IN (SELECT DOWNLOAD_PURPOSE FROM CTDOWNLOAD_PURPOSE))
;

ALTER TABLE cf_download
    add CONSTRAINT fk_CTDOWNLOAD_PURPOSE
    FOREIGN KEY (DOWNLOAD_PURPOSE)
    REFERENCES CTDOWNLOAD_PURPOSE(DOWNLOAD_PURPOSE);   
    
DROP TABLE CTEGG_NEST_COMBO;

ALTER TABLE electronic_address
    add CONSTRAINT fk_CTELECTRONIC_ADDR_TYPE
    FOREIGN KEY (ADDRESS_TYPE)
    REFERENCES CTELECTRONIC_ADDR_TYPE(ADDRESS_TYPE);  
    
ALTER TABLE encumbrance
    add CONSTRAINT fk_CTENCUMBRANCE_ACTION
    FOREIGN KEY (ENCUMBRANCE_ACTION)
    REFERENCES CTENCUMBRANCE_ACTION(ENCUMBRANCE_ACTION);  
 
ALTER TABLE  CTEW MODIFY E_OR_W CHAR(1);
    
ALTER TABLE lat_long
    add CONSTRAINT fk_CTEW
    FOREIGN KEY (LONG_DIR)
    REFERENCES CTEW(E_OR_W);    

INSERT INTO CTFEATURE (FEATURE) (
 select distinct(FEATURE) from geog_auth_rec
 WHERE FEATURE NOT IN (SELECT FEATURE FROM CTFEATURE))
;
	
ALTER TABLE geog_auth_rec
    add CONSTRAINT fk_CTFEATURE
    FOREIGN KEY (FEATURE)
    REFERENCES CTFEATURE(FEATURE);
    
DROP TABLE CTFLAG_YES_NO;
DROP TABLE CTFLAG_YES_NO_UNKNOWN;

ALTER TABLE fluid_container_history
    add CONSTRAINT fk_CTFLUID_CONCENTRATION
    FOREIGN KEY (CONCENTRATION)
    REFERENCES CTFLUID_CONCENTRATION(CONCENTRATION);

ALTER TABLE fluid_container_history
    add CONSTRAINT fk_CTFLUID_TYPE
    FOREIGN KEY (FLUID_TYPE)
    REFERENCES CTFLUID_TYPE(FLUID_TYPE);
    
DROP TABLE CTGEOG_SOURCE_AUTHORITY;

ALTER TABLE lat_long
    add CONSTRAINT fk_CTGEOREFMETHOD
    FOREIGN KEY (GEOREFMETHOD)
    REFERENCES CTGEOREFMETHOD(GEOREFMETHOD); 
    
DROP TABLE CTHABITAT_DESC;

DROP TABLE CTHISTO_SECTION_ORIENT;
DROP TABLE CTHISTO_STAIN_PROC;
DROP TABLE CTID_MODIFIER;
DROP TABLE CTIMAGE_CONTENT_TYPE;

ALTER TABLE taxonomy
    add CONSTRAINT fk_CTINFRASPECIFIC_RANK
    FOREIGN KEY (INFRASPECIFIC_RANK)
    REFERENCES CTINFRASPECIFIC_RANK(INFRASPECIFIC_RANK); 
 
ALTER TABLE geog_auth_rec
    add CONSTRAINT fk_CTISLAND_GROUP
    FOREIGN KEY (ISLAND_GROUP)
    REFERENCES CTISLAND_GROUP(ISLAND_GROUP);
      
DROP TABLE CTKARYO_STAIN_PROC;

CREATE OR REPLACE TRIGGER trg_CTKILL_METHOD_ud
BEFORE UPDATE OR DELETE ON CTKILL_METHOD
FOR EACH ROW
BEGIN
    FOR r IN (SELECT COUNT(*) c FROM attributes,cataloged_item,collection
                 WHERE 
                 attributes.collection_object_id=cataloged_item.collection_object_id AND
                 cataloged_item.collection_id=collection.collection_id AND
                 attribute_type='kill method' AND 
                 attribute_value=:OLD.KILL_METHOD AND
                 collection.collection_cde=:OLD.collection_cde) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		:OLD.KILL_METHOD || ' is used in attributes for collection type ' || :OLD.collection_cde);
        END IF;
    END LOOP;
END;
/
show err;

ALTER TABLE lat_long
    add CONSTRAINT fk_CTLAT_LONG_ERROR_UNITS
    FOREIGN KEY (MAX_ERROR_UNITS)
    REFERENCES CTLAT_LONG_ERROR_UNITS(LAT_LONG_ERROR_UNITS);
    
DROP TABLE CTLAT_LONG_REF_SOURCE;

ALTER TABLE lat_long
    add CONSTRAINT fk_CTLAT_LONG_UNITS
    FOREIGN KEY (ORIG_LAT_LONG_UNITS)
    REFERENCES CTLAT_LONG_UNITS(ORIG_LAT_LONG_UNITS);

DROP TABLE CTLEXICAL_RELATIONSHIP;
DROP TABLE CTLOAN_INSTALLMENT_STATUS;
DROP TABLE CTLOAN_ITEM_STATUS;

ALTER TABLE loan
    add CONSTRAINT fk_CTLOAN_STATUS
    FOREIGN KEY (LOAN_STATUS)
    REFERENCES CTLOAN_STATUS(LOAN_STATUS);
  
ALTER TABLE loan
    add CONSTRAINT fk_CTLOAN_TYPE
    FOREIGN KEY (LOAN_TYPE)
    REFERENCES CTLOAN_TYPE(LOAN_TYPE);
    
DROP TABLE CTLOCALITY_SECTION_PART;

ALTER TABLE media_labels
    add CONSTRAINT fk_CTMEDIA_LABEL
    FOREIGN KEY (MEDIA_LABEL)
    REFERENCES CTMEDIA_LABEL(MEDIA_LABEL);
    
ALTER TABLE media
    add CONSTRAINT fk_CTMEDIA_TYPE
    FOREIGN KEY (MEDIA_TYPE)
    REFERENCES CTMEDIA_TYPE(MEDIA_TYPE);
   
ALTER TABLE identification
    add CONSTRAINT fk_CTNATURE_OF_ID
    FOREIGN KEY (NATURE_OF_ID)
    REFERENCES CTNATURE_OF_ID(NATURE_OF_ID);
 
ALTER TABLE CTNS MODIFY N_OR_S CHAR(1);

ALTER TABLE lat_long
    add CONSTRAINT fk_CTNS
    FOREIGN KEY (LAT_DIR)
    REFERENCES CTNS(N_OR_S); 
    
CREATE OR REPLACE TRIGGER trg_CTNUMERIC_AGE_UNITS_ud
BEFORE UPDATE OR DELETE ON CTNUMERIC_AGE_UNITS
FOR EACH ROW
BEGIN
    FOR r IN (SELECT COUNT(*) c FROM attributes
                 WHERE 
                 attribute_type='numeric age' AND 
                 attribute_units=:OLD.NUMERIC_AGE_UNITS) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		:OLD.NUMERIC_AGE_UNITS || ' is used in attribute units');
        END IF;
    END LOOP;
END;
/
show err;

CREATE OR REPLACE TRIGGER trg_ctlength_units_ud
BEFORE UPDATE OR DELETE ON ctlength_units
FOR EACH ROW
BEGIN
    FOR r IN (SELECT COUNT(*) c FROM attributes
                 WHERE 
                 attribute_type LIKE '% length' AND 
                 attribute_units=:OLD.length_units) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		:OLD.length_units || ' is used in attribute units');
        END IF;
    END LOOP;
END;
/
show err;

ALTER TABLE locality
    add CONSTRAINT fk_CTORIG_ELEV_UNITS
    FOREIGN KEY (ORIG_ELEV_UNITS)
    REFERENCES CTORIG_ELEV_UNITS(ORIG_ELEV_UNITS); 

ALTER TABLE permit
    add CONSTRAINT fk_CTPERMIT_TYPE
    FOREIGN KEY (PERMIT_TYPE)
    REFERENCES CTPERMIT_TYPE(PERMIT_TYPE); 
    
ALTER TABLE person
    add CONSTRAINT fk_CTPREFIX
    FOREIGN KEY (PREFIX)
    REFERENCES CTPREFIX(PREFIX); 
  
ALTER TABLE PROJECT_AGENT
    add CONSTRAINT fk_CTPROJECT_AGENT_ROLE
    FOREIGN KEY (PROJECT_AGENT_ROLE)
    REFERENCES CTPROJECT_AGENT_ROLE(PROJECT_AGENT_ROLE); 
  
DROP TABLE CTREFERENCERELATION;
DROP TABLE CTREQUEST_STATUS;

CREATE OR REPLACE TRIGGER tr_CTSEX_CDE_ud
BEFORE UPDATE OR DELETE ON CTSEX_CDE
FOR EACH ROW
BEGIN
    FOR r IN (SELECT COUNT(*) c FROM attributes,cataloged_item,collection
                 WHERE 
                 attributes.collection_object_id=cataloged_item.collection_object_id AND
                 cataloged_item.collection_id=collection.collection_id AND
                 attribute_type='sex' AND 
                 attribute_value=:OLD.SEX_CDE AND
                 collection.collection_cde=:OLD.collection_cde) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		:OLD.SEX_CDE || ' is used in attributes for collection type ' || :OLD.collection_cde);
        END IF;
    END LOOP;
END;
/
show err;

DROP TABLE CTSHIPMENT_CARRIER;
DROP TABLE CTSHIPMENT_STATUS;

ALTER TABLE shipment
    add CONSTRAINT fk_CTSHIPPED_CARRIER_METHOD
    FOREIGN KEY (SHIPPED_CARRIER_METHOD)
    REFERENCES CTSHIPPED_CARRIER_METHOD(SHIPPED_CARRIER_METHOD); 


CREATE OR REPLACE TRIGGER tr_CTSPECIMEN_PRES_MET_ud
BEFORE UPDATE OR DELETE ON CTSPECIMEN_PRESERV_METHOD
FOR EACH ROW
BEGIN
    FOR r IN (SELECT COUNT(*) c FROM specimen_part,cataloged_item,collection
                 WHERE 
                 specimen_part.derived_from_cat_item=cataloged_item.collection_object_id AND
                 cataloged_item.collection_id=collection.collection_id AND
                 part_name=:OLD.PRESERVE_METHOD AND
                 collection.collection_cde=:OLD.collection_cde) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		:OLD.PRESERVE_METHOD || ' is used for collection type ' || :OLD.collection_cde);
        END IF;
    END LOOP;
END;
/
show err;

ALTER TABLE specimen_part
    add CONSTRAINT fk_CTSPECIMEN_PART_MODIFIER
    FOREIGN KEY (PART_MODIFIER)
    REFERENCES CTSPECIMEN_PART_MODIFIER(PART_MODIFIER); 

INSERT INTO CTSUFFIX (SUFFIX) (
 select distinct(SUFFIX) from person
 WHERE SUFFIX IS NOT NULL AND suffix NOT IN (SELECT SUFFIX FROM CTSUFFIX))
;

   
ALTER TABLE person
    add CONSTRAINT fk_CTSUFFIX
    FOREIGN KEY (SUFFIX)
    REFERENCES CTSUFFIX(SUFFIX); 
    
ALTER TABLE identification
    add CONSTRAINT fk_CTTAXA_FORMULA
    FOREIGN KEY (TAXA_FORMULA)
    REFERENCES CTTAXA_FORMULA(TAXA_FORMULA); 
    
DROP TABLE CTTAXA_ROLE;
    
ALTER TABLE taxonomy
    add CONSTRAINT fk_CTTAXONOMIC_AUTHORITY
    FOREIGN KEY (SOURCE_AUTHORITY)
    REFERENCES CTTAXONOMIC_AUTHORITY(SOURCE_AUTHORITY); 

ALTER TABLE taxon_relations
    add CONSTRAINT fk_CTTAXON_RELATION
    FOREIGN KEY (TAXON_RELATIONSHIP)
    REFERENCES CTTAXON_RELATION(TAXON_RELATIONSHIP); 

ALTER TABLE CTTAXON_VARIABLE MODIFY TAXON_VARIABLE CHAR(1);
    
ALTER TABLE identification_taxonomy
    add CONSTRAINT fk_CTTAXON_VARIABLE
    FOREIGN KEY (VARIABLE)
    REFERENCES CTTAXON_VARIABLE(TAXON_VARIABLE);    	

INSERT INTO CTTRANSACTION_TYPE (TRANSACTION_TYPE) (
 select distinct(TRANSACTION_TYPE) from trans
 WHERE TRANSACTION_TYPE IS NOT NULL AND TRANSACTION_TYPE NOT IN (SELECT TRANSACTION_TYPE FROM CTTRANSACTION_TYPE))
;

ALTER TABLE trans
    add CONSTRAINT fk_CTTRANSACTION_TYPE
    FOREIGN KEY (TRANSACTION_TYPE)
    REFERENCES CTTRANSACTION_TYPE(TRANSACTION_TYPE);    	
  
ALTER TABLE trans_agent
    add CONSTRAINT fk_CCTTRANS_AGENT_ROLE
    FOREIGN KEY (TRANS_AGENT_ROLE)
    REFERENCES CTTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);     	
		
DROP TABLE CTURL_TYPE;

ALTER TABLE lat_long
    add CONSTRAINT fk_CTVERIFICATIONSTATUS
    FOREIGN KEY (VERIFICATIONSTATUS)
    REFERENCES CTVERIFICATIONSTATUS(VERIFICATIONSTATUS);  
    
CREATE OR REPLACE TRIGGER tr_CTWEIGHT_UNITS_ud
BEFORE UPDATE OR DELETE ON CTWEIGHT_UNITS
FOR EACH ROW
BEGIN
    FOR r IN (SELECT COUNT(*) c FROM attributes
                 WHERE 
                 attribute_type LIKE '%weight' AND 
                 attribute_units=:OLD.WEIGHT_UNITS) LOOP
        IF r.c > 0 THEN
             raise_application_error(
        		-20001,
        		:OLD.WEIGHT_UNITS || ' is used in attribute units');
        END IF;
    END LOOP;
END;
/
show err;

DROP TABLE CTYES_NO;