-- documentation



-- totally unrelated crap


CREATE TABLE ctlocation_in_host (
    collection_cde varchar2(10) not null,
    location_in_host VARCHAR2(255) NOT NULL,
    description VARCHAR2(255) NOT NULL
);


CREATE OR REPLACE PUBLIC SYNONYM ctlocation_in_host FOR ctlocation_in_host;
GRANT ALL ON ctlocation_in_host TO manage_codetables;
GRANT SELECT ON ctlocation_in_host TO PUBLIC;


-- ok, kinda related

CREATE OR REPLACE FUNCTION getPreferredAgentName(aid IN varchar)
RETURN varchar
AS
   n varchar(255);
BEGIN
    SELECT /*+ RESULT_CACHE */ agent_name INTO n FROM preferred_agent_name WHERE agent_id=aid;
    RETURN n;
end;
    /
    sho err;


CREATE PUBLIC SYNONYM getPreferredAgentName FOR getPreferredAgentName;
GRANT EXECUTE ON getPreferredAgentName TO PUBLIC;





-- create functions to convert coordinates to strings in hopefully-standardized ways
-- store verbatim coordinates as strings rather than structured data to improve flexibility,
-- reduce complexity

-- this is sort of stoopid now, but it's portable and can be
-- used in the bulkloader - eventually
-- it should be updated to deal with datum etc

CREATE OR REPLACE FUNCTION utm_to_string (
    UTM_NS IN VARCHAR2,
    UTM_EW IN VARCHAR2,
    UTM_ZONE IN VARCHAR2
    ) return varchar2 as 
        rval varchar2(4000);
   begin
       rval := UTM_NS || 'N ' || UTM_EW || 'E ZONE ' || nvl(UTM_ZONE,'not recorded');
       RETURN rval;
   END;
/

CREATE OR REPLACE PUBLIC SYNONYM utm_to_string FOR utm_to_string;
GRANT EXECUTE ON utm_to_string TO PUBLIC;

CREATE OR REPLACE FUNCTION dd_to_string (
    dd_lat IN VARCHAR2,
    dd_long IN VARCHAR2
 ) return varchar2 as
       rval varchar2(4000);
   begin
       rval := dd_lat || '/' || dd_long;
       RETURN rval;
   END;
/

CREATE OR REPLACE PUBLIC SYNONYM dd_to_string FOR dd_to_string;
GRANT EXECUTE ON dd_to_string TO PUBLIC;

CREATE OR REPLACE FUNCTION dm_to_string (
    d_lat IN VARCHAR2,
    m_lat IN VARCHAR2,
    dir_lat IN VARCHAR2,
    d_long IN VARCHAR2,
    m_long IN VARCHAR2,
    dir_long  IN VARCHAR2
    ) return varchar2 as
       rval varchar2(4000);
   begin
       rval := d_lat || 'd ' || m_lat || 'm ' || upper(dir_lat) || '/' || d_long || 'd ' || m_long || 'm ' || upper(dir_long);
       RETURN rval;
   END;
/

CREATE OR REPLACE PUBLIC SYNONYM dm_to_string FOR dm_to_string;
GRANT EXECUTE ON dm_to_string TO PUBLIC;

CREATE OR REPLACE FUNCTION dms_to_string (
    d_lat IN VARCHAR2,
    m_lat IN VARCHAR2,
    s_lat IN VARCHAR2,
    dir_lat IN VARCHAR2,
    d_long IN VARCHAR2,
    m_long IN VARCHAR2,
    s_long  IN VARCHAR2,
    dir_long  IN VARCHAR2
    ) return varchar2 as
       rval varchar2(4000);
   BEGIN
       rval := d_lat || 'd ' || m_lat || 'm ' || s_lat || 's ' ||upper(dir_lat) || '/' || d_long || 'd ' || m_long || 'm ' || s_long || 's ' ||upper(dir_long);
       RETURN rval;
   END;
/

CREATE OR REPLACE PUBLIC SYNONYM dms_to_string FOR dms_to_string;
GRANT EXECUTE ON dms_to_string TO PUBLIC;

-- a big giant temp table to smooth things along
-- keep everything - every locality_id and collecting_event_id will survive this migration. Do some heavy weeding after we're settled, perhaps.
-- perform all manipulations, new key creation, etc. here
-- then push it out before allowing anyone else in the DB
-- this includes all specimen-habitat, specimen-event-locality, event, and locality data. Unaccepted coordinates end up
-- as new rows, as they are in the new model

CREATE TABLE 
    everything_locality 
AS SELECT
    cataloged_item.COLLECTION_OBJECT_ID,
    coll_object_remark.HABITAT,
    collecting_event.COLLECTING_EVENT_ID,
    collecting_event.VERBATIM_DATE,
    collecting_event.VERBATIM_LOCALITY,
    collecting_event.COLL_EVENT_REMARKS,
    collecting_event.COLLECTING_SOURCE,
    collecting_event.COLLECTING_METHOD,
    collecting_event.HABITAT_DESC,
    collecting_event.BEGAN_DATE,
    collecting_event.ENDED_DATE,
    locality.LOCALITY_ID,
    locality.MAXIMUM_ELEVATION,
    locality.MINIMUM_ELEVATION,
    locality.ORIG_ELEV_UNITS,
    locality.SPEC_LOCALITY,
    locality.LOCALITY_REMARKS,
    locality.DEPTH_UNITS,
    locality.MIN_DEPTH,
    locality.MAX_DEPTH,
    locality.NOGEOREFBECAUSE,
    locality.GEOG_AUTH_REC_ID,
    lat_long.LAT_LONG_ID,
    lat_long.LAT_DEG,
    lat_long.DEC_LAT_MIN,
    lat_long.LAT_MIN,
    lat_long.LAT_SEC,
    lat_long.LAT_DIR,
    lat_long.LONG_DEG,
    lat_long.DEC_LONG_MIN,
    lat_long.LONG_MIN,
    lat_long.LONG_SEC,
    lat_long.LONG_DIR,
    lat_long.DEC_LAT,
    lat_long.DEC_LONG,
    lat_long.DATUM,
    lat_long.UTM_ZONE,
    lat_long.UTM_EW,
    lat_long.UTM_NS,
    lat_long.ORIG_LAT_LONG_UNITS,
    lat_long.DETERMINED_BY_AGENT_ID,
    lat_long.DETERMINED_DATE,
    lat_long.LAT_LONG_REF_SOURCE,
    lat_long.LAT_LONG_REMARKS,
    lat_long.MAX_ERROR_DISTANCE,
    lat_long.MAX_ERROR_UNITS,
    lat_long.ACCEPTED_LAT_LONG_FG,
    lat_long.EXTENT,
    lat_long.GPSACCURACY,
    lat_long.GEOREFMETHOD,
    lat_long.VERIFICATIONSTATUS
FROM
    locality,
    lat_long,
    collecting_event,
    cataloged_item,
    coll_object_remark
WHERE
   locality.locality_id=lat_long.locality_id (+) AND
   locality.locality_id=collecting_event.locality_id (+) AND
   collecting_event.collecting_event_id=cataloged_item.collecting_event_id (+) AND
   cataloged_item.collection_object_id=coll_object_remark.collection_object_id (+)
   ;
   
   
-- recycle locality_id for accepted coordinates and no coordinates records. These will be "where collected" specimen_event_types.
-- Media etc. uses only these IDs

ALTER TABLE everything_locality ADD new_locality_id NUMBER;

UPDATE everything_locality SET new_locality_id=locality_id WHERE LAT_LONG_ID IS NULL;
UPDATE everything_locality SET new_locality_id=locality_id WHERE ACCEPTED_LAT_LONG_FG=1;

CREATE INDEX temp_el_nlid ON everything_locality (new_locality_id) TABLESPACE uam_idx_1;
CREATE INDEX temp_el_lid ON everything_locality (locality_id) TABLESPACE uam_idx_1;




-- these are "unaccepted" in the old and new models. The IDs aren't used, so just grab next available values
BEGIN
    FOR r IN (SELECT locality_id FROM everything_locality WHERE new_locality_id IS NULL GROUP BY locality_id) LOOP
        UPDATE everything_locality SET new_locality_id=sq_locality_id.nextval WHERE locality_id=r.locality_id;
    END LOOP;
END;
/

-- same thing for collecting events
ALTER TABLE everything_locality ADD new_collecting_event_id NUMBER;


CREATE INDEX temp_el_ncid ON everything_locality (new_collecting_event_id) TABLESPACE uam_idx_1;
CREATE INDEX temp_el_cid ON everything_locality (collecting_event_id) TABLESPACE uam_idx_1;


UPDATE everything_locality SET new_collecting_event_id=collecting_event_id WHERE LAT_LONG_ID IS NULL;
UPDATE everything_locality SET new_collecting_event_id=collecting_event_id WHERE ACCEPTED_LAT_LONG_FG=1;


SELECT MAX(collecting_event_id) FROM collecting_event;

SELECT sq_collecting_event_id.nextval FROM dual;


BEGIN
    FOR r IN (SELECT collecting_event_id FROM everything_locality WHERE new_collecting_event_id IS NULL GROUP BY collecting_event_id) LOOP
        UPDATE everything_locality SET new_collecting_event_id=sq_collecting_event_id.nextval,mcid=1 WHERE collecting_event_id=r.collecting_event_id;
    END LOOP;
END;
/

-- combine habitat data
ALTER TABLE everything_locality ADD merged_habitat VARCHAR2(4000);

UPDATE everything_locality SET merged_habitat = HABITAT WHERE HABITAT IS NOT NULL AND HABITAT_DESC IS NULL;
UPDATE everything_locality SET merged_habitat = HABITAT_DESC WHERE HABITAT_DESC IS NOT NULL AND HABITAT IS NULL;
UPDATE everything_locality SET merged_habitat = HABITAT_DESC || '; ' || HABITAT WHERE HABITAT_DESC IS NOT NULL AND HABITAT IS NOT NULL;


ALTER TABLE everything_locality ADD verbatim_coordinates VARCHAR2(4000);

UPDATE everything_locality SET verbatim_coordinates = utm_to_string(UTM_NS,UTM_EW,UTM_ZONE) WHERE ORIG_LAT_LONG_UNITS='UTM';
UPDATE everything_locality SET verbatim_coordinates = dd_to_string(dec_lat,dec_long) WHERE ORIG_LAT_LONG_UNITS='decimal degrees';
UPDATE everything_locality SET verbatim_coordinates = dm_to_string(
        LAT_DEG,
        DEC_LAT_MIN,
        LAT_DIR,
        LONG_DEG,
        DEC_LONG_MIN,
        LONG_DIR
    ) WHERE
   ORIG_LAT_LONG_UNITS='degrees dec. minutes';
   
   
