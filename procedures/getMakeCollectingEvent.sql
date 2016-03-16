
-- make a table to hold the fields
-- useful in writing code etc.
-- order is important because CF can't pass in variable names
-- that's fixed in CF11 but we don't have one of those!
-- keep this synced with the procedure and will all cfstoredproc calls

drop table temp_getMakeCE_flds;
create table temp_getMakeCE_flds (
	ord number,
	fld varchar2(255),
	blfld varchar2(255),
	dtype varchar2(255),
	requiredwhen varchar2(255),
	optionalwhen  varchar2(255),
	ignoredwhen  varchar2(255),
	descr varchar2(4000)
);

-- event
insert into temp_getMakeCE_flds (fld, ord) values ('COLLECTING_EVENT_ID',1);
insert into temp_getMakeCE_flds (fld, ord) values ('COLLECTING_EVENT_NAME',2);
insert into temp_getMakeCE_flds (fld, ord) values ('VERBATIM_DATE',3);
insert into temp_getMakeCE_flds (fld,ord) values ('BEGAN_DATE',4);
insert into temp_getMakeCE_flds (fld,ord) values ('ENDED_DATE',5);
insert into temp_getMakeCE_flds (fld,ord) values ('VERBATIM_LOCALITY',6);
insert into temp_getMakeCE_flds (fld,ord) values ('COLL_EVENT_REMARKS',7);
-- locality 
insert into temp_getMakeCE_flds (fld,ord) values ('LOCALITY_ID',8);
insert into temp_getMakeCE_flds (fld,ord) values ('LOCALITY_NAME',9);
insert into temp_getMakeCE_flds (fld,ord) values ('SPEC_LOCALITY',10);
insert into temp_getMakeCE_flds (fld,ord) values ('ORIG_ELEV_UNITS',11);
insert into temp_getMakeCE_flds (fld,ord) values ('MINIMUM_ELEVATION',12);
insert into temp_getMakeCE_flds (fld,ord) values ('MAXIMUM_ELEVATION',13);
insert into temp_getMakeCE_flds (fld,ord) values ('DEPTH_UNITS',14);
insert into temp_getMakeCE_flds (fld,ord) values ('MIN_DEPTH',15);
insert into temp_getMakeCE_flds (fld,ord) values ('MAX_DEPTH',16);
insert into temp_getMakeCE_flds (fld,ord) values ('ORIG_LAT_LONG_UNITS',17);
insert into temp_getMakeCE_flds (fld,ord) values ('DATUM',18);
insert into temp_getMakeCE_flds (fld,ord) values ('GEOREFERENCE_SOURCE',19);
insert into temp_getMakeCE_flds (fld,ord) values ('GEOREFERENCE_PROTOCOL',20);
insert into temp_getMakeCE_flds (fld,ord) values ('MAX_ERROR_UNITS',21);
insert into temp_getMakeCE_flds (fld,ord) values ('MAX_ERROR_DISTANCE',22);
insert into temp_getMakeCE_flds (fld,ord) values ('DEC_LAT',23);
insert into temp_getMakeCE_flds (fld,ord) values ('DEC_LONG',24);
insert into temp_getMakeCE_flds (fld,ord) values ('LAT_DEG',25);
insert into temp_getMakeCE_flds (fld,ord) values ('LAT_MIN',26);
insert into temp_getMakeCE_flds (fld,ord) values ('LAT_SEC',27);
insert into temp_getMakeCE_flds (fld,ord) values ('LAT_DIR',28);
insert into temp_getMakeCE_flds (fld,ord) values ('LONG_DEG',29);
insert into temp_getMakeCE_flds (fld,ord) values ('LONG_MIN',30);
insert into temp_getMakeCE_flds (fld,ord) values ('LONG_SEC',31);
insert into temp_getMakeCE_flds (fld,ord) values ('LONG_DIR',32);
insert into temp_getMakeCE_flds (fld,ord) values ('DEC_LAT_MIN',33);
insert into temp_getMakeCE_flds (fld,ord) values ('DEC_LONG_MIN',34);
insert into temp_getMakeCE_flds (fld,ord) values ('UTM_ZONE',35);
insert into temp_getMakeCE_flds (fld,ord) values ('UTM_EW',36);
insert into temp_getMakeCE_flds (fld,ord) values ('UTM_NS',37);
insert into temp_getMakeCE_flds (fld,ord) values ('WKT_POLYGON',38);

insert into temp_getMakeCE_flds (fld,ord) values ('LOCALITY_REMARKS',39);

insert into temp_getMakeCE_flds (fld,ord) values ('HIGHER_GEOG',40);

insert into temp_getMakeCE_flds (fld,ord) values ('geology_attribute_1',41);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_value_1',42);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_date_1',43);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determiner_1',44);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_method_1',45);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_remark_1',46);



insert into temp_getMakeCE_flds (fld,ord) values ('geology_attribute_2',47);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_value_2',48);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_date_2',49);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determiner_2',50);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_method_2',51);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_remark_2',52);


insert into temp_getMakeCE_flds (fld,ord) values ('geology_attribute_3',53);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_value_3',54);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_date_3',55);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determiner_3',56);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_method_3',57);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_remark_3',58);


insert into temp_getMakeCE_flds (fld,ord) values ('geology_attribute_4',59);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_value_4',60);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_date_4',61);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determiner_4',62);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_method_4',63);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_remark_4',64);


insert into temp_getMakeCE_flds (fld,ord) values ('geology_attribute_5',65);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_value_5',66);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_date_5',67);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determiner_5',68);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_method_5',69);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_remark_5',70);


insert into temp_getMakeCE_flds (fld,ord) values ('geology_attribute_6',71);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_value_6',72);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_date_6',73);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determiner_6',74);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_determined_method_6',75);
insert into temp_getMakeCE_flds (fld,ord) values ('geo_att_remark_6',76);




update temp_getMakeCE_flds set blfld=fld;

update temp_getMakeCE_flds set blfld='LATDEG' where fld='LAT_DEG';
update temp_getMakeCE_flds set blfld='LATMIN' where fld='LAT_MIN';
update temp_getMakeCE_flds set blfld='LATSEC' where fld='LAT_SEC';
update temp_getMakeCE_flds set blfld='LATDIR' where fld='LAT_DIR';
update temp_getMakeCE_flds set blfld='LONGDEG' where fld='LONG_DEG';
update temp_getMakeCE_flds set blfld='LONGMIN' where fld='LONG_MIN';
update temp_getMakeCE_flds set blfld='LONGSEC' where fld='LONG_SEC';
update temp_getMakeCE_flds set blfld='LONGDIR' where fld='LONG_DIR';





