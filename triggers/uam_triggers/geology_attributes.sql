
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
		    
				--dbms_output.put_line('through if yes');
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
		    	--dbms_output.put_line('through if no');
		    end if;		
		end if;
		
		--dbms_output.put_line('v_action:' || v_action);
		
	    if v_action is not null then
	    	-- something happened, we need to log
	    	-- make sure there's a parent record in the locality archive
	    	select count(*) into c from locality_archive where LOCALITY_ID=:NEW.LOCALITY_ID;
			if c=0 then
				--dbms_output.put_line('seeding:');
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
				 	wkt_media_id,
				 	changed_agent_id,
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
					 	wkt_media_id,
					 	getAgentIDFromLogin(sys_context('USERENV', 'SESSION_USER')),
						sysdate
					from
						locality
					where
						locality_id=nkey
				 );
			end if;
			
			
		--dbms_output.put_line('ready:' );
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
					changed_agent_id,
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
					getAgentIDFromLogin(sys_context('USERENV', 'SESSION_USER')),
					sysdate,
					'inserting'
				);
			elsif updating then
			
		--dbms_output.put_line('updating' );
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
					changed_agent_id,
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
					getAgentIDFromLogin(sys_context('USERENV', 'SESSION_USER')),
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
					changed_agent_id,
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
					getAgentIDFromLogin(sys_context('USERENV', 'SESSION_USER')),
					sysdate,
					'deleting'
				);
			end if;
		end if;
  end;
/
sho err;







CREATE or replace TRIGGER sq_GEOLOGY_ATTRIBUTES_SQ
	BEFORE INSERT ON GEOLOGY_ATTRIBUTES
FOR EACH ROW
BEGIN
    IF :new.geology_attribute_id IS NULL THEN
    	SELECT sq_geology_attribute_id.nextval
    	INTO :new.geology_attribute_id
		FROM dual;
    END IF;
END;
/


CREATE or replace TRIGGER GEOLOGY_ATTRIBUTES_CHECK
BEFORE UPDATE OR INSERT ON GEOLOGY_ATTRIBUTES
FOR EACH ROW
DECLARE numrows NUMBER;
BEGIN
	-- these are "locality attributes"
	-- control the type, not the value
	if :NEW.geology_attribute NOT IN (
		'Site Found By',
		'Site Found Date',
		'Site Identifier',
		'Site Collector Number',
		'Site Field Number',
		'TRS aliquot'
	) then
		SELECT COUNT(*) INTO numrows FROM geology_attribute_hierarchy WHERE attribute=:NEW.geology_attribute and ATTRIBUTE_VALUE=:NEW.GEO_ATT_VALUE and USABLE_VALUE_FG=1;
		IF (numrows = 0) THEN
			raise_application_error(
			    -20001,
			    'Invalid geology_attribute: ' || :NEW.geology_attribute || '='||:NEW.GEO_ATT_VALUE);
		END IF;
	end if;
END;
/

UAM@ARCTOSTE>  desc geology_attribute_hierarchy
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 GEOLOGY_ATTRIBUTE_HIERARCHY_ID 				   NOT NULL NUMBER
 PARENT_ID								    NUMBER
 ATTRIBUTE							   NOT NULL VARCHAR2(255)
 ATTRIBUTE_VALUE						   NOT NULL VARCHAR2(255)
 USABLE_VALUE_FG						   NOT NULL NUMBER
 DESCRIPTION								    VARCHAR2(4000)


UAM@ARCTOS> desc geology_attributes;
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 GEOLOGY_ATTRIBUTE_ID						   NOT NULL NUMBER
 LOCALITY_ID							   NOT NULL NUMBER
 GEOLOGY_ATTRIBUTE						   NOT NULL VARCHAR2(255)
 GEO_ATT_VALUE							   NOT NULL VARCHAR2(255)
 GEO_ATT_DETERMINER_ID							    NUMBER
 GEO_ATT_DETERMINED_DATE						    DATE
 GEO_ATT_DETERMINED_METHOD						    VARCHAR2(255)
 GEO_ATT_REMARK 							    VARCHAR2(4000)

UAM@ARCTOS> 


alter table geology_attribute_hierarchy add constraint PK_geo_attr_h PRIMARY KEY (ATTRIBUTE_VALUE) using index TABLESPACE UAM_IDX_1;

