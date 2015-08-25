CREATE OR REPLACE FUNCTION concatGeologyAttributes(coid in number)
RETURN varchar2
AS
    type rc is ref cursor;
    l_str varchar2(4000);
    l_sep varchar2(30);
    l_val varchar2(4000);
BEGIN
    FOR r IN (
        SELECT 
--            ga.geology_attribute_id || '|' ||
--            ga.locality_id || '|' ||
            ga.geology_attribute || '|' ||
            ga.geo_att_value || '|' ||
            ga.geo_att_determiner_id || '|' ||
            ga.geo_att_determined_date || '|' ||
            ga.geo_att_determined_method || '|' ||
            ga.geo_att_remark oneRec
        FROM
            geology_attributes ga,
            collecting_event ce,
            cataloged_item ci
        WHERE ga.locality_id = ce.locality_id
        AND ce.collecting_event_id = ci.collecting_event_id
        AND ci.collection_object_id = coid
        ORDER BY
--            ga.geology_attribute_id,
--			ga.locality_id,
			ga.geology_attribute,
			ga.geo_att_value,
			ga.geo_att_determiner_id,
			ga.geo_att_determined_date,
			ga.geo_att_determined_method,
			ga.geo_att_remark
    ) LOOP
        l_str := l_str || l_sep || r.oneRec;
        l_sep := '; ';
    END LOOP;

    RETURN l_str;
END;
/

CREATE PUBLIC SYNONYM concatGeologyAttributes FOR concatGeologyAttributes;
GRANT EXECUTE ON concatGeologyAttributes TO PUBLIC;

CREATE OR REPLACE FUNCTION concatCollectingEvent(coid in number)
RETURN varchar2
AS
    l_str varchar2(4000);
BEGIN
    SELECT 
		ce.collecting_event_id || '|' ||
		ce.locality_id || '|' ||
		ce.began_date || '|' ||
		ce.ended_date || '|' ||
		ce.verbatim_date || '|' ||
		ce.verbatim_locality || '|' ||
		ce.coll_event_remarks || '|' ||
		ce.collecting_source || '|' ||
		ce.collecting_method || '|' ||
		ce.habitat_desc
    INTO l_str
    FROM
        collecting_event ce,
        cataloged_item ci
    WHERE ce.collecting_event_id = ci.collecting_event_id
    AND ci.collection_object_id = coid;
		
    RETURN l_str;
END;
/

CREATE OR REPLACE FUNCTION concatLocality(coid in number)
RETURN varchar2
AS
    l_str varchar2(4000);
BEGIN
    SELECT 
		l.locality_id || '|' ||
		l.geog_auth_rec_id || '|' ||
		l.maximum_elevation || '|' ||
		l.minimum_elevation || '|' ||
		l.orig_elev_units || '|' ||
		l.spec_locality || '|' ||
		l.locality_remarks || '|' ||
		l.depth_units || '|' ||
		l.min_depth || '|' ||
		l.max_depth || '|' ||
		l.nogeorefbecause
    INTO l_str
    FROM
        locality l,
        collecting_event ce,
        cataloged_item ci
    WHERE l.locality_id = ce.locality_id
    AND ce.collecting_event_id = ci.collecting_event_id
    AND ci.collection_object_id = coid;
		
    RETURN l_str;
END;
/

CREATE OR REPLACE FUNCTION concatLatLongAccepted(coid in number)
RETURN varchar2
AS
    l_str varchar2(4000);
BEGIN
    SELECT 
		ll.lat_long_id || '|' ||
		ll.locality_id || '|' ||
		ll.lat_deg || '|' ||
		ll.dec_lat_min || '|' ||
		ll.lat_min || '|' ||
		ll.lat_sec || '|' ||
		ll.lat_dir || '|' ||
		ll.long_deg || '|' ||
		ll.dec_long_min || '|' ||
		ll.long_min || '|' ||
		ll.long_sec || '|' ||
		ll.long_dir || '|' ||
		ll.dec_lat || '|' ||
		ll.dec_long || '|' ||
		ll.datum || '|' ||
		ll.utm_zone || '|' ||
		ll.utm_ew || '|' ||
		ll.utm_ns || '|' ||
		ll.orig_lat_long_units || '|' ||
		ll.determined_by_agent_id || '|' ||
		ll.determined_date || '|' ||
		ll.lat_long_ref_source || '|' ||
		ll.lat_long_remarks || '|' ||
		ll.max_error_distance || '|' ||
		ll.max_error_units || '|' ||
		ll.accepted_lat_long_fg || '|' ||
		ll.extent || '|' ||
		ll.gpsaccuracy || '|' ||
		ll.georefmethod || '|' ||
		ll.verificationstatus
    INTO l_str
    FROM
        lat_long ll,
        locality l,
        collecting_event ce,
        cataloged_item ci
    WHERE ll.accepted_lat_long_fg = 1
    AND ll.locality_id = l.locality_id
    AND l.locality_id = ce.locality_id
    AND ce.collecting_event_id = ci.collecting_event_id
    AND ci.collection_object_id = coid;
		
    RETURN l_str;
END;
/

CREATE OR REPLACE FUNCTION concatLatLongUnaccepteds(coid in number)
RETURN varchar2
AS
    type rc is ref cursor;
    l_str varchar2(4000);
    l_sep varchar2(30);
    l_val varchar2(4000);
