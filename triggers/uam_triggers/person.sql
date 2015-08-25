-- not implemented! agent and person are in same transaction in arctos. 
-- could possibly check program name in session variables??

CREATE OR REPLACE TRIGGER TR_PERSON_BI
BEFORE INSERT ON PERSON
FOR EACH ROW
DECLARE atype VARCHAR2(30);
BEGIN
    SELECT agent_type INTO atype
	FROM AGENT
	WHERE AGENT_ID = :NEW.PERSON_ID;
	
    IF (atype != 'person') THEN
        RAISE_APPLICATION_ERROR(
    	-20001,
		'Cannot create the person; Agent type must be ''person''.');
    END IF;
END;