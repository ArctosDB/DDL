-- EDIT
-- 2018-09-06
-- https://github.com/ArctosDB/arctos/issues/1672
-- geology too

create table geology_archive (
	geology_archive_id number not null,
	GEOLOGY_ATTRIBUTE_ID number not null,
	LOCALITY_ID number not null,
	GEOLOGY_ATTRIBUTE VARCHAR2(255) not null,
	GEO_ATT_VALUE VARCHAR2(255) not null,
	GEO_ATT_DETERMINER_ID number,
	GEO_ATT_DETERMINED_DATE date,
	GEO_ATT_DETERMINED_METHOD VARCHAR2(255),
	GEO_ATT_REMARK VARCHAR2(4000),
 	whodunit varchar2(255),
 	changedate date,
 	triggering_event varchar2(255)
 );

 
 
create sequence sq_geology_archive_id;
CREATE PUBLIC SYNONYM sq_geology_archive_id FOR sq_geology_archive_id;
GRANT SELECT ON sq_geology_archive_id TO PUBLIC;


CREATE PUBLIC SYNONYM geology_archive FOR geology_archive;
-- everyone can read
-- only UAM can change (via trigger)
grant select on geology_archive to public;


CREATE OR REPLACE TRIGGER trg_geology_archive
	-- only care if there's been a successful change
	after insert or update or delete ON geology_attributes
    FOR EACH ROW
    	declare 
    		nkey number;
    		c number;
    		v_action varchar2(255);
    BEGIN
	    -- INSERT is fairly redundant, but capture it anyway
	    -- because it comes with WHO and WHEN inserted to Arctos
	    -- in addition to WHO and WHEN made the determination
	    
	    --dbms_output.put_line('here we go now:' );

	    -- first see if anything actually changed
	    if inserting then
	    	-- something changed...
	    	v_action:='inserting';
	    	nkey:=:NEW.locality_id;
	    elsif deleting then
	    	v_action:='deleting';
	    	nkey:=:OLD.locality_id;
	    else
		     if 
		    	:NEW.LOCALITY_ID != :OLD.LOCALITY_ID or
		    	:NEW.GEOLOGY_ATTRIBUTE != :OLD.GEOLOGY_ATTRIBUTE or
		    	:NEW.GEO_ATT_VALUE != :OLD.GEO_ATT_VALUE or
		    	nvl(:NEW.GEO_ATT_DETERMINER_ID,0) != nvl(:OLD.GEO_ATT_DETERMINER_ID,0) or	
		    	nvl(:NEW.GEO_ATT_DETERMINED_DATE,'1234-01-01') != nvl(:OLD.GEO_ATT_DETERMINED_DATE,'1234-01-01') or
		    	nvl(:NEW.GEO_ATT_DETERMINED_METHOD,'NULL') != nvl(:OLD.GEO_ATT_DETERMINED_METHOD,'NULL') or
		    	nvl(:NEW.GEO_ATT_REMARK,'NULL') != nvl(:OLD.GEO_ATT_REMARK,'NULL')
		    then
		    
				dbms_output.put_line('through if yes');
		    	-- something changed
		    	if updating then
		    		v_action:='updating';
	    			nkey:=:NEW.locality_id;
		    	else
		    		v_action:=NULL;
		    	end if;
		    else
		    	-- nothing changed
		    	v_action:=NULL;
		    	dbms_output.put_line('through if no');
		    end if;		
		end if;
		
		dbms_output.put_line('v_action:' || v_action);
		
	    if v_action is not null then
	    	-- something happened, we need to log
	    	-- make sure there's a parent record in the locality archive
	    	select count(*) into c from locality_archive where LOCALITY_ID=:NEW.LOCALITY_ID;
			if c=0 then
				dbms_output.put_line('seeding:');
				-- seed the locality archive
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
				 ) (
				 	select
					 	sq_locality_archive_id.nextval,
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
					 	sys_context('USERENV', 'SESSION_USER'),
						sysdate
					from
						locality
					where
						locality_id=nkey
				 );
			end if;
			
			
		dbms_output.put_line('ready:' );
			if inserting then
		    	-- use NEW values; that's all we have
				insert into geology_archive (
					geology_archive_id,
					GEOLOGY_ATTRIBUTE_ID,
					LOCALITY_ID,
					GEOLOGY_ATTRIBUTE,
					GEO_ATT_VALUE,
					GEO_ATT_DETERMINER_ID,
					GEO_ATT_DETERMINED_DATE,
					GEO_ATT_DETERMINED_METHOD,
					GEO_ATT_REMARK,
					whodunit,
					changedate,
					triggering_event
				) values (
					sq_geology_archive_id.nextval,
					:NEW.GEOLOGY_ATTRIBUTE_ID,
					nkey,
					:NEW.GEOLOGY_ATTRIBUTE,
					:NEW.GEO_ATT_VALUE,
					:NEW.GEO_ATT_DETERMINER_ID,
					:NEW.GEO_ATT_DETERMINED_DATE,
					:NEW.GEO_ATT_DETERMINED_METHOD,
					:NEW.GEO_ATT_REMARK,
					sys_context('USERENV', 'SESSION_USER'),
					sysdate,
					'inserting'
				);
			elsif updating then
			
		dbms_output.put_line('updating' );
				-- just insert, but use OLD values
				insert into geology_archive (
					geology_archive_id,
					GEOLOGY_ATTRIBUTE_ID,
					LOCALITY_ID,
					GEOLOGY_ATTRIBUTE,
					GEO_ATT_VALUE,
					GEO_ATT_DETERMINER_ID,
					GEO_ATT_DETERMINED_DATE,
					GEO_ATT_DETERMINED_METHOD,
					GEO_ATT_REMARK,
					whodunit,
					changedate,
					triggering_event
				) values (
					sq_geology_archive_id.nextval,
					:OLD.GEOLOGY_ATTRIBUTE_ID,
					nkey,
					:OLD.GEOLOGY_ATTRIBUTE,
					:OLD.GEO_ATT_VALUE,
					:OLD.GEO_ATT_DETERMINER_ID,
					:OLD.GEO_ATT_DETERMINED_DATE,
					:OLD.GEO_ATT_DETERMINED_METHOD,
					:OLD.GEO_ATT_REMARK,
					sys_context('USERENV', 'SESSION_USER'),
					sysdate,
					'updating'
				);
			elsif deleting then
				insert into geology_archive (
					geology_archive_id,
					GEOLOGY_ATTRIBUTE_ID,
					LOCALITY_ID,
					GEOLOGY_ATTRIBUTE,
					GEO_ATT_VALUE,
					GEO_ATT_DETERMINER_ID,
					GEO_ATT_DETERMINED_DATE,
					GEO_ATT_DETERMINED_METHOD,
					GEO_ATT_REMARK,
					whodunit,
					changedate,
					triggering_event
				) values (
					sq_geology_archive_id.nextval,
					:OLD.GEOLOGY_ATTRIBUTE_ID,
					nkey,
					:OLD.GEOLOGY_ATTRIBUTE,
					:OLD.GEO_ATT_VALUE,
					:OLD.GEO_ATT_DETERMINER_ID,
					:OLD.GEO_ATT_DETERMINED_DATE,
					:OLD.GEO_ATT_DETERMINED_METHOD,
					:OLD.GEO_ATT_REMARK,
					sys_context('USERENV', 'SESSION_USER'),
					sysdate,
					'deleting'
				);
			end if;
		end if;
  end;
