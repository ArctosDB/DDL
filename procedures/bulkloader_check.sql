PROCEDURE BULKLOADER_CHECK EXISTS AS part OF bulkload.sql bulk_pkg.

This FILE IS obsolete.

DO NOT try TO COMPILE it


create or replace PROCEDURE BULKLOADER_CHECK_________do_not_compile_this
is
 thisError varchar2(4000);
 numRecs NUMBER;
 justAString varchar2(255);
 attributeType varchar2(255);
 attributeValue varchar2(255);
  attributeUnits varchar2(255);
 attributeDate varchar2(255);
 attributeDeterminer varchar2(255);
 attributeValueTable varchar2(255);
 attributeUnitsTable varchar2(255);
  attributeCodeTableColName varchar2(255);
 partName  varchar2(255);
 partCondition  varchar2(255);
 partBarcode  varchar2(255);
 partContainerLabel  varchar2(255);
 partLotCount  varchar2(255);
 partDisposition  varchar2(255);
 otherIdType varchar2(255);
 otherIdNum varchar2(255);
 collectorName varchar2(255);
 collectorRole  varchar2(255);
  tempStr VARCHAR2(255);
tempStr2 VARCHAR2(255);
 num number;
 taxa_one varchar2(255);
 taxa_two varchar2(255);