BEGIN
    FOR r IN (
		SELECT 
			ll.lat_long_id || '|' ||
			ll.locality_id || '|' ||
			ll.lat_deg || '|' ||
			ll.dec_lat_min || '|' ||
			ll.lat_min || '|' ||
			ll.lat_sec || '|' ||
			ll.lat_dir || '|' ||
			ll.long_deg || '|' ||
			ll.dec_long_min || '|' ||
			ll.long_min || '|' ||
			ll.long_sec || '|' ||
			ll.long_dir || '|' ||
			ll.dec_lat || '|' ||
			ll.dec_long || '|' ||
			ll.datum || '|' ||
			ll.utm_zone || '|' ||
			ll.utm_ew || '|' ||
			ll.utm_ns || '|' ||
			ll.orig_lat_long_units || '|' ||
			ll.determined_by_agent_id || '|' ||
			ll.determined_date || '|' ||
			ll.lat_long_ref_source || '|' ||
			ll.lat_long_remarks || '|' ||
			ll.max_error_distance || '|' ||
			ll.max_error_units || '|' ||
			ll.accepted_lat_long_fg || '|' ||
			ll.extent || '|' ||
			ll.gpsaccuracy || '|' ||
			ll.georefmethod || '|' ||
			ll.verificationstatus oneRec
		FROM
			lat_long ll,
			locality l,
			collecting_event ce,
			cataloged_item ci
		WHERE ll.accepted_lat_long_fg = 0
		AND ll.locality_id = l.locality_id
		AND l.locality_id = ce.locality_id
		AND ce.collecting_event_id = ci.collecting_event_id
		AND ci.collection_object_id = coid
		ORDER BY
			ll.lat_long_id
	) LOOP
		l_str := l_str || l_sep || r.oneRec;
		l_sep := '; ';
	END LOOP;
		
    RETURN l_str;
END;
/
                                              
CREATE OR REPLACE VIEW spec_with_loc_test (
	COLLECTION_OBJECT_ID,
	COLLECTING_EVENT_ID,
	GEOG_AUTH_REC_ID,
	LOCALITY_ID	,
	LAT_LONG_ID,
	-- collecting_event
	BEGAN_DATE,
	ENDED_DATE,
	VERBATIM_DATE,
	VERBATIM_LOCALITY,
	COLL_EVENT_REMARKS,
	COLLECTING_SOURCE,
	COLLECTING_METHOD,
	HABITAT_DESC,
	-- geog_auth_rec
	HIGHER_GEOG,
	-- locality
	MAXIMUM_ELEVATION,
	MINIMUM_ELEVATION,
	ORIG_ELEV_UNITS,
	SPEC_LOCALITY,
	LOCALITY_REMARKS,
	DEPTH_UNITS,
	MIN_DEPTH,
	MAX_DEPTH,
	NOGEOREFBECAUSE,
	-- lat_long
	LAT_DEG,
	DEC_LAT_MIN,
	LAT_MIN,
	LAT_SEC,
	LAT_DIR,
	LONG_DEG,
	DEC_LONG_MIN,
	LONG_MIN,
	LONG_SEC,
	LONG_DIR,
	DEC_LAT,
	DEC_LONG,
	DATUM,
	UTM_ZONE,
	UTM_EW,
	UTM_NS,
	ORIG_LAT_LONG_UNITS,
	DETERMINED_BY_AGENT_ID,
	COORDINATE_DETERMINER,
	DETERMINED_DATE,
	LAT_LONG_REF_SOURCE,
	LAT_LONG_REMARKS,
	MAX_ERROR_DISTANCE,
	MAX_ERROR_UNITS,
	ACCEPTED_LAT_LONG_FG,
	EXTENT,
	GPSACCURACY,
	GEOREFMETHOD,
	VERIFICATIONSTATUS,
	-- geology_attributes
	GEOLOGY_ATTRIBUTES)
AS SELECT
	CATALOGED_ITEM.COLLECTION_OBJECT_ID,
	COLLECTING_EVENT.COLLECTING_EVENT_ID,
	GEOG_AUTH_REC.GEOG_AUTH_REC_ID,
	LOCALITY.LOCALITY_ID,
	ACCEPTED_LAT_LONG.LAT_LONG_ID,
	COLLECTING_EVENT.BEGAN_DATE,
	COLLECTING_EVENT.ENDED_DATE,
	COLLECTING_EVENT.VERBATIM_DATE,
	COLLECTING_EVENT.VERBATIM_LOCALITY,
	COLLECTING_EVENT.COLL_EVENT_REMARKS,
	COLLECTING_EVENT.COLLECTING_SOURCE,
	COLLECTING_EVENT.COLLECTING_METHOD,
	COLLECTING_EVENT.HABITAT_DESC,
	GEOG_AUTH_REC.HIGHER_GEOG,
	LOCALITY.MAXIMUM_ELEVATION,
	LOCALITY.MINIMUM_ELEVATION,
	LOCALITY.ORIG_ELEV_UNITS,
	LOCALITY.SPEC_LOCALITY,
	LOCALITY.LOCALITY_REMARKS,
	LOCALITY.DEPTH_UNITS,
	LOCALITY.MIN_DEPTH,
	LOCALITY.MAX_DEPTH,
	LOCALITY.NOGEOREFBECAUSE,
	ACCEPTED_LAT_LONG.LAT_DEG,
	ACCEPTED_LAT_LONG.DEC_LAT_MIN,
	ACCEPTED_LAT_LONG.LAT_MIN,
	ACCEPTED_LAT_LONG.LAT_SEC,
	ACCEPTED_LAT_LONG.LAT_DIR,
	ACCEPTED_LAT_LONG.LONG_DEG,
	ACCEPTED_LAT_LONG.DEC_LONG_MIN,
	ACCEPTED_LAT_LONG.LONG_MIN,
	ACCEPTED_LAT_LONG.LONG_SEC,
	ACCEPTED_LAT_LONG.LONG_DIR,
	ACCEPTED_LAT_LONG.DEC_LAT,
	ACCEPTED_LAT_LONG.DEC_LONG,
	ACCEPTED_LAT_LONG.DATUM,
	ACCEPTED_LAT_LONG.UTM_ZONE,
	ACCEPTED_LAT_LONG.UTM_EW,
	ACCEPTED_LAT_LONG.UTM_NS,
	ACCEPTED_LAT_LONG.ORIG_LAT_LONG_UNITS,
	ACCEPTED_LAT_LONG.DETERMINED_BY_AGENT_ID,
	PREFERRED_AGENT_NAME.AGENT_NAME COORDINATE_DETERMINER,
	ACCEPTED_LAT_LONG.DETERMINED_DATE,
	ACCEPTED_LAT_LONG.LAT_LONG_REF_SOURCE,
	ACCEPTED_LAT_LONG.LAT_LONG_REMARKS,
	ACCEPTED_LAT_LONG.MAX_ERROR_DISTANCE,
	ACCEPTED_LAT_LONG.MAX_ERROR_UNITS,
	ACCEPTED_LAT_LONG.ACCEPTED_LAT_LONG_FG,
	ACCEPTED_LAT_LONG.EXTENT,
	ACCEPTED_LAT_LONG.GPSACCURACY,
	ACCEPTED_LAT_LONG.GEOREFMETHOD,
	ACCEPTED_LAT_LONG.VERIFICATIONSTATUS,
	concatGeologyAttributes(cataloged_item.collection_object_id)
