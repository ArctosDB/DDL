CREATE OR REPLACE TRIGGER IDENTIFICATION_CT_CHECK
BEFORE UPDATE OR INSERT ON IDENTIFICATION
FOR EACH ROW
DECLARE 
    numrows NUMBER;
    status varchar2(255);
BEGIN
	SELECT COUNT(*) INTO numrows 
	FROM ctnature_of_id 
	WHERE nature_of_id = :NEW.nature_of_id;
	
	IF (numrows = 0) THEN
		raise_application_error(
		    -20001,
		    'Invalid nature_of_id');
	END IF;
	IF :NEW.made_date IS NOT NULL THEN
    	status:=is_iso8601(:NEW.made_date);
        IF status != 'valid' THEN
            raise_application_error(-20001,'ID Made Date: ' || status);
        END IF;
    END IF;
END;
/


CREATE OR REPLACE TRIGGER TR_IDENTIFICATION_AIU_FLAT
AFTER INSERT OR UPDATE ON IDENTIFICATION
FOR EACH ROW
BEGIN
    IF :NEW.accepted_id_fg = 1 THEN
        UPDATE flat SET 
            stale_flag = 1,
            lastuser = sys_context('USERENV', 'SESSION_USER'),
            lastdate = SYSDATE
        WHERE collection_object_id = :NEW.collection_object_id;
    END IF;
END;