UPDATE everything_locality SET verbatim_coordinates = dms_to_string(
        LAT_DEG,
        LAT_MIN,
        LAT_SEC,
        LAT_DIR,
        LONG_DEG,
        LONG_MIN,
        LONG_SEC,
        LONG_DIR
    ) WHERE  ORIG_LAT_LONG_UNITS='deg. min. sec.';

-- link between specimens and events
ALTER TABLE everything_locality ADD specimen_event_type VARCHAR2(4000);

-- no control over these things
-- a specimen can have no accepted event, or lots of accepted events, or anything else.

-- no coordinates = accepted
UPDATE everything_locality SET specimen_event_type='accepted place of collection' WHERE LAT_LONG_ID IS NULL;
-- accepted coordinates = accepted
UPDATE everything_locality SET specimen_event_type='accepted place of collection' WHERE ACCEPTED_LAT_LONG_FG=1;
-- unaccepted coordinates = unaccepted
UPDATE everything_locality SET specimen_event_type='unaccepted place of collection' WHERE ACCEPTED_LAT_LONG_FG=0;

-- reclaim UAM Insects collecting method data from attributes

CREATE INDEX temp_el_coid ON everything_locality (COLLECTION_OBJECT_ID) TABLESPACE uam_idx_1;



BEGIN
    FOR r IN (SELECT COLLECTION_OBJECT_ID, ATTRIBUTE_VALUE FROM attributes WHERE ATTRIBUTE_TYPE='collecting method') LOOP
      UPDATE  everything_locality SET COLLECTING_METHOD=r.ATTRIBUTE_VALUE WHERE COLLECTION_OBJECT_ID=r.COLLECTION_OBJECT_ID;
    END LOOP;
END;
/
             


-- new TABLE definitions, rename old for backup
                                   
CREATE TABLE ctspecimen_event_type (
    specimen_event_type VARCHAR2(60) NOT NULL,
    description VARCHAR2(255) NOT NULL
);

-- can have any number of these, but these two (which can get better names any time now) deal with legacy data

INSERT INTO ctspecimen_event_type (specimen_event_type,description) VALUES (
    'accepted place of collection',
    'Place where a specimen was removed from the wild. Also legacy migration target for accepted coordinate determination.'
);
INSERT INTO ctspecimen_event_type (specimen_event_type,description) VALUES (
    'unaccepted place of collection',
    'Place where a specimen was removed from the wild, deemed incorrect by curatorial staff. Also legacy migration target for unaccepted coordinate determination.'
);

CREATE OR REPLACE PUBLIC SYNONYM ctspecimen_event_type FOR ctspecimen_event_type;
GRANT ALL ON ctspecimen_event_type TO manage_codetables;
GRANT SELECT ON ctspecimen_event_type TO PUBLIC;

ALTER TABLE ctspecimen_event_type ADD CONSTRAINT pk_ctspecimen_event_type PRIMARY KEY (specimen_event_type) USING INDEX TABLESPACE UAM_IDX_1;

CREATE SEQUENCE sq_specimen_event_id;
CREATE OR REPLACE PUBLIC SYNONYM sq_specimen_event_id FOR sq_specimen_event_id;
GRANT SELECT ON sq_specimen_event_id TO PUBLIC;

CREATE TABLE SPECIMEN_EVENT (
    SPECIMEN_EVENT_ID NUMBER NOT NULL,
    collection_object_id NUMBER NOT NULL,
    collecting_event_id NUMBER NOT NULL,
    assigned_by_agent_id NUMBER NOT NULL,
    assigned_date DATE NOT NULL,
    specimen_event_remark VARCHAR2(4000),
    specimen_event_type VARCHAR2(60) NOT NULL,
    COLLECTING_METHOD VARCHAR2(255),
    COLLECTING_SOURCE VARCHAR2(60),
    VERIFICATIONSTATUS VARCHAR2(60) NOT NULL,
    habitat  VARCHAR2(4000)
);

CREATE OR REPLACE PUBLIC SYNONYM SPECIMEN_EVENT FOR SPECIMEN_EVENT;
GRANT ALL ON SPECIMEN_EVENT TO manage_specimens;
GRANT SELECT ON SPECIMEN_EVENT TO PUBLIC;

CREATE OR REPLACE TRIGGER trg_SPECIMEN_EVENT_biu
    BEFORE INSERT OR UPDATE ON SPECIMEN_EVENT
    FOR EACH ROW
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
    end;
/

ALTER TABLE SPECIMEN_EVENT ADD CONSTRAINT pk_SPECIMEN_EVENT PRIMARY KEY (SPECIMEN_EVENT_id) USING INDEX TABLESPACE UAM_IDX_1;
ALTER TABLE SPECIMEN_EVENT add CONSTRAINT fk_SPECIMEN_EVENT_catitem FOREIGN KEY (collection_object_id) REFERENCES cataloged_item (collection_object_id);		    
ALTER TABLE SPECIMEN_EVENT add CONSTRAINT fk_SPECIMEN_EVENT_collevent FOREIGN KEY (collecting_event_id) REFERENCES collecting_event (collecting_event_id);		    
ALTER TABLE SPECIMEN_EVENT add CONSTRAINT fk_SPECIMEN_EVENT_agent FOREIGN KEY (assigned_by_agent_id) REFERENCES agent (agent_id);	    
ALTER TABLE SPECIMEN_EVENT add CONSTRAINT fk_SPECIMEN_EVENT_ctsetype FOREIGN KEY (specimen_event_type) REFERENCES ctspecimen_event_type (specimen_event_type);
ALTER TABLE SPECIMEN_EVENT add CONSTRAINT fk_SPECIMEN_EVENT_ctvstatus FOREIGN KEY (VERIFICATIONSTATUS) REFERENCES ctVERIFICATIONSTATUS (VERIFICATIONSTATUS);
ALTER TABLE SPECIMEN_EVENT add CONSTRAINT fk_SPECIMEN_EVENT_ctcsource FOREIGN KEY (COLLECTING_SOURCE) REFERENCES ctCOLLECTING_SOURCE (COLLECTING_SOURCE);


-- bye bye, existing table collecting_event....	

         
ALTER TABLE cataloged_item DROP CONSTRAINT FK_CATITEM_COLLEVENT;
ALTER TABLE TAG DROP CONSTRAINT FK_TAG_COLLEVENT;
ALTER TABLE TAB_MEDIA_REL_FKEY DROP CONSTRAINT FK_TABMEDIARELFKEY_COLLEVENT;
ALTER TABLE SPECIMEN_EVENT DROP CONSTRAINT FK_SPECIMEN_EVENT_COLLEVENT;

ALTER TABLE collecting_event DROP CONSTRAINT pk_collecting_event;
ALTER TABLE COLLECTING_EVENT DROP CONSTRAINT FK_COLLEVENT_LOCALITY;


ALTER TABLE collecting_event RENAME TO collecting_event_old;

-- keep coordinates broken out in new collecting_event for now - would like to get rid of these, but
-- need the datum conversion thing working first. Craps....
-- Throw calculated un-datum-converted dec lat/long in here too - this will
-- get submerged into the datum conversion process, wherever that ends up,
-- should such a thing ever actually exist

CREATE TABLE collecting_event (
    COLLECTING_EVENT_ID NUMBER NOT NULL,
    LOCALITY_ID NUMBER NOT NULL,
    VERBATIM_DATE VARCHAR2(60),
    VERBATIM_LOCALITY VARCHAR2(4000),
    COLL_EVENT_REMARKS VARCHAR2(4000),
    BEGAN_DATE VARCHAR2(22),
    ENDED_DATE VARCHAR2(22),                            
    verbatim_coordinates VARCHAR2(255),
    collecting_event_name VARCHAR2(255),
    LAT_DEG NUMBER,
    DEC_LAT_MIN NUMBER(8,6),
    LAT_MIN NUMBER,
    LAT_SEC NUMBER(8,6),
    LAT_DIR CHAR(1),
    LONG_DEG NUMBER,
    DEC_LONG_MIN NUMBER(10,8),
    LONG_MIN NUMBER,
    LONG_SEC NUMBER(8,6),
    LONG_DIR CHAR(1),
    DEC_LAT NUMBER(12,10),
    DEC_LONG  NUMBER(13,10),
    DATUM VARCHAR2(55),
    UTM_ZONE VARCHAR2(3),
    UTM_EW NUMBER,
    UTM_NS NUMBER,
    ORIG_LAT_LONG_UNITS VARCHAR2(20),
    caclulated_dlat NUMBER(12,10),
    calculated_dlong  NUMBER(13,10)
);
                          


           
CREATE OR REPLACE PUBLIC SYNONYM collecting_event FOR collecting_event;
GRANT ALL ON collecting_event TO manage_locality;
GRANT SELECT ON collecting_event TO PUBLIC;     



ALTER TABLE GEOLOGY_ATTRIBUTES DROP CONSTRAINT FK_GEOLATTRIBUTES_LOCALITY;
ALTER TABLE LAT_LONG DROP CONSTRAINT FK_LATLONG_LOCALITY;
ALTER TABLE TAB_MEDIA_REL_FKEY DROP CONSTRAINT FK_TABMEDIARELFKEY_LOCALITY;
ALTER TABLE TAG DROP CONSTRAINT FK_TAG_LOCALITY;

	    
ALTER TABLE locality DROP CONSTRAINT pk_locality;


ALTER TABLE locality RENAME TO locality_old;

CREATE TABLE locality (
    locality_id NUMBER NOT NULL,
    GEOG_AUTH_REC_ID NUMBER NOT NULL,
    SPEC_LOCALITY VARCHAR2(255),
    DEC_LAT NUMBER (12,10),
    DEC_LONG NUMBER(13,10),
    MINIMUM_ELEVATION NUMBER,
    MAXIMUM_ELEVATION NUMBER,
    ORIG_ELEV_UNITS VARCHAR2(30),
    MIN_DEPTH NUMBER,
    MAX_DEPTH NUMBER,
    DEPTH_UNITS VARCHAR2(30),
    MAX_ERROR_DISTANCE NUMBER,
    MAX_ERROR_UNITS VARCHAR2(30),
    DATUM VARCHAR2(255),
    LOCALITY_REMARKS VARCHAR2(4000),
    georeference_source VARCHAR2(4000),
    georeference_protocol VARCHAR2(255),
    locality_name VARCHAR2(255)
);

		     