a_coln varchar2(255);
a_instn varchar2(255);
  BEGIN
	FOR rec IN (SELECT * FROM bulkloader WHERE loaded IS NULL) LOOP
	    dbms_output.put_line('I am bulkloader check');
	    --- AND ROWNUM < 10000
		thisError := '';
		 taxa_one := '';
         taxa_two := '';
		select  /*+ RESULT_CACHE */ count(distinct(agent_id)) into numRecs from agent_name where agent_name_type='login' AND agent_name = rec.ENTEREDBY;
		if (numRecs != 1) then
			thisError :=  thisError || '; ENTEREDBY matches ' || numRecs || ' agents';
		END IF;
		select  /*+ RESULT_CACHE */ count(*) into numRecs from collection where
					institution_acronym = rec.institution_acronym and
					collection_cde=rec.collection_cde;
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; INSTITUTION_ACRONYM and/or COLLECTION_CDE is invalid';
		END IF;
		IF (rec.cat_num is not null) THEN
			select  /*+ RESULT_CACHE */ count(*) into numRecs from collection,cataloged_item where
				collection.collection_id = cataloged_item.collection_id AND
				collection.institution_acronym = rec.institution_acronym and
				collection.collection_cde=rec.collection_cde AND
				cat_num=rec.cat_num;
			IF (numRecs > 0) THEN
				thisError :=  thisError || '; CAT_NUM is invalid';
			END IF;
		END IF;
		IF (rec.cat_num = 0) THEN
			thisError :=  thisError || '; CAT_NUM may not be 0';
		END IF;
		
		
		IF is_iso8601(rec.began_date) != 'valid' THEN
		    thisError :=  thisError || '; BEGAN_DATE is invalid';
		END IF;
		IF is_iso8601(rec.ended_date) != 'valid' THEN
			thisError :=  thisError || '; ENDED_DATE is invalid';
		END IF;
		IF (rec.verbatim_date is null) THEN
			thisError :=  thisError || '; VERBTIM_DATE is invalid';
		END IF;
		IF (rec.relationship is not null) THEN
			IF (rec.related_to_num_type is null OR rec.related_to_number is null) THEN
				thisError :=  thisError || '; ::RELATED_TO_NUMBER:: and ::RELATED_TO_NUM_TYPE:: are required when relationship is given';
			END IF;
			select  /*+ RESULT_CACHE */ count(*) into numRecs from ctbiol_relations where
				biol_indiv_relationship =rec.relationship;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; RELATIONSHIP is invalid';
			END IF;
			select  /*+ RESULT_CACHE */  count(*) into numRecs from ctcoll_other_id_type
				where other_id_type=rec.related_to_num_type;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; RELATED_TO_NUM_TYPE is invalid';
			END IF;
		END IF;
		select  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM geog_auth_rec WHERE higher_geog = rec.higher_geog;
		IF (numRecs != 1) THEN
			thisError :=  thisError || '; HIGHER_GEOG matched ' || numRecs || ' records';
		END IF;
		IF (isnumeric(rec.maximum_elevation) = 0) THEN
			thisError :=  thisError || '; MAXIMUM_ELEVATION is invalid';
		END IF;	
		IF (
			(rec.maximum_elevation is not null AND rec.minimum_elevation is null) OR
			(rec.minimum_elevation is not null AND rec.maximum_elevation is null) OR
			((rec.minimum_elevation is not null OR rec.maximum_elevation is not null) AND rec.orig_elev_units is null)
			) THEN
			thisError :=  thisError || '; MAXIMUM_ELEVATION,MINIMUM_ELEVATION,ORIG_ELEV_UNITS are all required if one is given';
		END IF;	
		IF (rec.orig_elev_units is not null) THEN
			select  /*+ RESULT_CACHE */ count(*) INTO numRecs from ctorig_elev_units where orig_elev_units = rec.orig_elev_units;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; ORIG_ELEV_UNITS is invalid';
			END IF;
		END IF;
		IF (rec.spec_locality is null) THEN
			thisError :=  thisError || '; SPEC_LOCALITY is required';
		END IF;
		
		IF (rec.orig_lat_long_units is NOT null) THEN
			select  /*+ RESULT_CACHE */ count(*) INTO numRecs from ctlat_long_units where orig_lat_long_units=rec.orig_lat_long_units;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; ORIG_ELEV_UNITS is invalid';
			END IF;
			
			IF (rec.orig_lat_long_units = 'decimal degrees') THEN
				IF (isnumeric(rec.dec_lat) = 0 OR isnumeric(rec.dec_long) = 0  OR 
					rec.dec_long < -180 OR rec.dec_long > 180 OR rec.dec_lat < -90 OR rec.dec_lat > 90) THEN	
					thisError :=  thisError || '; DEC_LAT or DEC_LONG is invalid';
				END IF;
			ELSIF (rec.orig_lat_long_units = 'deg. min. sec.') THEN	
				IF (isnumeric(rec.latdeg) = 0 OR rec.latdeg < 0 OR rec.latdeg > 90 OR
					isnumeric(rec.latmin) = 0 OR rec.latmin < 0 OR rec.latmin > 60 OR
					isnumeric(rec.latsec) = 0 OR rec.latsec < 0 OR rec.latsec > 60 OR
					isnumeric(rec.longdeg) = 0 OR rec.longdeg < 0 OR rec.longdeg > 180 OR
					isnumeric(rec.longmin) = 0 OR rec.longmin < 0 OR rec.longmin > 60 OR
					isnumeric(rec.longsec) = 0 OR rec.longsec < 0 OR rec.longsec > 60) THEN
					thisError :=  thisError || '; coordinates are invalid';
				END IF;	 
				IF (rec.latdir <> 'N' AND rec.LATDIR <> 'S') THEN
					thisError :=  thisError || '; LATDIR is invalid';
				END IF;
				IF (rec.longdir <> 'E' AND rec.longdir <> 'W') THEN
					thisError :=  thisError || '; LONGDIR is invalid';
				END IF;
			ELSIF (rec.orig_lat_long_units = 'degrees dec. minutes') THEN	
				IF (isnumeric(rec.latdeg) = 0 OR rec.latdeg < 0 OR rec.latdeg > 90 OR
					isnumeric(rec.dec_lat_min) = 0 OR rec.dec_lat_min < 0 OR rec.dec_lat_min > 60 OR
					isnumeric(rec.longdeg) = 0 OR rec.longdeg < 0 OR rec.longdeg > 180 OR
					isnumeric(rec.dec_long_min) = 0 OR rec.dec_long_min < 0 OR rec.dec_long_min > 60) THEN
					thisError :=  thisError || '; coordinates are invalid';
				END IF;	 
				IF (rec.latdir <> 'N' AND rec.latdir <> 'S') THEN
					thisError :=  thisError || '; LATDIR is invalid';
				END IF;
				IF (rec.longdir <> 'E' AND rec.longdir <> 'W') THEN
					thisError :=  thisError || '; LONGDIR is invalid';
				END IF;
			END IF;
			select  /*+ RESULT_CACHE */ count(*) INTO numRecs from ctdatum where datum =rec.datum;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; DATUM is invalid';
			END IF;
			select  /*+ RESULT_CACHE */ count(distinct(agent_id)) INTO numRecs from agent_name where agent_name = rec.determined_by_agent
				and agent_name_type <> 'Kew abbr.';
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; DETERMINED_BY_AGENT matches ' || numRecs || ' agents';
			END IF;
			IF is_iso8601(rec.determined_date) != 'valid' OR rec.determined_date is null THEN
				thisError :=  thisError || '; DETERMINED_DATE is invalid';
			END IF;
			IF (rec.lat_long_ref_source is null) THEN
				thisError :=  thisError || '; LAT_LONG_REF_SOURCE is required';
			END IF;
			IF (isnumeric(rec.max_error_distance) = 0) THEN
				thisError :=  thisError || '; MAX_ERROR_DISTANCE must be numeric';
			END IF;
			IF rec.max_error_units IS NOT NULL THEN
    			select  /*+ RESULT_CACHE */ count(*) INTO numRecs from CTLAT_LONG_ERROR_UNITS where LAT_LONG_ERROR_UNITS = rec.max_error_units;
    			IF (numRecs = 0) THEN
    				thisError :=  thisError || '; MAX_ERROR_UNITS is invalid';
    			END IF;
    		END IF;	
			select  /*+ RESULT_CACHE */ count(*) INTO numRecs from CTGEOREFMETHOD where GEOREFMETHOD = rec.GEOREFMETHOD;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; GEOREFMETHOD is invalid';
			END IF;
			select  /*+ RESULT_CACHE */ count(*) INTO numRecs from CTVERIFICATIONSTATUS where VERIFICATIONSTATUS = rec.VERIFICATIONSTATUS;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; VERIFICATIONSTATUS is invalid';
			END IF;	
		END IF;
		IF (rec.verbatim_locality is null) THEN
			thisError :=  thisError || '; VERBATIM_LOCALITY is required';
		END IF;
		IF (rec.made_date is NOT null AND is_iso8601(rec.made_date) != 'valid') THEN
			thisError :=  thisError || '; MADE_DATE is invalid';
		END IF;
		select  /*+ RESULT_CACHE */ count(*) INTO numRecs from ctnature_of_id WHERE nature_of_id = rec.nature_of_id;
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; NATURE_OF_ID is invalid';
		END IF;
