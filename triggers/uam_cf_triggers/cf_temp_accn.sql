
CREATE OR REPLACE TRIGGER trg_cf_temp_accn_date
BEFORE INSERT OR UPDATE ON cf_temp_accn
FOR EACH ROW
	declare status varchar2(255);
BEGIN
    status:=is_iso8601(:NEW.TRANS_DATE);
    IF status != 'valid' THEN
        raise_application_error(-20001,'TRANS_DATE: ' || status);
    END IF;
     status:=is_iso8601(:NEW.RECEIVED_DATE);
    IF status != 'valid' THEN
        raise_application_error(-20001,'RECEIVED_DATE: ' || status);
    END IF;
END;
/