CREATE OR REPLACE PUBLIC SYNONYM locality FOR locality;
GRANT ALL ON locality TO manage_locality;
GRANT SELECT ON locality TO PUBLIC;     
        
-- FOR THE purposes OF getting THE major changes Implemented, skip datum transformation FOR now. This IS evil AND should become a priority,
-- it's just less evil than not loading coordinates


---------- NEW TABLE locality - NOT THE OLD ONE!!!

 INSERT INTO locality (
    locality_id,
    GEOG_AUTH_REC_ID,
    SPEC_LOCALITY,
    DEC_LAT,
    DEC_LONG,
    MINIMUM_ELEVATION,
    MAXIMUM_ELEVATION,
    ORIG_ELEV_UNITS,
    MIN_DEPTH,
    MAX_DEPTH,
    DEPTH_UNITS,
    MAX_ERROR_DISTANCE,
    MAX_ERROR_UNITS,
    DATUM,
    LOCALITY_REMARKS,
    georeference_source,
    georeference_protocol
) (
    SELECT
        new_locality_id,
        GEOG_AUTH_REC_ID,
        SPEC_LOCALITY,
        DEC_LAT,
        DEC_LONG,
        MINIMUM_ELEVATION,
        MAXIMUM_ELEVATION,
        ORIG_ELEV_UNITS,
        MIN_DEPTH,
        MAX_DEPTH,
        DEPTH_UNITS,
        MAX_ERROR_DISTANCE,
        MAX_ERROR_UNITS,
        DATUM,
        LOCALITY_REMARKS,
        LAT_LONG_REF_SOURCE,
        GEOREFMETHOD
    FROM
        everything_locality
    GROUP BY
        new_locality_id,
        GEOG_AUTH_REC_ID,
        SPEC_LOCALITY,
        DEC_LAT,
        DEC_LONG,
        MINIMUM_ELEVATION,
        MAXIMUM_ELEVATION,
        ORIG_ELEV_UNITS,
        MIN_DEPTH,
        MAX_DEPTH,
        DEPTH_UNITS,
        MAX_ERROR_DISTANCE,
        MAX_ERROR_UNITS,
        DATUM,
        LOCALITY_REMARKS,
        LAT_LONG_REF_SOURCE,
        GEOREFMETHOD
);
    
---------- NEW TABLE collecting_event - NOT THE OLD ONE!!!

INSERT INTO collecting_event (
    COLLECTING_EVENT_ID,
    LOCALITY_ID,
    VERBATIM_DATE,
    VERBATIM_LOCALITY,
    COLL_EVENT_REMARKS,
    BEGAN_DATE,
    ENDED_DATE,
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
    dec_lat,
    DEC_LONG,
    DATUM,
    UTM_ZONE,
    UTM_EW,
    UTM_NS,
    ORIG_LAT_LONG_UNITS
   ) ( SELECT
    new_COLLECTING_EVENT_ID,
    new_LOCALITY_ID,
    VERBATIM_DATE,
    VERBATIM_LOCALITY,
    COLL_EVENT_REMARKS,
    BEGAN_DATE,
    ENDED_DATE,
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
    ORIG_LAT_LONG_UNITS
    FROM
        everything_locality
    WHERE
        new_COLLECTING_EVENT_ID IS NOT NULL AND mcid=1
    GROUP BY
    new_COLLECTING_EVENT_ID,
    new_LOCALITY_ID,
    VERBATIM_DATE,
    VERBATIM_LOCALITY,
    COLL_EVENT_REMARKS,
    BEGAN_DATE,
    ENDED_DATE,
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
    ORIG_LAT_LONG_UNITS
);


-------- specimen_events
INSERT INTO  SPECIMEN_EVENT (
    collection_object_id,
    collecting_event_id,
    assigned_by_agent_id,
    assigned_date,
    specimen_event_type,
    COLLECTING_METHOD,
    COLLECTING_SOURCE,
    VERIFICATIONSTATUS,
    habitat
) ( SELECT
    collection_object_id,
    new_collecting_event_id,
    nvl(DETERMINED_BY_AGENT_ID,0),
    nvl(DETERMINED_DATE,SYSDATE),
    specimen_event_type,
    COLLECTING_METHOD,
    COLLECTING_SOURCE,
    VERIFICATIONSTATUS,
    merged_habitat
    FROM
    everything_locality
    WHERE
    collection_object_id IS NOT NULL
    GROUP BY  
    collection_object_id,
    new_collecting_event_id,
    DETERMINED_BY_AGENT_ID,
    DETERMINED_DATE,
    specimen_event_type,
    COLLECTING_METHOD,
    COLLECTING_SOURCE,
    VERIFICATIONSTATUS,
    merged_habitat
);


CREATE TABLE ctgeoreference_protocol AS SELECT * FROM CTGEOREFMETHOD;
ALTER TABLE ctgeoreference_protocol RENAME COLUMN GEOREFMETHOD TO georeference_protocol;

CREATE OR REPLACE PUBLIC SYNONYM ctgeoreference_protocol FOR ctgeoreference_protocol;
    
GRANT ALL ON ctgeoreference_protocol TO manage_codetables;
GRANT SELECT ON ctgeoreference_protocol TO PUBLIC;

ALTER TABLE ctgeoreference_protocol ADD CONSTRAINT pk_ctgeoreference_protocol PRIMARY KEY (georeference_protocol) USING INDEX TABLESPACE UAM_IDX_1;

-- build/REBUILD ALL THE keys



drop index pk_locality;
alter table locality_old drop constraint fk_locality_geogauthrec;

    
ALTER TABLE locality ADD CONSTRAINT pk_locality PRIMARY KEY (locality_id) USING INDEX TABLESPACE UAM_IDX_1;
ALTER TABLE locality add CONSTRAINT fk_locality_geogauthrec FOREIGN KEY (GEOG_AUTH_REC_ID) REFERENCES GEOG_AUTH_REC (GEOG_AUTH_REC_ID);
ALTER TABLE locality add CONSTRAINT fk_locality_ctelevunit FOREIGN KEY (ORIG_ELEV_UNITS) REFERENCES ctORIG_ELEV_UNITS (ORIG_ELEV_UNITS);	
ALTER TABLE locality add CONSTRAINT fk_locality_ctdepthunit FOREIGN KEY (DEPTH_UNITS) REFERENCES ctDEPTH_UNITS (DEPTH_UNITS);		   
ALTER TABLE locality add CONSTRAINT fk_locality_ctmerrunit FOREIGN KEY (MAX_ERROR_UNITS) REFERENCES CTLAT_LONG_ERROR_UNITS (LAT_LONG_ERROR_UNITS);	  
ALTER TABLE locality add CONSTRAINT fk_locality_ctdatum FOREIGN KEY (DATUM) REFERENCES ctDATUM (DATUM);		       
ALTER TABLE locality add CONSTRAINT fk_locality_ctgprotocl FOREIGN KEY (georeference_protocol) REFERENCES ctgeoreference_protocol (georeference_protocol);
    
-- save for later - do not implement now - check performance
-- CREATE INDEX "UAM"."IX_LOCALITY_GEOGAUTHRECID" ON "UAM"."LOCALITY" ("GEOG_AUTH_REC_ID") TABLESPACE "UAM_IDX_1" PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE ( INITIAL 4096K BUFFER_POOL DEFAULT) LOGGING LOCAL 
-- CREATE INDEX "UAM"."IX_LOCALITY_LOCID_GEOGAUTHREC" ON "UAM"."LOCALITY" ("LOCALITY_ID", "GEOG_AUTH_REC_ID") TABLESPACE "UAM_IDX_1" PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE ( INITIAL 5120K BUFFER_POOL DEFAULT) LOGGING LOCAL 
-- CREATE UNIQUE INDEX "UAM"."PK_LOCALITY" ON "UAM"."LOCALITY" ("LOCALITY_ID") TABLESPACE "UAM_IDX_1" PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE ( INITIAL 4096K BUFFER_POOL DEFAULT) LOGGING LOCAL 

-- replaced with key constraints
DROP TRIGGER LOCALITY_CT_CHECK;

    
DROP TRIGGER TR_LOCALITY_AU_FLAT;




-- the few missed geology attributes are duplicates pointing to both accepted (all OK) and unaccepted ("orphaned" now) 
-- coordinate determinations on the same locality
-- just delete them

SELECT * FROM GEOLOGY_ATTRIBUTES WHERE LOCALITY_ID NOT IN (SELECT LOCALITY_ID FROM locality);



DELETE FROM GEOLOGY_ATTRIBUTES WHERE LOCALITY_ID NOT IN (SELECT LOCALITY_ID FROM locality);

ALTER TABLE GEOLOGY_ATTRIBUTES add CONSTRAINT FK_GEOLATTRIBUTES_LOCALITY FOREIGN KEY (LOCALITY_ID) REFERENCES LOCALITY (LOCALITY_ID);

-- the few missed media relations are duplicates pointing to both accepted (all OK) and unaccepted ("orphaned" now) 
-- coordinate determinations on the same locality
-- just delete them
 
 SELECT * FROM TAB_MEDIA_REL_FKEY WHERE CFK_LOCALITY IS NOT NULL AND CFK_LOCALITY NOT IN (SELECT LOCALITY_ID FROM locality);
 
 
DELETE FROM TAB_MEDIA_REL_FKEY WHERE CFK_LOCALITY IS NOT NULL AND CFK_LOCALITY NOT IN (SELECT LOCALITY_ID FROM locality);
    
    
ALTER TABLE TAB_MEDIA_REL_FKEY add CONSTRAINT FK_TABMEDIARELFKEY_LOCALITY FOREIGN KEY (CFK_LOCALITY) REFERENCES LOCALITY (LOCALITY_ID);
    
    
ALTER TABLE TAG add CONSTRAINT FK_TAG_LOCALITY FOREIGN KEY (LOCALITY_ID) REFERENCES LOCALITY (LOCALITY_ID);








CREATE OR REPLACE PUBLIC SYNONYM collecting_event FOR collecting_event;
GRANT ALL ON collecting_event TO manage_locality;
GRANT SELECT ON collecting_event TO PUBLIC;


CREATE OR REPLACE TRIGGER trg_locality_biu
    BEFORE INSERT OR UPDATE ON locality
    FOR EACH ROW declare 
        status varchar2(255);
    BEGIN
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
        END IF;
        IF :NEW.DEPTH_UNITS IS NOT NULL OR :NEW.MAX_DEPTH IS NOT NULL OR :NEW.MIN_DEPTH IS NOT NULL THEN
            IF :NEW.DEPTH_UNITS IS NULL OR :NEW.MAX_DEPTH IS NULL OR :NEW.MIN_DEPTH IS NULL THEN
                raise_application_error(-20001,'Depth must include all or none of units, minimum, and maximum.'); 
            END IF;
        END IF;
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
    end;
