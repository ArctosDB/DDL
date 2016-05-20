
  CREATE OR REPLACE TRIGGER "UAM"."TRG_SPECIMEN_EVENT_AU_FLAT"
    AFTER INSERT OR UPDATE OR DELETE ON SPECIMEN_EVENT
    FOR EACH ROW DECLARE
	coid NUMBER;
    BEGIN
	IF deleting THEN
	       coid:=:old.collection_object_id;
	ELSE
	    coid:=:new.collection_object_id;
	END IF;
	UPDATE flat
	    SET stale_flag = 1,
	    lastuser=sys_context('USERENV', 'SESSION_USER'),
	    lastdate=SYSDATE
	    WHERE collection_object_id = coid;
    end;




CREATE OR REPLACE TRIGGER TR_BIOLINDIVRELN_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON BIOL_INDIV_RELATIONS
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting THEN 
        id := :OLD.collection_object_id;
    ELSE
        id := :NEW.collection_object_id;
    END IF;
        
    UPDATE flat SET
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
        lastdate = SYSDATE
    WHERE collection_object_id = id;
END;





CREATE OR REPLACE TRIGGER TR_mediarelations_AU_FLAT
AFTER UPDATE or INSERT or DELETE ON media_relations
FOR EACH ROW
	DECLARE 
		id NUMBER;
		mr varchar2(255);
BEGIN
	IF deleting THEN 
        id := :OLD.related_primary_key;
        mr := :OLD.media_relationship;
    ELSE
        id := :NEW.related_primary_key;
        mr := :NEW.media_relationship;
    END IF;
	if mr = 'shows cataloged_item' then
	    UPDATE flat
		SET stale_flag = 1
	    WHERE collection_object_id = id;
	end if;
END;
/

CREATE OR REPLACE TRIGGER TR_collection_AU_FLAT
AFTER UPDATE ON collection
FOR EACH ROW
BEGIN
	UPDATE flat
	SET stale_flag = 1
    WHERE collection_id = :OLD.collection_id;
END;
/
--ACCN
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_ACCN_AIU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_ACCN_AIU_FLAT
AFTER INSERT OR UPDATE ON accn
FOR EACH ROW
BEGIN
	IF :NEW.accn_number != :OLD.accn_number THEN
    	UPDATE flat
    	SET stale_flag = 1,
    	lastuser=sys_context('USERENV', 'SESSION_USER'),
    	lastdate=SYSDATE
    	WHERE accn_id = :new.transaction_id;
	END IF;
END;
/

--AGENT_NAME
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_AGENTNAME_AIU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_AGENTNAME_AIU_FLAT
AFTER UPDATE ON agent
FOR EACH ROW
BEGIN
	IF :NEW.preferred_agent_name  != :OLD.preferred_agent_name THEN
    	 UPDATE flat
    	    SET stale_flag = 1,
        	lastuser=sys_context('USERENV', 'SESSION_USER'),
        	lastdate=SYSDATE
    	    WHERE collection_object_id in (
    	    	SELECT collection_object_id 
            	FROM collector 
            	WHERE agent_id = :NEW.agent_id
        	)
        ;
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
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
	WHERE collection_object_id = id;
END;
/

