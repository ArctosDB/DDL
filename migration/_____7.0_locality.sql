

-------------

-- address https://github.com/ArctosDB/arctos/issues/729
-- first step: create a locality archive, write to it with triggers

 -- exclude the service-derived stuff
 -- add who/when
 
create table locality_archive (
 	locality_archive_id number not null,
 	locality_id number,
 	geog_auth_rec_id number,
 	spec_locality varchar2(4000),
 	DEC_LAT number,
 	DEC_LONG number,
	MINIMUM_ELEVATION number,
	MAXIMUM_ELEVATION number,
	ORIG_ELEV_UNITS VARCHAR2(30),
	MIN_DEPTH NUMBER,
	MAX_DEPTH number,
	DEPTH_UNITS  VARCHAR2(30),
	MAX_ERROR_DISTANCE NUMBER,
	MAX_ERROR_UNITS VARCHAR2(30),
	DATUM VARCHAR2(255),
	LOCALITY_REMARKS VARCHAR2(4000),
	GEOREFERENCE_SOURCE VARCHAR2(4000),
	GEOREFERENCE_PROTOCOL VARCHAR2(255),
	LOCALITY_NAME VARCHAR2(255),
 	WKT_POLYGON CLOB,
 	whodunit varchar2(255),
 	changedate date 	
);

create sequence sq_locality_archive_id;
CREATE PUBLIC SYNONYM sq_locality_archive_id FOR sq_locality_archive_id;
GRANT SELECT ON sq_locality_archive_id TO PUBLIC;


CREATE PUBLIC SYNONYM locality_archive FOR locality_archive;
-- everyone can read
-- only UAM can change (via trigger)
grant select on locality_archive to public;


CREATE OR REPLACE TRIGGER trg_locality_archive
	-- only care if there's been a successful change
	after UPDATE ON locality
    FOR EACH ROW
    	declare nkey number;
    BEGIN
	    -- first test if we're changing anything - no reason to log
	    -- "save because there's a button" or webservice cache
	    -- actions
	    -- NULL never equals NULL so need NVL
	    --dbms_output.put_line('trg_locality_archive is firing');
	    if 
	    	:NEW.geog_auth_rec_id != :OLD.geog_auth_rec_id or
	    	nvl(:NEW.spec_locality,'NULL') != nvl(:OLD.spec_locality,'NULL') or
	    	nvl(:NEW.DEC_LAT,0) != nvl(:OLD.DEC_LAT,0) or	
	    	nvl(:NEW.DEC_LONG,0) != nvl(:OLD.DEC_LONG,0) or
	    	nvl(:NEW.MINIMUM_ELEVATION,0) != nvl(:OLD.MINIMUM_ELEVATION,0) or
	    	nvl(:NEW.MAXIMUM_ELEVATION,0) != nvl(:OLD.MAXIMUM_ELEVATION,0) or
	    	nvl(:NEW.ORIG_ELEV_UNITS,'NULL') != nvl(:OLD.ORIG_ELEV_UNITS,'NULL') or
	    	nvl(:NEW.MIN_DEPTH,0) != nvl(:OLD.MIN_DEPTH,0) or
	    	nvl(:NEW.MAX_DEPTH,0) != nvl(:OLD.MAX_DEPTH,0) or
	    	nvl(:NEW.DEPTH_UNITS,'NULL') != nvl(:OLD.DEPTH_UNITS,'NULL') or
	    	nvl(:NEW.MAX_ERROR_DISTANCE,0) != nvl(:OLD.MAX_ERROR_DISTANCE,0) or
	    	nvl(:NEW.MAX_ERROR_UNITS,'NULL') != nvl(:OLD.MAX_ERROR_UNITS,'NULL') or
	    	nvl(:NEW.DATUM,'NULL') != nvl(:OLD.DATUM,'NULL') or
	    	nvl(:NEW.LOCALITY_REMARKS,'NULL') != nvl(:OLD.LOCALITY_REMARKS,'NULL') or
	    	nvl(:NEW.GEOREFERENCE_SOURCE,'NULL') != nvl(:OLD.GEOREFERENCE_SOURCE,'NULL') or
	    	nvl(:NEW.GEOREFERENCE_PROTOCOL,'NULL') != nvl(:OLD.GEOREFERENCE_PROTOCOL,'NULL') or
	    	nvl(:NEW.LOCALITY_NAME,'NULL') != nvl(:OLD.LOCALITY_NAME,'NULL') or
	    	dbms_lob.compare(nvl(:NEW.WKT_POLYGON,'NULL'),nvl(:OLD.WKT_POLYGON,'NULL')) != 0	
	    	then
	    		--dbms_output.put_line('got change');  
	    		 -- now just grab all of the :OLD values
		        -- :NEWs are current data in locality, no need to do anything with them
		        insert into locality_archive (
				 	locality_archive_id,
				 	locality_id,
				 	geog_auth_rec_id,
				 	spec_locality,
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
					GEOREFERENCE_SOURCE,
					GEOREFERENCE_PROTOCOL,
					LOCALITY_NAME,
				 	WKT_POLYGON,
				 	whodunit,
				 	changedate
				 ) values (
				 	sq_locality_archive_id.nextval,
				 	:OLD.locality_id,
				 	:OLD.geog_auth_rec_id,
				 	:OLD.spec_locality,
				 	:OLD.DEC_LAT,
				 	:OLD.DEC_LONG,
					:OLD.MINIMUM_ELEVATION,
					:OLD.MAXIMUM_ELEVATION,
					:OLD.ORIG_ELEV_UNITS,
					:OLD.MIN_DEPTH,
					:OLD.MAX_DEPTH,
					:OLD.DEPTH_UNITS,
					:OLD.MAX_ERROR_DISTANCE,
					:OLD.MAX_ERROR_UNITS,
					:OLD.DATUM,
					:OLD.LOCALITY_REMARKS,
					:OLD.GEOREFERENCE_SOURCE,
					:OLD.GEOREFERENCE_PROTOCOL,
					:OLD.LOCALITY_NAME,
				 	:OLD.WKT_POLYGON,
				 	sys_context('USERENV', 'SESSION_USER'),
				 	sysdate
				 );
				--dbms_output.put_line('logged OLD values');  
	    end if;
  end;
