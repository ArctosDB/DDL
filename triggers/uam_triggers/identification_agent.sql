CREATE OR REPLACE TRIGGER TR_IDENTIFICATION_AGENT_SQ
BEFORE INSERT ON IDENTIFICATION_AGENT
FOR EACH ROW
BEGIN
    IF :NEW.identification_agent_id IS NULL THEN
        SELECT sq_identification_agent_id.nextval
        INTO :new.identification_agent_id 
        FROM dual;
    END IF;
END;

CREATE OR REPLACE TRIGGER TR_IDAGENT_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON IDENTIFICATION_AGENT
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting THEN 
        id := :OLD.identification_id;
    ELSE 
        id := :NEW.identification_id;
    END IF;
        
    UPDATE flat SET 
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
		lastdate = SYSDATE
    WHERE identification_id = id;
END;