CREATE OR REPLACE procedure getMakeCollectingEvent (
	/*
		IMPORTANT: This procedure requires properly-typed variable. 
		Failing to pre-sanitize variables will produce cryptic errors.
		Passing in "Sept. 29, 1964" as an Attribute Date will for example throw 
			ORA-01841: (full) year must be between -4713 and +9999, and not be 0

	*/
	v_COLLECTING_EVENT_ID in collecting_event.collecting_event_id%type  default null,
 	v_COLLECTING_EVENT_NAME in collecting_event.COLLECTING_EVENT_NAME%type default null,
	v_VERBATIM_DATE in collecting_event.VERBATIM_DATE%type default null,
 	v_BEGAN_DATE in collecting_event.BEGAN_DATE%type default null,
 	v_ENDED_DATE in collecting_event.ENDED_DATE%type default null,
 	v_VERBATIM_LOCALITY in collecting_event.VERBATIM_LOCALITY%type default null,
 	v_COLL_EVENT_REMARKS in collecting_event.COLL_EVENT_REMARKS%type default null,
	v_LOCALITY_ID in collecting_event.locality_id%type default null,
	v_LOCALITY_NAME in locality.LOCALITY_NAME%type default null,
 	v_SPEC_LOCALITY in locality.SPEC_LOCALITY%type default null,
	v_ORIG_ELEV_UNITS in locality.ORIG_ELEV_UNITS%type default null,
	v_MINIMUM_ELEVATION in locality.MINIMUM_ELEVATION%type default null,
 	v_MAXIMUM_ELEVATION in locality.MAXIMUM_ELEVATION%type default null,
	v_DEPTH_UNITS in locality.DEPTH_UNITS%type default null,
	v_MIN_DEPTH in locality.MIN_DEPTH%type default null,
	v_MAX_DEPTH in locality.MAX_DEPTH%type default null,
 	v_ORIG_LAT_LONG_UNITS in collecting_event.ORIG_LAT_LONG_UNITS%type default null,
	v_DATUM in collecting_event.DATUM%type default null,
	v_GEOREFERENCE_SOURCE in locality.GEOREFERENCE_SOURCE%type default null,
	v_GEOREFERENCE_PROTOCOL in locality.GEOREFERENCE_PROTOCOL%type default null,
	v_MAX_ERROR_UNITS in locality.MAX_ERROR_UNITS%type default null,
 	v_MAX_ERROR_DISTANCE in locality.MAX_ERROR_DISTANCE%type default null,
 	v_DEC_LAT in collecting_event.DEC_LAT%type default null,
 	v_DEC_LONG in collecting_event.DEC_LONG%type default null,
 	v_LAT_DEG in collecting_event.LAT_DEG%type default null,
 	v_LAT_MIN in collecting_event.LAT_MIN%type default null,
 	v_LAT_SEC in collecting_event.LAT_SEC%type default null,
 	v_LAT_DIR in collecting_event.LAT_DIR%type default null,
 	v_LONG_DEG in collecting_event.LONG_DEG%type default null,
 	v_LONG_MIN in collecting_event.LONG_MIN%type default null,
 	v_LONG_SEC in collecting_event.LONG_SEC%type default null,
 	v_LONG_DIR in collecting_event.LONG_DIR%type default null,
 	v_DEC_LAT_MIN in collecting_event.DEC_LAT_MIN%type default null,
 	v_DEC_LONG_MIN in collecting_event.DEC_LONG_MIN%type default null,
 	v_UTM_ZONE in collecting_event.UTM_ZONE%type default null,
 	v_UTM_EW in collecting_event.UTM_EW%type default null,
 	v_UTM_NS in collecting_event.UTM_NS%type default null,
	v_WKT_POLYGON in locality.WKT_POLYGON%type default null,
 	
 	
 	
	v_LOCALITY_REMARKS in locality.LOCALITY_REMARKS%type default null,
    v_HIGHER_GEOG geog_auth_rec.HIGHER_GEOG%TYPE default null,
    v_geology_attribute_1 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_1  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_1  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_1  agent_name.agent_name%type default null,
    v_geo_att_determined_method_1  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_1  geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_2 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_2  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_2  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_2  agent_name.agent_name%type default null,
    v_geo_att_determined_method_2  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_2  geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_3 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_3  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_3  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_3  agent_name.agent_name%type default null,
    v_geo_att_determined_method_3  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_3 geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_4 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_4  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_4  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_4  agent_name.agent_name%type default null,
    v_geo_att_determined_method_4  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_4  geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_5 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_5  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_5  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_5  agent_name.agent_name%type default null,
    v_geo_att_determined_method_5  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_5 geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_6 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_6  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_6  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_6  agent_name.agent_name%type default null,
    v_geo_att_determined_method_6  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_6  geology_attributes.GEO_ATT_REMARK%type default null,            
    v_r_ceid out number
 ) 
	is
		error_msg varchar2(4000);
		n number;
		l_locality_id number;
		l_geog_auth_rec_id number;
		l_dec_lat number;
		l_dec_long number;
		v_cc_geo_attrs varchar2(4000);
		l_verbatim_coordinates varchar2(4000);

	BEGIN

		--dbms_output.put_line('here we go now');
		-- user-supplied event ID - check it and return
		IF v_collecting_event_id IS NOT NULL THEN
	         select 
	            count(*) into n
	        from
	            collecting_event 
	        where 
	            collecting_event_id=v_collecting_event_id;
	        if n=1 then
	            v_r_ceid := v_collecting_event_id;
	            --dbms_output.put_line('got gcollecting_event_id @ user picked event ID: ' || gcollecting_event_id);
	            return;
	        else
	            error_msg := 'Bad collecting_event_id';
				raise_application_error( -20001, error_msg );
	        end if;
	    END IF;
	    -- user-supplied event name - check it and return
		IF v_COLLECTING_EVENT_NAME IS NOT NULL THEN
	         select 
	            count(*) into n
	        from
	            collecting_event 
	        where 
	            COLLECTING_EVENT_NAME=v_COLLECTING_EVENT_NAME;
	        if n=1 then
		        select 
		            collecting_event_id 
		        into
		        	v_r_ceid
		        from
		            collecting_event 
		        where 
		            COLLECTING_EVENT_NAME=v_COLLECTING_EVENT_NAME;
	            return;
	        else
	            error_msg := 'Bad COLLECTING_EVENT_NAME';
				raise_application_error( -20001, error_msg );
	        end if;
	    END IF;
	   
	    -- no collecting event specified, we need to get or make a locality_id
		IF v_locality_id IS NOT NULL THEN
	        select 
	            count(*) into n
	        from
	            locality
	        where 
	            locality_id=v_locality_id;
	        if n=1 then
	            l_locality_id := v_locality_id;
	        else
	            error_msg := 'Bad locality_id';
				raise_application_error( -20001, error_msg );
	        end if;
	    END IF;
    	-- try with locality name
    	IF v_LOCALITY_NAME IS NOT NULL THEN
    		--dbms_output.put_line('v_LOCALITY_NAME: ' ||  v_LOCALITY_NAME);
    		 select 
	            count(*) into n
	        from
	            locality
	        where 
	            LOCALITY_NAME=v_LOCALITY_NAME;
	        if n=1 then
	        	select 
		            locality_id into l_locality_id
		        from
		            locality 
		        where 
		            LOCALITY_NAME=v_LOCALITY_NAME;
		    else
		    	error_msg := 'Bad LOCALITY_NAME';
				raise_application_error( -20001, error_msg );
			end if;
		end if;
		
		
		
		-- if we don't yet have a locality_id we'll need to find one using locality data, or make one
		if l_locality_id is null then
			-- first check geography, which is required if we make it to here
			--dbms_output.put_line('v_higher_geog: ' || v_higher_geog);

			BEGIN
        		select geog_auth_rec_id into l_geog_auth_rec_id from geog_auth_rec where higher_geog = v_higher_geog;
        	EXCEPTION when no_data_found then
	            error_msg := 'Bad HIGHER_GEOG';
				raise_application_error( -20001, error_msg );
	        END;
        	-- now we have a geog_auth_rec_id, get geology attributes into a comparable form
        	
	        
        	if v_geology_attribute_1 is not null or v_geology_attribute_2 is not null or v_geology_attribute_3 is not null or
				v_geology_attribute_4 is not null or v_geology_attribute_5 is not null or v_geology_attribute_6 is not null then
				-- grab a temp key
				select somerandomsequence.nextval into n from dual;
				if v_geology_attribute_1 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_1,
						v_geo_att_value_1,
						v_geo_att_determined_date_1,
						v_geo_att_determined_method_1,
						v_geo_att_remark_1,
						v_geo_att_determiner_1,
						n
					);
				end if;
				if v_geology_attribute_2 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_2,
						v_geo_att_value_2,
						v_geo_att_determined_date_2,
						v_geo_att_determined_method_2,
						v_geo_att_remark_2,
						v_geo_att_determiner_2,
						n
					);
				end if;
				if v_geology_attribute_3 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_3,
						v_geo_att_value_3,
						v_geo_att_determined_date_3,
						v_geo_att_determined_method_3,
						v_geo_att_remark_3,
						v_geo_att_determiner_3,
						n
					);
				end if;
				if v_geology_attribute_4 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_4,
						v_geo_att_value_4,
						v_geo_att_determined_date_4,
						v_geo_att_determined_method_4,
						v_geo_att_remark_4,
						v_geo_att_determiner_4,
						n
					);
				end if;
				if v_geology_attribute_5 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_5,
						v_geo_att_value_5,
						v_geo_att_determined_date_5,
						v_geo_att_determined_method_5,
						v_geo_att_remark_5,
						v_geo_att_determiner_5,
						n
					);
				end if;
				if v_geology_attribute_6 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_6,
						v_geo_att_value_6,
						v_geo_att_determined_date_6,
						v_geo_att_determined_method_6,
						v_geo_att_remark_6,
						v_geo_att_determiner_6,
						n
					);
				end if;
				select bl_concatGeoAttDetail(n) into v_cc_geo_attrs from dual;
			end if;
	        -- /geology attributes

			
	       -- have everything we need to go looking for a locality
	        IF v_orig_lat_long_units IS NULL THEN
	            select 
	                min(locality.locality_id)
	            INTO
	                l_locality_Id
	            FROM 
	                locality
	            WHERE
	                geog_auth_rec_id = l_geog_auth_rec_id AND
	                NVL(MAXIMUM_ELEVATION,-1) = NVL(v_maximum_elevation,-1) AND
	                NVL(MINIMUM_ELEVATION,-1) = NVL(v_minimum_elevation,-1) AND
	                NVL(ORIG_ELEV_UNITS,'NULL') = NVL(v_orig_elev_units,'NULL') AND
	                NVL(MIN_DEPTH,-1) = nvl(v_min_depth,-1) AND
	                NVL(MAX_DEPTH,-1) = nvl(v_max_depth,-1) AND
	                NVL(SPEC_LOCALITY,'NULL') = NVL(v_spec_locality,'NULL') AND
	                NVL(LOCALITY_REMARKS,'NULL') = NVL(v_locality_remarks,'NULL') AND
	                NVL(DEPTH_UNITS,'NULL') = NVL(v_depth_units,'NULL') AND
	                dec_lat IS NULL AND -- because we didnt get event coordinates - assume for other coordinate info
	                locality_name IS NULL AND -- because we tested that above and will use it if it exists
	                nvl(concatGeologyAttributeDetail(locality.locality_id),'NULL') = nvl(v_cc_geo_attrs,'NULL') and
	                dbms_lob.compare(nvl(v_WKT_POLYGON,'Null'),nvl(WKT_POLYGON,'Null'))=0;
	        ELSE
	        -- we did get coordinates
	        	-- convert them to decimal
	        	if v_orig_lat_long_units = 'UTM' then
	        		-- we cannot convert UTM so...??? 
	        		error_msg := 'UTM cannot be converted';
					raise_application_error( -20001, error_msg );
					l_verbatim_coordinates := utm_to_string (v_UTM_NS,v_UTM_EW,v_UTM_ZONE);
	        	elsif v_orig_lat_long_units = 'decimal degrees' then
	        		l_dec_lat := v_dec_lat;
					l_dec_long := v_dec_long;
					l_verbatim_coordinates := dd_to_string (v_DEC_LAT,v_DEC_LONG);
	        	elsif v_orig_lat_long_units = 'degrees dec. minutes' then
	        		l_dec_lat := v_dec_lat + (v_dec_lat_min / 60);
			        if v_lat_dir = 'S' THEN
			        	l_dec_lat := l_dec_lat * -1;
			        end if;
			        l_dec_long := v_long_deg + (v_dec_long_min / 60);
			        IF v_long_dir = 'W' THEN
			        	l_dec_long := l_dec_long * -1;
			        END IF;
			        l_verbatim_coordinates := dm_to_string (v_LAT_DEG, v_dec_lat_min,v_LAT_DIR, v_LONG_DEG, v_dec_long_min,v_LONG_DIR);
	        	elsif v_orig_lat_long_units = 'deg. min. sec.' then
	        		l_dec_lat := v_lat_deg + (v_lat_min / 60) + (nvl(v_lat_sec,0) / 3600);
		            IF v_lat_dir = 'S' THEN
		                l_dec_lat := l_dec_lat * -1;
		            END IF;
		            l_dec_long := v_long_deg + (v_long_min / 60) + (nvl(v_long_sec,0) / 3600);
		            IF v_long_dir = 'W' THEN
		                l_dec_long := l_dec_long * -1;
		            END IF;
  		            l_verbatim_coordinates := dms_to_string (v_LAT_DEG,v_LAT_MIN,v_LAT_SEC, v_LAT_DIR,v_LONG_DEG,v_LONG_MIN,v_LONG_SEC,v_LONG_DIR);
		        else
		        	error_msg := 'Lat long units not recognized';
					raise_application_error( -20001, error_msg );
				end if;
				
       
				-- now we should have decimal coordinates, look for a locality
	           select 
	                min(locality.locality_id)
	            INTO
	                l_locality_id
	            FROM 
	                locality
	            WHERE
	                geog_auth_rec_id = l_geog_auth_rec_id AND
	                NVL(MAXIMUM_ELEVATION,-1) = NVL(v_maximum_elevation,-1) AND
	                NVL(MINIMUM_ELEVATION,-1) = NVL(v_minimum_elevation,-1) AND
	                NVL(ORIG_ELEV_UNITS,'NULL') = NVL(v_orig_elev_units,'NULL') AND
	                NVL(MIN_DEPTH,-1) = nvl(v_min_depth,-1) AND
	                NVL(MAX_DEPTH,-1) = nvl(v_max_depth,-1) AND
	                NVL(DEPTH_UNITS,'NULL') = NVL(v_depth_units,'NULL') AND
	                NVL(SPEC_LOCALITY,'NULL') = NVL(v_spec_locality,'NULL') AND
	                NVL(LOCALITY_REMARKS,'NULL') = NVL(v_locality_remarks,'NULL') AND
	                NVL(MAX_ERROR_UNITS,'NULL') = NVL(v_MAX_ERROR_UNITS,'NULL') AND
	                NVL(DATUM,'NULL') = NVL(v_DATUM,'NULL') AND
	                NVL(georeference_source,'NULL') = NVL(v_georeference_source,'NULL') AND
	                NVL(georeference_protocol,'NULL') = NVL(v_georeference_protocol,'NULL') AND
	                NVL(DEC_LAT,999) = nvl(l_dec_lat,999) AND
	                NVL(DEC_LONG,999) = nvl(l_dec_long,999) AND
	                NVL(MAX_ERROR_DISTANCE,-1) = nvl(v_MAX_ERROR_DISTANCE,-1) AND
	                locality_name IS NULL AND -- because we tested that above and will use it if it exists
	                nvl(concatGeologyAttributeDetail(locality.locality_id),'NULL') = nvl(v_cc_geo_attrs,'NULL') and
	                dbms_lob.compare(nvl(v_WKT_POLYGON,'Null'),nvl(WKT_POLYGON,'Null'))=0;
        	END IF;
        	-- now we should have a locality_id if a good one exists
        	-- if not, make one
        	
        
	        if l_locality_id is null then
	            -- did not find a locality, so make one
	            select sq_locality_id.nextval into l_locality_id from dual;
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
	                 DEC_LAT,
	                 DEC_LONG,
	                 MAX_ERROR_DISTANCE,
	                 MAX_ERROR_UNITS,
	                 DATUM,
	                 georeference_source,
	                 georeference_protocol,
	                 wkt_polygon
	            ) values (
	                l_locality_id,
	                l_geog_auth_rec_id,
	                v_MAXIMUM_ELEVATION,
	                v_MINIMUM_ELEVATION,
	                v_ORIG_ELEV_UNITS,
	                v_SPEC_LOCALITY,
	                v_LOCALITY_REMARKS,
	                v_DEPTH_UNITS,
	                v_MIN_DEPTH,
	                v_MAX_DEPTH,
	                l_dec_lat,
	                l_dec_long,
	                v_MAX_ERROR_DISTANCE,
	                v_MAX_ERROR_UNITS,
	                v_DATUM,
	                v_georeference_source,
	                v_georeference_protocol,
	                v_wkt_polygon
	            );
           	 --dbms_output.put_line('made a locality');
             -- grab any cached geology data 
	            for i IN (select * from bl_geology_attributes where key=n) LOOP
	            	 insert into geology_attributes (
	                        locality_id,
	                        geology_attribute,
	                        geo_att_value,
	                        geo_att_determiner_id,
	                        geo_att_determined_date,
	                        geo_att_determined_method,
	                        geo_att_remark
	                    ) values (
	                        l_locality_Id,
	                        i.GEOLOGY_ATTRIBUTE,
	                        i.GEO_ATT_VALUE,
	                        getAgentId(i.DETERMINER),
	                        i.GEO_ATT_DETERMINED_DATE,
	                        i.GEO_ATT_DETERMINED_METHOD,
	                        i.GEO_ATT_REMARK
	                    );
	            	--dbms_output.put_line('making geology');
	            end loop;
	            
	    	end if;-- end make locality
	    end if; -- end check locality_id - we should have locality one way or another now
	    -- find or create the event
	    
	    
	    select 
    	    MIN(collecting_event_id) into v_r_ceid 
    	from
    	    collecting_event 
    	where
    	    locality_id = l_locality_Id and
    	    nvl(verbatim_date,'NULL') = nvl(v_verbatim_date,'NULL') and
    	    nvl(VERBATIM_LOCALITY,'NULL') = nvl(v_VERBATIM_LOCALITY,'NULL') and
    	    nvl(COLL_EVENT_REMARKS,'NULL') = nvl(v_COLL_EVENT_REMARKS,'NULL') and
    	    nvl(began_date,'NULL') = nvl(v_began_date,'NULL') and
    	    nvl(ended_date,'NULL') = nvl(v_ended_date,'NULL') and
    	    COLLECTING_EVENT_NAME IS NULL AND -- or we'd have found it at that check
    	    nvl(verbatim_coordinates,'NULL') = nvl(l_verbatim_coordinates,'NULL') and
    	    nvl(DATUM,'NULL') = nvl(v_DATUM,'NULL') and
    	    nvl(ORIG_LAT_LONG_UNITS,'NULL') = nvl(v_ORIG_LAT_LONG_UNITS,'NULL')
    	;
        if 	v_r_ceid is not null then
            -- found a suitable event
            
           --dbms_output.put_line('got gcollecting_event_id @ found event: ' || gcollecting_event_id);
            return;        	
        end if;
        
        
         --dbms_output.put_line('DID NOT got gcollecting_event_id @ found event: or return failed');

                    
                    
                    
        -- if we're still here, we need to make an event   
   		select sq_collecting_event_id.nextval into v_r_ceid from dual;
		insert into collecting_event (
			collecting_event_id,
			locality_id,
			verbatim_date,
			VERBATIM_LOCALITY,
			began_date,
			ended_date,
			coll_event_remarks,
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
		) values (
			v_r_ceid,
			l_locality_Id,
			v_verbatim_date,
			v_VERBATIM_LOCALITY,
			v_began_date,			
			v_ended_date,
			v_coll_event_remarks,
			v_LAT_DEG,
			v_DEC_LAT_MIN,
			v_LAT_MIN,
			v_LAT_SEC,
			v_LAT_DIR,
			v_LONG_DEG,
			v_DEC_LONG_MIN,
			v_LONG_MIN,
			v_LONG_SEC,
			v_LONG_DIR,
			v_DEC_LAT,
			v_DEC_LONG,
			v_DATUM,
			v_UTM_ZONE,
			v_UTM_EW,
			v_UTM_NS,
			v_ORIG_LAT_LONG_UNITS
		);
		
		
		
	    
    	--dbms_output.put_line('localityID: ' || l_locality_Id);
    	--dbms_output.put_line('v_r_ceid: ' || v_r_ceid);
	end;
