CREATE OR REPLACE TRIGGER TR_CF_COLLECTION_SQ
BEFORE INSERT ON cf_collection
FOR EACH ROW
BEGIN
    IF :NEW.cf_collection_id IS NULL THEN
        SELECT sq_collection_id.nextval
        INTO :NEW.cf_collection_id
        FROM dual;
    END IF;
END;
