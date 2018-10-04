CREATE OR REPLACE TRIGGER TR_LOCALITY_VPD_AID
	-- not sure if this still exists or not....
AFTER INSERT OR DELETE ON LOCALITY
FOR EACH ROW
BEGIN
    IF inserting THEN
    	INSERT INTO vpd_collection_locality (
    	    locality_id,
    	    collection_id,
    	    stale_fg)
	    VALUES (
	        :NEW.locality_id,
	        0,
	        0);
    ELSIF deleting THEN
    	DELETE FROM vpd_collection_locality 
    	WHERE locality_id = :OLD.locality_id;
    END IF;
END;


-- triger  LOCALITY_CT_CHECK is obsolete and may be deleted

CREATE OR REPLACE TRIGGER 

see flat_triggers
TR_LOCALITY_AU_FLAT
	-- update cached specimen data when locality stuff changes
AFTER UPDATE ON LOCALITY
FOR EACH ROW
BEGIN
    UPDATE flat SET 
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
        lastdate = SYSDATE
    WHERE locality_id = :NEW.locality_id;
END;





CREATE OR REPLACE TRIGGER 
	TR_LOCALITY_FAKEERR_AID
	-- approximates error to allow more precise/complex searching
	AFTER 
		INSERT OR 
		DELETE OR 
		UPDATE ON 
	LOCALITY
FOR EACH ROW
BEGIN
    IF inserting or updating THEN
    	update fake_coordinate_error set stale_fg=1 where locality_id=:NEW.locality_id;
    ELSIF deleting THEN
    	DELETE FROM fake_coordinate_error 
    	WHERE locality_id = :OLD.locality_id;
    END IF;
END;
/



CREATE OR REPLACE TRIGGER 
	TR_LOCALITY_BUD
	-- lock localities used by "verified and locked" specimens
	-- EDIT 2016-11: allow access by anyone, change logs are now being maintained
	-- block only verified
	
	-- and those shared by collections to which the current user
	-- does not have access
	BEFORE 
		UPDATE OR 
		DELETE ON 
	LOCALITY
FOR EACH ROW
DECLARE
    num INTEGER;
    allrec INTEGER;
    vpdrec INTEGER;
    username VARCHAR2(30);
    cid VARCHAR2(200);
BEGIN
     -- DO not block updates to the service data 
    if :NEW.GEOG_AUTH_REC_ID != :OLD.GEOG_AUTH_REC_ID or
    	nvl(:NEW.SPEC_LOCALITY,'OK') != nvl(:OLD.SPEC_LOCALITY,'OK') or
    	nvl(:NEW.DEC_LAT,0) != nvl(:OLD.DEC_LAT,0) or
    	nvl(:NEW.DEC_LONG,0) != nvl(:OLD.DEC_LONG,0) or
    	nvl(:NEW.MINIMUM_ELEVATION,0) != nvl(:OLD.MINIMUM_ELEVATION,0) or
    	nvl(:NEW.MAXIMUM_ELEVATION,0) != nvl(:OLD.MAXIMUM_ELEVATION,0) or
    	nvl(:NEW.ORIG_ELEV_UNITS,'OK') != nvl(:OLD.ORIG_ELEV_UNITS,'OK') or
    	nvl(:NEW.MIN_DEPTH,0) != nvl(:OLD.MIN_DEPTH,0) or
    	nvl(:NEW.MAX_DEPTH,0) != nvl(:OLD.MAX_DEPTH,0) or
    	nvl(:NEW.DEPTH_UNITS,'OK') != nvl(:OLD.DEPTH_UNITS,'OK') or
    	nvl(:NEW.MAX_ERROR_DISTANCE,0) != nvl(:OLD.MAX_ERROR_DISTANCE,0) or
    	nvl(:NEW.MAX_ERROR_UNITS,'OK') != nvl(:OLD.MAX_ERROR_UNITS,'OK') or
    	nvl(:NEW.DATUM,'OK') != nvl(:OLD.DATUM,'OK') or
    	nvl(:NEW.LOCALITY_REMARKS,'OK') != nvl(:OLD.LOCALITY_REMARKS,'OK') or
    	nvl(:NEW.GEOREFERENCE_SOURCE,'OK') != nvl(:OLD.GEOREFERENCE_SOURCE,'OK') or
    	nvl(:NEW.GEOREFERENCE_PROTOCOL,'OK') != nvl(:OLD.GEOREFERENCE_PROTOCOL,'OK') or
    	nvl(:NEW.LOCALITY_NAME,'OK') != nvl(:OLD.LOCALITY_NAME,'OK')
    then
	
		SELECT COUNT(*) INTO num
	    FROM collecting_event, specimen_event
	    WHERE collecting_event.collecting_event_id=specimen_event.collecting_event_id
	    AND collecting_event.locality_id=:OLD.locality_id
	    AND specimen_event.verificationstatus = 'verified and locked';
	
	    IF num > 0 THEN
	        raise_application_error(-20001,
	        'This locality is used in verified and locked specimen/events and may not be changed or deleted.');
	    END IF;
	
	 end if;
END;
/

/*
 * 
 * 
 * 
 * pre-2016-11 code removed from the above:
 * 
	    SELECT SYS_CONTEXT('USERENV','SESSION_USER') INTO username FROM dual;
	
	    SELECT SYS.GET_COLLID_COUNT(:OLD.locality_id) INTO allrec FROM dual;
	
	    EXECUTE IMMEDIATE 'SELECT COUNT(*)
	        FROM collecting_event, specimen_event, cataloged_item
	        WHERE collecting_event.collecting_event_id=specimen_event.collecting_event_id
	        AND specimen_event.collection_object_id=cataloged_item.collection_object_id
	        AND collecting_event.locality_id=' || :OLD.locality_id
	    INTO vpdrec;
	
	    IF allrec > vpdrec THEN
	        raise_application_error(-20001,
	            'This locality is shared and may not be changed or deleted.');
	    END IF;
 */