/
sho err;






update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';
update temp_getMakeCE_flds set blfld='xxxxxxxx' where fld='xxxxxxxx';

			v_DEC_LONG_MIN => r.DEC_LONG_MIN,
			v_ => r.,
			v_ => r.,
			v_ => r.,
			v_DEC_LAT => r.DEC_LAT,
			v_DEC_LONG => r.DEC_LONG,
			v_DATUM => r.DATUM,
			v_UTM_ZONE => r.UTM_ZONE,
			v_UTM_EW => r.UTM_EW,
			v_UTM_NS => r.UTM_NS,
			v_ORIG_LAT_LONG_UNITS => r.ORIG_LAT_LONG_UNITS,
			v_SPEC_LOCALITY => r.SPEC_LOCALITY,
			v_MINIMUM_ELEVATION => r.MINIMUM_ELEVATION,
			v_MAXIMUM_ELEVATION => r.MAXIMUM_ELEVATION,
			v_ORIG_ELEV_UNITS => r.ORIG_ELEV_UNITS,
			v_MIN_DEPTH => r.MIN_DEPTH,
			v_MAX_DEPTH => r.MAX_DEPTH,
			v_DEPTH_UNITS => r.DEPTH_UNITS,
			v_MAX_ERROR_DISTANCE => r.MAX_ERROR_DISTANCE,
			v_MAX_ERROR_UNITS => r.MAX_ERROR_UNITS,
			v_LOCALITY_REMARKS => r.LOCALITY_REMARKS,
			v_GEOREFERENCE_SOURCE => r.GEOREFERENCE_SOURCE,
			v_GEOREFERENCE_PROTOCOL => r.GEOREFERENCE_PROTOCOL,
			v_LOCALITY_NAME => r.LOCALITY_NAME,
			v_WKT_POLYGON => r.WKT_POLYGON,
			v_HIGHER_GEOG => r.HIGHER_GEOG,
			v_geology_attribute_1 => r.geology_attribute_1,
			v_geo_att_value_1 => r.geo_att_value_1,
			v_geo_att_determined_date_1 => r.geo_att_determined_date_1,
			v_geo_att_determiner_1 => r.geo_att_determiner_1,
			v_geo_att_determined_method_1 => r.geo_att_determined_method_1,
			v_geo_att_remark_1 => r.geo_att_remark_1,
			v_geology_attribute_2 => r.geology_attribute_2,
			v_geo_att_value_2 => r.geo_att_value_2,
			v_geo_att_determined_date_2 => r.geo_att_determined_date_2,
			v_geo_att_determiner_2 => r.geo_att_determiner_2,
			v_geo_att_determined_method_2 => r.geo_att_determined_method_2,
			v_geo_att_remark_2 => r.geo_att_remark_2,
			v_geology_attribute_3 => r.geology_attribute_3,
			v_geo_att_value_3 => r.geo_att_value_3,
			v_geo_att_determined_date_3 => r.geo_att_determined_date_3,
			v_geo_att_determiner_3 => r.geo_att_determiner_3,
			v_geo_att_determined_method_3 => r.geo_att_determined_method_3,
			v_geo_att_remark_3 => r.geo_att_remark_3,
			v_geology_attribute_4 => r.geology_attribute_4,
			v_geo_att_value_4 => r.geo_att_value_4,
			v_geo_att_determined_date_4 => r.geo_att_determined_date_4,
			v_geo_att_determiner_4 => r.geo_att_determiner_4,
			v_geo_att_determined_method_4 => r.geo_att_determined_method_4,
			v_geo_att_remark_4 => r.geo_att_remark_4,
			v_geology_attribute_5 => r.geology_attribute_5,
			v_geo_att_value_5 => r.geo_att_value_5,
			v_geo_att_determined_date_5 => r.geo_att_determined_date_5,
			v_geo_att_determiner_5 => r.geo_att_determiner_5,
			v_geo_att_determined_method_5 => r.geo_att_determined_method_5,
			v_geo_att_remark_5 => r.geo_att_remark_5,
			v_geology_attribute_6 => r.geology_attribute_6,
			v_geo_att_value_6 => r.geo_att_value_6,
			v_geo_att_determined_date_6 => r.geo_att_determined_date_6,
			v_geo_att_determiner_6 => r.geo_att_determiner_6,
			v_geo_att_determined_method_6 => r.geo_att_determined_method_6,
			v_geo_att_remark_6 => r.geo_att_remark_6,
			v_r_ceid=>myvar