--dbms_output.put_line('=============================================' );
--dbms_output.put_line('startingError: ' || thisError);
--dbms_output.put_line('taxon_name: ' || rec.taxon_name);
		IF (rec.taxon_name is null) THEN
			thisError :=  thisError || '; TAXON_NAME is required';
		ELSE
			if instr(rec.taxon_name,' or ') > 1 then
				num := instr(rec.taxon_name, ' or ') -1;
				taxa_one := substr(rec.taxon_name,1,num);
				taxa_two := substr(rec.taxon_name,num+5);
			elsif instr(rec.taxon_name,' x ') > 1 then
				num := instr(rec.taxon_name, ' x ') -1;
				taxa_one := substr(rec.taxon_name,1,num);
				taxa_two := substr(rec.taxon_name,num+4);
			elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' sp.' then
				taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
			elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' cf.' then
				taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
			elsif  substr(rec.taxon_name,length(rec.taxon_name) - 1) = ' ?' then
				taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 1);
			elsif (instr(rec.taxon_name,' {') > 1 AND instr(rec.taxon_name,'}') > 1) then
				taxa_one := regexp_replace(rec.taxon_name,' {.*}$','');
			else
				taxa_one := rec.taxon_name;
				
			end if;				
			if taxa_two is not null AND (
				  substr(taxa_one,length(taxa_one) - 3) = ' sp.' OR
					substr(taxa_two,length(taxa_two) - 3) = ' sp.' OR
					substr(taxa_one,length(taxa_one) - 1) = ' ?' OR
					substr(taxa_two,length(taxa_two) - 1) = ' ?' 
				) then
					thisError :=  thisError || '; "sp." and "?" are not allowed in multi-taxon IDs';
			end if;
			if taxa_one is not null then
				select count(distinct(taxon_name_id)) into numRecs from taxonomy where scientific_name = trim(taxa_one) and VALID_CATALOG_TERM_FG = 1;
				if numRecs = 0 then
					thisError :=  thisError || '; TAXON_NAME (' || taxa_one || ') not found';
				end if;
			end if;
			if taxa_two is not null then
				select count(distinct(taxon_name_id)) into numRecs from taxonomy where scientific_name = trim(taxa_two) and VALID_CATALOG_TERM_FG = 1;
				if numRecs = 0 then
					thisError :=  thisError || '; TAXON_NAME (' || taxa_two || ') not found';
				end if;
			end if;
		END IF;