/



CREATE OR REPLACE TRIGGER trg_collecting_event_biu
    BEFORE INSERT OR UPDATE ON collecting_event
    FOR EACH ROW declare 
        status varchar2(255);
    BEGIN
        status:=is_iso8601(:NEW.began_date);
        IF status != 'valid' THEN
            raise_application_error(-20001,'Began Date: ' || status);
        END IF;
        status:=is_iso8601(:NEW.ended_date);
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
       END IF;   
    end;
/



-- replaced with keys
DROP TRIGGER COLLECTING_EVENT_CT_CHECK;

-- merged with trg_collecting_event_biu
DROP TRIGGER TRG_COLLECTINGEVENTDATE;



DROP TRIGGER TR_COLLEVENT_AU_FLAT;


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

CREATE OR REPLACE TRIGGER trg_SPECIMEN_EVENT_au_flat
    AFTER INSERT OR UPDATE OR DELETE ON SPECIMEN_EVENT
    FOR EACH ROW DECLARE
        coid NUMBER;
    BEGIN
        IF deleting THEN
               coid:=:old.collection_object_id;
        ELSE
            coid:=:new.collection_object_id;
        END IF;
        UPDATE flat
            SET stale_flag = 1,
            lastuser=sys_context('USERENV', 'SESSION_USER'),
            lastdate=SYSDATE
            WHERE collection_object_id = coid;
    end;
/



CREATE OR REPLACE TRIGGER TR_LOCALITY_AU_FLAT AFTER
UPDATE ON LOCALITY FOR EACH ROW BEGIN
UPDATE flat
SET stale_flag = 1,
lastuser=sys_context('USERENV', 'SESSION_USER'),
lastdate=SYSDATE
WHERE locality_id = :NEW.locality_id;
END;
/





-- save these until later/eliminate them - check performance without them
-- CREATE INDEX "UAM"."IX_COLLEVENT_LOCID" ON "UAM"."COLLECTING_EVENT_OLD" ("LOCALITY_ID") TABLESPACE "UAM_IDX_1" PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE ( INITIAL 6144K BUFFER_POOL DEFAULT) LOGGING LOCAL 
-- CREATE INDEX "UAM"."IX_COLLEVENT_LOCID_CEID" ON "UAM"."COLLECTING_EVENT_OLD" ("LOCALITY_ID", "COLLECTING_EVENT_ID") TABLESPACE "UAM_IDX_1" PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE ( INITIAL 7168K BUFFER_POOL DEFAULT) LOGGING LOCAL 
-- CREATE INDEX "UAM"."UPR_CE_VERB_LOC" ON "UAM"."COLLECTING_EVENT_OLD" (UPPER("VERBATIM_LOCALITY")) TABLESPACE "UAM_IDX_1" PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE ( INITIAL 64K BUFFER_POOL DEFAULT) LOGGING LOCAL 


drop index pk_collecting_event;

ALTER TABLE collecting_event ADD CONSTRAINT pk_collecting_event PRIMARY KEY (collecting_event_id) USING INDEX TABLESPACE UAM_IDX_1;



ALTER TABLE collecting_event add CONSTRAINT fk_collecting_event_locality FOREIGN KEY (LOCALITY_ID) REFERENCES LOCALITY (LOCALITY_ID);	
    
ALTER TABLE collecting_event add CONSTRAINT fk_collecting_event_datum FOREIGN KEY (DATUM) REFERENCES CTDATUM (DATUM);	
ALTER TABLE collecting_event add CONSTRAINT fk_collecting_event_llunit FOREIGN KEY (ORIG_LAT_LONG_UNITS) REFERENCES CTLAT_LONG_UNITS (ORIG_LAT_LONG_UNITS);	
    
ALTER TABLE TAG add CONSTRAINT FK_TAG_COLLEVENT FOREIGN KEY (collecting_event_ID) REFERENCES collecting_event (collecting_event_ID);
   
DECLARE 
    ncid NUMBER;
BEGIN
    FOR r IN (
        SELECT 
            CFK_COLLECTING_EVENT  from TAB_MEDIA_REL_FKEY WHERE CFK_COLLECTING_EVENT IS NOT NULL AND CFK_COLLECTING_EVENT NOT IN (
                SELECT collecting_event_ID FROM collecting_event)
     ) LOOP
         dbms_output.put_line('old CID: ' || r.CFK_COLLECTING_EVENT);
         SELECT MIN(new_collecting_event_id) INTO ncid FROM everything_locality WHERE collecting_event_id=r.CFK_COLLECTING_EVENT;
         dbms_output.put_line('bew CID: ' || ncid);
         UPDATE TAB_MEDIA_REL_FKEY SET CFK_COLLECTING_EVENT=ncid WHERE CFK_COLLECTING_EVENT=r.CFK_COLLECTING_EVENT;
    END LOOP;
    END;
    /
    

  
		    
ALTER TABLE TAB_MEDIA_REL_FKEY add CONSTRAINT FK_TABMEDIARELFKEY_COLLEVENT FOREIGN KEY (CFK_COLLECTING_EVENT) REFERENCES collecting_event (collecting_event_ID);		    
    

 select *
from dba_constraints
where r_constraint_name in ( select constraint_name
                             from   dba_constraints
                             where  table_name = 'LOCALITY'
                           );
 	
----------------------------------------------------- flat --------------------------------------------------

--"accepted mapping" view
-- zero-or-one record for every specimen

CREATE OR REPLACE VIEW 
    map_specimen_event 
AS SELECT 
     min(specimen_event_id) specimen_event_id,
     COLLECTION_OBJECT_ID FROM 
     specimen_event 
WHERE
    specimen_event_type != 'unaccepted place of collection'
GROUP BY
    COLLECTION_OBJECT_ID
;





CREATE OR REPLACE PUBLIC SYNONYM map_specimen_event FOR map_specimen_event;
GRANT SELECT ON map_specimen_event TO PUBLIC;


ALTER TABLE flat ADD event_assigned_by_agent VARCHAR2(255);
ALTER TABLE flat ADD event_assigned_date DATE;
ALTER TABLE flat ADD specimen_event_remark VARCHAR2(4000);
ALTER TABLE flat ADD specimen_event_type VARCHAR2(60);

ALTER TABLE flat ADD COLL_EVENT_REMARKS VARCHAR2(4000);
ALTER TABLE flat ADD verbatim_coordinates VARCHAR2(255);
ALTER TABLE flat ADD collecting_event_name VARCHAR2(255);
ALTER TABLE flat ADD georeference_source VARCHAR2(4000);
ALTER TABLE flat ADD georeference_protocol VARCHAR2(255);
ALTER TABLE flat ADD locality_name VARCHAR2(255);

























ALTER TABLE flat DROP COLUMN VERBATIMLATITUDE;
ALTER TABLE flat DROP COLUMN VERBATIMLONGITUDE;
ALTER TABLE flat DROP COLUMN LAT_LONG_REF_SOURCE;
ALTER TABLE flat DROP COLUMN GEOREFMETHOD;
ALTER TABLE flat DROP COLUMN LAT_LONG_REMARKS;
ALTER TABLE flat DROP COLUMN LAT_LONG_DETERMINER;
ALTER TABLE flat DROP COLUMN HABITAT_DESC;
























CREATE OR REPLACE TRIGGER TR_CATITEM_AI_FLAT
AFTER INSERT ON cataloged_item
FOR EACH ROW
BEGIN
	INSERT INTO flat (
		collection_object_id,
		cat_num,
		accn_id,
		collection_cde,
		collection_id,
		catalognumbertext,
		stale_flag)
	VALUES (
		:NEW.collection_object_id,
		:NEW.cat_num,
		:NEW.accn_id,
		:NEW.collection_cde,
		:NEW.collection_id,
		to_char(:NEW.cat_num),
		1);
END;
/

DROP TRIGGER TR_LATLONG_AIUD_FLAT;







CREATE OR REPLACE FUNCTION is_iso8601 (v  in varchar)
return varchar
as
	y char(4);
	mo char(2);
	d  char(2);
	h  char(2);
	mi  char(2);
	s  char(2);
	t varchar2(3);
	r varchar2(255):='valid';
	t2 varchar2(30);
begin
IF v IS NULL THEN
    RETURN r;
END IF;
IF regexp_like(v,'^[0-9]{4}$') then
	-- dbms_output.put_line('yearonly');
	y:=v;
elsif regexp_like(v,'^[0-9]{4}-[0-9]{2}$') then
	y:=substr(v,1,4);
	mo:=substr(v,6,2);
	-- dbms_output.put_line('yyyy-mm');
elsif regexp_like(v,'^[0-9]{4}-[0-9]{2}-[0-9]{2}$') then
	y:=substr(v,1,4);
	mo:=substr(v,6,2);
	d:=substr(v,9,2);
	-- dbms_output.put_line('yyyy-mm-dd');
elsif regexp_like(v,'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}$') then
	-- dbms_output.put_line('yyyy-mm-ddT12');
	y:=substr(v,1,4);
	mo:=substr(v,6,2);
	d:=substr(v,9,2);
	h:=substr(v,12,2);
elsif regexp_like(v,'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}$') then
	-- dbms_output.put_line('yyyy-mm-ddT12:54');
	y:=substr(v,1,4);
	mo:=substr(v,6,2);
	d:=substr(v,9,2);
	h:=substr(v,12,2);
	mi:=substr(v,15,2);
elsif regexp_like(v,'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}$') then
	-- dbms_output.put_line('yyyy-mm-ddT12:54:43');
	y:=substr(v,1,4);
	mo:=substr(v,6,2);
	d:=substr(v,9,2);
	h:=substr(v,12,2);
	mi:=substr(v,15,2);
	s:=substr(v,18,2);
elsif regexp_like(v,'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}[+-][0-9]{2}$') then
	-- dbms_output.put_line('yyyy-mm-ddT12:54:43+03 OR yyyy-mm-ddT12:54:43-06');
	y:=substr(v,1,4);
	mo:=substr(v,6,2);
	d:=substr(v,9,2);
	h:=substr(v,12,2);
	mi:=substr(v,15,2);
	s:=substr(v,18,2);
	t:=substr(v,20);
elsif regexp_like(v,'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$') then
	-- dbms_output.put_line('yyyy-mm-ddT12:54:43Z');
	y:=substr(v,1,4);
	mo:=substr(v,6,2);
	d:=substr(v,9,2);
	h:=substr(v,12,2);
	mi:=substr(v,15,2);
	s:=substr(v,18,2);
	t:=substr(v,20);
