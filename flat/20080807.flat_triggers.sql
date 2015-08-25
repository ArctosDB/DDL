/*
select table_name, trigger_name
from user_triggers
where trigger_name like '%FLAT%'
order by table_name, trigger_name

TABLE_NAME                     TRIGGER_NAME
------------------------------ ------------------------------
ACCN                           UP_FLAT_ACCN
AGENT_NAME                     UP_FLAT_AGENTNAME
ATTRIBUTES                     UP_FLAT_SEX
BIOL_INDIV_RELATIONS           UP_FLAT_RELN
CATALOGED_ITEM                 TR_CATITEM_FLAT_AD
CATALOGED_ITEM                 TR_CATITEM_FLAT_AI
CATALOGED_ITEM                 TR_CATITEM_FLAT_AU
CITATION                       UP_FLAT_CITATION
COLLECTING_EVENT               A_FLAT_COLLEVNT
COLLECTOR                      UP_FLAT_COLLECTOR
COLL_OBJECT                    UP_FLAT_COLLOBJ
COLL_OBJECT_ENCUMBRANCE        UP_FLAT_COLL_OBJ_ENCUMBER
COLL_OBJECT_REMARK             UP_FLAT_REMARK
COLL_OBJ_OTHER_ID_NUM          UP_FLAT_OTHERIDS
GEOG_AUTH_REC                  UP_FLAT_GEOG
IDENTIFICATION                 UP_FLAT_ID
IDENTIFICATION_AGENT           UP_FLAT_AGNT_ID
IDENTIFICATION_TAXONOMY        UP_FLAT_ID_TAX
LAT_LONG                       UP_FLAT_LAT_LONG
LOCALITY                       UP_FLAT_LOCALITY
SPECIMEN_PART                  UP_FLAT_PART

------------------------------ ------------------------------
alter trigger UP_FLAT_ACCN rename to tr_ACCN_aiu_flat;
alter trigger UP_FLAT_AGENTNAME rename to tr_AGENTNAME_aiu_flat;
alter trigger UP_FLAT_SEX rename to tr_ATTRIBUTES_aiud_flat;
alter trigger UP_FLAT_RELN rename to tr_BIOLINDIVRELN_aiud_flat;
alter trigger TR_CATITEM_FLAT_AD rename to tr_CATITEM_ad_flat;
alter trigger TR_CATITEM_FLAT_AI rename to tr_CATITEM_ai_flat;
alter trigger TR_CATITEM_FLAT_AU rename to tr_CATITEM_au_flat;
alter trigger UP_FLAT_CITATION rename to tr_CITATION_aiud_flat;
alter trigger A_FLAT_COLLEVNT rename to tr_COLLEVENT_au_flat;
alter trigger UP_FLAT_COLLECTOR rename to tr_COLLECTOR_aiud_flat;
alter trigger UP_FLAT_COLLOBJ rename to tr_COLLOBJECT_aiu_flat;
alter trigger UP_FLAT_COLL_OBJ_ENCUMBER rename to tr_COLLOBJENC_aiud_flat;
alter trigger UP_FLAT_REMARK rename to tr_COLLOBJREM_aiud_flat;
alter trigger UP_FLAT_OTHERIDS rename to tr_COLLOBJOIDNUM_aiud_flat;
alter trigger UP_FLAT_GEOG rename to tr_GEOGAUTHREC_au_flat;
alter trigger UP_FLAT_ID rename to tr_IDENTIFICATION_aiu_flat;
alter trigger UP_FLAT_AGNT_ID rename to tr_IDAGENT_aiud_flat;
alter trigger UP_FLAT_ID_TAX rename to tr_IDTAXONOMY_aiud_flat;
alter trigger UP_FLAT_LAT_LONG rename to tr_LATLONG_aiud_flat;
alter trigger UP_FLAT_LOCALITY rename to tr_LOCALITY_au_flat;
alter trigger UP_FLAT_PART rename to tr_SPECPART_aiud_flat;
*/

--ACCN
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_ACCN_AIU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_ACCN_AIU_FLAT
AFTER INSERT OR UPDATE ON accn
FOR EACH ROW
BEGIN
	IF :NEW.accn_number != :OLD.accn_number THEN
    	UPDATE flat
    	SET stale_flag = 1 
    	WHERE accn_id = :new.transaction_id;
	END IF;
END;
/

--AGENT_NAME
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_AGENTNAME_AIU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_AGENTNAME_AIU_FLAT
AFTER INSERT OR UPDATE ON agent_name
FOR EACH ROW
BEGIN
	IF :NEW.agent_name_type = 'preferred' THEN
    	FOR r IN (
            SELECT collection_object_id 
            FROM collector 
            WHERE agent_id = :NEW.agent_id
        ) LOOP
    	    UPDATE flat
    	    SET stale_flag = 1
    	    WHERE collection_object_id = r.collection_object_id;
    	END LOOP;
	END IF;
END;
/

--ATTRIBUTES
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_ATTRIBUTES_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_ATTRIBUTES_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON attributes
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	    
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/

--BIOL_INDIV_RELATIONS
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_BIOLINDIVRELN_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_BIOLINDIVRELN_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON biol_indiv_relations
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting 
        THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	    
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/