FROM
    LOCALITY,
	ACCEPTED_LAT_LONG,
	GEOG_AUTH_REC,
	COLLECTING_EVENT,
	CATALOGED_ITEM,
    PREFERRED_AGENT_NAME
WHERE LOCALITY.GEOG_AUTH_REC_ID = GEOG_AUTH_REC.GEOG_AUTH_REC_ID
    AND LOCALITY.LOCALITY_ID = ACCEPTED_LAT_LONG.LOCALITY_ID (+)
    AND LOCALITY.LOCALITY_ID = COLLECTING_EVENT.LOCALITY_ID
    AND ACCEPTED_LAT_LONG.DETERMINED_BY_AGENT_ID = PREFERRED_AGENT_NAME.AGENT_ID (+)
    AND COLLECTING_EVENT.COLLECTING_EVENT_ID = CATALOGED_ITEM.COLLECTING_EVENT_ID
;

CREATE OR REPLACE TRIGGER UP_SPEC_WITH_LOC
INSTEAD OF UPDATE
ON SPEC_WITH_LOC_TEST
FOR EACH ROW
DECLARE
    old_geolattr VARCHAR2(4000);
    old_latlong VARCHAR2(4000);
    old_locality VARCHAR2(4000);
    old_collevent VARCHAR2(4000);
    new_geolattr VARCHAR2(4000);
    new_latlong VARCHAR2(4000);
    new_locality VARCHAR2(4000);
    new_collevent VARCHAR2(4000);
	ngeog_auth_rec_id NUMBER;
	nlocality_id NUMBER;
	ncollecting_event_id NUMBER;
	nlat_long_id NUMBER;
	num NUMBER;
	oLocalityId VARCHAR2(4000);
	oCollectingEventId VARCHAR2(255);
