CREATE OR REPLACE TRIGGER cf_temp_relations_id
BEFORE INSERT ON cf_temp_relations
FOR EACH ROW
BEGIN
    SELECT sq_cf_temp_relations_id.NEXTVAL
    INTO :NEW.cf_temp_relations_id
    FROM dual;
END;
