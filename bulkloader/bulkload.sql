
CREATE OR REPLACE PACKAGE bulk_pkg as
  PROCEDURE check_and_load;
  PROCEDURE bulkloader_check;
END;
/



CREATE OR REPLACE PACKAGE BODY bulk_pkg as
	error_msg varchar2(4000);
	l_collection_object_id number;
	gcollecting_event_id number;
	l_entered_person_id number;
	l_accn_id number;
	l_taxa_formula varchar2(20);
	l_id_made_by_agent_id number;
	l_cat_num  varchar2(40);
	l_collection_id number;
	--gLocalityId number;
	l_taxon_name_id_1 number;
	l_taxon_name_id_2 number;
	tempStr VARCHAR2(255);
	tempStr2 VARCHAR2(255);
	tempStr3 VARCHAR2(255);
	failed_validation exception;
	num number;
	l_catalog_number_format VARCHAR2(255);
---------------------------------------------------------------------------------------------------------------------------------------------
 PROCEDURE bulkload_error  (
 	errMsg IN varchar,
 	sqlMsg IN varchar,
 	procName IN varchar,
 	collobjid IN number
 	) 
is
begin
	--dbms_output.put_line('errMsg: ' || errMsg);
	--dbms_output.put_line('sqlMsg: ' || sqlMsg);
	--dbms_output.put_line('procName: ' || procName);
	--dbms_output.put_line('errMsg: ' || errMsg);
	
	
	if procName is not null then
		error_msg:=procName || ': ';
	end if;
	
	error_msg:=error_msg || errMsg;
	
	if sqlMsg != 'User-Defined Exception' then
		error_msg:=error_msg || ': ' || sqlMsg;
	end if;

		
	
	--error_msg := nvl(errMsg,'') || '; called from ' || nvl(procName,'') || ': ' || nvl(sqlMsg,'');
	/*
	if sqlMsg != 'User-Defined Exception' then
		dbms_output.put_line('sqlMsg is User.... ');
		
			dbms_output.put_line('preerror_msg: ' || error_msg);

		-- unhandled exception
		--error_msg := errMsg || '; called from ' || procName || ': ' || sqlMsg;
		error_msg := errMsg;
		
		
			dbms_output.put_line('posterror_msg: ' || error_msg);

	end if;
	*/
	
	
	--dbms_output.put_line('fullaftererror_msg: ' || error_msg);
	
	if length(error_msg) > 224 then
		error_msg := substr(error_msg,1,200) || ' {snip...}';
	end if;
	
	
	--dbms_output.put_line('error_msg: ' || error_msg);
	
	update bulkloader set loaded = error_msg where collection_object_id = collobjid;
EXCEPTION
	when others then
		error_msg := 'An error in the error handler - OH NOES!! ' || error_msg;
		if length(error_msg) > 3500 then
			error_msg := substr(error_msg,1,3500) || ' {snip...}';
		end if;
		update bulkloader set loaded = error_msg where collection_object_id = collobjid;		
end;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE bulkloader_check 
is
 thisError varchar2(4000);
  BEGIN
   --dbms_output.put_line('bulkloader_check');
	FOR rec IN (SELECT collection_object_id FROM bulkloader where loaded is null) LOOP
	    --dbms_output.put_line('bulkloader_check:loop');
	    SELECT bulk_check_one(rec.collection_object_id) INTO thisError FROM dual;
		if thisError is not null then
			if length(thisError) > 224 then
				thisError := substr(thisError,1,200) || ' {snip...}';
				 --dbms_output.put_line('thisError: ' || thisError);
			end if;
			rollback;
			update bulkloader set loaded = thisError where collection_object_id = rec.collection_object_id;
		end if;
		commit;
	END LOOP;
END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_rollback_bulkloader  (l_collection_object_id IN number,collobjid IN number) 
is
	determiner_id number;
	b_locality_id bulkloader.locality_id%TYPE;
	error_msg varchar2(4000);  
	b_container_id container.container_id%TYPE;
BEGIN
	--dbms_output.put_line('starting b_rollback_bulkloader');
	delete from cf_temp_relations where collection_object_id = l_collection_object_id;
	delete from coll_obj_other_id_num where collection_object_id = l_collection_object_id;
	delete from specimen_part where derived_from_cat_item = l_collection_object_id;
	delete from attributes where collection_object_id = l_collection_object_id;
	delete from identification_agent where IDENTIFICATION_ID IN (
		select IDENTIFICATION_ID from IDENTIFICATION where collection_object_id = l_collection_object_id
	);
	delete from identification_taxonomy where IDENTIFICATION_ID IN (
		select IDENTIFICATION_ID from IDENTIFICATION where collection_object_id = l_collection_object_id
	);
	delete from identification_agent where IDENTIFICATION_ID IN (
		select IDENTIFICATION_ID from IDENTIFICATION where collection_object_id = l_collection_object_id
	);
	delete from IDENTIFICATION where collection_object_id = l_collection_object_id;
 	delete from collector where collection_object_id = l_collection_object_id;
	delete from specimen_event where collection_object_id = l_collection_object_id;
	delete from cataloged_item where collection_object_id = l_collection_object_id;
	--dbms_output.put_line('nuking coll_object ' || l_collection_object_id);
	delete from coll_object where collection_object_id = l_collection_object_id;	
	--dbms_output.put_line('ending b_rollback_bulkloader');