-- oldcrap follows












CREATE OR REPLACE procedure getMakeCollectingEvent (
	v_COLLECTING_EVENT_ID in collecting_event.collecting_event_id%type  default null,
	v_LOCALITY_ID in collecting_event.locality_id%type default null,
	v_VERBATIM_DATE in collecting_event.VERBATIM_DATE%type default null,
 	v_VERBATIM_LOCALITY in collecting_event.VERBATIM_LOCALITY%type default null,
 	v_COLL_EVENT_REMARKS in collecting_event.COLL_EVENT_REMARKS%type default null,
 	v_BEGAN_DATE in collecting_event.BEGAN_DATE%type default null,
 	v_ENDED_DATE in collecting_event.ENDED_DATE%type default null,
 	v_COLLECTING_EVENT_NAME in collecting_event.COLLECTING_EVENT_NAME%type default null,
 	v_LAT_DEG in collecting_event.LAT_DEG%type default null,
 	v_DEC_LAT_MIN in collecting_event.DEC_LAT_MIN%type default null,
 	v_LAT_MIN in collecting_event.LAT_MIN%type default null,
 	v_LAT_SEC in collecting_event.LAT_SEC%type default null,
 	v_LAT_DIR in collecting_event.LAT_DIR%type default null,
 	v_LONG_DEG in collecting_event.LONG_DEG%type default null,
 	v_DEC_LONG_MIN in collecting_event.DEC_LONG_MIN%type default null,
 	v_LONG_MIN in collecting_event.LONG_MIN%type default null,
 	v_LONG_SEC in collecting_event.LONG_SEC%type default null,
 	v_LONG_DIR in collecting_event.LONG_DIR%type default null,
 	v_DEC_LAT in collecting_event.DEC_LAT%type default null,
 	v_DEC_LONG in collecting_event.DEC_LONG%type default null,
	v_DATUM in collecting_event.DATUM%type default null,
 	v_UTM_ZONE in collecting_event.UTM_ZONE%type default null,
 	v_UTM_EW in collecting_event.UTM_EW%type default null,
 	v_UTM_NS in collecting_event.UTM_NS%type default null,
 	v_ORIG_LAT_LONG_UNITS in collecting_event.ORIG_LAT_LONG_UNITS%type default null,
 	v_SPEC_LOCALITY in locality.SPEC_LOCALITY%type default null,
	v_MINIMUM_ELEVATION in locality.MINIMUM_ELEVATION%type default null,
 	v_MAXIMUM_ELEVATION in locality.MAXIMUM_ELEVATION%type default null,
	v_ORIG_ELEV_UNITS in locality.ORIG_ELEV_UNITS%type default null,
	v_MIN_DEPTH in locality.MIN_DEPTH%type default null,
	v_MAX_DEPTH in locality.MAX_DEPTH%type default null,
	v_DEPTH_UNITS in locality.DEPTH_UNITS%type default null,
 	v_MAX_ERROR_DISTANCE in locality.MAX_ERROR_DISTANCE%type default null,
	v_MAX_ERROR_UNITS in locality.MAX_ERROR_UNITS%type default null,
	v_LOCALITY_REMARKS in locality.LOCALITY_REMARKS%type default null,
	v_GEOREFERENCE_SOURCE in locality.GEOREFERENCE_SOURCE%type default null,
	v_GEOREFERENCE_PROTOCOL in locality.GEOREFERENCE_PROTOCOL%type default null,
	v_LOCALITY_NAME in locality.LOCALITY_NAME%type default null,
	v_WKT_POLYGON in locality.WKT_POLYGON%type default null,
    v_HIGHER_GEOG geog_auth_rec.HIGHER_GEOG%TYPE default null,
    v_geology_attribute_1 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_1  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_1  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_1  agent_name.agent_name%type default null,
    v_geo_att_determined_method_1  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_1  geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_2 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_2  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_2  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_2  agent_name.agent_name%type default null,
    v_geo_att_determined_method_2  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_2  geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_3 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_3  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_3  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_3  agent_name.agent_name%type default null,
    v_geo_att_determined_method_3  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_3 geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_4 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_4  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_4  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_4  agent_name.agent_name%type default null,
    v_geo_att_determined_method_4  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_4  geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_5 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_5  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_5  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_5  agent_name.agent_name%type default null,
    v_geo_att_determined_method_5  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_5 geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_6 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_6  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_6  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_6  agent_name.agent_name%type default null,
    v_geo_att_determined_method_6  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_6  geology_attributes.GEO_ATT_REMARK%type default null,            
    v_r_ceid out number
 ) 
	is
		error_msg varchar2(4000);
		n number;
		l_locality_id number;
		l_geog_auth_rec_id number;
		l_dec_lat number;
		l_dec_long number;
		v_cc_geo_attrs varchar2(4000);
		l_verbatim_coordinates varchar2(4000);

	BEGIN
		-- user-supplied event ID - check it and return
		IF v_collecting_event_id IS NOT NULL THEN
	         select 
	            count(*) into n
	        from
	            collecting_event 
	        where 
	            collecting_event_id=v_collecting_event_id;
	        if n=1 then
	            v_r_ceid := v_collecting_event_id;
	            --dbms_output.put_line('got gcollecting_event_id @ user picked event ID: ' || gcollecting_event_id);
	            return;
	        else
	            error_msg := 'Bad collecting_event_id';
				raise_application_error( -20001, error_msg );
	        end if;
	    END IF;
	    -- user-supplied event name - check it and return
		IF v_COLLECTING_EVENT_NAME IS NOT NULL THEN
	         select 
	            count(*) into n
	        from
	            collecting_event 
	        where 
	            COLLECTING_EVENT_NAME=v_COLLECTING_EVENT_NAME;
	        if n=1 then
		        select 
		            collecting_event_id 
		        into
		        	v_r_ceid
		        from
		            collecting_event 
		        where 
		            COLLECTING_EVENT_NAME=v_COLLECTING_EVENT_NAME;
	            return;
	        else
	            error_msg := 'Bad COLLECTING_EVENT_NAME';
				raise_application_error( -20001, error_msg );
	        end if;
	    END IF;
	   
	    -- no collecting event specified, we need to get or make a locality_id
		IF v_locality_id IS NOT NULL THEN
	        select 
	            count(*) into n
	        from
	            locality
	        where 
	            locality_id=v_locality_id;
	        if n=1 then
	            l_locality_id := v_locality_id;
	        else
	            error_msg := 'Bad locality_id';
				raise_application_error( -20001, error_msg );
	        end if;
	    END IF;
    	-- try with locality name
    	IF v_LOCALITY_NAME IS NOT NULL THEN
    		dbms_output.put_line('v_LOCALITY_NAME: ' ||  v_LOCALITY_NAME);
    		 select 
	            count(*) into n
	        from
	            locality
	        where 
	            LOCALITY_NAME=v_LOCALITY_NAME;
	        if n=1 then
	        	select 
		            locality_id into l_locality_id
		        from
		            locality 
		        where 
		            LOCALITY_NAME=v_LOCALITY_NAME;
		    else
		    	error_msg := 'Bad LOCALITY_NAME';
				raise_application_error( -20001, error_msg );
			end if;
		end if;
		
		
		
		-- if we don't yet have a locality_id we'll need to find one using locality data, or make one
		if l_locality_id is null then
			-- first check geography, which is required if we make it to here
			dbms_output.put_line('v_higher_geog: ' || v_higher_geog);
        	select geog_auth_rec_id into l_geog_auth_rec_id from geog_auth_rec where higher_geog = v_higher_geog;
	         if l_geog_auth_rec_id is null then
	            error_msg := 'Bad HIGHER_GEOG';
				raise_application_error( -20001, error_msg );
	        end if;
        	-- now we have a geog_auth_rec_id, get geology attributes into a comparable form
        	
	        
        	if v_geology_attribute_1 is not null or v_geology_attribute_2 is not null or v_geology_attribute_3 is not null or
				v_geology_attribute_4 is not null or v_geology_attribute_5 is not null or v_geology_attribute_6 is not null then
				-- grab a temp key
				select somerandomsequence.nextval into n from dual;
				if v_geology_attribute_1 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_1,
						v_geo_att_value_1,
						v_geo_att_determined_date_1,
						v_geo_att_determined_method_1,
						v_geo_att_remark_1,
						v_geo_att_determiner_1,
						n
					);
				end if;
				if v_geology_attribute_2 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_2,
						v_geo_att_value_2,
						v_geo_att_determined_date_2,
						v_geo_att_determined_method_2,
						v_geo_att_remark_2,
						v_geo_att_determiner_2,
						n
					);
				end if;
				if v_geology_attribute_3 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_3,
						v_geo_att_value_3,
						v_geo_att_determined_date_3,
						v_geo_att_determined_method_3,
						v_geo_att_remark_3,
						v_geo_att_determiner_3,
						n
					);
				end if;
				if v_geology_attribute_4 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_4,
						v_geo_att_value_4,
						v_geo_att_determined_date_4,
						v_geo_att_determined_method_4,
						v_geo_att_remark_4,
						v_geo_att_determiner_4,
						n
					);
				end if;
				if v_geology_attribute_5 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_5,
						v_geo_att_value_5,
						v_geo_att_determined_date_5,
						v_geo_att_determined_method_5,
						v_geo_att_remark_5,
						v_geo_att_determiner_5,
						n
					);
				end if;
				if v_geology_attribute_6 is not null then
					insert into bl_geology_attributes (
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK,
						DETERMINER,
						KEY
					) values (
						v_geology_attribute_6,
						v_geo_att_value_6,
						v_geo_att_determined_date_6,
						v_geo_att_determined_method_6,
						v_geo_att_remark_6,
						v_geo_att_determiner_6,
						n
					);
				end if;
				select bl_concatGeoAttDetail(n) into v_cc_geo_attrs from dual;
			end if;
	        -- /geology attributes

			
	       -- have everything we need to go looking for a locality
	        IF v_orig_lat_long_units IS NULL THEN
	            select 
	                min(locality.locality_id)
	            INTO
	                l_locality_Id
	            FROM 
	                locality
	            WHERE
	                geog_auth_rec_id = l_geog_auth_rec_id AND
	                NVL(MAXIMUM_ELEVATION,-1) = NVL(v_maximum_elevation,-1) AND
	                NVL(MINIMUM_ELEVATION,-1) = NVL(v_minimum_elevation,-1) AND
	                NVL(ORIG_ELEV_UNITS,'NULL') = NVL(v_orig_elev_units,'NULL') AND
	                NVL(MIN_DEPTH,-1) = nvl(v_min_depth,-1) AND
	                NVL(MAX_DEPTH,-1) = nvl(v_max_depth,-1) AND
	                NVL(SPEC_LOCALITY,'NULL') = NVL(v_spec_locality,'NULL') AND
	                NVL(LOCALITY_REMARKS,'NULL') = NVL(v_locality_remarks,'NULL') AND
	                NVL(DEPTH_UNITS,'NULL') = NVL(v_depth_units,'NULL') AND
	                dec_lat IS NULL AND -- because we didnt get event coordinates - assume for other coordinate info
	                locality_name IS NULL AND -- because we tested that above and will use it if it exists
	                nvl(concatGeologyAttributeDetail(locality.locality_id),'NULL') = nvl(v_cc_geo_attrs,'NULL') and
	                dbms_lob.compare(nvl(v_WKT_POLYGON,'Null'),nvl(WKT_POLYGON,'Null'))=0;
	        ELSE
	        -- we did get coordinates
	        	-- convert them to decimal
	        	if v_orig_lat_long_units = 'UTM' then
	        		-- we cannot convert UTM so...??? 
	        		error_msg := 'UTM cannot be converted';
					raise_application_error( -20001, error_msg );
					l_verbatim_coordinates := utm_to_string (v_UTM_NS,v_UTM_EW,v_UTM_ZONE);
	        	elsif v_orig_lat_long_units = 'decimal degrees' then
	        		l_dec_lat := v_dec_lat;
					l_dec_long := v_dec_long;
					l_verbatim_coordinates := dd_to_string (v_DEC_LAT,v_DEC_LONG);
	        	elsif v_orig_lat_long_units = 'degrees dec. minutes' then
	        		l_dec_lat := v_dec_lat + (v_dec_lat_min / 60);
			        if v_lat_dir = 'S' THEN
			        	l_dec_lat := l_dec_lat * -1;
			        end if;
			        l_dec_long := v_long_deg + (v_dec_long_min / 60);
			        IF v_long_dir = 'W' THEN
			        	l_dec_long := l_dec_long * -1;
			        END IF;
			        l_verbatim_coordinates := dm_to_string (v_LAT_DEG, v_dec_lat_min,v_LAT_DIR, v_LONG_DEG, v_dec_long_min,v_LONG_DIR);
	        	elsif v_orig_lat_long_units = 'deg. min. sec.' then
	        		l_dec_lat := v_lat_deg + (v_lat_min / 60) + (nvl(v_lat_sec,0) / 3600);
		            IF v_lat_dir = 'S' THEN
		                l_dec_lat := l_dec_lat * -1;
		            END IF;
		            l_dec_long := v_long_deg + (v_long_min / 60) + (nvl(v_long_sec,0) / 3600);
		            IF v_long_dir = 'W' THEN
		                l_dec_long := l_dec_long * -1;
		            END IF;
  		            l_verbatim_coordinates := dms_to_string (v_LAT_DEG,v_LAT_MIN,v_LAT_SEC, v_LAT_DIR,v_LONG_DEG,v_LONG_MIN,v_LONG_SEC,v_LONG_DIR);
		        else
		        	error_msg := 'Lat long units not recognized';
					raise_application_error( -20001, error_msg );
				end if;
				
       
				-- now we should have decimal coordinates, look for a locality
	           select 
	                min(locality.locality_id)
	            INTO
	                l_locality_id
	            FROM 
	                locality
	            WHERE
	                geog_auth_rec_id = l_geog_auth_rec_id AND
	                NVL(MAXIMUM_ELEVATION,-1) = NVL(v_maximum_elevation,-1) AND
	                NVL(MINIMUM_ELEVATION,-1) = NVL(v_minimum_elevation,-1) AND
	                NVL(ORIG_ELEV_UNITS,'NULL') = NVL(v_orig_elev_units,'NULL') AND
	                NVL(MIN_DEPTH,-1) = nvl(v_min_depth,-1) AND
	                NVL(MAX_DEPTH,-1) = nvl(v_max_depth,-1) AND
	                NVL(DEPTH_UNITS,'NULL') = NVL(v_depth_units,'NULL') AND
	                NVL(SPEC_LOCALITY,'NULL') = NVL(v_spec_locality,'NULL') AND
	                NVL(LOCALITY_REMARKS,'NULL') = NVL(v_locality_remarks,'NULL') AND
	                NVL(MAX_ERROR_UNITS,'NULL') = NVL(v_MAX_ERROR_UNITS,'NULL') AND
	                NVL(DATUM,'NULL') = NVL(v_DATUM,'NULL') AND
	                NVL(georeference_source,'NULL') = NVL(v_georeference_source,'NULL') AND
	                NVL(georeference_protocol,'NULL') = NVL(v_georeference_protocol,'NULL') AND
	                NVL(DEC_LAT,999) = nvl(l_dec_lat,999) AND
	                NVL(DEC_LONG,999) = nvl(l_dec_long,999) AND
	                NVL(MAX_ERROR_DISTANCE,-1) = nvl(v_MAX_ERROR_DISTANCE,-1) AND
	                locality_name IS NULL AND -- because we tested that above and will use it if it exists
	                nvl(concatGeologyAttributeDetail(locality.locality_id),'NULL') = nvl(v_cc_geo_attrs,'NULL') and
	                dbms_lob.compare(nvl(v_WKT_POLYGON,'Null'),nvl(WKT_POLYGON,'Null'))=0;
        	END IF;
        	-- now we should have a locality_id if a good one exists
        	-- if not, make one
        	
        
	        if l_locality_id is null then
	            -- did not find a locality, so make one
	            -- first verify coordinate data
	            if v_orig_lat_long_units is null then
	            	if 
	            
	            
	            
	            select sq_locality_id.nextval into l_locality_id from dual;
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
	                 DEC_LAT,
	                 DEC_LONG,
	                 MAX_ERROR_DISTANCE,
	                 MAX_ERROR_UNITS,
	                 DATUM,
	                 georeference_source,
	                 georeference_protocol,
	                 wkt_polygon
	            ) values (
	                l_locality_id,
	                l_geog_auth_rec_id,
	                v_MAXIMUM_ELEVATION,
	                v_MINIMUM_ELEVATION,
	                v_ORIG_ELEV_UNITS,
	                v_SPEC_LOCALITY,
	                v_LOCALITY_REMARKS,
	                v_DEPTH_UNITS,
	                v_MIN_DEPTH,
	                v_MAX_DEPTH,
	                l_dec_lat,
	                l_dec_long,
	                v_MAX_ERROR_DISTANCE,
	                v_MAX_ERROR_UNITS,
	                v_DATUM,
	                v_georeference_source,
	                v_georeference_protocol,
	                v_wkt_polygon
	            );
           	 --dbms_output.put_line('made a locality');
             -- grab any cached geology data 
	            for i IN (select * from bl_geology_attributes where key=n) LOOP
	            	 insert into geology_attributes (
	                        locality_id,
	                        geology_attribute,
	                        geo_att_value,
	                        geo_att_determiner_id,
	                        geo_att_determined_date,
	                        geo_att_determined_method,
	                        geo_att_remark
	                    ) values (
	                        l_locality_Id,
	                        i.GEOLOGY_ATTRIBUTE,
	                        i.GEO_ATT_VALUE,
	                        getAgentId(i.DETERMINER),
	                        i.GEO_ATT_DETERMINED_DATE,
	                        i.GEO_ATT_DETERMINED_METHOD,
	                        i.GEO_ATT_REMARK
	                    );
	            	dbms_output.put_line('making geology');
	            end loop;
	            
	    	end if;-- end make locality
	    end if; -- end check locality_id - we should have locality one way or another now
	    -- find or create the event
	    
	    
	    select 
    	    MIN(collecting_event_id) into v_r_ceid 
    	from
    	    collecting_event 
    	where
    	    locality_id = l_locality_Id and
    	    nvl(verbatim_date,'NULL') = nvl(v_verbatim_date,'NULL') and
    	    nvl(VERBATIM_LOCALITY,'NULL') = nvl(v_VERBATIM_LOCALITY,'NULL') and
    	    nvl(COLL_EVENT_REMARKS,'NULL') = nvl(v_COLL_EVENT_REMARKS,'NULL') and
    	    nvl(began_date,'NULL') = nvl(v_began_date,'NULL') and
    	    nvl(ended_date,'NULL') = nvl(v_ended_date,'NULL') and
    	    COLLECTING_EVENT_NAME IS NULL AND -- or we'd have found it at that check
    	    nvl(verbatim_coordinates,'NULL') = nvl(l_verbatim_coordinates,'NULL') and
    	    nvl(DATUM,'NULL') = nvl(v_DATUM,'NULL') and
    	    nvl(ORIG_LAT_LONG_UNITS,'NULL') = nvl(v_ORIG_LAT_LONG_UNITS,'NULL')
    	;
        if 	v_r_ceid is not null then
            -- found a suitable event
            
           --dbms_output.put_line('got gcollecting_event_id @ found event: ' || gcollecting_event_id);
            return;        	
        end if;
        
        
         --dbms_output.put_line('DID NOT got gcollecting_event_id @ found event: or return failed');

                    
                    
                    
        -- if we're still here, we need to make an event   
   		select sq_collecting_event_id.nextval into v_r_ceid from dual;
		insert into collecting_event (
			collecting_event_id,
			locality_id,
			verbatim_date,
			VERBATIM_LOCALITY,
			began_date,
			ended_date,
			coll_event_remarks,
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
		) values (
			v_r_ceid,
			l_locality_Id,
			v_verbatim_date,
			v_VERBATIM_LOCALITY,
			v_began_date,			
			v_ended_date,
			v_coll_event_remarks,
			v_LAT_DEG,
			v_DEC_LAT_MIN,
			v_LAT_MIN,
			v_LAT_SEC,
			v_LAT_DIR,
			v_LONG_DEG,
			v_DEC_LONG_MIN,
			v_LONG_MIN,
			v_LONG_SEC,
			v_LONG_DIR,
			v_DEC_LAT,
			v_DEC_LONG,
			v_DATUM,
			v_UTM_ZONE,
			v_UTM_EW,
			v_UTM_NS,
			v_ORIG_LAT_LONG_UNITS
		);
		
		
		
	    
    	dbms_output.put_line('localityID: ' || l_locality_Id);
    	dbms_output.put_line('v_r_ceid: ' || v_r_ceid);
	end;