--SELECT dbms_metadata.get_ddl('TRIGGER','TRG_LOCALITY_BIU') FROM dual;

CREATE OR REPLACE TRIGGER trg_locality_biu
  -- enforces conditional data requirements
  -- and prevents nonsensical data
    BEFORE INSERT OR UPDATE ON locality
    FOR EACH ROW declare 
        status varchar2(255);
    BEGIN
	    -- Oracle is making some super-weird distinction between
	    -- NULL and 0-length (or something) for CLOBs, so....
	    if dbms_lob.getlength(:NEW.wkt_polygon) = 0 then
	    	:NEW.wkt_polygon:=NULL;
	    end if;
	    
	    -- set last check date to now so the auto merge procedure won't run for ~30D
	    if :NEW.last_dup_check_date is null then
	    	:NEW.last_dup_check_date:=sysdate;
	    end if;
	    
	    
        IF :NEW.DEC_LAT IS NOT NULL OR :NEW.DEC_LONG IS NOT NULL THEN
            IF :new.datum IS NULL THEN
                raise_application_error(-20001,'Datum is required when coordinates are given.');
            end if;
            IF :new.georeference_source IS NULL THEN
                raise_application_error(-20001,'georeference_source is required when coordinates are given.');
            end if;
            IF :new.georeference_protocol IS NULL THEN
                raise_application_error(-20001,'georeference_protocol is required when coordinates are given.');
            end if;
            IF :NEW.DEC_LAT IS NULL OR :NEW.DEC_LONG IS NULL THEN
                raise_application_error(-20001,'Either both or neither of Latitude and Longitude must be given.');
            END IF;
            IF :new.dec_lat < -90 OR :new.dec_lat > 90 THEN
                raise_application_error(-20001,'Latitude must be between -90 and 90.');
            END IF;
             IF :new.DEC_LONG < -180 OR :new.DEC_LONG > 180 THEN
                raise_application_error(-20001,'Longitude must be between -180 and 180.');
            END IF;
        elsif (
            :NEW.MAX_ERROR_DISTANCE is not null or 
            :NEW.MAX_ERROR_UNITS is not null or 
            :NEW.datum is not null or
            :NEW.GEOREFERENCE_SOURCE is not null or
            :NEW.GEOREFERENCE_PROTOCOL is not null
           ) then
            raise_application_error(-20001,'Error and units, datum, and georeference source and protocol must be accompanied by coordinates.');
        END IF;
        IF :NEW.DEPTH_UNITS IS NOT NULL OR :NEW.MAX_DEPTH IS NOT NULL OR :NEW.MIN_DEPTH IS NOT NULL THEN
            IF :NEW.DEPTH_UNITS IS NULL OR :NEW.MAX_DEPTH IS NULL OR :NEW.MIN_DEPTH IS NULL THEN
                raise_application_error(-20001,'Depth must include all or none of units, minimum, and maximum.'); 
            END IF;
        END IF;
        -- if we made it through the above we should have all or none
        IF :NEW.DEPTH_UNITS IS NOT NULL and :NEW.MAX_DEPTH IS NOT NULL and :NEW.MIN_DEPTH IS NOT NULL THEN
        	if to_meters(:NEW.MIN_DEPTH,:NEW.DEPTH_UNITS)>to_meters(:NEW.MAX_DEPTH,:NEW.DEPTH_UNITS) then
                raise_application_error(-20001,'Minimum Depth cannot be greater than Maximum Depth');
             end if;
         end if;


        IF :NEW.MAX_ERROR_DISTANCE IS NOT NULL OR :NEW.MAX_ERROR_UNITS IS NOT NULL THEN
            IF :NEW.MAX_ERROR_DISTANCE IS NULL OR :NEW.MAX_ERROR_UNITS IS NULL THEN
                raise_application_error(-20001,'Error must include both or neither of units and distance.'); 
            END IF;
        END IF;  
        
        IF :NEW.MINIMUM_ELEVATION IS NOT NULL OR :NEW.MAXIMUM_ELEVATION IS NOT NULL OR :NEW.ORIG_ELEV_UNITS IS NOT NULL THEN
            IF :NEW.MINIMUM_ELEVATION IS NULL OR :NEW.MAXIMUM_ELEVATION IS NULL OR :NEW.ORIG_ELEV_UNITS IS NULL THEN
                raise_application_error(-20001,'Elevation must include all or none of units, minimum, and maximum.'); 
            END IF;
        END IF;  
        -- if we made it through the above we should have all or none
         IF :NEW.MINIMUM_ELEVATION IS NOT NULL and :NEW.MAXIMUM_ELEVATION IS NOT NULL and :NEW.ORIG_ELEV_UNITS IS NOT NULL THEN
        	if to_meters(:NEW.MINIMUM_ELEVATION,:NEW.ORIG_ELEV_UNITS)>to_meters(:NEW.MAXIMUM_ELEVATION,:NEW.ORIG_ELEV_UNITS) then
                raise_application_error(-20001,'Minimum Elevation cannot be greater than Maximum Elevation');
             end if;
         end if;
    end;
/
sho err;