EXCEPTION
	when others then
		--dbms_output.put_line('error b_rollback_bulkloader');
		bulkload_error (error_msg,SQLERRM,'b_bulk_this',collobjid);
END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulkload_attribute  (collobjid IN number) is
	catitemcollid cataloged_item.collection_object_id%TYPE;
	DETERMINED_BY_AGENT_ID attributes.DETERMINED_BY_AGENT_ID%TYPE;
	ATTRIBUTE attributes.attribute_type%TYPE;
	ATTRIBUTE_VALUE attributes.ATTRIBUTE_VALUE%TYPE;
	ATTRIBUTE_UNITS attributes.ATTRIBUTE_UNITS%TYPE;
	ATTRIBUTE_REMARKS attributes.ATTRIBUTE_REMARK%TYPE;
	ATTRIBUTE_DATE attributes.DETERMINED_DATE%TYPE;
	ATTRIBUTE_DET_METH attributes.DETERMINATION_METHOD%TYPE;
	ATTRIBUTE_DETERMINER_ID agent.agent_id%TYPE;
	ATTRIBUTE_DETERMINER varchar2(255);
	ATTRIBUTE_ID attributes.ATTRIBUTE_ID%TYPE;
BEGIN
	--dbms_output.put_line ('catitemcollid' || catitemcollid);
	for i IN 1 .. 10 LOOP -- number of attributes
		execute immediate 'select count(*) from bulkloader where ATTRIBUTE_' || i || ' is not null and 
			ATTRIBUTE_VALUE_' || i || ' is not null and collection_object_id = ' || collobjid into num;
			--dbms_output.put_line ('num: ' || num);
		if num = 1 then -- there's an attribute - insert it
			select sq_attribute_id.nextval into ATTRIBUTE_ID from dual;
			--dbms_output.put_line ('ATTRIBUTE_ID: ' || ATTRIBUTE_ID);
			execute immediate 'select ATTRIBUTE_DETERMINER_' || i || ' from bulkloader where collection_object_id = ' || 
				collobjid into ATTRIBUTE_DETERMINER;
				--dbms_output.put_line ('ATTRIBUTE_DETERMINER: ' || ATTRIBUTE_DETERMINER);
			if ATTRIBUTE_DETERMINER is null then
				error_msg := 'Bad ATTRIBUTE_DETERMINER_' || i;
				raise failed_validation;
			end if;
			
			select getAgentID(ATTRIBUTE_DETERMINER) into ATTRIBUTE_DETERMINER_ID from dual;
	
			if ATTRIBUTE_DETERMINER_ID is null then
				error_msg := 'Bad ATTRIBUTE_DETERMINER_' || i;
				raise failed_validation;
			end if;
			execute immediate 'select ATTRIBUTE_' || i || 
				',ATTRIBUTE_VALUE_' || i || 
				',ATTRIBUTE_UNITS_' || i || 
				',ATTRIBUTE_REMARKS_' || i ||
				',ATTRIBUTE_DATE_' || i ||
				',ATTRIBUTE_DET_METH_' || i || 
				' from bulkloader where collection_object_id = ' || collobjid into
				ATTRIBUTE,
				ATTRIBUTE_VALUE,
				ATTRIBUTE_UNITS,
				ATTRIBUTE_REMARKS,
				ATTRIBUTE_DATE,
				ATTRIBUTE_DET_METH
			;
			--dbms_output.put_line ('ATTRIBUTE: ' || ATTRIBUTE);
			--dbms_output.put_line ('ATTRIBUTE_VALUE: ' || ATTRIBUTE_VALUE);
			insert into attributes (
				ATTRIBUTE_ID,
				COLLECTION_OBJECT_ID,
				DETERMINED_BY_AGENT_ID,
				ATTRIBUTE_TYPE,
				ATTRIBUTE_VALUE,
				ATTRIBUTE_UNITS,
				ATTRIBUTE_REMARK,
				DETERMINED_DATE,
				DETERMINATION_METHOD 
			) values (
				ATTRIBUTE_ID,
				l_collection_object_id,
				ATTRIBUTE_DETERMINER_ID,
				ATTRIBUTE,
				ATTRIBUTE_VALUE,
				ATTRIBUTE_UNITS,
				ATTRIBUTE_REMARKS,
				ATTRIBUTE_DATE,
				ATTRIBUTE_DET_METH
			);
				 --dbms_output.put_line('inserted attribute);
		end if;
	end loop;
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload_attribute',collobjid);
END;       
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulkload_parts  (collobjid IN number) is
	r_partname  specimen_part.PART_NAME%TYPE;
	r_condn  coll_object.CONDITION%TYPE;
	r_barcode  container.BARCODE%TYPE;
	r_lotcount  coll_object.LOT_COUNT%TYPE;
	r_disposition  coll_object.COLL_OBJ_DISPOSITION%TYPE;
	r_partremark  coll_object_remark.COLL_OBJECT_REMARKS%TYPE;
	catitemcollid CATALOGED_ITEM.COLLECTION_OBJECT_ID%TYPE;
	r_container_id container.container_id%TYPE;
	part_id specimen_part.COLLECTION_OBJECT_ID%TYPE;
	entered_person_id agent.agent_id%TYPE;
	part_label varchar2(255);
	r_parent_container_id container.parent_container_id%TYPE;
	r_collection_id number;
	r_institution_acronym container.institution_acronym%TYPE;
BEGIN
	--dbms_output.put_line ('parts...');
	--dbms_output.put_line ('got catcollid...');
	for i IN 1 .. 12 LOOP -- number of parts
	    --dbms_output.put_line('on part loop ' || i);
		execute immediate 'select count(*) from bulkloader where PART_NAME_' || i || ' is not null 
			and collection_object_id = ' || collobjid into num;
		if num = 1 then -- there's a part - insert it
			--dbms_output.put_line ('inserting a part...');
			execute immediate 'select 
				collection_id,
				PART_NAME_' || i || ', 
				PART_CONDITION_' || i || ', 
				PART_BARCODE_' || i || ', 
				PART_LOT_COUNT_' || i || ', 
				PART_DISPOSITION_' || i || ', 
				PART_REMARK_' || i || ' 
			from bulkloader 
			where collection_object_id = ' || collobjid 
			into 
				r_collection_id,
				r_partname,
				r_condn,
				r_barcode,
				r_lotcount,
				r_disposition,
				r_partremark
			;
			select sq_collection_object_id.nextval into part_id from dual;
			--dbms_output.put_line ('got coll obj id');
			execute immediate 'select guid_prefix || '':' || l_cat_num || ' ''  || 
				part_name_' || i ||  ' from bulkloader where collection_object_id = ' || 
				collobjid into part_label;
			--dbms_output.put_line ('got label');
			INSERT INTO coll_object (
				COLLECTION_OBJECT_ID,
				COLL_OBJECT_TYPE,
				ENTERED_PERSON_ID,
				COLL_OBJECT_ENTERED_DATE,
				COLL_OBJ_DISPOSITION,
				LOT_COUNT,
				CONDITION 
			) VALUES (
				part_id,
				'SP',
				l_entered_person_id,
				sysdate,
				r_disposition,
				r_lotcount,
				r_condn   
			);
			INSERT INTO specimen_part (	
				COLLECTION_OBJECT_ID,
				PART_NAME,
				DERIVED_FROM_CAT_ITEM
			) VALUES (
				part_id,
				r_partname,
				l_collection_object_id
			);
			if r_partremark is not null then
				INSERT INTO coll_object_remark (
						collection_object_id, 
						coll_object_remarks
				) VALUES (
					part_id, r_partremark);
			end if;
	
			--dbms_output.put_line ('made coll_obj_cont_hist');
			if r_barcode is not null then
				--select institution_acronym into r_institution_acronym from collection where collection_id=r_collection_id;
			    -- find the container_id of the part we just made
			    SELECT container_id INTO r_container_id FROM coll_obj_cont_hist WHERE collection_object_id = part_id;
			    --dbms_output.put_line ('CURRENT part IS : ' || r_container_id);
				SELECT container_id into r_parent_container_id FROM container WHERE barcode = r_barcode;
				--and	institution_acronym=r_institution_acronym;
				--dbms_output.put_line ('got parent contianer id: ' || r_parent_container_id);
				UPDATE container SET 
					parent_container_id = r_parent_container_id
				WHERE 
					container_id = r_container_id;
			end if;			
		end if;
		--dbms_output.put_line ('parts loop de looooppppeeeee.....');
	end loop;
--dbms_output.put_line ('made it thru parts');	
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload_parts',collobjid);
END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulkload_otherid  (collobjid IN number) is
	oidn  coll_obj_other_id_num.DISPLAY_VALUE%TYPE;
	oidt  coll_obj_other_id_num.OTHER_ID_TYPE%TYPE;
	oidr  coll_obj_other_id_num.ID_REFERENCES%TYPE;
	catcollid cataloged_item.collection_object_id%TYPE;
BEGIN
	--dbms_output.put_line('starting b_bulkload_otherid');
	for i IN 1 .. 5 LOOP -- number of other IDs		
		execute immediate 'select count(*) from bulkloader where OTHER_ID_NUM_' || i || ' is not null 
			and collection_object_id = ' || collobjid into num;
		if num = 1 then -- there's an other ID number - insert it
		--dbms_output.put_line('inserting into other IDs....');
		execute immediate 'select OTHER_ID_NUM_' || i || ', OTHER_ID_NUM_TYPE_' || i || ', OTHER_ID_REFERENCES_' || i || ' from bulkloader where 
				collection_object_id = ' || collobjid
				into oidn,oidt,oidr;			
			-- call the function to attempt parsing other IDs out into components
			--dbms_output.put_line('calling function');
			parse_other_id(l_collection_object_id, oidn, oidt,oidr);			
			--dbms_output.put_line('back from  function');
		end if;
	end loop;		
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload_otherid',collobjid);
END;        
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulkload (collobjid IN NUMBER) is
	catcollid number;
	someRandomString varchar2(4000);
	someRandomStringTwo varchar2(4000);
	someRandomNumber number;
	someRandomNumberTwo number;
	someRandomNumberThree number;
	someRandomNumberFour number;
	someRandomNumberFive number;
	rec bulkloader%ROWTYPE;
	gGeog_auth_rec_id geog_auth_rec.geog_auth_rec_id%TYPE;
	newLocId  locality.locality_id%TYPE;
	DETERMINED_BY_AGENT_ID  agent.agent_id%TYPE;
	bulk_table_coll_obj_id number;
	temp number;
BEGIN
		SELECT * into rec FROM bulkloader where collection_object_id = collobjid;		
		--select catcollid into catcollid from bulkloader_keys where k_collection_object_id = collobjid;
		-- coll object and cataloged_item
		--dbms_output.put_line ('loadin a coll_object... ');
		--select entered_person_id into someRandomNumber from bulkloader_keys where k_collection_object_id = rec.collection_object_id;
		INSERT INTO coll_object (
			COLLECTION_OBJECT_ID,
			COLL_OBJECT_TYPE,
			ENTERED_PERSON_ID,
			COLL_OBJECT_ENTERED_DATE,
			COLL_OBJ_DISPOSITION,
			LOT_COUNT,
			CONDITION,
			FLAGS
		) VALUES (
			l_collection_object_id,
			'CI',
			l_entered_person_id,
			sysdate,
			'not applicable',
			1,
			'not applicable',
			rec.FLAGS
		)
		;
		--dbms_output.put_line ('loadied a coll_object... ');
		
		--select accn_id into someRandomNumber from bulkloader_keys where k_collection_object_id = rec.collection_object_id;
		--select K_CAT_NUM into someRandomNumberThree from bulkloader_keys where k_collection_object_id = rec.collection_object_id;
		--select collecting_event_id into someRandomNumberFour from bulkloader_keys where k_collection_object_id = rec.collection_object_id;
		--dbms_output.put_line ('keys colleventid: ' || someRandomNumberFour);
		--select collection_id into someRandomNumberFive from bulkloader_keys where k_collection_object_id = rec.collection_object_id;
		
		-- nasty workaround until we figure something more usable out
		SELECT lower(collection) INTO someRandomString FROM collection WHERE collection_id=l_collection_id;
		IF someRandomString LIKE '%obs%' THEN
		    someRandomStringTwo:='observation';
		ELSE
		    someRandomStringTwo:='specimen';
		END IF;
		
		INSERT INTO cataloged_item (
			COLLECTION_OBJECT_ID,
			CAT_NUM,
			ACCN_ID,
			COLLECTION_CDE,
			CATALOGED_ITEM_TYPE,
			COLLECTION_ID
			)
		VALUES (
			l_collection_object_id,
			l_cat_num,
			l_accn_id,
			(select collection_cde from collection where guid_prefix=rec.guid_prefix),
			someRandomStringTwo,
			l_collection_id
		);
		
        --dbms_output.put_line('got gcollecting_event_id @ inserting into specimen-event: ' || gcollecting_event_id);

		INSERT INTO specimen_event (
            COLLECTION_OBJECT_ID,
            COLLECTING_EVENT_ID,
            ASSIGNED_BY_AGENT_ID,
            ASSIGNED_DATE,
            SPECIMEN_EVENT_REMARK,
            SPECIMEN_EVENT_TYPE,
            COLLECTING_METHOD,
            COLLECTING_SOURCE,
            VERIFICATIONSTATUS,
            HABITAT
        ) VALUES (
            l_collection_object_id,
            gcollecting_event_id,
            (getAgentID(rec.event_assigned_by_agent)),
            rec.event_assigned_date,
            rec.SPECIMEN_EVENT_REMARK,
            rec.SPECIMEN_EVENT_TYPE,
            rec.COLLECTING_METHOD,
            rec.COLLECTING_SOURCE,
            rec.VERIFICATIONSTATUS,
            rec.HABITAT
        );
		-- commit; -- necessary so triggers work
		
		select sq_identification_id.nextval into someRandomNumber from dual;
	    IF (instr(rec.taxon_name,' {') > 1 AND instr(rec.taxon_name,'}') > 1) then
			someRandomString := regexp_replace(rec.taxon_name,'^.* {(.*)}$','\1');
	    ELSE
	        someRandomString:=rec.taxon_name;
	    END IF;
				
		insert into identification (
			IDENTIFICATION_ID,
			COLLECTION_OBJECT_ID,
			MADE_DATE,
			NATURE_OF_ID,
			ACCEPTED_ID_FG,
			IDENTIFICATION_REMARKS,
			TAXA_FORMULA,
			SCIENTIFIC_NAME
		) values (
			someRandomNumber,
			l_collection_object_id,
			rec.MADE_DATE,
			rec.NATURE_OF_ID,
			1,
			rec.IDENTIFICATION_REMARKS,
			l_taxa_formula,
			someRandomString
		);
		
		insert into identification_taxonomy (
			IDENTIFICATION_ID,
			TAXON_NAME_ID,
			VARIABLE
		) values (
			someRandomNumber,
			l_taxon_name_id_1,
			'A'
		);
		if l_taxon_name_id_2 is not null then
			insert into identification_taxonomy (
				IDENTIFICATION_ID,
				TAXON_NAME_ID,
				VARIABLE
			) values (
				someRandomNumber,
				l_taxon_name_id_2,
				'B'
			);
		end if;
		
		insert into identification_agent (
			IDENTIFICATION_ID,
			AGENT_ID,
			IDENTIFIER_ORDER
		) values (
			someRandomNumber,
			l_id_made_by_agent_id,
			1
		);
	
		
			if rec.ASSOCIATED_SPECIES is not null OR 
			rec.COLL_OBJECT_REMARKS is not null then
			insert into coll_object_remark (
				COLLECTION_OBJECT_ID,
				COLL_OBJECT_REMARKS,
				ASSOCIATED_SPECIES
			) values (
				l_collection_object_id,
				rec.COLL_OBJECT_REMARKS,
				rec.ASSOCIATED_SPECIES
			);
		end if;
		-- collectors
		for i IN 1 .. 8 LOOP -- number of collectors
			execute immediate 'select count(*)
				FROM bulkloader
				where 
				COLLECTOR_AGENT_' || i || ' is not null and 
				collection_object_id = ' || rec.collection_object_id 
				INTO num;
			if num > 0 then
				execute immediate 'select 
					COLLECTOR_AGENT_' || i || ', 
					COLLECTOR_ROLE_' || i || '
					FROM bulkloader
					where collection_object_id = ' || rec.collection_object_id  
					INTO someRandomString,
					someRandomStringTwo;
					
				select getAgentID(someRandomString) into someRandomNumber from dual;
				
				
				if someRandomNumber is null then
					error_msg := 'Bad COLLECTOR_AGENT_' || i || '(' || someRandomString || ')';
					raise failed_validation;
				else
					insert into collector (
						COLLECTION_OBJECT_ID,
						AGENT_ID,
						COLLECTOR_ROLE,
						COLL_ORDER
					) values (
						l_collection_object_id,
						someRandomNumber,
						someRandomStringTwo,
						i
					);
				end if;
			end if;
		END LOOP;
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload',collobjid);
END;
---------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE b_bulkload_coll_event (collobjid IN number) is
    n number;
    rec bulkloader%ROWTYPE;
    gGeog_auth_rec_id geog_auth_rec.geog_auth_rec_id%TYPE;
    k_locality_id locality.locality_id%TYPE;
    gLocalityId number;
    ERROR_MSG VARCHAR2(4000) ;
    verbatimcoordinates VARCHAR2(4000) := '';
    meu locality.max_error_units%type;
	med locality.max_error_distance%type;
	ATTRIBUTE geology_attributes.GEOLOGY_ATTRIBUTE%type;
	ATTRIBUTE_DATE geology_attributes.GEO_ATT_DETERMINED_DATE%type;
	ATTRIBUTE_VALUE geology_attributes.GEO_ATT_VALUE%type;
	ATTRIBUTE_DETERMINER agent_name.agent_name%type;
	ATTRIBUTE_DET_METH geology_attributes.GEO_ATT_DETERMINED_METHOD%type;
	ATTRIBUTE_REMARKS geology_attributes.GEO_ATT_REMARK%type;
	ATTRIBUTE_DETERMINER_ID geology_attributes.GEO_ATT_DETERMINER_ID%type;
	v_DATUM locality.datum%type;
	v_georeference_source locality.georeference_source%type;
	v_georeference_protocol locality.georeference_protocol%type;
         
BEGIN
	
	--dbms_output.put_line('begin locality');
	
    -- Do whatever we have to in order to return a collecting_event_id
	select * into rec from bulkloader where collection_object_id=collobjid;
	
	--dbms_output.put_line('dec_lat: ' || rec.dec_lat);
    --dbms_output.put_line('dec_long: ' || rec.dec_long);
    --dbms_output.put_line('c$lat: ' || rec.c$lat);
    --dbms_output.put_line('c$long: ' || rec.c$long);
	
    -- user-supplied event ID - we're done here
	IF rec.collecting_event_id IS NOT NULL THEN
		--dbms_output.put_line('got collecting_event_id: ' || rec.collecting_event_id);

         select 
            count(*) into n
        from
            collecting_event 
        where 
            collecting_event_id=rec.collecting_event_id;
        if n=1 then
            gcollecting_event_id := rec.collecting_event_id;
            --dbms_output.put_line('got gcollecting_event_id @ user picked event ID: ' || gcollecting_event_id);
            return;
        else
            error_msg := 'Bad collecting_event_id';
            raise failed_validation;
        end if;
    END IF;

    -- user-supplied event name - check it
    IF rec.collecting_event_name IS NOT NULL THEN
    
		--dbms_output.put_line('got collecting_event_name: ' || rec.collecting_event_name);
        select 
            MIN(collecting_event_id) into gcollecting_event_id 
        from
            collecting_event 
        where 
            collecting_event_name=rec.collecting_event_name;
        if gcollecting_event_id is not null then
            return;
        else
            error_msg := 'Bad collecting_event_name';
            raise failed_validation;
        end if;
    end if;

    -- no user-supplied collecting event or name
    -- we need a locality to find or build an event

    IF rec.locality_id IS NOT NULL THEN
    
    
		--dbms_output.put_line('got locality_id: ' || rec.locality_id);
        select 
            count(*) into n
        from
            locality
        where 
            locality_id=rec.locality_id;
        if n=1 then
            gLocalityId := rec.locality_id;
        else
            error_msg := 'Bad locality_id';
            raise failed_validation;
        end if;
    END IF;

    -- did not get a locality id but did get a locality name
    if gLocalityId is null and rec.locality_name is not null then
    		--dbms_output.put_line('got locality_name: ' || rec.locality_name);

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
        
        --dbms_output.put_line('locality noexist');

        IF rec.orig_lat_long_units IS NULL THEN
        
                --dbms_output.put_line('orig_lat_long_units is null');

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
                nvl(concatGeologyAttributeDetail(locality.locality_id),'NULL') = nvl(b_concatGeologyAttributeDetail(rec.collection_object_id),'NULL') and
                NVL(wkt_media_id,-1) = nvl(rec.wkt_media_id,-1)
            ;
        ELSE  
        	--dbms_output.put_line('making locality with coordinates');
        	
     	
					
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
                nvl(concatGeologyAttributeDetail(locality.locality_id),'NULL') = nvl(b_concatGeologyAttributeDetail(rec.collection_object_id),'NULL') and
                 -- this needs developed if we ever add WKT to the bulkloader
                --wkt_polygon is null
                NVL(wkt_media_id,-1) = nvl(rec.wkt_media_id,-1)
            ;
        END IF; 
        if gLocalityId is null then
        
            --dbms_output.put_line('gLocalityId is null');

            -- did not find a locality, so make one
            --dbms_output.put_line('make locality');
            select sq_locality_id.nextval into gLocalityId from dual;
            if rec.MAX_ERROR_DISTANCE is not null and rec.MAX_ERROR_UNITS is not null then
                meu:=rec.MAX_ERROR_UNITS;
                med:=rec.MAX_ERROR_DISTANCE;
            else
                meu:=null;
                med:=null;
            end if;
            if REC.orig_lat_long_units='UTM' then
            	if rec.MAX_ERROR_DISTANCE is not null or rec.MAX_ERROR_UNITS is not null then
            		 error_msg := 'UTM may not be accompanied by MAX_ERROR_DISTANCE or MAX_ERROR_UNITS';
                     raise failed_validation;
            	end if;
            	v_DATUM:=null;
            	v_georeference_source:=null;
            	v_georeference_protocol:=null;
            	if rec.MAX_ERROR_DISTANCE is not null or rec.MAX_ERROR_UNITS is not null then
            		 error_msg := 'UTM may not be accompanied by MAX_ERROR_DISTANCE or MAX_ERROR_UNITS';
                     raise failed_validation;
            	end if;
            else
            	v_DATUM:=REC.DATUM;
            	v_georeference_source:=REC.georeference_source;
            	v_georeference_protocol:=REC.georeference_protocol;
			end if;
			
			        	--dbms_output.put_line('inserting into locality');

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
                 wkt_media_id
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
                v_DATUM,
                v_georeference_source,
                v_georeference_protocol,
                rec.wkt_media_id
            );
            
            			        	--dbms_output.put_line('inserted into locality');

            ----dbms_output.put_line('made a locality');
            for i IN 1 .. 6 LOOP -- number of geology attributes
                execute immediate 'select count(*) from bulkloader where geology_attribute_' || i || ' is not null and 
                    geo_att_value_' || i || ' is not null and collection_object_id = ' || collobjid into num;
                    ----dbms_output.put_line ('num: ' || num);
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
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_build_keys_table (collobjid IN number) is
	rec bulkloader%ROWTYPE;
	taxa_one varchar2(255);
	taxa_two varchar2(255);
	a_coln varchar2(255);
	a_instn varchar2(255);
