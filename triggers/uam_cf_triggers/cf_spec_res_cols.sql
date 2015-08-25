CREATE OR REPLACE TRIGGER TR_CF_SPEC_RES_COLS_SQ
BEFORE INSERT ON cf_spec_res_cols
FOR EACH ROW
BEGIN
    IF :NEW.cf_spec_res_cols_id IS NULL THEN
        SELECT sq_cf_spec_res_cols_id.nextval
        INTO :NEW.cf_spec_res_cols_id
        FROM dual;
    END IF;
END;
