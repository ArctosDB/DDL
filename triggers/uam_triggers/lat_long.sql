CREATE OR REPLACE TRIGGER LAT_LONG_CT_CHECK
BEFORE UPDATE OR INSERT ON LAT_LONG
FOR EACH ROW
DECLARE numrows NUMBER;
BEGIN
	IF is_iso8601(:NEW.determined_date) != 'valid' THEN
        raise_application_error(-20001,'Determined_Date: ' || is_iso8601(:NEW.determined_date));
    END IF;
	IF :new.orig_lat_long_units = 'deg. min. sec.' THEN
    	:new.dec_lat := :new.lat_deg + (:new.lat_min / 60) + (nvl(:new.lat_sec,0) / 3600);
        IF :new.lat_dir = 'S' THEN
            :new.dec_lat := :new.dec_lat * -1;
        END IF;
        :new.dec_long := :new.long_deg + (:new.long_min / 60) + (nvl(:new.long_sec,0) / 3600);
        IF :new.long_dir = 'W' THEN
            :new.dec_long := :new.dec_long * -1;
        END IF;
    ELSIF :new.orig_lat_long_units = 'degrees dec. minutes' THEN
    	:new.dec_lat := :new.lat_deg + (:new.dec_lat_min / 60);
    	if :new.lat_dir = 'S' THEN
    		:new.dec_lat := :new.dec_lat * -1;
    	end if;
    	:new.dec_long := :new.long_deg + (:new.dec_long_min / 60);
    	IF :new.long_dir = 'W' THEN
    		:new.dec_long := :new.dec_long * -1;
    	END IF;
    END IF;

	SELECT COUNT(*) INTO numrows 
	FROM ctVERIFICATIONSTATUS 
    WHERE VERIFICATIONSTATUS = :NEW.VERIFICATIONSTATUS;
        
	IF (numrows = 0) THEN
		raise_application_error(
		    -20001,
			'Invalid VERIFICATIONSTATUS');
	END IF;
	    
	SELECT COUNT(*) INTO numrows 
	FROM ctGEOREFMETHOD 
	WHERE GEOREFMETHOD = :NEW.GEOREFMETHOD;
	
	IF (numrows = 0) THEN
		raise_application_error(
		    -20001,
			'Invalid GEOREFMETHOD');
	END IF;
	    
	SELECT COUNT(*) INTO numrows 
	FROM ctdatum 
	WHERE datum = :NEW.datum;
	
	IF (numrows = 0) THEN
		raise_application_error(
		    -20001,
			'Invalid datum');
	END IF;
	    
	SELECT COUNT(*) INTO numrows 
	FROM ctlat_long_units 
	WHERE orig_lat_long_units = :NEW.orig_lat_long_units;
	
	IF (numrows = 0) THEN
		raise_application_error(
		    -20001,
			'Invalid orig_lat_long_units');
	END IF;
	    
	IF (:NEW.MAX_ERROR_UNITS IS NOT NULL) THEN
		SELECT COUNT(*) INTO numrows 
		FROM ctlat_long_error_units 
		WHERE LAT_LONG_ERROR_UNITS = :NEW.MAX_ERROR_UNITS;
		
		IF (numrows = 0) THEN
			raise_application_error(
			    -20001,
			    'Invalid MAX_ERROR_UNITS');
		END IF;
	END IF;
	    
	IF (:NEW.orig_lat_long_units = 'decimal degrees') THEN
		IF (:NEW.dec_lat IS NULL OR :NEW.dec_long IS NULL) THEN
			raise_application_error(
			    -20001,
			    'dec_lat and dec_long are required when orig_lat_long_units is decimal degrees');
        END IF;
    ELSIF (:NEW.orig_lat_long_units = 'deg. min. sec.') THEN
		IF (:NEW.LAT_DEG IS NULL 
		    OR :NEW.LAT_DIR IS NULL 
		    OR :NEW.LONG_DEG IS NULL 
		    OR :NEW.LONG_DIR IS NULL
        ) THEN
			raise_application_error(
			    -20001,
			    'Insufficient information to create new coordinates with degrees minutes seconds');
		END IF;
	ELSIF (:NEW.orig_lat_long_units = 'degrees dec. minutes') THEN
		IF (:NEW.LAT_DEG IS NULL 
            OR :NEW.LAT_DIR IS NULL 
            OR :NEW.LONG_DEG IS NULL 
		    OR :NEW.LONG_DIR IS NULL
        ) THEN
			raise_application_error(
			    -20001,
			    'Insufficient information to create new coordinates with degrees dec. minutes');
		END IF;
	ELSIF (:NEW.orig_lat_long_units = 'UTM') THEN
		IF (:NEW.utm_ew IS NULL OR :NEW.utm_ns IS NULL OR :NEW.utm_zone IS NULL) THEN
			raise_application_error(
			-20001,
			'Insufficient information to create new coordinates with UTM');
		END IF;
	ELSE
		raise_application_error(
			-20001,
			:NEW.orig_lat_long_units || ' is not handled. Please contact your database administrator.'
	   	);
	END IF;
END;

CREATE OR REPLACE TRIGGER TR_LATLONG_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON LAT_LONG
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting THEN 
        id := :OLD.locality_id;
    ELSE 
        id := :NEW.locality_id;
    END IF;
        
    UPDATE flat SET 
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
		lastdate = SYSDATE
    WHERE locality_id = id;
END;

CREATE OR REPLACE TRIGGER TR_LATLONG_ACCEPTED_BIUPA
BEFORE INSERT OR UPDATE ON LAT_LONG
FOR EACH ROW
DECLARE 
    numrows NUMBER;
    pragma autonomous_transaction;
BEGIN
    SELECT count(*) INTO numrows
    FROM lat_long 
    WHERE locality_id = :new.locality_id 
    AND accepted_lat_long_fg = 1;
	
    IF numrows > 0 AND :new.accepted_lat_long_fg = 1 THEN
    raise_application_error(
        -20001,
        'Accepted lat/long coordinates already exist for this locality.');
    END IF;
END;