else
	-- dbms_output.put_line('somethingelse');
	r:='the input string "' || v || '" is not in a recognizable format.';
end if;

	-- dbms_output.put_line('input: ' || v);
	-- dbms_output.put_line('y: ' || y);
	-- dbms_output.put_line('mo: ' || mo);
	-- dbms_output.put_line('d: ' || d);
	-- dbms_output.put_line('h: ' || h);
	-- dbms_output.put_line('mi: ' || mi);
	-- dbms_output.put_line('s: ' || s);
	-- dbms_output.put_line('t: ' || t);
	-- dbms_output.put_line('checks follow. If none, then pass ');

	if mo is not null and (mo <1 or mo>12) then
			r:='month component "' || mo || '" is invalid';
			-- dbms_output.put_line('failmo: ' || mo);
	end if;
	if d is not null then
		if (d <1 or d>31) then
			-- dbms_output.put_line('failD');
			r:='d component "' || d || '" is invalid';
		end if;
		begin
			t2:=d ||'-'||mo||'-'||y;
			t2:=to_date(t2,'DD-MM-YYYY');
		exception when others then
			-- dbms_output.put_line('notadate: ' || t2);
			-- dbms_output.put_line(SQLERRM);
			r:=y||'-'||mo||'-'||d||' is not a valid date';
		end;
	end if;
	if h is not null and (h <0 or h>24) then
			r:='hour component "' || h || '" is invalid';
			-- dbms_output.put_line('failH');
	end if;
	if mi is not null and (mi <0 or mi>60) then
			r:='minute component "' || mi || '" is invalid';
			-- dbms_output.put_line('failmi');
	end if;
	if s is not null and (s <0 or s>60) then
			r:='second component "' || s || '" is invalid';
			-- dbms_output.put_line('failS');
	end if;
	if t is not null and t!='Z' and (t<-24 or t>24) then
		r:='timezone component "' || t || '" is invalid';
	end if;
	-- dbms_output.put_line('end checks');
	IF length(r)>200 THEN
	    dbms_output.put_line('r is long');
	    --r:=substr(r,1,250) || '...';
	END IF;
	return r;
	--exception	when others then return 0;
end;
/

sho err;


CREATE OR REPLACE PUBLIC SYNONYM is_iso8601 FOR is_iso8601;
GRANT EXECUTE ON is_iso8601 TO PUBLIC;


 ------------------- bulkloader -----------------
 ALTER TABLE bulkloader RENAME COLUMN LAT_LONG_REF_SOURCE TO georeference_source;
 ALTER TABLE bulkloader RENAME COLUMN GEOREFMETHOD TO georeference_protocol;
 ALTER TABLE bulkloader RENAME COLUMN DETERMINED_BY_AGENT TO event_assigned_by_agent;
 
 UPDATE BULKLOADER SET event_assigned_by_agent='unknown' WHERE event_assigned_by_agent IS NULL;
 
 ALTER TABLE bulkloader RENAME COLUMN DETERMINED_DATE TO event_assigned_date;
 
 UPDATE BULKLOADER SET event_assigned_date=SYSDATE WHERE event_assigned_date IS NULL;
 
 ALTER TABLE bulkloader MODIFY locality_remarks VARCHAR2(4000);
  
 
   UPDATE BULKLOADER SET locality_remarks=LAT_LONG_REMARKS WHERE LAT_LONG_REMARKS IS NOT NULL AND locality_remarks IS NULL;
   UPDATE BULKLOADER SET locality_remarks=locality_remarks || '; ' || LAT_LONG_REMARKS WHERE LAT_LONG_REMARKS IS NOT NULL AND locality_remarks IS NOT NULL;
   
 
 
 ALTER TABLE bulkloader DROP COLUMN LAT_LONG_REMARKS;
 ALTER TABLE bulkloader RENAME COLUMN HABITAT_DESC TO HABITAT;
 
  ALTER TABLE bulkloader MODIFY HABITAT VARCHAR2(4000);
 

   UPDATE BULKLOADER SET HABITAT=COLL_OBJECT_HABITAT WHERE COLL_OBJECT_HABITAT IS NOT NULL AND HABITAT IS NULL;

   UPDATE BULKLOADER SET HABITAT=HABITAT  || '; ' || COLL_OBJECT_HABITAT WHERE COLL_OBJECT_HABITAT IS NOT NULL AND HABITAT IS NOT NULL;

ALTER TABLE bulkloader DROP COLUMN COLL_OBJECT_HABITAT;

 ALTER TABLE bulkloader DROP COLUMN EXTENT;
  ALTER TABLE bulkloader DROP COLUMN GPSACCURACY;
ALTER TABLE bulkloader ADD specimen_event_remark varchar2(255);
  ALTER TABLE bulkloader ADD specimen_event_type varchar2(255);
  ALTER TABLE bulkloader ADD collecting_event_name varchar2(255);
  ALTER TABLE bulkloader ADD locality_name varchar2(255);
  
  
  
  ALTER TABLE bulkloader DROP COLUMN c$lat;
  ALTER TABLE bulkloader DROP COLUMN c$long;
  
  
  ALTER TABLE bulkloader ADD c$lat NUMBER (12,10);
  ALTER TABLE bulkloader ADD c$long NUMBER(13,10);





 ALTER TABLE bulkloader_deletes ADD georeference_source VARCHAR2(4000);
 ALTER TABLE bulkloader_deletes ADD georeference_protocol VARCHAR2(4000);
 ALTER TABLE bulkloader_deletes ADD event_assigned_by_agent VARCHAR2(4000);
 ALTER TABLE bulkloader_deletes ADD event_assigned_date VARCHAR2(4000);
 ALTER TABLE bulkloader_deletes ADD specimen_event_remark VARCHAR2(4000);
 ALTER TABLE bulkloader_deletes ADD specimen_event_type VARCHAR2(4000);
 ALTER TABLE bulkloader_deletes ADD collecting_event_name VARCHAR2(4000);
 ALTER TABLE bulkloader_deletes ADD locality_name VARCHAR2(4000);
 ALTER TABLE bulkloader_deletes ADD habitat VARCHAR2(4000);


--- rebuild triggers/bulkloader.sql


declare
	calclat NUMBER(12,10);
	calclong NUMBER(13,10);
BEGIN
    FOR r IN (SELECT * FROM bulkloader where orig_lat_long_units is not null) LOOP
       begin
       IF r.orig_lat_long_units = 'deg. min. sec.' THEN
        	calclat := r.LATDEG + (r.LATMIN / 60) + (nvl(r.LATSEC,0) / 3600);
            IF r.LATDIR = 'S' THEN
                calclat := calclat * -1;
            END IF;
            calclong := r.LONGDEG + (r.LONGMIN / 60) + (nvl(r.LONGSEC,0) / 3600);
            IF r.LONGDIR = 'W' THEN
                calclong := calclong * -1;
            END IF;
        ELSIF r.orig_lat_long_units = 'degrees dec. minutes' THEN
        	calclat := r.LATDEG + (r.dec_lat_min / 60);
        	if r.LATDIR = 'S' THEN
        		calclat := calclat * -1;
        	end if;
        	calclong := r.LONGDEG + (r.DEC_LONG_MIN / 60);
        	IF r.LONGDIR = 'W' THEN
        		calclong := calclong * -1;
        	END IF;
       ELSIF r.orig_lat_long_units = 'decimal degrees' THEN
           calclat := r.DEC_LAT;
            calclong := r.DEC_LONG;
       ELSE
           dbms_output.put_line(calclat);
           dbms_output.put_line(calclong);
           
           calclat := NULL;
           calclong := NULL;
       END IF;
       update bulkloader set c$lat=calclat,c$long=calclong where collection_object_id=r.collection_object_id;
       
         exception when others then
       
            update bulkloader set loaded=substr(loaded || '; ' || 'coordinate value error',1,255) where collection_object_id=r.collection_object_id;
		end;
	
	
	
       end loop;
     
       
   end;
/
        
        
        
        
CREATE OR REPLACE TRIGGER TR_bulkloader_BIU
BEFORE INSERT OR UPDATE ON bulkloader
FOR EACH ROW
BEGIN
 IF :new.orig_lat_long_units = 'deg. min. sec.' THEN
        	:new.c$lat := :new.LATDEG + (:new.LATMIN / 60) + (nvl(:new.LATSEC,0) / 3600);
            IF :new.LATDIR = 'S' THEN
                :new.c$lat := :new.c$lat * -1;
            END IF;
            :new.c$long := :new.LONGDEG + (:new.LONGMIN / 60) + (nvl(:new.LONGSEC,0) / 3600);
            IF :new.LONGDIR = 'W' THEN
                :new.c$long := :new.c$long * -1;
            END IF;
        ELSIF :new.orig_lat_long_units = 'degrees dec. minutes' THEN
        	:new.c$lat := :new.LATDEG + (:new.dec_lat_min / 60);
        	if :new.LATDIR = 'S' THEN
        		:new.c$lat := :new.c$lat * -1;
        	end if;
        	:new.c$long := :new.LONGDEG + (:new.DEC_LONG_MIN / 60);
        	IF :new.LONGDIR = 'W' THEN
        		:new.c$long := :new.c$long * -1;
        	END IF;
       ELSIF :new.orig_lat_long_units = 'decimal degrees' THEN
           :new.c$lat := :new.DEC_LAT;
           :new.c$long := :new.DEC_LONG;
       ELSE
            :new.c$lat := NULL;
           	:new.c$long := NULL;
       END IF; 
       exception when others then
           :new.loaded:='coordinate value error';
  END;
/     



ALTER TABLE lat_long RENAME TO lat_long_old;

-- create as sys:

CREATE OR REPLACE FUNCTION GET_COLLID_COUNT (locid in number)
RETURN number
IS
    x number;
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*)
        FROM uam.collecting_event ce, uam.specimen_event se, uam.cataloged_item ci
        WHERE ce.collecting_event_id = se.collecting_event_id
        AND se.collection_object_id = ci.collection_object_id
        AND ce.locality_id=' || locid
    INTO x;

RETURN x;

END;
/

grant execute on get_collid_count to public;

--select sys.get_collid_count(10055937) from dual;
--select sys.get_collid_count(16115) from dual;




CREATE OR REPLACE TRIGGER TR_LOCALITY_BUD
BEFORE UPDATE OR DELETE ON LOCALITY
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
	    AND specimen_event.verificationstatus LIKE 'verified by %';
	
	    IF num > 0 THEN
	        raise_application_error(-20001,
	        'This locality is used in verified specimen/events and may not be changed or deleted.');
	    END IF;
	
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
	 end if;