/
sho err;


 update geology_attributes set geology_attribute='formation', geo_att_value='Prince Creek Formation' ,geo_att_determiner_id=NULL ,geo_att_determined_date=NULL ,geo_att_determined_method='boogity' ,geo_att_remark=NULL where geology_attribute_id=62 ;
 
 

-------------

-- address https://github.com/ArctosDB/arctos/issues/729
-- first step: create a locality archive, write to it with triggers

 -- exclude the service-derived stuff
 -- add who/when
 
 -- add key to agents
 
 alter table locality_archive add  changed_agent_id number;
 update locality_archive set changed_agent_id=getAgentIDFromLogin(whodunit);
  alter table locality_archive modify  changed_agent_id not null;

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
	after insert or UPDATE ON locality
    FOR EACH ROW
    	declare nkey number;
    BEGIN
	    -- first test if we're changing anything - no reason to log
	    -- "save because there's a button" or webservice cache
	    -- actions
	    -- NULL never equals NULL so need NVL
	    --dbms_output.put_line('trg_locality_archive is firing');
	    if updating then
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
					 	changed_agent_id,
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
					 	getAgentIDFromLogin(sys_context('USERENV', 'SESSION_USER')),
					 	sysdate
					 );
					--dbms_output.put_line('logged OLD values');  
		    end if;
		end if;
		if inserting then
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
			 	changed_agent_id,
			 	changedate
			 ) values (
			 	sq_locality_archive_id.nextval,
			 	:NEW.locality_id,
			 	:NEW.geog_auth_rec_id,
			 	:NEW.spec_locality,
			 	:NEW.DEC_LAT,
			 	:NEW.DEC_LONG,
				:NEW.MINIMUM_ELEVATION,
				:NEW.MAXIMUM_ELEVATION,
				:NEW.ORIG_ELEV_UNITS,
				:NEW.MIN_DEPTH,
				:NEW.MAX_DEPTH,
				:NEW.DEPTH_UNITS,
				:NEW.MAX_ERROR_DISTANCE,
				:NEW.MAX_ERROR_UNITS,
				:NEW.DATUM,
				:NEW.LOCALITY_REMARKS,
				:NEW.GEOREFERENCE_SOURCE,
				:NEW.GEOREFERENCE_PROTOCOL,
				:NEW.LOCALITY_NAME,
			 	:NEW.WKT_POLYGON,
			 	getAgentIDFromLogin(sys_context('USERENV', 'SESSION_USER')),
			 	sysdate
			 );
		end if;
  end;
/
sho err;