--CATALOGED_ITEM
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_CATITEM_AD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_CATITEM_AD_FLAT
AFTER DELETE ON cataloged_item
FOR EACH ROW
BEGIN
	DELETE FROM flat
	WHERE collection_object_id = :OLD.collection_object_id;
END;
/

--CATALOGED_ITEM
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_CATITEM_AI_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_CATITEM_AI_FLAT
AFTER INSERT ON cataloged_item
FOR EACH ROW
BEGIN
	INSERT INTO flat (
		collection_object_id,
		cat_num,
		accn_id,
		collecting_event_id,
		collection_cde,
		collection_id,
		catalognumbertext,
		stale_flag)
	VALUES (
		:NEW.collection_object_id,
		:NEW.cat_num,
		:NEW.accn_id,
		:NEW.collecting_event_id,
		:NEW.collection_cde,
		:NEW.collection_id,
		to_char(:NEW.cat_num),
		1);
END;
/

--CATALOGED_ITEM
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_CATITEM_AU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_CATITEM_AU_FLAT
AFTER UPDATE ON cataloged_item
FOR EACH ROW
BEGIN
	UPDATE flat
	SET stale_flag = 1
    WHERE collection_object_id = :OLD.collection_object_id
	OR collection_object_id = :NEW.collection_object_id;
END;
/

--CITATION
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_CITATION_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_CITATION_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON citation
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	    
	UPDATE flat
	SET stale_flag = 1
    WHERE collection_object_id = id;
END;
/

--COLLECTING_EVENT
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_COLLEVENT_AU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_COLLEVENT_AU_FLAT
AFTER UPDATE ON collecting_event
FOR EACH ROW
BEGIN
    UPDATE flat
	SET stale_flag = 1
	WHERE collecting_event_id = :NEW.collecting_event_id;
END;
/

--COLLECTOR
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_COLLECTOR_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_COLLECTOR_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON collector
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting
        THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	    
    UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/

--COLL_OBJECT
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_COLLOBJECT_AIU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_COLLOBJECT_AIU_FLAT
AFTER INSERT OR UPDATE ON coll_object
FOR EACH ROW
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET stale_flag = 1
        WHERE collection_object_id = :NEW.collection_object_id;
	END LOOP;
END;
/

--COLL_OBJECT_ENCUMBRANCE
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_COLLOBJENC_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_COLLOBJENC_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON coll_object_encumbrance
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting 
        THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	    
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/

--COLL_OBJECT_REMARK
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_COLLOBJREM_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_COLLOBJREM_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON coll_object_remark
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting 
        THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	    
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/

--COLL_OBJ_OTHER_ID_NUM
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_COLLOBJOIDNUM_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_COLLOBJOIDNUM_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON coll_obj_other_id_num
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	    
	UPDATE flat
	SET stale_flag = 1
    WHERE collection_object_id = id;
END;
/

--GEOG_AUTH_REC
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_GEOGAUTHREC_AU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_GEOGAUTHREC_AU_FLAT
AFTER UPDATE ON geog_auth_rec
FOR EACH ROW
BEGIN
	UPDATE flat
	SET stale_flag = 1
    WHERE geog_auth_rec_id = :NEW.geog_auth_rec_id;
END;
/

--IDENTIFICATION
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_IDENTIFICATION_AIU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_IDENTIFICATION_AIU_FLAT
AFTER INSERT OR UPDATE ON identification
FOR EACH ROW
BEGIN
    IF :NEW.accepted_id_fg = 1 THEN
    	UPDATE flat
	    SET stale_flag = 1
		WHERE collection_object_id = :NEW.collection_object_id;
    END IF;
END;
/

--IDENTIFICATION_AGENT
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_IDAGENT_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_IDAGENT_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON identification_agent
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting 
        THEN id := :OLD.identification_id;
	    ELSE id := :NEW.identification_id;
	END IF;
	    
    UPDATE flat
    SET stale_flag = 1
	WHERE identification_id = id; 
END;
/

--IDENTIFICATION_TAXONOMY
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_IDTAXONOMY_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_IDTAXONOMY_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON identification_taxonomy
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting 
        THEN id := :OLD.identification_id;
	    ELSE id := :NEW.identification_id;
	        
	END IF;
    UPDATE flat
    SET stale_flag = 1
	WHERE identification_id = id; 
END;
/

--LAT_LONG
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_LATLONG_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_LATLONG_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON lat_long
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.locality_id;
	    ELSE id := :NEW.locality_id;
	END IF;
	    
    UPDATE flat
	SET  stale_flag = 1
    WHERE locality_id = id;
END;
/

--LOCALITY
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_LOCALITY_AU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_LOCALITY_AU_FLAT
AFTER UPDATE ON locality
FOR EACH ROW
BEGIN
    UPDATE flat
    SET stale_flag = 1
    WHERE locality_id = :NEW.locality_id;
END;
/

--SPECIMEN_PART
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_SPECPART_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_SPECPART_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON specimen_part
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.derived_from_cat_item;
	    ELSE id := :NEW.derived_from_cat_item;
	END IF;
	    
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/