--BIOL_INDIV_RELATIONS
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_BIOLINDIVRELN_AIUD_FLAT') FROM dual;
-- DROPPED at otherID==relations update
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
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
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
		collection_cde,
		collection_id,
		catalognumbertext,
		cataloged_item_type,
		stale_flag)
	VALUES (
		:NEW.collection_object_id,
		:NEW.cat_num,
		:NEW.accn_id,
		:NEW.collection_cde,
		:NEW.collection_id,
		to_char(:NEW.cat_num),
		:NEW.cataloged_item_type,
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
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
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
	IF deleting THEN 
	    id := :OLD.collection_object_id;
    ELSE 
        id := :NEW.collection_object_id;
	END IF;
	UPDATE flat
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
    WHERE collection_object_id = id;
END;
/

CREATE OR REPLACE TRIGGER TR_PUBLICATION_AIUD_FLAT
AFTER UPDATE ON PUBLICATION
FOR EACH ROW
DECLARE id NUMBER;
BEGIN  
	if :NEW.SHORT_CITATION != :OLD.SHORT_CITATION then
		UPDATE flat
		SET stale_flag = 1,
		lastuser=sys_context('USERENV', 'SESSION_USER'),
		lastdate=SYSDATE
	    WHERE collection_object_id IN (SELECT collection_object_id FROM citation where publication_id = :NEW.publication_id);
	end if;
END;
/
--COLLECTING_EVENT
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_COLLEVENT_AU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_COLLEVENT_AU_FLAT
AFTER UPDATE ON collecting_event
FOR EACH ROW
BEGIN
    UPDATE flat
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
	WHERE collecting_event_id = :NEW.collecting_event_id;
END;
/

--COLLECTOR
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_COLLECTOR_AIUD_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_COLLECTOR_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON collector
FOR EACH ROW
DECLARE 
    id NUMBER;
    action VARCHAR2(30);
BEGIN
    IF deleting THEN 
        id := :OLD.collection_object_id;
        action:='delete collector';
	ELSE 
	    id := :NEW.collection_object_id;
        action:='update or insert collector';
	END IF;
	    
    UPDATE flat	SET stale_flag = 1 WHERE collection_object_id = id;
	
	

	INSERT INTO edit_history (
	    collection_object_id,
	    lastuser,
	    lastdate,
	    edited_from_table,
	    pushed_to_flat
	) VALUES (
	    id,
	    sys_context('USERENV', 'SESSION_USER'),
	    SYSDATE,
	    action,
	    0
	);
	
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
		SET stale_flag = 1,
    	lastuser=sys_context('USERENV', 'SESSION_USER'),
    	lastdate=SYSDATE
        WHERE collection_object_id = :NEW.collection_object_id;
        
        INSERT INTO edit_history (
	    collection_object_id,
	    lastuser,
	    lastdate,
	    edited_from_table,
	    pushed_to_flat
	) VALUES (
	    :NEW.collection_object_id,
	    sys_context('USERENV', 'SESSION_USER'),
	    SYSDATE,
	    'update coll_object',
	    0
	);
	
	
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
    IF deleting THEN 
    	id := :OLD.collection_object_id;
	ELSE 
		id := :NEW.collection_object_id;
	END IF;
	    
	UPDATE flat
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
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
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
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
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
    WHERE collection_object_id = id;
END;
/

--GEOG_AUTH_REC
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_GEOGAUTHREC_AU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_GEOGAUTHREC_AU_FLAT
AFTER UPDATE ON geog_auth_rec
FOR EACH ROW
BEGIN
	if :NEW.higher_geog != :OLD.higher_geog then
		UPDATE flat
		SET stale_flag = 1,
		lastuser=sys_context('USERENV', 'SESSION_USER'),
		lastdate=SYSDATE
	    WHERE geog_auth_rec_id = :NEW.geog_auth_rec_id;
	end if;
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
	    SET stale_flag = 1,
    	lastuser=sys_context('USERENV', 'SESSION_USER'),
    	lastdate=SYSDATE
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
    SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
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
    SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
	WHERE identification_id = id; 
END;
/

--LOCALITY
--SELECT dbms_metadata.get_ddl('TRIGGER','TR_LOCALITY_AU_FLAT') FROM dual;
CREATE OR REPLACE TRIGGER TR_LOCALITY_AU_FLAT
AFTER UPDATE ON locality
FOR EACH ROW
BEGIN
    -- DO not log updates to the service data as "specimen changes."
    if :NEW.GEOG_AUTH_REC_ID != :OLD.GEOG_AUTH_REC_ID or
    	nvl(:NEW.SPEC_LOCALITY,'OK') != nvl(:OLD.SPEC_LOCALITY,'OK') or
    	nvl(:NEW.DEC_LAT,0) != nvl(:OLD.DEC_LAT,0) or
    	nvl(:NEW.DEC_LONG,0) != nvl(:OLD.DEC_LONG,0) or
    	nvl(:NEW.MINIMUM_ELEVATION,0) != nvl(:OLD.MINIMUM_ELEVATION,0) or
    	nvl(:NEW.MAXIMUM_ELEVATION,0) != nvl(:OLD.MAXIMUM_ELEVATION,0) or
    	nvl(:NEW.ORIG_ELEV_UNITS,'OK') != nvl(:OLD.ORIG_ELEV_UNITS,'OK') or
    	nvl(:NEW.MIN_DEPTH,0) != nvl(:OLD.MIN_DEPTH,0) or
    	nvl(:NEW.MAX_DEPTH,0) != nvl(:OLD.MAX_DEPTH,0) or
    	nvl(:NEW.DEPTH_UNITS,'OK') != nvl(:OLD.DEPTH_UNITS,'OK') or
    	nvl(:NEW.MAX_ERROR_DISTANCE,0) != nvl(:OLD.MAX_ERROR_DISTANCE,0) or
    	nvl(:NEW.MAX_ERROR_UNITS,'OK') != nvl(:OLD.MAX_ERROR_UNITS,'OK') or
    	nvl(:NEW.DATUM,'OK') != nvl(:OLD.DATUM,'OK') or
    	nvl(:NEW.LOCALITY_REMARKS,'OK') != nvl(:OLD.LOCALITY_REMARKS,'OK') or
    	nvl(:NEW.GEOREFERENCE_SOURCE,'OK') != nvl(:OLD.GEOREFERENCE_SOURCE,'OK') or
    	nvl(:NEW.GEOREFERENCE_PROTOCOL,'OK') != nvl(:OLD.GEOREFERENCE_PROTOCOL,'OK') or
    	nvl(:NEW.LOCALITY_NAME,'OK') != nvl(:OLD.LOCALITY_NAME,'OK')
    then

	
		UPDATE flat
	    SET stale_flag = 1,
		lastuser=sys_context('USERENV', 'SESSION_USER'),
		lastdate=SYSDATE
	    WHERE locality_id = :NEW.locality_id;
	end if;
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
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
	WHERE collection_object_id = id;
END;
/