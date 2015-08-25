CREATE OR REPLACE TRIGGER TRG_BEF_AGENT_RANK
BEFORE INSERT OR UPDATE ON AGENT_RANK
FOR EACH ROW
BEGIN
    IF :NEW.AGENT_RANK_ID IS NULL THEN
        SELECT SQ_AGENT_RANK_ID.NEXTVAL
        INTO :NEW.AGENT_RANK_ID 
        FROM DUAL;
    END IF;
        
    IF :NEW.AGENT_RANK = 'unsatisfactory' AND LENGTH(:NEW.REMARK) < 20 THEN
        raise_application_error(
            -20001,
            'You must leave a >20 character comment for unsatisfactory rankings.');
    END IF;
END;
