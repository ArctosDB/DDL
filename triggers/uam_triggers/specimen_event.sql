CREATE OR REPLACE TRIGGER trg_SPECIMEN_EVENT_biu
    BEFORE INSERT OR UPDATE ON SPECIMEN_EVENT
    FOR EACH ROW
    declare status varchar2(255);
    BEGIN
        if :new.SPECIMEN_EVENT_ID is null then
        	select sq_specimen_event_id.nextval into :new.SPECIMEN_EVENT_ID from dual;
        end if;
        if :new.VERIFICATIONSTATUS is null then
        	:new.VERIFICATIONSTATUS:='unverified';
        end if;
        if :new.specimen_event_type is null then
        	:new.specimen_event_type:='accepted place of collection';
        end if;
        status:=is_iso8601(:NEW.verified_date);
    	IF status != 'valid' THEN
        	raise_application_error(-20001,'Verified Date: ' || status);
    	END IF;
    end;
/



CREATE OR REPLACE TRIGGER trg_SPECIMEN_EVENT_AD
    after delete ON SPECIMEN_EVENT
    FOR EACH ROW
    BEGIN
	    delete from cache_anygeog where specimen_event_id=:OLD.specimen_event_id;
    end;
/

