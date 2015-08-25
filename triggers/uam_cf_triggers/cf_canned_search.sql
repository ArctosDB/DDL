CREATE OR REPLACE TRIGGER TR_CF_CANNED_SEARCH_SQ
BEFORE INSERT ON cf_canned_search
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
    IF :NEW.canned_id IS NULL THEN
        SELECT sq_canned_id.nextval
        INTO :NEW.canned_id
        FROM dual;
    END IF;
END;
