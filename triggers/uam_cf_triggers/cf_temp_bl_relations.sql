CREATE OR REPLACE TRIGGER CF_TEMP_BL_RELATIONS_KEY
BEFORE INSERT ON cf_temp_bl_relations
FOR EACH ROW
BEGIN
    IF :NEW.key IS NULL THEN
        SELECT somerandomsequence.nextval
        INTO :NEW.key
        FROM dual;
    END IF;
END;
