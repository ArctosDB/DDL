CREATE OR REPLACE TRIGGER RELATIONSHIP_CT_CHECK
BEFORE UPDATE OR INSERT ON BIOL_INDIV_RELATIONS
FOR EACH ROW
DECLARE numrows NUMBER;
BEGIN
    SELECT COUNT(*) INTO numrows
    FROM ctbiol_relations
    WHERE BIOL_INDIV_RELATIONSHIP = :NEW.BIOL_INDIV_RELATIONSHIP;
    
	IF (numrows = 0) THEN
		raise_application_error(
		-20001,
		'Invalid BIOL_INDIV_RELATIONSHIP');
	END IF;
END;

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