BEGIN
    
    --geology_attributes
    --acc_lat_long
    --locality/geology
    --collecting_event
    
	SELECT COUNT(*) INTO num
	FROM GEOG_AUTH_REC
	WHERE HIGHER_GEOG = :NEW.HIGHER_GEOG;
	
	IF num = 0 THEN
		RAISE_APPLICATION_ERROR(-20000, 'New higher geography not found.');
	END IF;
	
	SELECT GEOG_AUTH_REC_ID INTO ngeog_auth_rec_id
	FROM GEOG_AUTH_REC
	WHERE HIGHER_GEOG = :NEW.HIGHER_GEOG;
    
	DBMS_OUTPUT.PUT_LINE('ngeog_auth_rec_id: ' || ngeog_auth_rec_id);
	
	IF :NEW.ORIG_LAT_LONG_UNITS IS NULL THEN
		RAISE_APPLICATION_ERROR(-20000, 'Original Lat/Long Units cannot be null.');
	END IF;

	old_collevent := 
		:OLD.BEGAN_DATE || '|' ||
		:OLD.ENDED_DATE || '|' ||
		:OLD.VERBATIM_DATE || '|' ||
		:OLD.VERBATIM_LOCALITY || '|' ||
		:OLD.COLL_EVENT_REMARKS || '|' ||
		:OLD.COLLECTING_SOURCE || '|' ||
		:OLD.COLLECTING_METHOD || '|' ||
		:OLD.HABITAT_DESC;
		
	DBMS_OUTPUT.PUT_LINE('old_collevent: ' || old_collevent);
		
    new_collevent := 
		:NEW.BEGAN_DATE || '|' ||
		:NEW.ENDED_DATE || '|' ||
		:NEW.VERBATIM_DATE || '|' ||
		:NEW.VERBATIM_LOCALITY || '|' ||
		:NEW.COLL_EVENT_REMARKS || '|' ||
		:NEW.COLLECTING_SOURCE || '|' ||
		:NEW.COLLECTING_METHOD || '|' ||
		:NEW.HABITAT_DESC;
		
	DBMS_OUTPUT.PUT_LINE('new_collevent: ' || new_collevent);
	
	old_locality := 
		:OLD.MAXIMUM_ELEVATION || '|' ||
		:OLD.MINIMUM_ELEVATION || '|' ||
		:OLD.ORIG_ELEV_UNITS || '|' ||
		:OLD.SPEC_LOCALITY || '|' ||
		:OLD.LOCALITY_REMARKS || '|' ||
		:OLD.DEPTH_UNITS || '|' ||
		:OLD.MIN_DEPTH || '|' ||
		:OLD.MAX_DEPTH || '|' ||
		:OLD.NOGEOREFBECAUSE;
		
	DBMS_OUTPUT.PUT_LINE('old_locality: ' || old_locality);
	
	new_locality := 
		:NEW.MAXIMUM_ELEVATION || '|' ||
		:NEW.MINIMUM_ELEVATION || '|' ||
		:NEW.ORIG_ELEV_UNITS || '|' ||
		:NEW.SPEC_LOCALITY || '|' ||
		:NEW.LOCALITY_REMARKS || '|' ||
		:NEW.DEPTH_UNITS || '|' ||
		:NEW.MIN_DEPTH || '|' ||
		:NEW.MAX_DEPTH || '|' ||
		:NEW.NOGEOREFBECAUSE;
		
	DBMS_OUTPUT.PUT_LINE('new_locality: ' || new_locality);
		
	old_latlong :=
		:OLD.LAT_DEG || '|' ||
		:OLD.DEC_LAT_MIN || '|' ||
		:OLD.LAT_MIN || '|' ||
		:OLD.LAT_SEC || '|' ||
		:OLD.LAT_DIR || '|' ||
		:OLD.LONG_DEG || '|' ||
		:OLD.DEC_LONG_MIN || '|' ||
		:OLD.LONG_MIN || '|' ||
		:OLD.LONG_SEC || '|' ||
		:OLD.LONG_DIR || '|' ||
		:OLD.DEC_LAT || '|' ||
		:OLD.DEC_LONG || '|' ||
		:OLD.DATUM || '|' ||
		:OLD.UTM_ZONE || '|' ||
		:OLD.UTM_EW || '|' ||
		:OLD.UTM_NS || '|' ||
		:OLD.ORIG_LAT_LONG_UNITS || '|' ||
		:OLD.COORDINATE_DETERMINER || '|' ||
		:OLD.DETERMINED_DATE || '|' ||
		:OLD.LAT_LONG_REF_SOURCE || '|' ||
		:OLD.LAT_LONG_REMARKS || '|' ||
		:OLD.MAX_ERROR_DISTANCE || '|' ||
		:OLD.MAX_ERROR_UNITS || '|' ||
		:OLD.ACCEPTED_LAT_LONG_FG || '|' ||
		:OLD.EXTENT || '|' ||
		:OLD.GPSACCURACY || '|' ||
		:OLD.GEOREFMETHOD || '|' ||
		:OLD.VERIFICATIONSTATUS;
		    
	DBMS_OUTPUT.PUT_LINE('old_latlong: ' || old_latlong);

	new_latlong :=
		:NEW.LAT_DEG || '|' ||
		:NEW.DEC_LAT_MIN || '|' ||
		:NEW.LAT_MIN || '|' ||
		:NEW.LAT_SEC || '|' ||
		:NEW.LAT_DIR || '|' ||
		:NEW.LONG_DEG || '|' ||
		:NEW.DEC_LONG_MIN || '|' ||
		:NEW.LONG_MIN || '|' ||
		:NEW.LONG_SEC || '|' ||
		:NEW.LONG_DIR || '|' ||
		:NEW.DEC_LAT || '|' ||
		:NEW.DEC_LONG || '|' ||
		:NEW.DATUM || '|' ||
		:NEW.UTM_ZONE || '|' ||
		:NEW.UTM_EW || '|' ||
		:NEW.UTM_NS || '|' ||
		:NEW.ORIG_LAT_LONG_UNITS || '|' ||
		:NEW.COORDINATE_DETERMINER || '|' ||
		:NEW.DETERMINED_DATE || '|' ||
		:NEW.LAT_LONG_REF_SOURCE || '|' ||
		:NEW.LAT_LONG_REMARKS || '|' ||
		:NEW.MAX_ERROR_DISTANCE || '|' ||
		:NEW.MAX_ERROR_UNITS || '|' ||
		:NEW.ACCEPTED_LAT_LONG_FG || '|' ||
		:NEW.EXTENT || '|' ||
		:NEW.GPSACCURACY || '|' ||
		:NEW.GEOREFMETHOD || '|' ||
		:NEW.VERIFICATIONSTATUS;
		    
	DBMS_OUTPUT.PUT_LINE('new_latlong: ' || new_latlong);
    
	IF (new_collevent != old_collevent
		OR new_locality != old_locality 
        OR new_latlong != old_latlong
        OR :NEW.GEOLOGY_ATTRIBUTES != :OLD.GEOLOGY_ATTRIBUTES
	) THEN
	    SELECT sq_locality_id.nextval INTO nlocality_id FROM dual;
		DBMS_OUTPUT.PUT_LINE('nlocality_id: ' || nlocality_id);
	    
	    INSERT INTO locality (
			LOCALITY_ID,
			GEOG_AUTH_REC_ID,
			MAXIMUM_ELEVATION,
			MINIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			SPEC_LOCALITY,
			LOCALITY_REMARKS,
			DEPTH_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			NOGEOREFBECAUSE)
        VALUES (            
			nlocality_id,
			ngeog_auth_rec_id,
			:NEW.MAXIMUM_ELEVATION,
			:NEW.MINIMUM_ELEVATION,
			:NEW.ORIG_ELEV_UNITS,
			:NEW.SPEC_LOCALITY,
			:NEW.LOCALITY_REMARKS,
			:NEW.DEPTH_UNITS,
			:NEW.MIN_DEPTH,
			:NEW.MAX_DEPTH,
			:NEW.NOGEOREFBECAUSE);
			
	    SELECT sq_lat_long_id.nextval INTO nlat_long_id FROM dual;
		DBMS_OUTPUT.PUT_LINE('nlat_long_id: ' || nlat_long_id);
			
		INSERT INTO lat_long (
			LAT_LONG_ID,
			LOCALITY_ID,
			LAT_DEG,
			DEC_LAT_MIN,
			LAT_MIN,
			LAT_SEC,
			LAT_DIR,
			LONG_DEG,
			DEC_LONG_MIN,
			LONG_MIN,
			LONG_SEC,
			LONG_DIR,
			DEC_LAT,
			DEC_LONG,
			DATUM,
			UTM_ZONE,
			UTM_EW,
			UTM_NS,
			ORIG_LAT_LONG_UNITS,
			DETERMINED_BY_AGENT_ID,
			DETERMINED_DATE,
			LAT_LONG_REF_SOURCE,
			LAT_LONG_REMARKS,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			ACCEPTED_LAT_LONG_FG,
			EXTENT,
			GPSACCURACY,
			GEOREFMETHOD,
			VERIFICATIONSTATUS)
		VALUES (
			nlat_long_id,
			nlocality_id,
			:NEW.LAT_DEG,
			:NEW.DEC_LAT_MIN,
			:NEW.LAT_MIN,
			:NEW.LAT_SEC,
			:NEW.LAT_DIR,
			:NEW.LONG_DEG,
			:NEW.DEC_LONG_MIN,
			:NEW.LONG_MIN,
			:NEW.LONG_SEC,
			:NEW.LONG_DIR,
			:NEW.DEC_LAT,
			:NEW.DEC_LONG,
			:NEW.DATUM,
			:NEW.UTM_ZONE,
			:NEW.UTM_EW,
			:NEW.UTM_NS,
			:NEW.ORIG_LAT_LONG_UNITS,
			:NEW.DETERMINED_BY_AGENT_ID,
			:NEW.DETERMINED_DATE,
			:NEW.LAT_LONG_REF_SOURCE,
			:NEW.LAT_LONG_REMARKS,
			:NEW.MAX_ERROR_DISTANCE,
			:NEW.MAX_ERROR_UNITS,
			1,
			:NEW.EXTENT,
			:NEW.GPSACCURACY,
			:NEW.GEOREFMETHOD,
			:NEW.VERIFICATIONSTATUS);

	    SELECT sq_collecting_event_id.nextval INTO ncollecting_event_id FROM dual;
		DBMS_OUTPUT.PUT_LINE('ncollecting_event_id: ' || ncollecting_event_id);
		
		INSERT INTO collecting_event (
			COLLECTING_EVENT_ID,
			LOCALITY_ID,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			COLL_EVENT_REMARKS,
			COLLECTING_SOURCE,
			COLLECTING_METHOD,
			HABITAT_DESC)
		VALUES (
			ncollecting_event_id,
			nlocality_id,
			:NEW.BEGAN_DATE,
			:NEW.ENDED_DATE,
			:NEW.VERBATIM_DATE,
			:NEW.VERBATIM_LOCALITY,
			:NEW.COLL_EVENT_REMARKS,
			:NEW.COLLECTING_SOURCE,
			:NEW.COLLECTING_METHOD,
			:NEW.HABITAT_DESC);

	    UPDATE CATALOGED_ITEM
	    SET COLLECTING_EVENT_ID = ncollecting_event_id 
	    WHERE COLLECTION_OBJECT_ID = :NEW.COLLECTION_OBJECT_ID;
	END IF;
		

	-- geology_attributes
	GEOLOGY_ATTRIBUTES)
    
    -- get geog_auth_rec_id or fail

	
	
	