/
sho err;

















/*
 * 
 * DEPENDANCIES:
 	- a table to sort geology attributes
 	create table bl_geology_attributes as select * from geology_attributes where 1=2;
 	alter table bl_geology_attributes drop column GEOLOGY_ATTRIBUTE_ID;
 	alter table bl_geology_attributes add determiner varchar2(255) ;
 	alter table bl_geology_attributes drop column GEO_ATT_DETERMINER_ID;
  	alter table bl_geology_attributes drop column LOCALITY_ID;
 	alter table bl_geology_attributes add key number ;
 	alter table bl_geology_attributes modify GEOLOGY_ATTRIBUTE null;
 	alter table bl_geology_attributes modify GEO_ATT_VALUE null;



 */











CREATE OR REPLACE procedure getMakeCollectingEvent (
	v_COLLECTING_EVENT_ID in collecting_event.collecting_event_id%type  default null,  
	blabitty in collecting_event.collecting_event_id%type  default null,  
	v_r_ceid out number
 ) 	is
		error_msg varchar2(4000);
		n number;
		l_locality_id number;
		l_geog_auth_rec_id number;
		l_dec_lat number;
		l_dec_long number;
		v_cc_geo_attrs varchar2(4000);
		l_verbatim_coordinates varchar2(4000);

	BEGIN