END;




-- For collecting_event table:

-- create as sys:
-- create as sys:

CREATE OR REPLACE FUNCTION GET_COLLEVENTID_COUNT (ceid in number)
RETURN number
IS
    x number;
BEGIN    EXECUTE IMMEDIATE 'SELECT COUNT(*)
        FROM uam.specimen_event se, uam.cataloged_item ci
        WHERE ci.collection_object_id = se.collection_object_id

        AND se.collecting_event_id = ' || ceid
    INTO x;

RETURN x;

END;
/
grant execute on get_colleventid_count to public;

/*
 select sys.get_colleventid_count(30287) from dual;

 SELECT COUNT(*)
        FROM uam.specimen_event se, uam.cataloged_item ci
        WHERE ci.collection_object_id = se.collection_Object_id
        AND se.collecting_event_id = 30287
*/


CREATE OR REPLACE TRIGGER TR_COLLECTINGEVENT_BUD

BEFORE UPDATE OR DELETE ON collecting_event
FOR EACH ROW
DECLARE
    num NUMBER;
    allrec INTEGER;
    vpdrec INTEGER;
    username VARCHAR2(30);
BEGIN

    SELECT
        COUNT(*)
    INTO
        num
    FROM
        specimen_event
    WHERE
        specimen_event.collecting_event_id=:OLD.collecting_event_id AND
        specimen_event.VERIFICATIONSTATUS LIKE 'verified by %';
    IF num > 0 THEN
       raise_application_error(-20001,'This collecting event is used in verified specimen/events and may not be changed or deleted.');
    END IF;

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

END;
/









--- rebuild procedure set_media_flat @ DDL

drop TRIGGER tr_catitem_vpd_ad;

drop TRIGGER tr_catitem_vpd_aiu;

drop TRIGGER tr_locality_vpd_aid;

exec DBMS_SCHEDULER.DROP_JOB('VPD_COLL_LOC_STALE');

exec dbms_rls.drop_policy('UAM','LOCALITY_OLD','LOCALITY_SIUD_POL');

drop table vpd_collection_locality;
drop procedure vpd_collection_locality_stale;

exec dbms_rls.drop_policy('UAM','LOCALITY_OLD','LOCALITY_SIUD_POL');



















	select * from cf_spec_res_cols WHERE category != 'attribute' order by disp_order

 COLUMN_NAME								    VARCHAR2(38)
 SQL_ELEMENT								    VARCHAR2(255)
 CATEGORY								    VARCHAR2(255)
 CF_SPEC_RES_COLS_ID						   NOT NULL NUMBER
 DISP_ORDER	
 
 DELETE FROM cf_spec_res_cols WHERE COLUMN_NAME='verbatimlatitude';
 DELETE FROM cf_spec_res_cols WHERE COLUMN_NAME='verbatimlongitude';
 DELETE FROM cf_spec_res_cols WHERE COLUMN_NAME='lat_long_determiner';
 DELETE FROM cf_spec_res_cols WHERE COLUMN_NAME='lat_long_ref_source';
 DELETE FROM cf_spec_res_cols WHERE COLUMN_NAME='lat_long_remarks';
 DELETE FROM cf_spec_res_cols WHERE COLUMN_NAME='habitat_desc';
FLATTABLENAME
flatTableName
UPDATE cf_spec_res_cols SET disp_order=disp_order+1 WHERE disp_order>20;

INSERT INTO cf_spec_res_cols (
    COLUMN_NAME,
    SQL_ELEMENT,
    CATEGORY,
    DISP_ORDER
   ) VALUES (
    'verbatimcoordinates',
    'flatTableName.verbatimcoordinates',
    'locality',
    21
   );






UPDATE  cf_spec_res_cols SET   COLUMN_NAME='VERBATIM_COORDINATES',SQL_ELEMENT='flatTableName.VERBATIM_COORDINATES' WHERE COLUMN_NAME='verbatimcoordinates';




UPDATE cf_spec_res_cols SET disp_order=disp_order+1 WHERE disp_order>21;
    	
INSERT INTO cf_spec_res_cols (
    COLUMN_NAME,
    SQL_ELEMENT,
    CATEGORY,
    DISP_ORDER
   ) VALUES (
    'SPECIMEN_EVENT_TYPE',
    'flatTableName.SPECIMEN_EVENT_TYPE',
    'locality',
    22
   );
   
   UPDATE cf_spec_res_cols SET disp_order=disp_order+1 WHERE disp_order>22;
    	
INSERT INTO cf_spec_res_cols (
    COLUMN_NAME,
    SQL_ELEMENT,
    CATEGORY,
    DISP_ORDER
   ) VALUES (
    'EVENT_ASSIGNED_BY_AGENT',
    'flatTableName.EVENT_ASSIGNED_BY_AGENT',
    'locality',
    23
   );
   
    UPDATE cf_spec_res_cols SET disp_order=disp_order+1 WHERE disp_order>23;
    	
INSERT INTO cf_spec_res_cols (
    COLUMN_NAME,
    SQL_ELEMENT,
    CATEGORY,
    DISP_ORDER
   ) VALUES (
    'EVENT_ASSIGNED_DATE',
    'flatTableName.EVENT_ASSIGNED_DATE',
    'locality',
    24
   );
 		
  		  UPDATE cf_spec_res_cols SET SQL_ELEMENT='to_char(flatTableName.EVENT_ASSIGNED_DATE,''yyyy-mm-dd'')' WHERE SQL_ELEMENT='flatTableName.EVENT_ASSIGNED_DATE';
 		
 		  UPDATE cf_spec_res_cols SET disp_order=disp_order+1 WHERE disp_order>24;
    	
INSERT INTO cf_spec_res_cols (
    COLUMN_NAME,
    SQL_ELEMENT,
    CATEGORY,
    DISP_ORDER
   ) VALUES (
    'SPECIMEN_EVENT_REMARK',
    'flatTableName.SPECIMEN_EVENT_REMARK',
    'locality',
    25
   );
 		
 		
 		  UPDATE cf_spec_res_cols SET disp_order=disp_order+1 WHERE disp_order>25;
    	
INSERT INTO cf_spec_res_cols (
    COLUMN_NAME,
    SQL_ELEMENT,
    CATEGORY,
    DISP_ORDER
   ) VALUES (
    'COLLECTING_EVENT_NAME',
    'flatTableName.COLLECTING_EVENT_NAME',
    'locality',
    26
   );
 			
	  UPDATE cf_spec_res_cols SET disp_order=disp_order+1 WHERE disp_order>26;
    	
INSERT INTO cf_spec_res_cols (
    COLUMN_NAME,
    SQL_ELEMENT,
    CATEGORY,
    DISP_ORDER
   ) VALUES (
    'LOCALITY_NAME',
    'flatTableName.LOCALITY_NAME',
    'locality',
    27
   ); 
   
   
   UPDATE cf_spec_res_cols SET disp_order=disp_order+1 WHERE disp_order>28;
    	
INSERT INTO cf_spec_res_cols (
    COLUMN_NAME,
    SQL_ELEMENT,
    CATEGORY,
    DISP_ORDER
   ) VALUES (
    'GEOREFERENCE_SOURCE',
    'flatTableName.GEOREFERENCE_SOURCE',
    'locality',
    28
   ); 
     
   
   UPDATE cf_spec_res_cols SET disp_order=disp_order+1 WHERE disp_order>29;
    	
INSERT INTO cf_spec_res_cols (
    COLUMN_NAME,
    SQL_ELEMENT,
    CATEGORY,
    DISP_ORDER
   ) VALUES (
    'GEOREFERENCE_PROTOCOL',
    'flatTableName.GEOREFERENCE_PROTOCOL',
    'locality',
    29
   ); 
     
   



CREATE UNIQUE INDEX iu_collecting_event_name ON collecting_event(collecting_event_name) TABLESPACE uam_idx_1;
CREATE UNIQUE INDEX iu_locality_name ON locality(locality_name) TABLESPACE uam_idx_1;







drop table bulkloader_stage;

CREATE table bulkloader_stage AS SELECT * FROM bulkloader WHERE 1=2;

CREATE OR REPLACE PUBLIC SYNONYM bulkloader_stage FOR bulkloader_stage;
    
 GRANT ALL ON bulkloader_stage TO coldfusion_user;

ALTER TABLE bulkloader_stage MODIFY collection_id NULL;
ALTER TABLE bulkloader_stage MODIFY ENTERED_AGENT_ID NULL;


--  REBUILD functions/BULKLOADER_STAGE_CHECK

-- rebuild functions/bulk_check_one


-- rebuild functions/bulk_stage_check_one


-- keep it around for now, just 'cuz, but...
ALTER TABLE cataloged_item MODIFY collecting_event_id NULL;





ALTER TABLE flat ADD enteredby varchar2(255);
ALTER TABLE flat ADD entereddate DATE;
ALTER TABLE flat ADD flags varchar2(255);



ALTER TABLE flat ADD nature_of_id VARCHAR2(255);

/*
UPDATE flat SET nature_of_id=(
    SELECT nature_of_id FROM identification WHERE accepted_id_fg=1 AND identification.collection_object_id=flat.collection_object_id
        HAVING COUNT(*)=1 GROUP BY nature_of_id
 );
    
    
    AND identification.collection_object_id=flat.collection_object_id

SELECT nature_of_id FROM identification WHERE accepted_id_fg=1  ;
*/

-- DO NOT USE THIS
-- USE THE PROCEDUReS FOLDER!!!!!!!!!!!!!!!!!!!!

CREATE OR REPLACE PROCEDURE UPDATE_FLAT (collobjid IN NUMBER) IS
this will make an error IF you try TO copypasta
    USE procedures
    go
    buhbye
