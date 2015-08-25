CREATE OR REPLACE TRIGGER CF_TEMP_AGENTS_KEY
BEFORE INSERT ON cf_temp_agents
FOR EACH ROW
BEGIN
    IF :NEW.key IS NULL THEN
        SELECT somerandomsequence.nextval
        INTO :NEW.key
        FROM dual;
    END IF;
END;
