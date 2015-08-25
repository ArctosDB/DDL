CREATE OR REPLACE TRIGGER CF_TEMP_OIDS_KEY
BEFORE INSERT ON cf_temp_oids
FOR EACH ROW
BEGIN
    IF :NEW.key IS NULL THEN
        SELECT somerandomsequence.nextval 
        INTO :NEW.key
        FROM dual;
    END IF; 
END;