v_r_ceid:=42;
end;
/



CREATE OR REPLACE procedure getMakeCollectingEvent (
	v_COLLECTING_EVENT_ID in collecting_event.collecting_event_id%type  default null,
	v_LOCALITY_ID in collecting_event.locality_id%type default null,
	v_VERBATIM_DATE in collecting_event.VERBATIM_DATE%type default null,
 	v_VERBATIM_LOCALITY in collecting_event.VERBATIM_LOCALITY%type default null,
 	v_COLL_EVENT_REMARKS in collecting_event.COLL_EVENT_REMARKS%type default null,
 	v_BEGAN_DATE in collecting_event.BEGAN_DATE%type default null,
 	v_ENDED_DATE in collecting_event.ENDED_DATE%type default null,
 	v_COLLECTING_EVENT_NAME in collecting_event.COLLECTING_EVENT_NAME%type default null,
 	v_LAT_DEG in collecting_event.LAT_DEG%type default null,
 	v_DEC_LAT_MIN in collecting_event.DEC_LAT_MIN%type default null,
 	v_LAT_MIN in collecting_event.LAT_MIN%type default null,
 	v_LAT_SEC in collecting_event.LAT_SEC%type default null,
 	v_LAT_DIR in collecting_event.LAT_DIR%type default null,
 	v_LONG_DEG in collecting_event.LONG_DEG%type default null,
 	v_DEC_LONG_MIN in collecting_event.DEC_LONG_MIN%type default null,
 	v_LONG_MIN in collecting_event.LONG_MIN%type default null,
 	v_LONG_SEC in collecting_event.LONG_SEC%type default null,
 	v_LONG_DIR in collecting_event.LONG_DIR%type default null,
 	v_DEC_LAT in collecting_event.DEC_LAT%type default null,
 	v_DEC_LONG in collecting_event.DEC_LONG%type default null,
	v_DATUM in collecting_event.DATUM%type default null,
 	v_UTM_ZONE in collecting_event.UTM_ZONE%type default null,
 	v_UTM_EW in collecting_event.UTM_EW%type default null,
 	v_UTM_NS in collecting_event.UTM_NS%type default null,
 	v_ORIG_LAT_LONG_UNITS in collecting_event.ORIG_LAT_LONG_UNITS%type default null,
 	v_SPEC_LOCALITY in locality.SPEC_LOCALITY%type default null,
	v_MINIMUM_ELEVATION in locality.MINIMUM_ELEVATION%type default null,
 	v_MAXIMUM_ELEVATION in locality.MAXIMUM_ELEVATION%type default null,
	v_ORIG_ELEV_UNITS in locality.ORIG_ELEV_UNITS%type default null,
	v_MIN_DEPTH in locality.MIN_DEPTH%type default null,
	v_MAX_DEPTH in locality.MAX_DEPTH%type default null,
	v_DEPTH_UNITS in locality.DEPTH_UNITS%type default null,
 	v_MAX_ERROR_DISTANCE in locality.MAX_ERROR_DISTANCE%type default null,
	v_MAX_ERROR_UNITS in locality.MAX_ERROR_UNITS%type default null,
	v_LOCALITY_REMARKS in locality.LOCALITY_REMARKS%type default null,
	v_GEOREFERENCE_SOURCE in locality.GEOREFERENCE_SOURCE%type default null,
	v_GEOREFERENCE_PROTOCOL in locality.GEOREFERENCE_PROTOCOL%type default null,
	v_LOCALITY_NAME in locality.LOCALITY_NAME%type default null,
	v_WKT_POLYGON in locality.WKT_POLYGON%type default null,
    v_HIGHER_GEOG geog_auth_rec.HIGHER_GEOG%TYPE default null,
    v_geology_attribute_1 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_1  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_1  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_1  agent_name.agent_name%type default null,
    v_geo_att_determined_method_1  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_1  geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_2 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_2  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_2  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_2  agent_name.agent_name%type default null,
    v_geo_att_determined_method_2  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_2  geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_3 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_3  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_3  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_3  agent_name.agent_name%type default null,
    v_geo_att_determined_method_3  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_3 geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_4 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_4  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_4  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_4  agent_name.agent_name%type default null,
    v_geo_att_determined_method_4  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_4  geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_5 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_5  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_5  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_5  agent_name.agent_name%type default null,
    v_geo_att_determined_method_5  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_5 geology_attributes.GEO_ATT_REMARK%type default null,
    v_geology_attribute_6 geology_attributes.GEOLOGY_ATTRIBUTE%type default null,
    v_geo_att_value_6  geology_attributes.GEO_ATT_VALUE%type default null,
    v_geo_att_determined_date_6  geology_attributes.GEO_ATT_DETERMINED_DATE%type default null,
    v_geo_att_determiner_6  agent_name.agent_name%type default null,
    v_geo_att_determined_method_6  geology_attributes.GEO_ATT_DETERMINED_METHOD%type default null,
    v_geo_att_remark_6  geology_attributes.GEO_ATT_REMARK%type default null,            
    v_r_ceid out number
 ) 

 
 
 
 var myvar number;

begin
	
	for r in (select * from bulkloader where collection_object_id>1000 and rownum=1) loop
	
	getMakeCollectingEvent(
		v_COLLECTING_EVENT_ID => r.COLLECTING_EVENT_ID,
		v_LOCALITY_ID => r.LOCALITY_ID,
		v_VERBATIM_DATE => r.VERBATIM_DATE,
		v_VERBATIM_LOCALITY => r.VERBATIM_LOCALITY,
		v_COLL_EVENT_REMARKS => r.COLL_EVENT_REMARKS,
		v_BEGAN_DATE => r.BEGAN_DATE,
		v_ENDED_DATE => r.ENDED_DATE,
		v_COLLECTING_EVENT_NAME => r.COLLECTING_EVENT_NAME,
		v_LAT_DEG => r.LAT_DEG,
		v_DEC_LAT_MIN => r.DEC_LAT_MIN,
		v_LAT_MIN => r.LAT_MIN,
		v_LAT_SEC => r.LAT_SEC,
		v_LAT_DIR => r.LAT_DIR,
		v_LONG_DEG => r.LONG_DEG,
		v_DEC_LONG_MIN => r.DEC_LONG_MIN,
		v_LONG_MIN => r.LONG_MIN,
		v_LONG_SEC => r.LONG_SEC,
		v_LONG_DIR => r.LONG_DIR,
		v_DEC_LAT => r.DEC_LAT,
		v_DEC_LONG => r.DEC_LONG,
		v_DATUM => r.DATUM,
		v_UTM_ZONE => r.UTM_ZONE,
		v_UTM_EW => r.UTM_EW,
		v_UTM_NS => r.UTM_NS,
		v_ORIG_LAT_LONG_UNITS => r.ORIG_LAT_LONG_UNITS.xxxx,
		v_SPEC_LOCALITY => r.SPEC_LOCALITY,
		v_MINIMUM_ELEVATION => r.MINIMUM_ELEVATION,
		v_MAXIMUM_ELEVATION => r.MAXIMUM_ELEVATION,
		v_ORIG_ELEV_UNITS => r.ORIG_ELEV_UNITS,
		v_MIN_DEPTH => r.MIN_DEPTH,
		v_MAX_DEPTH => r.MAX_DEPTH,
		v_DEPTH_UNITS => r.DEPTH_UNITS,
		v_MAX_ERROR_DISTANCE => r.MAX_ERROR_DISTANCE,
		v_MAX_ERROR_UNITS => r.MAX_ERROR_UNITS,
		v_LOCALITY_REMARKS => r.LOCALITY_REMARKS,
		v_GEOREFERENCE_SOURCE => r.GEOREFERENCE_SOURCE,
		v_GEOREFERENCE_PROTOCOL => r.GEOREFERENCE_PROTOCOL,
		v_LOCALITY_NAME => r.LOCALITY_NAME,
		v_WKT_POLYGON => r.WKT_POLYGON,
		v_HIGHER_GEOG => r.HIGHER_GEOG,
		v_geology_attribute_1 => r.geology_attribute_1,
		v_geo_att_value_1 => r.geo_att_value_1,
		v_geo_att_determined_date_1 => r.geo_att_determined_date_1,
		v_geo_att_determiner_1 => r.geo_att_determiner_1,
		v_geo_att_determined_method_1 => r.geo_att_determined_method_1,
		v_geo_att_remark_1 => r.geo_att_remark_1,
		v_geology_attribute_2 => r.geology_attribute_2,
		v_geo_att_value_2 => r.geo_att_value_2,
		v_geo_att_determined_date_2 => r.geo_att_determined_date_2,
		v_geo_att_determiner_2 => r.geo_att_determiner_2,
		v_geo_att_determined_method_2 => r.geo_att_determined_method_2,
		v_geo_att_remark_2 => r.geo_att_remark_2,
		v_geology_attribute_3 => r.geology_attribute_3,
		v_geo_att_value_3 => r.geo_att_value_3,
		v_geo_att_determined_date_3 => r.geo_att_determined_date_3,
		v_geo_att_determiner_3 => r.geo_att_determiner_3,
		v_geo_att_determined_method_3 => r.geo_att_determined_method_3,
		v_geo_att_remark_3 => r.geo_att_remark_3,
		v_geology_attribute_4 => r.geology_attribute_4,
		v_geo_att_value_4 => r.geo_att_value_4,
		v_geo_att_determined_date_4 => r.geo_att_determined_date_4,
		v_geo_att_determiner_4 => r.geo_att_determiner_4,
		v_geo_att_determined_method_4 => r.geo_att_determined_method_4,
		v_geo_att_remark_4 => r.geo_att_remark_4,
		v_geology_attribute_5 => r.geology_attribute_5,
		v_geo_att_value_5 => r.geo_att_value_5,
		v_geo_att_determined_date_5 => r.geo_att_determined_date_5,
		v_geo_att_determiner_5 => r.geo_att_determiner_5,
		v_geo_att_determined_method_5 => r.geo_att_determined_method_5,
		v_geo_att_remark_5 => r.geo_att_remark_5,
		v_geology_attribute_6 => r.geology_attribute_6,
		v_geo_att_value_6 => r.geo_att_value_6,
		v_geo_att_determined_date_6 => r.geo_att_determined_date_6,
		v_geo_att_determiner_6 => r.geo_att_determiner_6,
		v_geo_att_determined_method_6 => r.geo_att_determined_method_6,
		v_geo_att_remark_6 => r.geo_att_remark_6,
		v_r_ceid=>:myvar
		);
    
    
	dbms_output.put_line('got: ' || :myvar);