--dbms_output.put_line('taxa_one: ' || taxa_one);
--dbms_output.put_line('taxa_two: ' || taxa_two);
--dbms_output.put_line('thisError: ' || thisError);
		select  /*+ RESULT_CACHE */ count(distinct(agent_id)) INTO numRecs from agent_name where agent_name = rec.ID_MADE_BY_AGENT
				and agent_name_type <> 'Kew abbr.';
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; ID_MADE_BY_AGENT matches ' || numRecs || ' agents';
		END IF;
		IF (rec.min_depth is not null OR rec.max_depth is not null OR rec.depth_units is not null OR 
			isnumeric(rec.min_depth) = 0 OR isnumeric(rec.max_depth) = 0) THEN
			thisError :=  thisError || '; depth is invalid';
		END IF;	
		IF (rec.depth_units is not null) THEN
			select  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctdepth_units where depth_units=rec.depth_units;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; DEPTH_UNITS is invalid';
			END IF;
			if rec.MIN_DEPTH is null or is_number(rec.MIN_DEPTH) = 0 OR rec.MAX_DEPTH is null or is_number(rec.MAX_DEPTH) = 0 then
				thisError :=  thisError || '; MIN_DEPTH and/or MAX_DEPTH is invalid';
			END IF;
		END IF;
		for i IN 1 .. 10 LOOP -- number of attributes
			attributeValueTable := NULL;
			attributeUnitsTable := NULL;
			execute immediate 'select  /*+ RESULT_CACHE */ 
					ATTRIBUTE_' || i || ',
					 ATTRIBUTE_VALUE_' || i || ',
					ATTRIBUTE_UNITS_' || i || ',
					 ATTRIBUTE_DATE_' || i || ',
					 ATTRIBUTE_DETERMINER_' || i || '
				 from bulkloader where  collection_object_id = ' || rec.collection_object_id into 
				 attributeType,
				 attributeValue,
				 attributeUnits,
				 attributeDate,
				 attributeDeterminer;
				IF attributeType is not null and attributeValue is not null THEN
					select  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctattribute_type WHERE ATTRIBUTE_TYPE = attributeType AND 
					collection_cde = rec.collection_cde;
					IF (numRecs = 0) THEN
						thisError :=  thisError || '; ATTRIBUTE_' || i || ' is invalid';
					END IF;
					execute immediate 'select  /*+ RESULT_CACHE */ count(*) FROM ctattribute_code_tables WHERE ATTRIBUTE_TYPE = ''' || attributeType || '''' INTO numRecs;
					IF (numRecs > 0) THEN
						select  /*+ RESULT_CACHE */ VALUE_CODE_TABLE,UNITS_CODE_TABLE into attributeValueTable,attributeUnitsTable
							FROM ctattribute_code_tables WHERE ATTRIBUTE_TYPE = attributeType;
						IF attributeValueTable is not null then
							execute immediate 'select  /*+ RESULT_CACHE */ count(*) from user_tab_cols where table_name = ''' ||attributeValueTable || '''
								and column_name=''COLLECTION_CDE''' into numRecs;
							execute immediate 'select  /*+ RESULT_CACHE */ column_name from user_tab_cols where table_name = ''' ||upper(attributeValueTable) || '''
								and column_name <> ''DESCRIPTION'' and column_name <> ''COLLECTION_CDE''' into attributeCodeTableColName;
							
							if numRecs = 1 then
								execute immediate 'select  /*+ RESULT_CACHE */ count(*) from ' || attributeValueTable || ' where ' || 
									attributeCodeTableColName || ' = ''' || attributeValue || ''' and collection_cde = ''' || 
									rec.collection_cde || '''' into numRecs;
								if numRecs = 0 then
									thisError :=  thisError || '; ATTRIBUTE_' || i || ' value is not in the code table';
								end if;
							else
								execute immediate 'select  /*+ RESULT_CACHE */ count(*) from ' || attributeValueTable || ' where ' || 
									attributeCodeTableColName || ' = ''' || attributeValue || '''' into numRecs;
								if numRecs = 0 then
									thisError :=  thisError || '; ATTRIBUTE_' || i || ' value is not in the code table';
								end if;
							end if;
						elsif attributeUnitsTable  is not null then
							execute immediate 'select  /*+ RESULT_CACHE */ count(*) from user_tab_cols where table_name = ''' || attributeUnitsTable || '''
								and column_name=''COLLECTION_CDE''' into numRecs;
							execute immediate 'select  /*+ RESULT_CACHE */ column_name from user_tab_cols where table_name = ''' ||upper(attributeUnitsTable) || '''
								and column_name <> ''DESCRIPTION'' and column_name <> ''COLLECTION_CDE''' into attributeCodeTableColName;
							if numRecs = 1 then
								execute immediate 'select  /*+ RESULT_CACHE */ count(*) from ' || attributeUnitsTable || ' where ' || 
									attributeCodeTableColName || ' = ''' || attributeUnits || ''' and collection_cde = ''' || 
									rec.collection_cde || '''' into numRecs;
								if numRecs = 0 then
									thisError :=  thisError || '; ATTRIBUTE_' || i || ' units is not in the code table';
								end if;
							else
								execute immediate 'select  /*+ RESULT_CACHE */ count(*) from ' || attributeUnitsTable || ' where ' || 
									attributeCodeTableColName || ' = ''' || attributeUnits || '''' into numRecs;
								if numRecs = 0 then
									thisError :=  thisError || '; ATTRIBUTE_' || i || ' units is not in the code table';
								end if;
							end if;
						END IF;	
					END IF;
					if attributeDate is null or is_iso8601(attributeDate) != 'valid' then
						thisError :=  thisError || '; ATTRIBUTE_DATE_' || i || ' is invalid';
					end if;
					attributeDeterminer:=REPLACE(attributeDeterminer,'''','''''');
					execute immediate 'select  /*+ RESULT_CACHE */ count(distinct(agent_id)) from agent_name where agent_name = ''' || attributeDeterminer ||'''' into numRecs;
					
					if numRecs = 0 then
						thisError :=  thisError || '; ATTRIBUTE_DETERMINER_' || i || ' is invalid';
					end if;
				END IF;
		end loop; -- end attributes loop
		for i IN 1 .. 12 LOOP -- number of parts
			partName := NULL;
			partCondition := NULL;
			partBarcode := NULL;
			partContainerLabel := NULL;
			partLotCount := NULL;
			partDisposition := NULL;
			 
				 execute immediate 'select  /*+ RESULT_CACHE */ 
					PART_NAME_' || i || ',
					PART_CONDITION_' || i || ',
					PART_BARCODE_' || i || ',
					PART_CONTAINER_LABEL_' || i || ',
					PART_LOT_COUNT_' || i || ',
					PART_DISPOSITION_' || i || '
				 from bulkloader where  collection_object_id = ' || rec.collection_object_id into 
				 partName,
				 partCondition,
				 partBarcode,
				 partContainerLabel,
				 partLotCount,
				 partDisposition;
			if partName is not null then
				select  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = partName AND 
					collection_cde = rec.collection_cde;
					IF (numRecs = 0) THEN
						thisError :=  thisError || '; PART_NAME_' || i || ' is invalid';
					END IF;
				if partCondition is null then
					thisError :=  thisError || '; PART_CONDITION_' || i || ' is invalid';
				END IF; 
				if partBarcode is not null then
					select  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE barcode = partBarcode;
					if numRecs = 0 then
						thisError :=  thisError || '; PART_BARCODE_' || i || ' is invalid';
					END IF;
					if partContainerLabel is null then
						thisError :=  thisError || '; PART_CONTAINER_LABEL_' || i || ' is invalid';
					END IF;
				else
					if partContainerLabel is not null then
						thisError :=  thisError || '; PART_CONTAINER_LABEL_' || i || ' is invalid';
					END IF;
				END IF;
				if partLotCount is null or is_number(partLotCount) = 0 then
					thisError :=  thisError || '; PART_LOT_COUNT_' || i || ' is invalid';
				END IF;
				select  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE partDisposition = partDisposition;
					if numRecs = 0 then
						thisError :=  thisError || '; PART_DISPOSITION_' || i || ' is invalid';
					END IF;
			END IF;
		end loop; -- end parts loop
		for i IN 1 .. 5 LOOP -- number of other IDs
			 execute immediate 'select  /*+ RESULT_CACHE */ 
					OTHER_ID_NUM_TYPE_' || i || ',
					OTHER_ID_NUM_' || i || '
				 from bulkloader where  collection_object_id = ' || rec.collection_object_id into 
				 otherIdType,
				 otherIdNum;
			if otherIdNum is not null then
				if otherIdType is not null then
					select  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE = otherIdType;
						if numRecs = 0 then
							thisError :=  thisError || '; OTHER_ID_NUM_TYPE_' || i || ' is invalid';
						END IF;
				else
					thisError :=  thisError || '; OTHER_ID_TYPE_' || i || ' is invalid';
				end if;
			end if;
 		end loop; -- end other ID loop
 		for i IN 1 .. 8 LOOP -- number of collectors
 			 execute immediate 'select  /*+ RESULT_CACHE */ 
					COLLECTOR_AGENT_' || i || ',
					COLLECTOR_ROLE_' || i || '
				 from bulkloader where  collection_object_id = ' || rec.collection_object_id into 
				 collectorName,
				 collectorRole;
			if i = 1 and (collectorName is null or collectorRole != 'c') then
				thisError :=  thisError || '; First collector is required';
			end if;
			if  collectorName is not null then
				select  /*+ RESULT_CACHE */ count(distinct(agent_id)) INTO numRecs FROM agent_name WHERE agent_name = collectorName;
					if numRecs = 0 then
						thisError :=  thisError || '; COLLECTOR_AGENT_' || i || ' is invalid';
					END IF;
				if collectorRole not in ('c','p') then
					thisError :=  thisError || '; COLLECTOR_ROLE_' || i || ' is invalid';
				end if;
			end if;
		end loop; -- end collector loop
		if rec.flags is not null then
			select  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctflags WHERE FLAGS = rec.FLAGS;
			if numRecs = 0 then
				thisError :=  thisError || '; FLAGS is invalid';
			END IF; 
		end if;
		    
	  
	  IF rec.accn LIKE '[%' AND rec.accn LIKE '%]%' THEN
    	tempStr :=  substr(rec.accn, instr(rec.accn,'[',1,1) + 1,instr(rec.accn,']',1,1) -2);
    	tempStr2 := REPLACE(rec.accn,'['||tempStr||']');
    	tempStr:=REPLACE(tempStr,'[');
    	tempStr:=REPLACE(tempStr,']');
    	a_instn := substr(tempStr,1,instr(tempStr,':')-1);
        a_coln := substr(tempStr,instr(tempStr,':')+1);
        --dbms_output.put_line('a_instn='||a_instn);
       -- dbms_output.put_line('a_coln='||a_coln);
        
      ELSE
        a_coln := rec.collection_cde;
        a_instn := rec.institution_acronym;
        tempStr2 := rec.accn;
	 END IF;
	    
	    
	    select  /*+ RESULT_CACHE */ count(distinct(accn.transaction_id)) into numRecs from accn,trans,collection where 
    	accn.transaction_id = trans.transaction_id and
    	trans.collection_id=collection.collection_id AND
    	collection.institution_acronym = a_instn and
    	collection.collection_cde = a_coln AND
    	accn_number = tempStr2;
    	
    	if numRecs = 0 then
			thisError :=  thisError || '; ACCN is invalid';
		END IF; 
    	
		
		select  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctCOLLECTING_SOURCE WHERE COLLECTING_SOURCE = rec.COLLECTING_SOURCE;
		if numRecs = 0 then
			thisError :=  thisError || '; COLLECTING_SOURCE is invalid';
		END IF;
		    
		
        if thisError is not null then
            if length(thisError) > 224 then
    			thisError := substr(thisError,1,200) || ' {snip...}';
    		end if;
            update bulkloader 
            set loaded = thisError 
            where collection_object_id = rec.collection_object_id;
        end if;
        --dbms_output.put_line (rec.collection_object_id ||': ' || thisError);
        
       
		--- dbms_output.put_line (rec.collection_object_id ||': ' || thisError);
	END LOOP;
END;
/
sho err
create OR REPLACE public synonym bulkloader_check for bulkloader_check;
 grant execute on bulkloader_check to public;