BEGIN
	l_collection_object_id  := NULL;
	gcollecting_event_id := NULL;
	l_entered_person_id := NULL;
	l_accn_id := NULL;
	l_taxa_formula := NULL;
	l_id_made_by_agent_id := NULL;
	l_cat_num := NULL;
	l_collection_id := NULL;
	-- gLocalityId := NULL;
	l_taxon_name_id_1 := NULL;
	l_taxon_name_id_2 := NULL;
	--l_catalog_number_format := NULL;
	
	select * into rec from bulkloader where collection_object_id=collobjid;
	select sq_collection_object_id.nextval into l_collection_object_id from dual;
	
	
	select  /*+ RESULT_CACHE */  count(distinct(collection_id)) into num from collection where guid_prefix=rec.guid_prefix;
	if num != 1 then
		error_msg := 'Bad guid_prefix';
		raise failed_validation;
	else
		select /*+ RESULT_CACHE */ 
			collection_id ,catalog_number_format
		into 
			l_collection_id ,l_catalog_number_format
		from collection where guid_prefix=rec.guid_prefix;
	end if;
	
	
	if l_catalog_number_format='integer' then
		if rec.cat_num is null then
			select nvl(max(cat_num_integer),0) + 1 into l_cat_num from cataloged_item,collection		
			where cataloged_item.collection_id = collection.collection_id and
			collection.guid_prefix=rec.guid_prefix;
		else
			select count(cat_num) into num from cataloged_item,collection
			where cataloged_item.collection_id = collection.collection_id and
			collection.guid_prefix=rec.guid_prefix and
			cat_num=rec.cat_num;
			if num = 1 then
				error_msg := 'cat_num already exists';
				raise failed_validation;
			else
				l_cat_num := rec.cat_num;
			end if;
		end if;
	else
		if rec.cat_num is null then
			error_msg := 'cat_num is required for catalog_number_format non-integer collections';
			raise failed_validation;
		else
			l_cat_num := rec.cat_num;
		end if;
	end if;
	
	
	
	
	select  /*+ RESULT_CACHE */ count(distinct(agent_id)) into num from agent_name where agent_name = rec.ENTEREDBY
		AND agent_name_type = 'login';
	
	if num != 1 then
		error_msg := 'Bad enteredby (use login)';
		raise failed_validation;
	else
		select  /*+ RESULT_CACHE */ distinct(agent_id) into l_entered_person_id from agent_name where agent_name = rec.ENTEREDBY
    		AND agent_name_type = 'login';
	end if;
	IF rec.accn LIKE '[%' AND rec.accn LIKE '%]%' THEN
    	tempStr :=  trim(substr(rec.accn, instr(rec.accn,'[',1,1) + 1,instr(rec.accn,']',1,1) -2));
    	tempStr2 := trim(REPLACE(rec.accn,'['||tempStr||']'));
    	
      ELSE
        tempStr := rec.guid_prefix;
        tempStr2 := rec.accn;
	END IF;
   select  /*+ RESULT_CACHE */ count(distinct(accn.transaction_id)) into num from accn,trans,collection where 
    	accn.transaction_id = trans.transaction_id and
    	trans.collection_id=collection.collection_id AND
    	collection.guid_prefix=tempStr and
    	accn_number = tempStr2;
	if num != 1 then
		error_msg := 'Bad accn: ' || rec.accn;
		raise failed_validation;
	else
		select  /*+ RESULT_CACHE */ accn.transaction_id into l_accn_id from accn,trans,collection where 
		accn.transaction_id = trans.transaction_id and
	    trans.collection_id=collection.collection_id AND
	    collection.guid_prefix=tempStr and
		accn_number = tempStr2;
	end if;
	if (instr(rec.taxon_name,' {') > 1 AND instr(rec.taxon_name,'}') > 1) then
		l_taxa_formula := 'A {string}';
		taxa_one := regexp_replace(rec.taxon_name,' {.*}$','');
	elsif instr(rec.taxon_name,' or ') > 1 then
		num := instr(rec.taxon_name, ' or ') -1;
		taxa_one := substr(rec.taxon_name,1,num);
		taxa_two := substr(rec.taxon_name,num+5);
		l_taxa_formula := 'A or B';
	elsif instr(rec.taxon_name,' and ') > 1 then
		num := instr(rec.taxon_name, ' and ') -1;
		taxa_one := substr(rec.taxon_name,1,num);
		taxa_two := substr(rec.taxon_name,num+5);
		l_taxa_formula := 'A and B';
    elsif instr(rec.taxon_name,' x ') > 1 then
		num := instr(rec.taxon_name, ' x ') -1;
		taxa_one := substr(rec.taxon_name,1,num);
		taxa_two := substr(rec.taxon_name,num+4);
		l_taxa_formula := 'A x B';			
	elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' sp.' then
		l_taxa_formula := 'A sp.';
		taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
	elsif  substr(rec.taxon_name,length(rec.taxon_name) - 4) = ' ssp.' then
		l_taxa_formula := 'A ssp.';
		taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 4);
	elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' cf.' then
		l_taxa_formula := 'A cf.';
		taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
	elsif  substr(rec.taxon_name,length(rec.taxon_name) - 1) = ' ?' then
		l_taxa_formula := 'A ?';
		taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 1);
	else
		l_taxa_formula := 'A';
		taxa_one := rec.taxon_name;
	end if;
	if taxa_two is not null AND (
		  substr(taxa_one,length(taxa_one) - 3) = ' sp.' OR
			substr(taxa_two,length(taxa_two) - 3) = ' sp.' OR
			substr(taxa_one,length(taxa_one) - 1) = ' ?' OR
			substr(taxa_two,length(taxa_two) - 1) = ' ?' 
		) then
			error_msg := '"sp." and "?" are not allowed in multi-taxon IDs';
			raise failed_validation;	
	end if;
	if taxa_one is not null then
		select count(distinct(taxon_name_id)) into num from taxon_name where scientific_name = trim(taxa_one);
		if num = 1 then
			select distinct(taxon_name_id) into l_taxon_name_id_1 from taxon_name where scientific_name = trim(taxa_one);
		else
			error_msg := 'taxonomy (' || taxa_one || ') not found';
			raise failed_validation;
		end if;
	end if;
	if taxa_two is not null then
		select count(distinct(taxon_name_id)) into num from taxon_name where scientific_name = trim(taxa_two);
		if num = 1 then
			select distinct(taxon_name_id) into l_taxon_name_id_2 from taxon_name where scientific_name = trim(taxa_two);
		else
			error_msg := 'taxonomy (' || taxa_two || ') not found';
			raise failed_validation;	
		end if;
	end if;
	

	select getAgentID(rec.ID_MADE_BY_AGENT) into l_id_made_by_agent_id from dual;
	if l_id_made_by_agent_id is null then
		error_msg := 'ID_MADE_BY_AGENT (' || rec.ID_MADE_BY_AGENT || ') not found';
		raise failed_validation;
	end if;
	
	
	
	--dbms_output.put_line('l_collection_object_id: ' || l_collection_object_id);
	--dbms_output.put_line('l_entered_person_id: ' || l_entered_person_id);
	--dbms_output.put_line('l_accn_id: ' || l_accn_id);
	--dbms_output.put_line('l_taxon_name_id_1: ' || l_taxon_name_id_1);
	--dbms_output.put_line('l_taxa_formula: ' || l_taxa_formula);
	--dbms_output.put_line('l_id_made_by_agent_id: ' || l_id_made_by_agent_id);
	--dbms_output.put_line('l_cat_num: ' || l_cat_num);
	--dbms_output.put_line('l_collection_id: ' || l_collection_id);
	
	
	
	
	if l_collection_object_id IS NULL OR
		l_entered_person_id  IS NULL OR
		l_accn_id  IS NULL OR
		l_taxon_name_id_1  IS NULL OR
		l_taxa_formula  IS NULL OR
		l_id_made_by_agent_id  IS NULL OR
		l_cat_num  IS NULL OR
		l_collection_id  IS NULL THEN
		error_msg := 'Failed to set key values at b_build_keys_table';
		raise failed_validation;
	end if;
	

	insert into bulkloader_attempts (
		b_collection_object_id,
 		collection_object_id,
 		tstamp 
 	) values (
 		rec.collection_object_id,
 		l_collection_object_id,
 		sysdate
 	);
 	
 	commit;
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_build_keys_table',collobjid);
END;