end;
/






	getMakeCollectingEvent(
		v_COLLECTING_EVENT_ID => null,
		v_COLLECTING_EVENT_NAME=> 'Captive Animal',
		v_r_ceid=>:myvar
	);

select :myvar from dual;



exec getMakeCollectingEvent(v_COLLECTING_EVENT_ID => NULL,HIGHER_GEOG => 'no higher geography recorded',v_r_ceid=>:myvar);

select locality_id from test;
 
    -- no user-supplied collecting event or name
    -- we need a locality to find or build an event

   

    -- did not get a locality id but did get a locality name
    if gLocalityId is null and rec.locality_name is not null then
        select 
           MIN(locality_id) into gLocalityId
        from
            locality
        where 
            locality_name=rec.locality_name;
        if gLocalityId is null then
            error_msg := 'Bad locality_name';
            raise failed_validation;
        end if;
    end if;

    -- still do not have a locality ID - so we need to figure out the geog_auth_rec_id
    if gLocalityId is null then
        select geog_auth_rec_id into gGeog_auth_rec_id from geog_auth_rec where higher_geog = rec.higher_geog;
         if gGeog_auth_rec_id is null then
            error_msg := 'Bad HIGHER_GEOG';
            raise failed_validation;
        end if;
        -- now we have a geog_auth_rec_id so we can go looking for a locality
        -- check with and without coordinates because the bulkloader assumes that no llunits==no coordinates
        -- that is, ignore coordiante metadata
        IF rec.orig_lat_long_units IS NULL THEN
            select 
                min(locality.locality_id)
            INTO
                gLocalityId
            FROM 
                locality
            WHERE
                geog_auth_rec_id = gGeog_auth_rec_id AND
                NVL(MAXIMUM_ELEVATION,-1) = NVL(rec.maximum_elevation,-1) AND
                NVL(MINIMUM_ELEVATION,-1) = NVL(rec.minimum_elevation,-1) AND
                NVL(ORIG_ELEV_UNITS,'NULL') = NVL(rec.orig_elev_units,'NULL') AND
                NVL(MIN_DEPTH,-1) = nvl(rec.min_depth,-1) AND
                NVL(MAX_DEPTH,-1) = nvl(rec.max_depth,-1) AND
                NVL(SPEC_LOCALITY,'NULL') = NVL(rec.spec_locality,'NULL') AND
                NVL(LOCALITY_REMARKS,'NULL') = NVL(rec.locality_remarks,'NULL') AND
                NVL(DEPTH_UNITS,'NULL') = NVL(rec.depth_units,'NULL') AND
                dec_lat IS NULL AND -- because we didnt get event coordinates - assume for other coordinate info
                locality_name IS NULL AND -- because we tested that above and will use it if it exists
                nvl(concatGeologyAttributeDetail(locality.locality_id),'NULL') =
                	nvl(b_concatGeologyAttributeDetail(rec.collection_object_id),'NULL') and
                -- this needs developed if we ever add WKT to the bulkloader
                --wkt_polygon is null
                dbms_lob.compare(nvl(rec.WKT_POLYGON,'Null'),nvl(WKT_POLYGON,'Null'))=0
            ;
        ELSE          
           select 
                min(locality.locality_id)
            INTO
                gLocalityId
            FROM 
                locality
            WHERE
                geog_auth_rec_id = gGeog_auth_rec_id AND
                NVL(MAXIMUM_ELEVATION,-1) = NVL(rec.maximum_elevation,-1) AND
                NVL(MINIMUM_ELEVATION,-1) = NVL(rec.minimum_elevation,-1) AND
                NVL(ORIG_ELEV_UNITS,'NULL') = NVL(rec.orig_elev_units,'NULL') AND
                NVL(MIN_DEPTH,-1) = nvl(rec.min_depth,-1) AND
                NVL(MAX_DEPTH,-1) = nvl(rec.max_depth,-1) AND
                NVL(DEPTH_UNITS,'NULL') = NVL(rec.depth_units,'NULL') AND
                NVL(SPEC_LOCALITY,'NULL') = NVL(rec.spec_locality,'NULL') AND
                NVL(LOCALITY_REMARKS,'NULL') = NVL(rec.locality_remarks,'NULL') AND
                NVL(MAX_ERROR_UNITS,'NULL') = NVL(rec.MAX_ERROR_UNITS,'NULL') AND
                NVL(DATUM,'NULL') = NVL(rec.DATUM,'NULL') AND
                NVL(georeference_source,'NULL') = NVL(rec.georeference_source,'NULL') AND
                NVL(georeference_protocol,'NULL') = NVL(rec.georeference_protocol,'NULL') AND
                NVL(DEC_LAT,999) = nvl(rec.C$LAT,999) AND
                NVL(DEC_LONG,999) = nvl(rec.C$LONG,999) AND
                NVL(MAX_ERROR_DISTANCE,-1) = nvl(rec.MAX_ERROR_DISTANCE,-1) AND
                locality_name IS NULL AND -- because we tested that above and will use it if it exists
                nvl(concatGeologyAttributeDetail(locality.locality_id),'NULL') = 
                	nvl(b_concatGeologyAttributeDetail(rec.collection_object_id),'NULL') and
                	-- this needs developed if we ever add WKT to the bulkloader
                --wkt_polygon is null
                dbms_lob.compare(nvl(rec.WKT_POLYGON,'Null'),nvl(WKT_POLYGON,'Null'))=0
            ;
        END IF; 
        if gLocalityId is null then
            -- did not find a locality, so make one
            select sq_locality_id.nextval into gLocalityId from dual;
            if rec.MAX_ERROR_DISTANCE is not null and rec.MAX_ERROR_UNITS is not null then
                meu:=rec.MAX_ERROR_UNITS;
                med:=rec.MAX_ERROR_DISTANCE;
            else
                meu:=null;
                med:=null;
            end if;
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
                 DEC_LAT,
                 DEC_LONG,
                 MAX_ERROR_DISTANCE,
                 MAX_ERROR_UNITS,
                 DATUM,
                 georeference_source,
                 georeference_protocol,
                 wkt_polygon
            ) values (
                gLocalityId,
                gGeog_auth_rec_id,
                rec.MAXIMUM_ELEVATION,
                rec.MINIMUM_ELEVATION,
                rec.ORIG_ELEV_UNITS,
                rec.SPEC_LOCALITY,
                rec.LOCALITY_REMARKS,
                rec.DEPTH_UNITS,
                rec.MIN_DEPTH,
                rec.MAX_DEPTH,
                rec.C$LAT,
                rec.C$LONG,
                med,
                meu,
                rec.DATUM,
                rec.georeference_source,
                rec.georeference_protocol,
                rec.wkt_polygon
            );
            --dbms_output.put_line('made a locality');
            for i IN 1 .. 6 LOOP -- number of geology attributes
                execute immediate 'select count(*) from bulkloader where geology_attribute_' || i || ' is not null and 
                    geo_att_value_' || i || ' is not null and collection_object_id = ' || collobjid into num;
                    --dbms_output.put_line ('num: ' || num);
                if num = 1 then -- there's an attribute - insert it
                    ATTRIBUTE := NULL;
                    ATTRIBUTE_VALUE := NULL;
                    ATTRIBUTE_DATE := NULL;
                    ATTRIBUTE_DETERMINER := NULL;
                    ATTRIBUTE_DET_METH := NULL;
                    ATTRIBUTE_REMARKS := NULL;
                    ATTRIBUTE_DETERMINER_ID := NULL;
                    execute immediate 'select geology_attribute_' || i || 
                        ',geo_att_value_' || i || 
                        ',geo_att_determined_date_' || i || 
                        ',geo_att_determiner_' || i ||
                        ',geo_att_determined_method_' || i ||
                        ',geo_att_remark_' || i || 
                        ' from bulkloader where collection_object_id = ' || collobjid into
                        ATTRIBUTE,
                        ATTRIBUTE_VALUE,
                        ATTRIBUTE_DATE,
                        ATTRIBUTE_DETERMINER,
                        ATTRIBUTE_DET_METH,
                        ATTRIBUTE_REMARKS
                    ;
                    if ATTRIBUTE_DETERMINER is NOT null then
                    	select getAgentID(ATTRIBUTE_DETERMINER) into ATTRIBUTE_DETERMINER_ID from dual;
                    	if ATTRIBUTE_DETERMINER_ID is null then
                            error_msg := 'Bad ATTRIBUTE_DETERMINER_' || i;
                            raise failed_validation;
                        end if;
                    ELSE
                        ATTRIBUTE_DETERMINER_ID:=NULL;
                    end if;
                              
                    insert into geology_attributes (
                        locality_id,
                        geology_attribute,
                        geo_att_value,
                        geo_att_determiner_id,
                        geo_att_determined_date,
                        geo_att_determined_method,
                        geo_att_remark
                    ) values (
                        gLocalityId,
                        ATTRIBUTE,
                        ATTRIBUTE_VALUE,
                        ATTRIBUTE_DETERMINER_ID,
                        ATTRIBUTE_DATE,
                        ATTRIBUTE_DET_METH,
                        ATTRIBUTE_REMARKS
                    );
                     --dbms_output.put_line ('inserted attribute);
                end if;
            end loop;
        end if;
        
       
    end if;
    ------- at this endif, we should have a locality ID
  --dbms_output.put_line ('we have a locality ID, now working on event.....');
  
  --dbms_output.put_line ('we do NOT have an event ID or we would have exited');

        
		IF rec.orig_lat_long_units = 'deg. min. sec.' THEN
           	--dbms_output.put_line(rec.orig_lat_long_units);
           verbatimcoordinates := dms_to_string (rec.latdeg,rec.latmin,rec.latsec, rec.latdir,rec.longdeg,rec.longmin,rec.longsec,rec.longdir);
        ELSIF rec.orig_lat_long_units = 'degrees dec. minutes' THEN
           	--dbms_output.put_line(rec.orig_lat_long_units);
        	verbatimcoordinates := dm_to_string (rec.latdeg, rec.dec_lat_min,rec.latdir, rec.longdeg, rec.dec_long_min,rec.longdir);
       ELSIF rec.orig_lat_long_units = 'decimal degrees' THEN
           	--dbms_output.put_line(rec.orig_lat_long_units);
           verbatimcoordinates := dd_to_string (rec.DEC_LAT,rec.DEC_LONG);
       ELSIF rec.orig_lat_long_units = 'UTM' THEN
           	--dbms_output.put_line(rec.orig_lat_long_units);
            verbatimcoordinates := utm_to_string (rec.UTM_NS,rec.UTM_EW,rec.UTM_ZONE);
       END IF; 
       select 
    	    MIN(collecting_event_id) into gcollecting_event_id 
    	from
    	    collecting_event 
    	where
    	    locality_id = gLocalityId and
    	    nvl(verbatim_date,'NULL') = nvl(rec.verbatim_date,'NULL') and
    	    nvl(VERBATIM_LOCALITY,'NULL') = nvl(rec.VERBATIM_LOCALITY,'NULL') and
    	    nvl(COLL_EVENT_REMARKS,'NULL') = nvl(rec.COLL_EVENT_REMARKS,'NULL') and
    	    nvl(began_date,'NULL') = nvl(rec.began_date,'NULL') and
    	    nvl(ended_date,'NULL') = nvl(rec.ended_date,'NULL') and
    	    COLLECTING_EVENT_NAME IS NULL AND -- or we'd have found it at that check
    	    nvl(verbatimcoordinates,'NULL') = nvl(verbatim_coordinates,'NULL') and
    	    nvl(DATUM,'NULL') = nvl(rec.DATUM,'NULL') and
    	    nvl(ORIG_LAT_LONG_UNITS,'NULL') = nvl(rec.ORIG_LAT_LONG_UNITS,'NULL')
    	;
        if 	gcollecting_event_id is not null then
            -- found a suitable event
            
           --dbms_output.put_line('got gcollecting_event_id @ found event: ' || gcollecting_event_id);
            return;        	
        end if;
        
        
         --dbms_output.put_line('DID NOT got gcollecting_event_id @ found event: or return failed');

                    
                    
                    
        -- if we're still here, we need to make an event   
   		select sq_collecting_event_id.nextval into gcollecting_event_id from dual;
		insert into collecting_event (
			collecting_event_id,
			locality_id,
			verbatim_date,
			VERBATIM_LOCALITY,
			began_date,
			ended_date,
			coll_event_remarks,
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
		) values (
			gcollecting_event_id,
			gLocalityId,
			rec.verbatim_date,
			rec.VERBATIM_LOCALITY,
			rec.began_date,			
			rec.ended_date,
			rec.coll_event_remarks,
			rec.LATDEG,
			rec.DEC_LAT_MIN,
			rec.LATMIN,
			rec.LATSEC,
			rec.LATDIR,
			rec.LONGDEG,
			rec.DEC_LONG_MIN,
			rec.LONGMIN,
			rec.LONGSEC,
			rec.LONGDIR,
			rec.DEC_LAT,
			rec.DEC_LONG,
			rec.DATUM,
			rec.UTM_ZONE,
			rec.UTM_EW,
			rec.UTM_NS,
			rec.ORIG_LAT_LONG_UNITS
		);
        --dbms_output.put_line('got gcollecting_event_id @ made event: ' || gcollecting_event_id);   
    
    
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload_coll_event',collobjid);
END;



















---------------------- non-bulkloader sql ---------------

getMakeCollectingEvent(
		v_COLLECTING_EVENT_ID => r.COLLECTING_EVENT_ID,
		v_LOCALITY_ID => r.LOCALITY_ID,
		v_VERBATIM_DATE => r.VERBATIM_DATE,
		v_VERBATIM_LOCALITY => r.VERBATIM_LOCALITY,
		v_COLL_EVENT_REMARKS => r.COLL_EVENT_REMARKS,
		v_BEGAN_DATE => r.BEGAN_DATE,
		v_ENDED_DATE => r.ENDED_DATE,
		v_COLLECTING_EVENT_NAME => r.COLLECTING_EVENT_NAME,
		v_LAT_DEG => r.LAT_DEG,
		v_DEC_LAT_MIN => r.DEC_LAT_MIN,
		v_LAT_MIN => r.LAT_MIN,
		v_LAT_SEC => r.LAT_SEC,
		v_LAT_DIR => r.LAT_DIR,
		v_LONG_DEG => r.LONG_DEG,
		v_DEC_LONG_MIN => r.DEC_LONG_MIN,
		v_LONG_MIN => r.LONG_MIN,
		v_LONG_SEC => r.LONG_SEC,
		v_LONG_DIR => r.LONG_DIR,
		v_DEC_LAT => r.DEC_LAT,
		v_DEC_LONG => r.DEC_LONG,
		v_DATUM => r.DATUM,
		v_UTM_ZONE => r.UTM_ZONE,
		v_UTM_EW => r.UTM_EW,
		v_UTM_NS => r.UTM_NS,
		v_ORIG_LAT_LONG_UNITS => r.ORIG_LAT_LONG_UNITS.xxxx,
		v_SPEC_LOCALITY => r.SPEC_LOCALITY,
		v_MINIMUM_ELEVATION => r.MINIMUM_ELEVATION,
		v_MAXIMUM_ELEVATION => r.MAXIMUM_ELEVATION,
		v_ORIG_ELEV_UNITS => r.ORIG_ELEV_UNITS,
		v_MIN_DEPTH => r.MIN_DEPTH,
		v_MAX_DEPTH => r.MAX_DEPTH,
		v_DEPTH_UNITS => r.DEPTH_UNITS,
		v_MAX_ERROR_DISTANCE => r.MAX_ERROR_DISTANCE,
		v_MAX_ERROR_UNITS => r.MAX_ERROR_UNITS,
		v_LOCALITY_REMARKS => r.LOCALITY_REMARKS,
		v_GEOREFERENCE_SOURCE => r.GEOREFERENCE_SOURCE,
		v_GEOREFERENCE_PROTOCOL => r.GEOREFERENCE_PROTOCOL,
		v_LOCALITY_NAME => r.LOCALITY_NAME,
		v_WKT_POLYGON => r.WKT_POLYGON,
		v_HIGHER_GEOG => r.HIGHER_GEOG,
		v_geology_attribute_1 => r.geology_attribute_1,
		v_geo_att_value_1 => r.geo_att_value_1,
		v_geo_att_determined_date_1 => r.geo_att_determined_date_1,
		v_geo_att_determiner_1 => r.geo_att_determiner_1,
		v_geo_att_determined_method_1 => r.geo_att_determined_method_1,
		v_geo_att_remark_1 => r.geo_att_remark_1,
		v_geology_attribute_2 => r.geology_attribute_2,
		v_geo_att_value_2 => r.geo_att_value_2,
		v_geo_att_determined_date_2 => r.geo_att_determined_date_2,
		v_geo_att_determiner_2 => r.geo_att_determiner_2,
		v_geo_att_determined_method_2 => r.geo_att_determined_method_2,
		v_geo_att_remark_2 => r.geo_att_remark_2,
		v_geology_attribute_3 => r.geology_attribute_3,
		v_geo_att_value_3 => r.geo_att_value_3,
		v_geo_att_determined_date_3 => r.geo_att_determined_date_3,
		v_geo_att_determiner_3 => r.geo_att_determiner_3,
		v_geo_att_determined_method_3 => r.geo_att_determined_method_3,
		v_geo_att_remark_3 => r.geo_att_remark_3,
		v_geology_attribute_4 => r.geology_attribute_4,
		v_geo_att_value_4 => r.geo_att_value_4,
		v_geo_att_determined_date_4 => r.geo_att_determined_date_4,
		v_geo_att_determiner_4 => r.geo_att_determiner_4,
		v_geo_att_determined_method_4 => r.geo_att_determined_method_4,
		v_geo_att_remark_4 => r.geo_att_remark_4,
		v_geology_attribute_5 => r.geology_attribute_5,
		v_geo_att_value_5 => r.geo_att_value_5,
		v_geo_att_determined_date_5 => r.geo_att_determined_date_5,
		v_geo_att_determiner_5 => r.geo_att_determiner_5,
		v_geo_att_determined_method_5 => r.geo_att_determined_method_5,
		v_geo_att_remark_5 => r.geo_att_remark_5,
		v_geology_attribute_6 => r.geology_attribute_6,
		v_geo_att_value_6 => r.geo_att_value_6,
		v_geo_att_determined_date_6 => r.geo_att_determined_date_6,
		v_geo_att_determiner_6 => r.geo_att_determiner_6,
		v_geo_att_determined_method_6 => r.geo_att_determined_method_6,
		v_geo_att_remark_6 => r.geo_att_remark_6,
		v_r_ceid=>:myvar
		);
    