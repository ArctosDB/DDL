CREATE OR REPLACE TRIGGER TR_COLLEVENT_AU_FLAT
AFTER UPDATE ON COLLECTING_EVENT
FOR EACH ROW
BEGIN
    UPDATE flat SET 
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
        lastdate = SYSDATE
    WHERE collecting_event_id = :NEW.collecting_event_id;
END;




CREATE OR REPLACE TRIGGER TR_COLLECTINGEVENT_BUD
BEFORE UPDATE OR DELETE ON collecting_event
FOR EACH ROW
DECLARE
    num NUMBER;
    allrec INTEGER;
    vpdrec INTEGER;
    username VARCHAR2(30);
BEGIN
	if :NEW.admin_flag = 'proc auto_merge_locality' then
		:NEW.admin_flag := NULL;
		return;
	end if;
    SELECT
        COUNT(*)
    INTO
        num
    FROM
        specimen_event
    WHERE
        specimen_event.collecting_event_id=:OLD.collecting_event_id AND
        specimen_event.VERIFICATIONSTATUS LIKE 'verified and locked';
    IF num > 0 THEN
    		raise_application_error(-20001,'This collecting event is used in verified specimen/events and may not be changed or deleted.');
    END IF;
    /*
    SELECT SYS_CONTEXT('USERENV','SESSION_USER') INTO username FROM dual;
    SELECT SYS.GET_COLLEVENTID_COUNT(:OLD.collecting_event_id) INTO allrec FROM dual;
    EXECUTE IMMEDIATE 'SELECT COUNT(*)
        FROM specimen_event, cataloged_item
        WHERE specimen_event.collection_object_id=cataloged_item.collection_object_id
        AND specimen_event.collecting_event_id=' || :OLD.collecting_event_id
    INTO vpdrec;
    IF allrec > vpdrec THEN
        raise_application_error(-20001,
            'This collecting event is shared and may not be changed or deleted.');
    END IF;
    */
END;
/



CREATE OR REPLACE TRIGGER TR_COLLEVENT_AU_FLAT AFTER
UPDATE ON COLLECTING_EVENT FOR EACH ROW BEGIN
UPDATE flat
SET stale_flag = 1,
lastuser=sys_context('USERENV', 'SESSION_USER'),
lastdate=SYSDATE
WHERE collection_object_id IN (
           SELECT collection_object_id FROM specimen_event WHERE collecting_event_id = :NEW.collecting_event_id);
END;
/


CREATE OR REPLACE TRIGGER TRG_COLLECTING_EVENT_BIU
    BEFORE INSERT OR UPDATE ON collecting_event
    FOR EACH ROW declare
        status varchar2(255);
    BEGIN
	    if :NEW.LAST_DUP_CHECK_DATE is null then
	    	:new.LAST_DUP_CHECK_DATE:=sysdate;
	    end if;
	    
        status:=is_iso8601(:NEW.began_date,1);
        IF status != 'valid' THEN
            raise_application_error(-20001,'Began Date: ' || status);
        END IF;
        status:=is_iso8601(:NEW.ended_date,1);
        IF status != 'valid' THEN
            raise_application_error(-20001,'Ended Date: ' || status);
        END IF;
        IF :NEW.began_date>:NEW.ended_date THEN
            raise_application_error(-20001,'Began Date can not occur after Ended Date.');
        END IF;
 		
        	
        :new.caclulated_dlat := '';
        :new.calculated_dlong := '';

        if :new.COLLECTING_EVENT_ID is null then
        	select sq_COLLECTING_EVENT_ID.nextval into :new.COLLECTING_EVENT_ID from dual;
        end if;
            -- this IS ALL SORT OF stoopid lacking datum AND UTM conversion capabilities, but here it IS anyway...
            -- keep populating verbatim_coordinates, even while we're keeping the explicit fields,
            -- for display/future purposes
        IF :new.orig_lat_long_units = 'deg. min. sec.' THEN
        	:new.caclulated_dlat := :new.lat_deg + (:new.lat_min / 60) + (nvl(:new.lat_sec,0) / 3600);
            IF :new.lat_dir = 'S' THEN
                :new.caclulated_dlat := :new.caclulated_dlat * -1;
            END IF;
            :new.calculated_dlong := :new.long_deg + (:new.long_min / 60) + (nvl(:new.long_sec,0) / 3600);
            IF :new.long_dir = 'W' THEN
                :new.calculated_dlong := :new.calculated_dlong * -1;
            END IF;
            :new.verbatim_coordinates := dms_to_string (
                :new.lat_deg,
                :new.lat_min,
                :new.lat_sec,
                :new.lat_dir,
                :new.long_deg,
                :new.long_min,
                :new.long_sec,
                :new.long_dir
             );
        ELSIF :new.orig_lat_long_units = 'degrees dec. minutes' THEN
        	:new.caclulated_dlat := :new.lat_deg + (:new.dec_lat_min / 60);
	        if :new.lat_dir = 'S' THEN
	        	:new.caclulated_dlat := :new.caclulated_dlat * -1;
	        end if;
	        :new.calculated_dlong := :new.long_deg + (:new.dec_long_min / 60);
	        IF :new.long_dir = 'W' THEN
	        	:new.calculated_dlong := :new.calculated_dlong * -1;
	        END IF;
	        :new.verbatim_coordinates := dm_to_string (
	                :new.lat_deg,
	                :new.dec_lat_min,
	                :new.lat_dir,
	                :new.long_deg,
	                :new.dec_long_min,
	                :new.long_dir
	             );
       ELSIF :new.orig_lat_long_units = 'decimal degrees' THEN
           :new.caclulated_dlat := :new.DEC_LAT;
           :new.calculated_dlong := :new.DEC_LONG;
           :new.verbatim_coordinates := dd_to_string (
                :new.DEC_LAT,
                :new.DEC_LONG
             );
       ELSIF :new.orig_lat_long_units = 'UTM' THEN
            :new.verbatim_coordinates := utm_to_string (
                :new.UTM_NS,
                :new.UTM_EW,
                :new.UTM_ZONE
            );
       ELSE
       		:NEW.verbatim_coordinates := NULL;
       END IF;
    end;
/