---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulk_this is
	CURSOR rec_cursor IS SELECT collection_object_id from bulkloader where loaded is null and collection_object_id > 500 AND ROWNUM < 2000;
	n_collection_object_id cataloged_item.collection_object_id%TYPE;
	n_clocality_id locality.locality_id%TYPE;
	--error_msg varchar2(4000);  
	collobjid cataloged_item.collection_object_id%TYPE;
	l_loaded bulkloader.loaded%TYPE;
	thisError varchar2(4000);
begin
	FOR rec IN rec_cursor LOOP
		collobjid := rec.collection_object_id;
		-- run bulkloader check for this one record
		SELECT bulk_check_one(collobjid) INTO thisError FROM dual;
		if thisError is not null then
			if length(thisError) > 224 then
				thisError := substr(thisError,1,200) || ' {snip...}';
				 --dbms_output.put_line('thisError: ' || thisError);
			end if;
			update bulkloader set loaded = thisError where collection_object_id = collobjid;
		else
			-- passed preliminary checks, load it
			error_msg := NULL;
			b_build_keys_table(collobjid);
			--if error_msg is null then
			--	b_bulkload_locality(collobjid);
			--end if;
			if error_msg is null then
				b_bulkload_coll_event(collobjid);
				--dbms_output.put_line('back from b_bulkload_coll_event');
			end if;
			if error_msg is null then
				b_bulkload(collobjid);
				--dbms_output.put_line('back from b_bulkload');
			end if;
			if error_msg is null then
				b_bulkload_otherid(collobjid);
				--dbms_output.put_line('back from b_bulkload_otherid');
			end if;
			if error_msg is null then
				b_bulkload_parts(collobjid);
				--dbms_output.put_line('back from b_bulkload_parts');
			end if;
			if error_msg is null then
				b_bulkload_attribute(collobjid);
				--dbms_output.put_line('back from b_bulkload_attribute');
			end if;		
			--dbms_output.put_line('error_msg: ' || error_msg);
			if error_msg is null then
			    --dbms_output.put_line('deletING from bulkloader');
				delete from bulkloader where collection_object_id = collobjid;
				--dbms_output.put_line('deleted from bulkloader');
				--update bulkloader set loaded = 'spiffification complete' where collection_object_id = collobjid;
			else
				b_rollback_bulkloader (l_collection_object_id,collobjid);
			end if;	
			--dbms_output.put_line('end of b_bulk_this loop');
		end if;
		-- end passed check
	end loop;
	--b_bulk_enable;
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulk_this',collobjid);
end;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE check_and_load is
	num number;
