CREATE OR REPLACE TRIGGER CF_TEMP_LOAN_ITEM_KEY
BEFORE INSERT ON cf_temp_loan_item
FOR EACH ROW
BEGIN
    IF :NEW.key IS NULL THEN
        SELECT somerandomsequence.nextval
        INTO :NEW.key
        FROM dual;
    END IF;
END;