BEGIN
	UPDATE flat
	SET (
			nature_of_id,
			flags,
			enteredby,
			entereddate,
			cat_num,
			accn_id,
			collecting_event_id,
			collection_cde,
			collection_id,
			catalognumbertext,
			institution_acronym,
			collection,
			began_date,
			ended_date,
			verbatim_date,
			individualCount,
			coll_obj_disposition,
			collectors,
			preparators,
			field_num,
			otherCatalogNumbers,
			genbankNum,
			relatedCatalogedItems,
			typeStatus,
			sex,
			parts,
			partdetail,
			encumbrances,
			accession,
			geog_auth_rec_id,
			higher_geog,
			continent_ocean,
			country,
			state_prov,
			county,
			feature,
			island,
			island_group,
			quad,
			sea,
			locality_id,
			spec_locality,
			minimum_elevation,
			maximum_elevation,
			orig_elev_units,
			min_elev_in_m,
			max_elev_in_m,
			dec_lat,
			dec_long,
			datum,
			orig_lat_long_units,
			coordinateUncertaintyInMeters,
			identification_id,
			scientific_name,
			identifiedby,
			made_date,
			remarks,
			habitat,
			associated_species,
			taxa_formula,
			full_taxon_name,
			phylclass,
			kingdom,
			phylum,
			phylOrder,
			family,
			genus,
			species,
			subspecies,
			author_text,
			nomenclatural_code,
			infraspecific_rank,
			identificationModifier,
			guid,
			basisOfRecord,
			depth_units,
			min_depth,
			max_depth,
			min_depth_in_m,
			max_depth_in_m,
			collecting_method,
			collecting_source,
			dayOfYear,
			age_class,
			attributes,
			verificationStatus,
			specimenDetailUrl,
			imageUrl,
			fieldNotesUrl,
			collectorNumber,
			verbatimElevation,
			year,
			month,
			day,
			id_sensu,
			verbatim_locality,
			event_assigned_by_agent,
			event_assigned_date,
			specimen_event_remark,
			specimen_event_type,
			COLL_EVENT_REMARKS,
			verbatim_coordinates,
			collecting_event_name,
			georeference_source,
			georeference_protocol,
			locality_name
			) = (
		SELECT
			nature_of_id,
			flags,
			getPreferredAgentName(coll_object.ENTERED_PERSON_ID),
			COLL_OBJECT_ENTERED_DATE,
			cataloged_item.cat_num,
			cataloged_item.accn_id,
			specimen_event.collecting_event_id,
			collection.collection_cde,
			cataloged_item.collection_id,
			to_char(cataloged_item.cat_num),
			collection.institution_acronym,
			collection.collection,
			collecting_event.began_date,
			collecting_event.ended_date,
			collecting_event.verbatim_date,
			coll_object.lot_count,
			coll_object.coll_obj_disposition,
			concatColl(cataloged_item.collection_object_id),
			concatPrep(cataloged_item.collection_object_id),
			concatSingleOtherId(cataloged_item.collection_object_id, 'Field Num'),
			concatOtherId(cataloged_item.collection_object_id),
			concatGenbank(cataloged_item.collection_object_id),
			concatRelations(cataloged_item.collection_object_id),
			concatTypeStatus(cataloged_item.collection_object_id),
			concatAttributeValue(cataloged_item.collection_object_id, 'sex'),
			concatParts(cataloged_item.collection_object_id),
			concatPartsDetail(cataloged_item.collection_object_id),
			concatEncumbrances(cataloged_item.collection_object_id),
			accn.accn_number,
			geog_auth_rec.geog_auth_rec_id,
			geog_auth_rec.higher_geog,
			geog_auth_rec.continent_ocean,
			geog_auth_rec.country,
			geog_auth_rec.state_prov,
			geog_auth_rec.county,
			geog_auth_rec.feature,
			geog_auth_rec.island,
			geog_auth_rec.island_group,
			geog_auth_rec.quad,
			geog_auth_rec.sea,
			locality.locality_id,
			locality.spec_locality,
			locality.minimum_elevation,
			locality.maximum_elevation,
			locality.orig_elev_units,
			to_meters(locality.minimum_elevation, locality.orig_elev_units),
			to_meters(locality.maximum_elevation, locality.orig_elev_units),
			locality.dec_lat,
			locality.dec_long,
			collecting_event.datum,
			collecting_event.orig_lat_long_units,
			to_meters(locality.max_error_distance, locality.max_error_units),
			identification.identification_id,
			identification.scientific_name,
			concatidentifiers(cataloged_item.collection_object_id),
			identification.made_date,
			coll_object_remark.coll_object_remarks,
			coll_object_remark.habitat,
			coll_object_remark.associated_species,
			taxa_formula,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'full_taxon_name')
				ELSE full_taxon_name
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'phylclass')
				ELSE phylclass
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Kingdom')
				ELSE kingdom
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Phylum')
				ELSE phylum
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'phylOrder')
				ELSE phylOrder
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Family')
				ELSE family
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Genus')
				ELSE genus
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Species')
				ELSE species
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Subspecies')
				ELSE subspecies
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'author_text')
				ELSE author_text
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'nomenclatural_code')
				ELSE nomenclatural_code
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'infraspecific_rank')
				ELSE infraspecific_rank
			END,
			' ',
			collection.guid_prefix || ':' ||
			cataloged_item.cat_num,
			decode(coll_object.coll_object_type,
				'CI', 'PreservedSpecimen',
				'HO', 'HumanObservation',
				'OtherSpecimen'),
			locality.depth_units,
			locality.min_depth,
			locality.max_depth,
			to_meters(locality.min_depth,locality.depth_units),
			to_meters(locality.max_depth,locality.depth_units),
			specimen_event.collecting_method,
			specimen_event.collecting_source,
			--decode(collecting_event.began_date,
			--	collecting_event.ended_date, to_number(to_char(collecting_event.began_date, 'DDD')),
			--	NULL),
			0,
			concatAttributeValue(cataloged_item.collection_object_id, 'age class'),
			concatattribute(cataloged_item.collection_object_id),
			specimen_event.verificationstatus,
			'<a href="http://arctos.database.museum/guid/' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num || '">' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num || '</a>',
			'http://arctos.database.museum/guid/' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num,
			'http://arctos.database.museum/guid/' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num,
			concatSingleOtherId(cataloged_item.collection_object_id,'collector number'),
			decode(locality.orig_elev_units,
				NULL, NULL,
				locality.minimum_elevation || '-' || 
					locality.maximum_elevation || ' ' ||
					locality.orig_elev_units),
			-- decode(to_number(to_char(collecting_event.began_date,'YYYY')),to_number(to_char(collecting_event.ended_date,'YYYY')),to_number(to_char(collecting_event.began_date,'YYYY')),NULL),
			substr(collecting_event.began_date,1,4),
			substr(collecting_event.began_date,6,2),
			substr(collecting_event.began_date,9,2),
			'<a href="http://arctos.database.museum/publication/' || idpub.publication_id || '">' || idpub.short_citation || '</a>',
			collecting_event.verbatim_locality,
			getPreferredAgentName(specimen_event.assigned_by_agent_id),
			assigned_date,
			specimen_event_remark,
			specimen_event_type,
			COLL_EVENT_REMARKS,
			verbatim_coordinates,
			collecting_event_name,
			georeference_source,
			georeference_protocol,
			locality_name
		FROM
			cataloged_item,
			coll_object,
			collection,
			accn,
			trans,
			map_specimen_event,
			specimen_event,
			collecting_event,
			locality,
			geog_auth_rec,
			identification,
			coll_object_remark,
			identification_taxonomy,
			taxonomy,
			publication idpub
		WHERE flat.collection_object_id = cataloged_item.collection_object_id
			AND cataloged_item.collection_object_id = coll_object.collection_object_id
			AND cataloged_item.collection_id = collection.collection_id
			AND cataloged_item.accn_id = accn.transaction_id
			AND accn.transaction_id = trans.transaction_id
			AND cataloged_item.collection_object_id = map_specimen_event.collection_object_id (+)
			AND map_specimen_event.specimen_event_id=specimen_event.specimen_event_id (+)
			AND specimen_event.collecting_event_id=collecting_event.collecting_event_id (+)
			AND collecting_event.locality_id = locality.locality_id (+)
			AND locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id (+)
			AND cataloged_item.collection_object_id = identification.collection_object_id
			AND identification.accepted_id_fg = 1
			AND identification.publication_id=idpub.publication_id (+)
			AND identification.identification_id = identification_taxonomy.identification_id
			AND identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id
			AND identification_taxonomy.variable = 'A'
			AND coll_object.collection_object_id = coll_object_remark.collection_object_id (+))
	WHERE flat.collection_object_id = collobjid;
EXCEPTION WHEN OTHERS THEN
    UPDATE flat SET stale_flag=-1 WHERE collection_object_id = collobjid;
END;
/


DROP INDEX IX_SPECIMENEVENT_CATALOGEDITEM;
CREATE INDEX IX_SPECIMENEVENT_CATALOGEDITEM ON SPECIMEN_EVENT (COLLECTION_OBJECT_ID) TABLESPACE uam_idx_1;

DROP INDEX IX_SPECIMENEVENT_COLLEVENT;
CREATE INDEX IX_SPECIMENEVENT_COLLEVENT ON SPECIMEN_EVENT (COLLECTING_EVENT_ID) TABLESPACE uam_idx_1;


DROP INDEX IX_COLLEVENT_LOCALITY;
CREATE INDEX IX_COLLEVENT_LOCALITY ON COLLECTING_EVENT (LOCALITY_ID) TABLESPACE uam_idx_1;


DROP INDEX IX_LOCALITY_GEOGAUTH;
CREATE INDEX IX_LOCALITY_GEOGAUTH ON LOCALITY (GEOG_AUTH_REC_ID) TABLESPACE uam_idx_1;


DROP INDEX IX_identification_acceptedfg;
CREATE INDEX IX_identification_acceptedfg ON identification (accepted_id_fg) TABLESPACE uam_idx_1;
    

DROP INDEX IX_identification_pubid;
CREATE INDEX IX_identification_pubid ON identification (publication_id) TABLESPACE uam_idx_1;
    



SELECT
     INDEX_NAME,
     COLUMN_NAME
     FROM
     USER_IND_COLUMNS
     WHERE
     LOWER(TABLE_NAME)=LOWER('coll_object_remark')
     ORDER BY INDEX_NAME,
     COLUMN_NAME;
     



ALTER TABLE locality ADD s$elevation NUMBER;

ALTER TABLE locality ADD s$geography VARCHAR2(4000);

ALTER TABLE locality ADD s$dec_lat NUMBER;
ALTER TABLE locality ADD s$dec_long NUMBER;