begin
	-- preemptive strike: zap all coordinate-stuff where orig_lat_long_units is NULL
	--    in order to prevent this stuff from clogging up the triggers, etc.
	/*
	update bulkloader set
		DEC_LAT=null,
		DEC_LONG=null,
		LATDEG=null,
		LATMIN=null,
		DEC_LAT_MIN=null,
		UTM_ZONE=null,
		UTM_EW=null,
		UTM_NS=null,
		GEOREFERENCE_PROTOCOL=null,
		MAX_ERROR_UNITS=null,
		MAX_ERROR_DISTANCE=null,
		GEOREFERENCE_SOURCE=null,
		DATUM=null,
		LONGDIR=null,
		LONGSEC=null,
		LONGMIN=null,
		DEC_LONG_MIN=null,
		LONGDEG=null,
		LATDIR=null,
		LATSEC=null
		where ORIG_LAT_LONG_UNITS is null;

	*/
	--dbms_output.put_line('here i am');
	-- relies on table proc_bl_status:
	-- create table proc_bl_status (status number(1));
	select count(*) into num from proc_bl_status;
	if num != 1 then
		delete from proc_bl_status;
		insert into proc_bl_status (status) values (0);
		commit;
	end if;
	select status into num from proc_bl_status;
	if num = 0 then
		-- lock this process
		update proc_bl_status set status=1;
		commit;
		-- move bulkloader_check to b_bulk_this
		-- run it by-record
		--bulkloader_check;
		--dbms_output.put_line('back from check');
		b_bulk_this;
		-- update status table to indicate loading attempt complete
		update proc_bl_status set status=0;
		commit;
	end if;
end;
---------------------------------------------------------------------------------------------------------------------------------------------
END;
/

sho err;