/
sho err;




---- above running at prod 20161026


select min(locality_id) from locality where WKT_POLYGON is not null;

update locality set wkt_polygon='5' where locality_id=10043723;
select * from locality_archive;



alter trigger UAM.TRG_LOCALITY_BIU disable;

update locality set dec_lat=dec_lat where locality_id=3;
update locality set dec_lat=null where locality_id=3;
alter trigger UAM.TRG_LOCALITY_BIU enable;

 or
	    		    	
	    		    
	    		    	
	    		    	
	    		    	
	    		    	nvl(:NEW.nnnnnn,0) != nvl(:OLD.nnnnn,0) or
	    		    	nvl(:NEW.xxxxxxx,'NULL') != nvl(:OLD.xxxxxxx,'NULL')
	    	update locality set spec_locality=spec_locality where locality_id=1;
	    	update locality set geog_auth_rec_id=12 where locality_id=1;
	    	
	    	or
	    	
	    	:NEW.DEC_LAT != :OLD.DEC_LAT or
	    	:NEW.DEC_LONG != :OLD.DEC_LONG or
	    	:NEW.MINIMUM_ELEVATION != :OLD.MINIMUM_ELEVATION or
	    	:NEW.MAXIMUM_ELEVATION != :OLD.MAXIMUM_ELEVATION or
	    	:NEW.ORIG_ELEV_UNITS != :OLD.ORIG_ELEV_UNITS or
	    	:NEW.MIN_DEPTH != :OLD.MIN_DEPTH or
	    	:NEW.MAX_DEPTH != :OLD.MAX_DEPTH or
	    	:NEW.DEPTH_UNITS != :OLD.DEPTH_UNITS or
	    	:NEW.geog_auth_rec_id != :OLD.geog_auth_rec_id or
	    	:NEW.geog_auth_rec_id != :OLD.geog_auth_rec_id or
	    	:NEW.geog_auth_rec_id != :OLD.geog_auth_rec_id or
	    	:NEW.geog_auth_rec_id != :OLD.geog_auth_rec_id or
	    	:NEW.geog_auth_rec_id != :OLD.geog_auth_rec_id or
	    	:NEW.geog_auth_rec_id != :OLD.geog_auth_rec_id or
	    	:NEW.geog_auth_rec_id != :OLD.geog_auth_rec_id or
	    	:NEW.geog_auth_rec_id != :OLD.geog_auth_rec_id or
	    	
		 	,
		 	,
		 	,
			,
			,
			,
			,
			,
			,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			DATUM,
			LOCALITY_REMARKS,
			GEOREFERENCE_SOURCE,
			GEOREFERENCE_PROTOCOL,
			LOCALITY_NAME,
		 	WKT_POLYGON,
		 	whodunit,
		 	changedate
		 	
		 	
		 	
		 	
	  
		 
		 	
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