CREATE OR REPLACE VIEW filtered_flat AS
    SELECT
        flags,
        LASTDATE,
        LASTUSER,
        nature_of_id,
        collection_object_id,
        enteredby,
        entereddate,
        cat_num,
        accn_id,
        institution_acronym,
        collection_cde,
        collection_id,
        collection,
        minimum_elevation,
        maximum_elevation,
        orig_elev_units,
        identification_id,
        individualcount,
        coll_obj_disposition,
        -- mask collector
        CASE
            WHEN encumbrances LIKE '%mask collector%'
            THEN 'Anonymous'
            ELSE collectors
        END collectors,
        CASE
            WHEN encumbrances LIKE '%mask preparator%'
            THEN 'Anonymous'
            ELSE preparators
        END preparators,
        -- mask original field number
        CASE
            WHEN encumbrances LIKE '%mask original field number%'
            THEN 'Anonymous'
            ELSE field_num
        END field_num,
        otherCatalogNumbers,
        genbankNum,
        relatedCatalogedItemS,
        typeStatus,
        sex,
        parts,
        partdetail,
        accession,
        -- mask original field number
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN replace(began_date,substr(began_date,1,4),'8888')
            ELSE began_date
        END began_date,
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN replace(ended_date,substr(ended_date,1,4),'8888')
            ELSE ended_date
        END ended_date,
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN 'Masked'
            ELSE verbatim_date
        END verbatim_date,
        collecting_event_id,
        higher_geog,
        continent_ocean,
        country,
        state_prov,
        county,
        feature,
        island,
        island_group,
        quad,
        sea,
        geog_auth_rec_id,
        spec_locality,
        min_elev_in_m,
        max_elev_in_m ,
        locality_id,
        -- mask coordinates
        CASE
            WHEN encumbrances LIKE '%mask coordinates%'
            THEN NULL
            ELSE dec_lat
        END dec_lat,
        CASE
            WHEN encumbrances LIKE '%mask coordinates%'
            THEN NULL
            ELSE dec_long
        END dec_long,
        datum,
        orig_lat_long_units,
        CASE
            WHEN encumbrances LIKE '%mask coordinates%'
            THEN 'Masked'
            ELSE verbatim_coordinates
        END verbatim_coordinates,
        coordinateuncertaintyinmeters,
        scientific_name,
        identifiedby,
        made_date,
        remarks,
        habitat,
        associated_species,
        encumbrances,
        taxa_formula,
        full_taxon_name,
        phylClass,
        kingdom,
        phylum,
        phylOrder,
        family,
        genus,
        species,
        subspecies,
        infraspecific_rank,
        author_text,
        identificationModifier,
        nomenclatural_code,
        guid,
        basisOfRecord,
        depth_units,
        min_depth,
        max_depth,
        min_depth_in_m,
        max_depth_in_m,
        collecting_method,
        collecting_source,
        dayOfYear,
        age_class,
        attributes,
        verificationStatus,
        specimenDetailUrl,
        imageUrl,
        fieldNotesUrl,
        catalogNumberText,
        '<a href="http://arctos.database.museum/guid/' || guid || '">' || guid || '</a>'  RelatedInformation,
        collectorNumber,
        verbatimelEvation,
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN 8888
            ELSE year
        END year,
        month,
        day,
        id_sensu,
        '' emptystring,
        verbatim_locality,
		event_assigned_by_agent,
		event_assigned_date,
		specimen_event_remark,
		specimen_event_type,
		COLL_EVENT_REMARKS,
		collecting_event_name,
		georeference_source,
		georeference_protocol,
		locality_name
    FROM
        flat
    WHERE
    -- exclude masked records
        (encumbrances is null OR encumbrances NOT LIKE '%mask record%');	                           






CREATE OR REPLACE PROCEDURE set_media_flat
is
    tabl varchar2(255);
    kw VARCHAR2(4000);
    kwt VARCHAR2(4000);
    lbl VARCHAR2(4000);
    lblt VARCHAR2(4000);
    rel VARCHAR2(4000);
    relt VARCHAR2(4000);
    rsep VARCHAR2(4);
    ksep VARCHAR2(4);
    lsep VARCHAR2(4);
    csep varchar2(4);
    tn number;
    ct varchar2(4000);
    coords varchar2(4000);
    hastags NUMBER;
BEGIN
    FOR m IN (
        SELECT media_id
        FROM media_flat
        WHERE (lastdate IS NULL OR ((SYSDATE - lastdate) > 1))
        AND ROWNUM <= 2000
    ) LOOP
        kw := '';
        ksep:='';
        lsep:='';
        rsep:='';
        csep:='';
        tabl := '';
        kwt := '';
        lbl := '';
        lblt := '';
        rel := '';
        relt := '';
        rsep := '';
        ksep := '';
        lsep := '';
        csep := '';
        tn := NULL;
        ct  := '';
        coords  := '';
        hastags := NULL;
        FOR r IN (
            SELECT media_relationship, related_primary_key
            from media_relations
            where media_id = m.media_id
        ) LOOP
            tabl := SUBSTR(r.media_relationship, instr(r.media_relationship, ' ', -1) + 1);
            case tabl
                when 'locality' then
                    select 
                        r.media_relationship || '==<a href="/showLocality.cfm?action=srch\&locality_id=' || locality.locality_id || '">' || state_prov || ': ' || spec_locality || '</a>',
                        spec_locality || ';' || higher_geog,
                        dec_lat || ',' || dec_long
                    into 
                        relt,
                        kwt,
                        ct
                    from 
                        locality,geog_auth_rec
                    where 
                        locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and 
                        locality.locality_id=r.related_primary_key;
                when 'collecting_event' then
                    select
                        r.media_relationship || '==<a href="/showLocality.cfm?action=srch\&collecting_event_id=' || collecting_event.collecting_event_id || '">' || state_prov || ': ' || spec_locality || '</a>',
                        verbatim_locality || '; ' || verbatim_date || '; ' ||
                        locality.spec_locality || '; ' || higher_geog,
                        locality.dec_lat || ',' || locality.dec_long
                    into
                        relt,
                        kwt,
                        ct
                    from
                        collecting_event, locality, geog_auth_rec
                    WHERE 
                        collecting_event.locality_id = locality.locality_id and 
                        locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
                        collecting_event.collecting_event_id = r.related_primary_key;
                when 'agent' then
                    select 
                        r.media_relationship || '==' || agent_name,
                        agent_name,
                        NULL
                    into
                        relt,
                        kwt,
                        ct
                    from 
                        preferred_agent_name
                    where 
                        agent_id=r.related_primary_key;
                when 'media' then
                    select 
                        r.media_relationship || '==' || media_id,
                        NULL,
                        NULL
                    into
                        relt,
                        kwt,
                        ct
                    from 
                        media
                    where 
                        media_id=r.related_primary_key;
                when 'cataloged_item' then
                     select
                         r.media_relationship || '==<a href="/guid/' || guid || '">' || guid  || '</a>',
                         collection || ' ' || cat_num || '; ' ||
                         GUID || '; ' ||
                         OTHERCATALOGNUMBERS || '; ' ||
                         COLLECTORS || '; ' ||
                         scientific_name || '; ' ||
                         regexp_replace(get_taxonomy(filtered_flat.collection_object_id,'display_name'),'<[^<]+>','')  || '; ' ||
                         verbatim_date || '; ' ||
                         spec_locality || '; ' ||
                         higher_geog,
                         dec_lat || ',' || dec_long
                     into
                         relt,
                         kwt,
                         ct
                     from  
                         filtered_flat
                     where 
                         filtered_flat.collection_object_id=r.related_primary_key;
                when 'project' then
                    select 
                        r.media_relationship || '==<a href="/project/' || niceURL(project_name) || '">' || project_name  || '</a>',
                        project_name
                    into
                        relt,
                        kwt
                    from 
                        project
                    where project_id=r.related_primary_key;
                when 'accn' then
                    select 
                        r.media_relationship || '==<a href="/viewAccn.cfm?transaction_id=' || accn.transaction_id  || '">' || collection || ' ' || accn_number || '</a>',
                        collection || ' ' || accn_number
                    into 
                        relt,
                        kwt
                    from 
                        accn,trans,collection
                    where
                        accn.transaction_id=trans.transaction_id AND
                        trans.collection_id=collection.collection_id AND
                        accn.transaction_id=r.related_primary_key;
                when 'taxonomy' then
                    select 
                        r.media_relationship || '==<a href="/name/' || scientific_name || '">' || display_name  || '</a>',
                        full_taxon_name || ' ' || display_name 
                    into 
                        relt,
                        kwt
                    from taxonomy
                    where  taxonomy.taxon_name_id=r.related_primary_key;
                ELSE
                    NULL;
            end case;
          IF ct=',' THEN
              ct:='';
          END IF;
          tn:=nvl(length(coords),0) + nvl(length(ct),0) + 20;
          IF length(ct) > 0 AND tn < 4000 THEN
               coords := coords || csep || ct;
               csep := '|';
            END IF;
           ct:='';
            tn:=nvl(length(rel),0) + nvl(length(relt),0) + 20;
            IF tn < 4000 THEN
                rel := rel || rsep || relt;
               rsep := '|';
            END IF;
            tn:=nvl(length(kw),0) + nvl(length(kwt),0) + 20;
            IF tn < 4000 THEN
                kw := kw || ksep || kwt;
               ksep := '|';
            END IF;
             kwt:='';
        END LOOP;
        FOR rm IN (select 
                        media_relationship || '==' || media_id mrs
                    from 
                        media_relations
                    where 
                        media_relationship LIKE '% media' AND
                        related_primary_key=m.media_id) LOOP
             tn:=nvl(length(rel),0) + nvl(length(rm.mrs),0) + 20;
            IF tn < 4000 THEN
                rel := rel || rsep || rm.mrs;
               rsep := '|';
            END IF;
        END LOOP; 
        FOR l IN (
            SELECT media_label || '==' || label_value label_value
            FROM media_labels
            WHERE media_id=m.media_id
        ) LOOP
            kwt:=regexp_replace(l.label_value, '<[^<]+>', '');
            tn:=nvl(length(kw),0) + nvl(length(kwt),0) + 20;
            IF tn < 4000 THEN
                kw := kw || ksep || kwt;
                ksep := '|';
            END IF;
            tn:=nvl(length(lbl),0) + nvl(length(l.label_value),0) + 20;
            IF tn < 4000 THEN
                lbl := lbl || lsep || regexp_replace(l.label_value, '<[^<]+>', '');
                lsep := '|';
            END IF;
        END LOOP;
        SELECT COUNT(*) INTO hastags FROM tag WHERE media_id=m.media_id;
        -- allow zero or one set of coordinates only
        IF instr(coords,'|') != 0 THEN
            coords:=NULL;
        END IF;
        UPDATE media_flat SET
            relationships=trim(rel),
            labels=trim(lbl),
            keywords=trim(kw),
            coordinates=trim(coords),
            hastags=hastags,
            lastdate = SYSDATE
        WHERE 
            media_id=m.media_id;                         
        rel:='';
        kw:='';
        lbl:='';
    END LOOP;   
END;
/
sho err










UPDATE flat SET stale_flag=1;



	