---------------
/*
CREATE OR REPLACE TRIGGER UP_SPEC_WITH_LOC
INSTEAD OF UPDATE
ON SPEC_WITH_LOC
FOR EACH ROW
DECLARE
	ngeog_auth_rec_id NUMBER;
	nlocality_id NUMBER;
	ncollecting_event_id NUMBER;
	nlat_long_id NUMBER;
	num NUMBER;
	oLocalityId VARCHAR2(4000);
	oCollectingEventId VARCHAR2(255);
BEGIN
	-- possibilities covered in this trigger:
	-- 1) One or more appropriate coll event/locality/coordinates exist
	-- 		Solution: update cataloged item with the new collecting_event_id
	-- 2) One or more appropriate locality/ies exist/s
	-- 		Solution: create an appropriate collecting event for the good locality, update cataloged_item
	-- 3) No collecting events or localities exist
	-- 		Solution: create everything, update cataloged_item

	-- make sure we can get a good geog_auth_rec_id
	SELECT COUNT(*) INTO num
	FROM GEOG_AUTH_REC
	WHERE HIGHER_GEOG = :NEW.HIGHER_GEOG;
	
	IF num = 0 THEN
		RAISE_APPLICATION_ERROR(-20000, 'New higher geography not found.');
	END IF;

	-- get g_auth_rec_id into a local variable
	-- unique index on geog_auth_rec.higher_geog
	-- SELECT MIN(GEOG_AUTH_REC_ID) INTO ngeog_auth_rec_id
	SELECT GEOG_AUTH_REC_ID INTO ngeog_auth_rec_id
	FROM GEOG_AUTH_REC
	WHERE HIGHER_GEOG = :NEW.HIGHER_GEOG;
	
	DBMS_OUTPUT.PUT_LINE('ngeog_auth_rec_id: ' || ngeog_auth_rec_id);
	
	-- get the old IDs - we may want to delete them at the end
	-- need lat_long_id??? or geology_attribute_id???
	-- have to deal with multiple values since a collection_object_id will have multiple records
	-- due to one:many geology.
	SELECT COUNT(DISTINCT(LOCALITY_ID, COLLECTING_EVENT_ID)) INTO num
	FROM SPEC_WITH_LOC
	WHERE COLLECTION_OBJECT_ID = :NEW.COLLECTION_OBJECT_ID;
	
	IF num != 0 THEN
		RAISE_APPLICATION_ERROR(
		    -20000, 
		    'There are more than one distinct locid, colleventid for collobject: ' || 
		        :NEW.COLLECTION_OBJECT_ID);
	END IF;
	
	SELECT DISTINCT LOCALITY_ID, COLLECTING_EVENT_ID INTO oLocalityId, oCollectingEventId
	FROM SPEC_WITH_LOC
	WHERE COLLECTION_OBJECT_ID = :NEW.COLLECTION_OBJECT_ID;
	
	SELECT NVL(MIN(LOCALITY_ID),-1) INTO nlocality_id
	FROM LOC_ACC_LAT_LONG
	WHERE
		GEOG_AUTH_REC_ID || '|' ||
		MAXIMUM_ELEVATION || '|' ||
		MINIMUM_ELEVATION || '|' ||
		ORIG_ELEV_UNITS || '|' ||
		SPEC_LOCALITY || '|' ||
		LOCALITY_REMARKS || '|' ||
		DEPTH_UNITS || '|' ||
		MIN_DEPTH || '|' ||
		MAX_DEPTH || '|' ||
		NOGEOREFBECAUSE || '|' ||
		LAT_DEG || '|' ||
		DEC_LAT_MIN || '|' ||
		LAT_MIN || '|' ||
		LAT_SEC || '|' ||
		LAT_DIR || '|' ||
		LONG_DEG || '|' ||
		DEC_LONG_MIN || '|' ||
		LONG_MIN || '|' ||
		LONG_SEC || '|' ||
		LONG_DIR || '|' ||
		DEC_LAT || '|' ||
		DEC_LONG || '|' ||
		DATUM || '|' ||
		UTM_ZONE || '|' ||
		UTM_EW || '|' ||
		UTM_NS || '|' ||
		ORIG_LAT_LONG_UNITS || '|' ||
		DETERMINED_BY_AGENT_ID || '|' ||
		DETERMINED_DATE || '|' ||
		LAT_LONG_REF_SOURCE || '|' ||
		LAT_LONG_REMARKS || '|' ||
		MAX_ERROR_DISTANCE || '|' ||
		MAX_ERROR_UNITS || '|' ||
		EXTENT || '|' ||
		GPSACCURACY || '|' ||
		GEOREFMETHOD || '|' ||
		VERIFICATIONSTATUS
		= 
		ngeog_auth_rec_id || '|' ||
		:NEW.MAXIMUM_ELEVATION || '|' ||
		:NEW.MINIMUM_ELEVATION || '|' ||
		:NEW.ORIG_ELEV_UNITS || '|' ||
		:NEW.SPEC_LOCALITY || '|' ||
		:NEW.LOCALITY_REMARKS || '|' ||
		:NEW.DEPTH_UNITS || '|' ||
		:NEW.MIN_DEPTH || '|' ||
		:NEW.MAX_DEPTH || '|' ||
		:NEW.NOGEOREFBECAUSE || '|' ||
		:NEW.LAT_DEG || '|' ||
		:NEW.DEC_LAT_MIN || '|' ||
		:NEW.LAT_MIN || '|' ||
		:NEW.LAT_SEC || '|' ||
		:NEW.LAT_DIR || '|' ||
		:NEW.LONG_DEG || '|' ||
		:NEW.DEC_LONG_MIN || '|' ||
		:NEW.LONG_MIN || '|' ||
		:NEW.LONG_SEC || '|' ||
		:NEW.LONG_DIR || '|' ||
		:NEW.DEC_LAT || '|' ||
		:NEW.DEC_LONG || '|' ||
		:NEW.DATUM || '|' ||
		:NEW.UTM_ZONE || '|' ||
		:NEW.UTM_EW || '|' ||
		:NEW.UTM_NS || '|' ||
		:NEW.ORIG_LAT_LONG_UNITS || '|' ||
		:NEW.DETERMINED_BY_AGENT_ID || '|' ||
		:NEW.DETERMINED_DATE || '|' ||
		:NEW.LAT_LONG_REF_SOURCE || '|' ||
		:NEW.LAT_LONG_REMARKS || '|' ||
		:NEW.MAX_ERROR_DISTANCE || '|' ||
		:NEW.MAX_ERROR_UNITS || '|' ||
		:NEW.EXTENT || '|' ||
		:NEW.GPSACCURACY || '|' ||
		:NEW.GEOREFMETHOD || '|' ||
		:NEW.VERIFICATIONSTATUS;
	/*
	select nvl(min(locality_id),-1) INTO nlocality_id
	FROM loc_acc_lat_long
	WHERE GEOG_AUTH_REC_ID = ngeog_auth_rec_id
		AND NVL(MAXIMUM_ELEVATION,-1) = NVL(:NEW.MAXIMUM_ELEVATION,-1)
		AND NVL(MINIMUM_ELEVATION,-1) = NVL(:NEW.MINIMUM_ELEVATION,-1)
		AND NVL(ORIG_ELEV_UNITS,'NULL') = NVL(:NEW.ORIG_ELEV_UNITS,'NULL')
		AND NVL(SPEC_LOCALITY,'NULL') = NVL(:NEW.SPEC_LOCALITY,'NULL')
		AND NVL(LOCALITY_REMARKS,'NULL') = NVL(:NEW.LOCALITY_REMARKS,'NULL')
		AND NVL(DEPTH_UNITS,'NULL') = NVL(:NEW.DEPTH_UNITS,'NULL')
		AND NVL(MIN_DEPTH,-1) = NVL(:NEW.MIN_DEPTH,-1)
		AND NVL(MAX_DEPTH,-1) = NVL(:NEW.MAX_DEPTH,-1)
		AND NVL(NOGEOREFBECAUSE,'NULL') = NVL(:NEW.NOGEOREFBECAUSE,'NULL')
		AND NVL(LAT_DEG,-1) = NVL(:NEW.LAT_DEG,-1)
		AND NVL(DEC_LAT_MIN,-1) = NVL(:NEW.DEC_LAT_MIN,-1)
		AND NVL(LAT_MIN,-1) = NVL(:NEW.LAT_MIN,-1)
		AND NVL(LAT_SEC,-1) = NVL(:NEW.LAT_SEC,-1)
		AND NVL(LAT_DIR,'NULL') = NVL(:NEW.LAT_DIR,'NULL')
		AND NVL(LONG_DEG,-1) = NVL(:NEW.LONG_DEG,-1)
		AND NVL(DEC_LONG_MIN,-1) = NVL(:NEW.DEC_LONG_MIN,-1)
		AND NVL(LONG_MIN,-1) = NVL(:NEW.LONG_MIN,-1)
		AND NVL(LONG_SEC,-1) = NVL(:NEW.LONG_SEC,-1)
		AND NVL(LONG_DIR,'NULL') = NVL(:NEW.LONG_DIR,'NULL')
		AND NVL(DEC_LAT,-1) = NVL(:NEW.DEC_LAT,-1)
		AND NVL(DEC_LONG,-1) = NVL(:NEW.DEC_LONG,-1)
		AND NVL(UTM_ZONE,'NULL') = NVL(:NEW.UTM_ZONE,'NULL')
		AND NVL(UTM_EW,-1) = NVL(:NEW.UTM_EW,-1)
		AND NVL(UTM_NS,-1) = NVL(:NEW.UTM_NS,-1)
		AND NVL(DATUM,'NULL') = NVL(:NEW.DATUM,'NULL')
		AND NVL(ORIG_LAT_LONG_UNITS,'NULL') = NVL(:NEW.ORIG_LAT_LONG_UNITS,'NULL')
		AND NVL(DETERMINED_BY_AGENT_ID,-1) = NVL(:NEW.DETERMINED_BY_AGENT_ID,-1)
		AND NVL(DETERMINED_DATE,'1-JAN-1600') = NVL(TO_DATE(:NEW.DETERMINED_DATE),'1-JAN-1600')
		AND NVL(LAT_LONG_REMARKS,'NULL') = NVL(:NEW.LAT_LONG_REMARKS,'NULL')
		AND NVL(MAX_ERROR_DISTANCE,-1) = NVL(:NEW.MAX_ERROR_DISTANCE,-1)
		AND NVL(MAX_ERROR_UNITS,'NULL') = NVL(:NEW.MAX_ERROR_UNITS,'NULL')
		AND NVL(EXTENT,-1) = NVL(:NEW.EXTENT,-1)
		AND NVL(GPSACCURACY,-1) = NVL(:NEW.GPSACCURACY,-1)
		AND NVL(GEOREFMETHOD,'NULL') = NVL(:NEW.GEOREFMETHOD,'NULL')
		AND NVL(VERIFICATIONSTATUS,'NULL') = NVL(:NEW.VERIFICATIONSTATUS,'NULL')
		AND NVL(LAT_LONG_REF_SOURCE,'NULL') = NVL(:NEW.LAT_LONG_REF_SOURCE,'NULL');
		*/
 
 	dbms_output.put_line('nlocality_id: ' || nlocality_id) ;
 	
	IF nlocality_id = -1 THEN
		-- need a new locality
		-- use sq_locality_id
		-- select max(locality_id) + 1 into nlocality_id from locality;
		SELECT SQ_LOCALITY_ID.NEXTVAL INTO nlocality_id FROM DUAL; 

	    INSERT INTO LOCALITY (
		    LOCALITY_ID,
			GEOG_AUTH_REC_ID,
			MAXIMUM_ELEVATION,
			MINIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			SPEC_LOCALITY,
			LOCALITY_REMARKS,
			DEPTH_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			NOGEOREFBECAUSE)
		VALUES (
			nlocality_id,
			ngeog_auth_rec_id,
			:NEW.MAXIMUM_ELEVATION,
			:NEW.MINIMUM_ELEVATION,
			:NEW.ORIG_ELEV_UNITS,
			:NEW.SPEC_LOCALITY,
			:NEW.LOCALITY_REMARKS,
			:NEW.DEPTH_UNITS,
			:NEW.MIN_DEPTH,
			:NEW.MAX_DEPTH,
			:NEW.NOGEOREFBECAUSE);
		
		IF :NEW.ORIG_LAT_LONG_UNITS IS NOT NULL THEN
			-- use sq_lat_long_id
			--select max(lat_long_id) + 1 into nlat_long_id from lat_long;
			SELECT SQ_LAT_LONG_ID.NEXTVAL INTO nlat_long_id FROM DUAL;
		
			INSERT INTO LAT_LONG (
				LAT_LONG_ID,
				LOCALITY_ID,
				LAT_DEG,
				DEC_LAT_MIN,
				LAT_MIN,
				LAT_SEC,
				LAT_DIR,
				LONG_DEG,
				DEC_LONG_MIN,
				LONG_MIN,
				LONG_SEC,
				LONG_DIR,
				DEC_LAT,
				DEC_LONG,
				DATUM,
				UTM_ZONE,
				UTM_EW,
				UTM_NS,
				ORIG_LAT_LONG_UNITS,
				DETERMINED_BY_AGENT_ID,
				DETERMINED_DATE,
				LAT_LONG_REF_SOURCE,
				LAT_LONG_REMARKS,
				MAX_ERROR_DISTANCE,
				MAX_ERROR_UNITS,
				ACCEPTED_LAT_LONG_FG,
				EXTENT,
				GPSACCURACY,
				GEOREFMETHOD,
				VERIFICATIONSTATUS)
			VALUES (
				nlat_long_id,
				nlocality_id,
				:NEW.LAT_DEG,
				:NEW.DEC_LAT_MIN,
				:NEW.LAT_MIN,
				:NEW.LAT_SEC,
				:NEW.LAT_DIR,
				:NEW.LONG_DEG,
				:NEW.DEC_LONG_MIN,
				:NEW.LONG_MIN,
				:NEW.LONG_SEC,
				:NEW.LONG_DIR,
				:NEW.DEC_LAT,
				:NEW.DEC_LONG,
				:NEW.DATUM,
				:NEW.UTM_ZONE,
				:NEW.UTM_EW,
				:NEW.UTM_NS,
				:NEW.ORIG_LAT_LONG_UNITS,
				:NEW.DETERMINED_BY_AGENT_ID,
				:NEW.DETERMINED_DATE,
				:NEW.LAT_LONG_REF_SOURCE,
				:NEW.LAT_LONG_REMARKS,
				:NEW.MAX_ERROR_DISTANCE,
				:NEW.MAX_ERROR_UNITS,
				1,
				:NEW.EXTENT,
				:NEW.GPSACCURACY,
				:NEW.GEOREFMETHOD,
				:NEW.VERIFICATIONSTATUS);
		END IF;
	END IF;

	-- locality at this point was found or created - see about collecting events
	SELECT NVL(MIN(COLLECTING_EVENT_ID),-1) INTO ncollecting_event_id
	FROM COLLECTING_EVENT 
	WHERE
		LOCALITY_ID || '|' ||
		BEGAN_DATE || '|' ||
		ENDED_DATE || '|' ||
		VERBATIM_DATE || '|' ||
		VERBATIM_LOCALITY || '|' ||
		COLL_EVENT_REMARKS || '|' ||
		COLLECTING_SOURCE || '|' ||
		COLLECTING_METHOD || '|' ||
		HABITAT_DESC
		=
		nlocality_id || '|' ||
		:NEW.BEGAN_DATE || '|' ||
		:NEW.ENDED_DATE || '|' ||
		:NEW.VERBATIM_DATE || '|' ||
		:NEW.VERBATIM_LOCALITY || '|' ||
		:NEW.COLL_EVENT_REMARKS || '|' ||
		:NEW.COLLECTING_SOURCE || '|' ||
		:NEW.COLLECTING_METHOD || '|' ||
		:NEW.HABITAT_DESC;

	/*
	select nvl(min(collecting_event_id),-1) INTO ncollecting_event_id
	FROM collecting_event 
	WHERE locality_id = nlocality_id
		AND NVL(VERBATIM_DATE,'NULL') = NVL(:NEW.VERBATIM_DATE,'NULL')
		AND NVL(BEGAN_DATE,'1-JAN-1600') = NVL(to_date(:NEW.BEGAN_DATE),'1-JAN-1600')
		AND NVL(ENDED_DATE,'1-JAN-1600') = NVL(to_date(:NEW.ENDED_DATE),'1-JAN-1600')
		AND NVL(VERBATIM_LOCALITY,'NULL') = NVL(:NEW.VERBATIM_LOCALITY,'NULL')
		AND NVL(COLL_EVENT_REMARKS,'NULL') = NVL(:NEW.COLL_EVENT_REMARKS,'NULL')
		AND NVL(COLLECTING_SOURCE,'NULL') = NVL(:NEW.COLLECTING_SOURCE,'NULL')
		AND NVL(COLLECTING_METHOD,'NULL') = NVL(:NEW.COLLECTING_METHOD,'NULL')
		AND NVL(HABITAT_DESC,'NULL') = NVL(:NEW.HABITAT_DESC,'NULL');
	*/
		
	IF ncollecting_event_id = -1 THEN
		-- need a new collecting event
		-- use sq_collecting_event_id
		-- select max(COLLECTING_EVENT_ID) + 1 into ncollecting_event_id from collecting_event;
		SELECT SQ_COLLECTING_EVENT_ID INTO ncollecting_event_id FROM DUAL;

		INSERT INTO COLLECTING_EVENT (
			COLLECTING_EVENT_ID,
			LOCALITY_ID,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			COLL_EVENT_REMARKS,
			COLLECTING_SOURCE,
			COLLECTING_METHOD,
			HABITAT_DESC)
		VALUES (
			ncollecting_event_id,
			nlocality_id,
			:NEW.BEGAN_DATE,
			:NEW.ENDED_DATE,
			:NEW.VERBATIM_DATE,
			:NEW.VERBATIM_LOCALITY,
			:NEW.COLL_EVENT_REMARKS,
			:NEW.COLLECTING_SOURCE,
			:NEW.COLLECTING_METHOD,
			:NEW.HABITAT_DESC);
	END IF;

	-- we now have a locality ID and a collecting event ID. All that's left is to update cataloged_item.
	UPDATE CATALOGED_ITEM
	SET COLLECTING_EVENT_ID = ncollecting_event_id 
	WHERE COLLECTION_OBJECT_ID = :NEW.COLLECTION_OBJECT_ID;

	-- see if we can clean up some orphans
	SELECT COUNT(*) INTO num
	FROM CATALOGED_ITEM
	WHERE COLLECTING_EVENT_ID = oCollectingEventId;

	IF num = 0 THEN
		DELETE FROM COLLECTING_EVENT
		WHERE COLLECTING_EVENT_ID = oCollectingEventId;
	END IF;

	SELECT COUNT(*) INTO num
	FROM CATALOGED_ITEM, COLLECTING_EVENT, LOCALITY
	WHERE CATALOGED_ITEM.COLLECTING_EVENT_ID = COLLECTING_EVENT.COLLECTING_EVENT_ID
		AND COLLECTING_EVENT.LOCALITY_ID = LOCALITY.LOCALITY_ID
		AND LOCALITY.LOCALITY_ID = oLocalityId;

	IF num = 0 THEN
		DELETE FROM LAT_LONG WHERE LOCALITY_ID = oLocalityId;
		DELETE FROM LOCALITY WHERE LOCALITY_ID = oLocalityId;
	END IF;
END;
/
sho err;
*/