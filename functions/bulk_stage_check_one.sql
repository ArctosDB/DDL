/*
	:::::::::::::::::::::::::IMPORTANT:::::::::::::::::::::::::
	
	THE CODE IN THIS FILE IS DUPLICATED ELSEWHERE
	
	DO NOT MODIFY THIS FILE EXCEPT ACCORDING TO THESE INSTRUCTIONS
	
	This file differs from function bulk_check_one only in having table bulkloader replaced with bulkloader_stage
	
	This is in exactly one row of code.
	
	Also the name of the function - don't screw that up.
	
	Oh yea and the synonyms. Especially don't screw that up.
	
	DO NOT MODIFY THIS FILE EXCEPT ACCORDING TO THESE INSTRUCTIONS
	
	Edit bulk_check_one, copy/paste it here, then make the table-name replacement. This will ensure that we are consistent in
	checking bulkloading.
	
	DO NOT MODIFY THIS FILE EXCEPT ACCORDING TO THESE INSTRUCTIONS

	DO NOT REMOVE OR MODIFY THIS WARNING
	
	:::::::::::::::::::::::::IMPORTANT:::::::::::::::::::::::::
	
	
	CREATE OR REPLACE FUNCTION bulk_stage_check_one (colobjid  in NUMBER)

	FOR rec IN (SELECT * FROM bulkloader_stage where collection_object_id=colobjid) LOOP

*/


	CREATE OR REPLACE FUNCTION bulk_stage_check_one (colobjid  in NUMBER)
return varchar2
as
 thisError varchar2(4000);
 numRecs NUMBER;
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
 taxa_one varchar2(255);
 taxa_two varchar2(255);
 num number;
 tempStr VARCHAR2(255);
tempStr2 VARCHAR2(255);
collectionid NUMBER;
a_coln varchar2(255);
a_instn varchar2(255);
--- collection_cde as determined from guid_prefix
r_collection_cde varchar2(255);
  BEGIN
	FOR rec IN (SELECT * FROM bulkloader_stage where collection_object_id=colobjid) LOOP
		BEGIN
    		thisError := '';
    		--dbms_output.put_line('bulk_check_one');
    		select  /*+ RESULT_CACHE */ count(distinct(agent_id)) into numRecs from agent_name where agent_name_type='login' AND agent_name = rec.ENTEREDBY;
    		if (numRecs != 1) then
    			thisError :=  thisError || '; ENTEREDBY [ ' || rec.ENTEREDBY || ' ] matches ' || numRecs || ' login agents';
    		END IF;
		    IF rec.collection_id IS NULL THEN
    		    select  /*+ RESULT_CACHE */ count(*) into numRecs from collection where guid_prefix = rec.guid_prefix;
        		IF (numRecs = 0) THEN
        			thisError :=  thisError || '; guid_prefix is invalid';
        		else
        			select  /*+ RESULT_CACHE */ collection_cde into r_collection_cde from collection where guid_prefix = rec.guid_prefix;
        		END IF;
        	ELSE
        	    select  /*+ RESULT_CACHE */ count(distinct(collection_id)) into numRecs from collection where collection_id = rec.collection_id;
        	    IF (numRecs = 0) THEN
        			thisError :=  thisError || '; COLLECTION_ID is invalid';
        		else
        			select  /*+ RESULT_CACHE */ collection_cde into r_collection_cde from collection where collection_id = rec.collection_id;
        		END IF;
		    END IF;
    		IF (rec.cat_num is not null) THEN
    			select  /*+ RESULT_CACHE */ count(*) into numRecs from collection,cataloged_item where
    				collection.collection_id = cataloged_item.collection_id AND
    				collection.guid_prefix = rec.guid_prefix and
    				cat_num=rec.cat_num;
    			IF (numRecs > 0) THEN
    				thisError :=  thisError || '; CAT_NUM is invalid (dup)';
    			END IF;
    		END IF;
    		IF (rec.cat_num = '0') THEN
    			thisError :=  thisError || '; CAT_NUM may not be 0';
    		END IF;
  
    		-- only care about collecting event, locality, and geog if we've not prepicked a collecting_event_id
    		IF rec.collecting_event_id IS NULL AND rec.collecting_event_name IS NULL THEN
    		   IF rec.locality_id IS NULL AND rec.locality_name IS NULL THEN -- only care about locality if no event picked        		
            		SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM geog_auth_rec WHERE higher_geog = rec.higher_geog;
            		IF (numRecs != 1) THEN
            			thisError :=  thisError || '; HIGHER_GEOG matches ' || numRecs || ' records';
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
		    	    IF rec.min_depth is not null OR rec.max_depth is not null OR rec.depth_units is not null then
		    	    	-- they have some depth info
		    	    	if isnumeric(rec.min_depth) = 0 OR isnumeric(rec.max_depth) = 0 THEN
            				thisError :=  thisError || '; DEPTH (' || rec.min_depth || '-' || rec.max_depth || ':' || rec.depth_units || ') is invalid';
            			END IF;
            		END IF;	
            		IF (rec.depth_units is not null) THEN
            			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctdepth_units where depth_units=rec.depth_units;
            			IF (numRecs = 0) THEN
            				thisError :=  thisError || '; DEPTH_UNITS is invalid';
            			END IF;
            			if rec.MIN_DEPTH is null or is_number(rec.MIN_DEPTH) = 0 OR rec.MAX_DEPTH is null or is_number(rec.MAX_DEPTH) = 0 then
            				thisError :=  thisError || '; MIN_DEPTH and/or MAX_DEPTH is invalid';
            			END IF;
            		END IF;
            		IF (rec.orig_lat_long_units is NOT null) THEN
			            select  /*+ RESULT_CACHE */ count(*) INTO numRecs from ctlat_long_units where orig_lat_long_units=rec.orig_lat_long_units;
            			IF (numRecs = 0) THEN
            				thisError :=  thisError || '; ORIG_LAT_LONG_UNITS is invalid';
            			END IF;
            			
            			IF (rec.orig_lat_long_units = 'decimal degrees') THEN
            				IF (isnumeric(rec.dec_lat) = 0 OR isnumeric(rec.dec_long) = 0  OR 
            					rec.dec_long < -180 OR rec.dec_long > 180 OR rec.dec_lat < -90 OR rec.dec_lat > 90) THEN	
            					thisError :=  thisError || '; DECLAT or DECLONG is invalid';
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
            				IF (rec.latdir <> 'N' AND rec.latdir <> 'S') THEN
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
            				IF (rec.latdir != 'N' AND rec.latdir != 'S') THEN
            					thisError := thisError || ' stuff broke at coordinates';
            				END IF;
            				IF (rec.longdir <> 'E' AND rec.longdir <> 'W') THEN
            					thisError :=  thisError || '; LONGDIR is invalid';
            				END IF;
            			ELSIF (rec.orig_lat_long_units = 'UTM') THEN
            				IF isnumeric(rec.UTM_EW) = 0 OR isnumeric(rec.UTM_NS) = 0 THEN
            					thisError := thisError || '; UTM_EW or UTM_NS is invalid';
            				END IF;	
            			END IF;
            			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs from ctdatum where datum=rec.datum;
            			IF (numRecs = 0) THEN
            				thisError :=  thisError || '; DATUM is invalid';
            			END IF;
            			
            		
            			IF (rec.georeference_source is null) THEN
            				thisError :=  thisError || '; GEOREFERENCE_SOURCE is required';
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
			            select  /*+ RESULT_CACHE */ count(*) INTO numRecs from CTgeoreference_protocol where georeference_protocol = rec.georeference_protocol;
            			IF (numRecs = 0) THEN
            				thisError :=  thisError || '; GEOREFERENCE_PROTOCOL is invalid';
            			END IF;
            			
            			IF (rec.VERIFICATIONSTATUS != 'unverified') THEN
            				thisError :=  thisError || '; VERIFICATIONSTATUS must be unverified for initial load';
            			END IF;	
            			--SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs from CTVERIFICATIONSTATUS where VERIFICATIONSTATUS = rec.VERIFICATIONSTATUS;
            			--IF (numRecs = 0) THEN
            			--	thisError :=  thisError || '; VERIFICATIONSTATUS is invalid';
            			--END IF;	
            		END IF;  -- end lat/long check
            		---------------------------------------------------- geol att ----------------------------------------------------  		
            		  
        		    IF rec.GEOLOGY_ATTRIBUTE_1 is not null and rec.GEO_ATT_VALUE_1 is not null THEN
    				    SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM geology_attribute_hierarchy WHERE ATTRIBUTE = rec.GEOLOGY_ATTRIBUTE_1 and ATTRIBUTE_VALUE=rec.GEO_ATT_VALUE_1 and USABLE_VALUE_FG=1;
                		IF (numRecs = 0) THEN
                			thisError :=  thisError || '; GEOLOGY_ATTRIBUTE_1 is invalid';
                		END IF;
                		if rec.GEO_ATT_DETERMINED_DATE_1 is NOT null AND isdate(rec.GEO_ATT_DETERMINED_DATE_1)=0 then
                			thisError:=thisError || '; GEO_ATT_DETERMINED_DATE_1 is invalid';
                		end if;
                		IF rec.GEO_ATT_DETERMINER_1 IS NOT NULL THEN
                		    numRecs := isValidAgent(rec.GEO_ATT_DETERMINER_1);
                			if numRecs != 1 then
                    			thisError :=  thisError || '; GEO_ATT_DETERMINER_1 matches ' || numRecs || ' agents';
                    		end if;
                		END IF;
    				END IF;
    				IF rec.GEOLOGY_ATTRIBUTE_2 is not null and rec.GEO_ATT_VALUE_2 is not null THEN
    				    SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM geology_attribute_hierarchy WHERE ATTRIBUTE = rec.GEOLOGY_ATTRIBUTE_2 and ATTRIBUTE_VALUE=rec.GEO_ATT_VALUE_2 and USABLE_VALUE_FG=1;
                		IF (numRecs = 0) THEN
                			thisError :=  thisError || '; GEOLOGY_ATTRIBUTE_2 is invalid';
                		END IF;
                		if rec.GEO_ATT_DETERMINED_DATE_2 is NOT null AND isdate(rec.GEO_ATT_DETERMINED_DATE_2)=0 then
                			thisError:=thisError || '; GEO_ATT_DETERMINED_DATE_2 is invalid';
                		end if;
                		IF rec.GEO_ATT_DETERMINER_2 IS NOT NULL THEN
                		    numRecs := isValidAgent(rec.GEO_ATT_DETERMINER_2);
                			if numRecs != 1 then
                    			thisError :=  thisError || '; GEO_ATT_DETERMINER_2 matches ' || numRecs || ' agents';
                    		end if;
                		END IF;
    				END IF;
    				IF rec.GEOLOGY_ATTRIBUTE_3 is not null and rec.GEO_ATT_VALUE_3 is not null THEN
    				    SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM geology_attribute_hierarchy WHERE ATTRIBUTE = rec.GEOLOGY_ATTRIBUTE_3 and ATTRIBUTE_VALUE=rec.GEO_ATT_VALUE_3 and USABLE_VALUE_FG=1;
                		IF (numRecs = 0) THEN
                			thisError :=  thisError || '; GEOLOGY_ATTRIBUTE_3 is invalid';
                		END IF;
                		if rec.GEO_ATT_DETERMINED_DATE_3 is NOT null AND isdate(rec.GEO_ATT_DETERMINED_DATE_3)=0 then
                			thisError:=thisError || '; GEO_ATT_DETERMINED_DATE_3 is invalid';
                		end if;
                		IF rec.GEO_ATT_DETERMINER_3 IS NOT NULL THEN
                		    numRecs := isValidAgent(rec.GEO_ATT_DETERMINER_3);
                			if numRecs != 1 then
                    			thisError :=  thisError || '; GEO_ATT_DETERMINER_3 matches ' || numRecs || ' agents';
                    		end if;
                		END IF;
    				END IF;
    				IF rec.GEOLOGY_ATTRIBUTE_4 is not null and rec.GEO_ATT_VALUE_4 is not null THEN
    				    SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM geology_attribute_hierarchy WHERE ATTRIBUTE = rec.GEOLOGY_ATTRIBUTE_4 and ATTRIBUTE_VALUE=rec.GEO_ATT_VALUE_4 and USABLE_VALUE_FG=1;
                		IF (numRecs = 0) THEN
                			thisError :=  thisError || '; GEOLOGY_ATTRIBUTE_4 is invalid';
                		END IF;
                		if rec.GEO_ATT_DETERMINED_DATE_4 is NOT null AND isdate(rec.GEO_ATT_DETERMINED_DATE_4)=0 then
                			thisError:=thisError || '; GEO_ATT_DETERMINED_DATE_4 is invalid';
                		end if;
                		IF rec.GEO_ATT_DETERMINER_4 IS NOT NULL THEN
                		    numRecs := isValidAgent(rec.GEO_ATT_DETERMINER_4);
                			if numRecs != 1 then
                    			thisError :=  thisError || '; GEO_ATT_DETERMINER_4 matches ' || numRecs || ' agents';
                    		end if;
                		END IF;
    				END IF;
    				IF rec.GEOLOGY_ATTRIBUTE_5 is not null and rec.GEO_ATT_VALUE_5 is not null THEN
    				    SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM geology_attribute_hierarchy WHERE ATTRIBUTE = rec.GEOLOGY_ATTRIBUTE_5 and ATTRIBUTE_VALUE=rec.GEO_ATT_VALUE_5 and USABLE_VALUE_FG=1;
                		IF (numRecs = 0) THEN
                			thisError :=  thisError || '; GEOLOGY_ATTRIBUTE_5 is invalid';
                		END IF;
                		if rec.GEO_ATT_DETERMINED_DATE_5 is NOT null AND isdate(rec.GEO_ATT_DETERMINED_DATE_5)=0 then
                			thisError:=thisError || '; GEO_ATT_DETERMINED_DATE_5 is invalid';
                		end if;
                		IF rec.GEO_ATT_DETERMINER_5 IS NOT NULL THEN
                		    numRecs := isValidAgent(rec.GEO_ATT_DETERMINER_5);
                			if numRecs != 1 then
                    			thisError :=  thisError || '; GEO_ATT_DETERMINER_5 matches ' || numRecs || ' agents';
                    		end if;
                		END IF;
    				END IF;
    				IF rec.GEOLOGY_ATTRIBUTE_6 is not null and rec.GEO_ATT_VALUE_6 is not null THEN
    				    SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM geology_attribute_hierarchy WHERE ATTRIBUTE = rec.GEOLOGY_ATTRIBUTE_6 and ATTRIBUTE_VALUE=rec.GEO_ATT_VALUE_6 and USABLE_VALUE_FG=1;
                		IF (numRecs = 0) THEN
                			thisError :=  thisError || '; GEOLOGY_ATTRIBUTE_6 is invalid';
                		END IF;
                		if rec.GEO_ATT_DETERMINED_DATE_6 is NOT null AND isdate(rec.GEO_ATT_DETERMINED_DATE_6)=0 then
                			thisError:=thisError || '; GEO_ATT_DETERMINED_DATE_6 is invalid';
                		end if;
                		IF rec.GEO_ATT_DETERMINER_6 IS NOT NULL THEN
                		    numRecs := isValidAgent(rec.GEO_ATT_DETERMINER_6);
                			if numRecs != 1 then
                    			thisError :=  thisError || '; GEO_ATT_DETERMINER_6 matches ' || numRecs || ' agents';
                    		end if;
                		END IF;
    				END IF;
    		               
    		               		
                ELSE -- no event picked; locality IS picked by either name or ID
                    IF rec.locality_id IS NOT NULL THEN
                    	if is_number(rec.locality_id) = 0 then
                    		thisError :=  thisError || '; LOCALITY_ID must be numeric - did you mean to specify a pre-existing locality_name?';
                    	else
	                        SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM locality WHERE locality_id = rec.locality_id;
	                		if numRecs = 0 then
	                			thisError :=  thisError || '; LOCALITY_ID is invalid';
	                		END IF;
	                	END IF;
                	ELSIF rec.locality_name IS NOT NULL THEN
                	     SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM locality WHERE locality_name = rec.locality_name;
                    	if numRecs != 1 then
                    		thisError :=  thisError || '; locality_name does not exist';
                    	END IF;
                    ELSE
                    		thisError :=  thisError || '; strange things happened in locality picked chooser';
                	END IF;
            	END IF;  -- end locality_id check; event NOT picked
              
		        IF (rec.verbatim_locality is null) THEN
			        thisError :=  thisError || '; VERBATIM_LOCALITY is required';
		        END IF;
		        numRecs := isValidAgent(rec.event_assigned_by_agent);
    			IF (numRecs != 1) THEN
		            thisError :=  thisError || '; EVENT_ASSIGNED_BY_AGENT [ ' || rec.event_assigned_by_agent || ' ] matches ' || numRecs || ' agents';
	            END IF;
            	IF ISDATE(rec.event_assigned_date,1) != 1 OR rec.event_assigned_date is null THEN
    				thisError :=  thisError || '; EVENT_ASSIGNED_DATE is invalid';
    			END IF;
    			 SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_event_type WHERE specimen_event_type = rec.specimen_event_type;
            		if numRecs = 0 then
            			thisError :=  thisError || '; SPECIMEN_EVENT_TYPE is invalid';
            		END IF;   
    			    
    			    
    			    
		         IF rec.COLLECTING_SOURCE IS NOT NULL THEN   
            		SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctCOLLECTING_SOURCE WHERE COLLECTING_SOURCE = rec.COLLECTING_SOURCE;
            		if numRecs = 0 then
            			thisError :=  thisError || '; COLLECTING_SOURCE is invalid';
            		END IF;
		         END IF;
        		IF (is_iso8601(rec.began_date,1)!='valid' OR rec.began_date is null) THEN
        			thisError :=  thisError || '; BEGAN_DATE is invalid';
        		END IF;
        		IF (is_iso8601(rec.ended_date,1)!='valid' OR rec.ended_date is null) THEN
        			thisError :=  thisError || '; ENDED_DATE is invalid';
        		END IF;
        		IF (rec.verbatim_date is null) THEN
        			thisError :=  thisError || '; VERBATIM_DATE is invalid';
        		END IF;
            ELSE -- collecting_event_id is NOT null    	  
        	    IF rec.collecting_event_id IS NOT NULL THEN
            	    SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM collecting_event WHERE collecting_event_id = rec.collecting_event_id;
            		if numRecs = 0 then
            			thisError :=  thisError || '; COLLECTING_EVENT_ID is invalid';
            		END IF;
            		ELSIF rec.collecting_event_name IS NOT NULL THEN
            		    SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM collecting_event WHERE collecting_event_name = rec.collecting_event_name;
                		if numRecs != 1 then
                			thisError :=  thisError || '; COLLECTING_EVENT_NAME is invalid';
                		END IF;
                	ELSE
                    		thisError :=  thisError || '; strange things happened in collecting_event picked chooser';
            		END IF;
            END IF; -- end collecting_event_id/locality_id check
    		
    		IF (rec.made_date is NOT null AND is_iso8601(rec.made_date,1) != 'valid') THEN
    			thisError :=  thisError || '; MADE_DATE is invalid';
    		END IF;
    	    SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs from ctnature_of_id WHERE nature_of_id = rec.nature_of_id;
    		IF (numRecs = 0) THEN
    			thisError :=  thisError || '; NATURE_OF_ID is invalid';
    		END IF;	
    		IF (rec.taxon_name is null) THEN
    			thisError :=  thisError || '; TAXON_NAME is required';
    		ELSE
        		if (instr(rec.taxon_name,' {') > 1 AND instr(rec.taxon_name,'}') > 1) then
        			taxa_one := regexp_replace(rec.taxon_name,' {.*}$','');
        		ELSIF instr(rec.taxon_name,' or ') > 1 then
        			num := instr(rec.taxon_name, ' or ') -1;
        			taxa_one := substr(rec.taxon_name,1,num);
        			taxa_two := substr(rec.taxon_name,num+5);
        		ELSIF instr(rec.taxon_name,' and ') > 1 then
        			num := instr(rec.taxon_name, ' and ') -1;
        			taxa_one := substr(rec.taxon_name,1,num);
        			taxa_two := substr(rec.taxon_name,num+5);
        		elsif instr(rec.taxon_name,' x ') > 1 then
        			num := instr(rec.taxon_name, ' x ') -1;
        			taxa_one := substr(rec.taxon_name,1,num);
        			taxa_two := substr(rec.taxon_name,num+4);
        		elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' sp.' then
        			taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
        		elsif  substr(rec.taxon_name,length(rec.taxon_name) - 4) = ' ssp.' then
        			taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 4);
        		elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' cf.' then
        			taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
        		elsif  substr(rec.taxon_name,length(rec.taxon_name) - 1) = ' ?' then
        			taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 1);
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
        			select /*+ RESULT_CACHE */ count(distinct(taxon_name_id)) into numRecs from taxon_name where scientific_name = trim(taxa_one) ;
        			if numRecs = 0 then
        				thisError :=  thisError || '; TAXON_NAME (' || taxa_one || ') not found';
        			end if;
        		end if;
        		if taxa_two is not null then
        			select /*+ RESULT_CACHE */ count(distinct(taxon_name_id)) into numRecs from taxon_name where scientific_name = trim(taxa_two) ;
        			if numRecs = 0 then
        				thisError :=  thisError || '; TAXON_NAME (' || taxa_two || ') not found';
        			end if;
        		end if;
            END IF;
    		numRecs := isValidAgent(rec.ID_MADE_BY_AGENT);
    		IF (numRecs != 1) THEN
    			thisError :=  thisError || '; ID_MADE_BY_AGENT [ ' || rec.ID_MADE_BY_AGENT || ' ] matches ' || numRecs || ' agents';
    		END IF;
    		
    		IF rec.ATTRIBUTE_1 is not null and rec.ATTRIBUTE_VALUE_1 is not null THEN
    			select /*+ RESULT_CACHE */ isValidAttribute(rec.ATTRIBUTE_1,rec.ATTRIBUTE_VALUE_1,rec.ATTRIBUTE_UNITS_1,r_collection_cde) INTO numRecs from dual;
    			if numRecs = 0 then
    				thisError :=  thisError || '; ATTRIBUTE_1 is not valid';
    			end if;
    			if rec.ATTRIBUTE_DATE_1 is null or is_iso8601(rec.ATTRIBUTE_DATE_1,1) != 'valid' then
    				thisError :=  thisError || '; ATTRIBUTE_DATE_1 is invalid';
    			end if;
    			numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_1);
    			if numRecs !=1 then
					thisError :=  thisError || '; ATTRIBUTE_DETERMINER_1 [ ' || rec.ATTRIBUTE_DETERMINER_1 || ' ] matches ' || numRecs || ' agents';
				end if;
    		end if;
    		IF rec.ATTRIBUTE_2 is not null and rec.ATTRIBUTE_VALUE_2 is not null THEN
    			select /*+ RESULT_CACHE */ isValidAttribute(rec.ATTRIBUTE_2,rec.ATTRIBUTE_VALUE_2,rec.ATTRIBUTE_UNITS_2,r_collection_cde) INTO numRecs from dual;
    			if numRecs = 0 then
    				thisError :=  thisError || '; ATTRIBUTE_2 is not valid';
    			end if;
    			if rec.ATTRIBUTE_DATE_2 is null or is_iso8601(rec.ATTRIBUTE_DATE_2,1) != 'valid' then
    				thisError :=  thisError || '; ATTRIBUTE_DATE_2 is invalid';
    			end if;
    			numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_2);
    			if numRecs !=1 THEN
					thisError :=  thisError || '; ATTRIBUTE_DETERMINER_2 [ ' || rec.ATTRIBUTE_DETERMINER_2 || ' ] matches ' || numRecs || ' agents';
				end if;
    		end if;
    		
    		IF rec.ATTRIBUTE_3 is not null and rec.ATTRIBUTE_VALUE_3 is not null THEN
    			select /*+ RESULT_CACHE */ isValidAttribute(rec.ATTRIBUTE_3,rec.ATTRIBUTE_VALUE_3,rec.ATTRIBUTE_UNITS_3,r_collection_cde) INTO numRecs from dual;
    			if numRecs = 0 then
    				thisError :=  thisError || '; ATTRIBUTE_3 is not valid';
    			end if;
    			if rec.ATTRIBUTE_DATE_3 is null or is_iso8601(rec.ATTRIBUTE_DATE_3,1) != 'valid' then
    				thisError :=  thisError || '; ATTRIBUTE_DATE_3 is invalid';
    			end if;
    			numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_3);
    			if numRecs !=1 THEN
					thisError :=  thisError || '; ATTRIBUTE_DETERMINER_3 [ ' || rec.ATTRIBUTE_DETERMINER_3 || ' ] matches ' || numRecs || ' agents';
				end if;
    		end if;
    		    
    		
    		IF rec.ATTRIBUTE_4 is not null and rec.ATTRIBUTE_VALUE_4 is not null THEN
    			select /*+ RESULT_CACHE */ isValidAttribute(rec.ATTRIBUTE_4,rec.ATTRIBUTE_VALUE_4,rec.ATTRIBUTE_UNITS_4,r_collection_cde) INTO numRecs from dual;
    			if numRecs = 0 then
    				thisError :=  thisError || '; ATTRIBUTE_4 is not valid';
    			end if;
    			if rec.ATTRIBUTE_DATE_4 is null or is_iso8601(rec.ATTRIBUTE_DATE_4,1) != 'valid' then
    				thisError :=  thisError || '; ATTRIBUTE_DATE_4 is invalid';
    			end if;
    			numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_4);
    			if numRecs !=1 THEN
					thisError :=  thisError || '; ATTRIBUTE_DETERMINER_4 [ ' || rec.ATTRIBUTE_DETERMINER_4 || ' ] matches ' || numRecs || ' agents';
				end if;
    		end if;    
    		
    		
    		IF rec.ATTRIBUTE_5 is not null and rec.ATTRIBUTE_VALUE_5 is not null THEN
    			select /*+ RESULT_CACHE */ isValidAttribute(rec.ATTRIBUTE_5,rec.ATTRIBUTE_VALUE_5,rec.ATTRIBUTE_UNITS_5,r_collection_cde) INTO numRecs from dual;
    			if numRecs = 0 then
    				thisError :=  thisError || '; ATTRIBUTE_5 is not valid';
    			end if;
    			if rec.ATTRIBUTE_DATE_5 is null or is_iso8601(rec.ATTRIBUTE_DATE_5,1) != 'valid' then
    				thisError :=  thisError || '; ATTRIBUTE_DATE_5 is invalid';
    			end if;
    			numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_5);
    			if numRecs !=1 THEN
					thisError :=  thisError || '; ATTRIBUTE_DETERMINER_5  [ ' || rec.ATTRIBUTE_DETERMINER_5 || ' ] matches ' || numRecs || ' agents';
				end if;
    		end if;
    		    
    		IF rec.ATTRIBUTE_6 is not null and rec.ATTRIBUTE_VALUE_6 is not null THEN
    			select /*+ RESULT_CACHE */ isValidAttribute(rec.ATTRIBUTE_6,rec.ATTRIBUTE_VALUE_6,rec.ATTRIBUTE_UNITS_6,r_collection_cde) INTO numRecs from dual;
    			if numRecs = 0 then
    				thisError :=  thisError || '; ATTRIBUTE_6 is not valid';
    			end if;
    			if rec.ATTRIBUTE_DATE_6 is null or is_iso8601(rec.ATTRIBUTE_DATE_6,1) != 'valid' then
    				thisError :=  thisError || '; ATTRIBUTE_DATE_6 is invalid';
    			end if;
    			numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_6);
    			if numRecs !=1 THEN
					thisError :=  thisError || '; ATTRIBUTE_DETERMINER_6 [ ' || rec.ATTRIBUTE_DETERMINER_6 || ' ] matches ' || numRecs || ' agents';
				end if;
    		end if;
    		
    		IF rec.ATTRIBUTE_7 is not null and rec.ATTRIBUTE_VALUE_7 is not null THEN
    			select /*+ RESULT_CACHE */ isValidAttribute(rec.ATTRIBUTE_7,rec.ATTRIBUTE_VALUE_7,rec.ATTRIBUTE_UNITS_7,r_collection_cde) INTO numRecs from dual;
    			if numRecs = 0 then
    				thisError :=  thisError || '; ATTRIBUTE_7 is not valid';
    			end if;
    			if rec.ATTRIBUTE_DATE_7 is null or is_iso8601(rec.ATTRIBUTE_DATE_7,1) != 'valid' then
    				thisError :=  thisError || '; ATTRIBUTE_DATE_7 is invalid';
    			end if;
    			numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_7);
    			if numRecs !=1 THEN
					thisError :=  thisError || '; ATTRIBUTE_DETERMINER_7 [ ' || rec.ATTRIBUTE_DETERMINER_7 || ' ] matches ' || numRecs || ' agents';
				end if;
    		end if;
    		
    		IF rec.ATTRIBUTE_8 is not null and rec.ATTRIBUTE_VALUE_8 is not null THEN
    			select /*+ RESULT_CACHE */ isValidAttribute(rec.ATTRIBUTE_8,rec.ATTRIBUTE_VALUE_8,rec.ATTRIBUTE_UNITS_8,r_collection_cde) INTO numRecs from dual;
    			if numRecs = 0 then
    				thisError :=  thisError || '; ATTRIBUTE_8 is not valid';
    			end if;
    			if rec.ATTRIBUTE_DATE_8 is null or is_iso8601(rec.ATTRIBUTE_DATE_8,1) != 'valid' then
    				thisError :=  thisError || '; ATTRIBUTE_DATE_8 is invalid';
    			end if;
    			numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_8);
    			if numRecs !=1 THEN
					thisError :=  thisError || '; ATTRIBUTE_DETERMINER_8 [ ' || rec.ATTRIBUTE_DETERMINER_8 || ' ] matches ' || numRecs || ' agents';
				end if;
    		end if;
    		IF rec.ATTRIBUTE_9 is not null and rec.ATTRIBUTE_VALUE_9 is not null THEN
    			select /*+ RESULT_CACHE */ isValidAttribute(rec.ATTRIBUTE_9,rec.ATTRIBUTE_VALUE_9,rec.ATTRIBUTE_UNITS_9,r_collection_cde) INTO numRecs from dual;
    			if numRecs = 0 then
    				thisError :=  thisError || '; ATTRIBUTE_9 is not valid';
    			end if;
    			if rec.ATTRIBUTE_DATE_9 is null or is_iso8601(rec.ATTRIBUTE_DATE_9,1) != 'valid' then
    				thisError :=  thisError || '; ATTRIBUTE_DATE_9 is invalid';
    			end if;
    			numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_9);
    			if numRecs !=1 THEN
					thisError :=  thisError || '; ATTRIBUTE_DETERMINER_9 [ ' || rec.ATTRIBUTE_DETERMINER_9 || ' ] matches ' || numRecs || ' agents';
				end if;
    		end if;
    		    
    		IF rec.ATTRIBUTE_10 is not null and rec.ATTRIBUTE_VALUE_10 is not null THEN
    			select /*+ RESULT_CACHE */ isValidAttribute(rec.ATTRIBUTE_10,rec.ATTRIBUTE_VALUE_10,rec.ATTRIBUTE_UNITS_10,r_collection_cde) INTO numRecs from dual;
    			if numRecs = 0 then
    				thisError :=  thisError || '; ATTRIBUTE_10 is not valid';
    			end if;
    			if rec.ATTRIBUTE_DATE_10 is null or is_iso8601(rec.ATTRIBUTE_DATE_10,1) != 'valid' then
    				thisError :=  thisError || '; ATTRIBUTE_DATE_10 is invalid';
    			end if;
    			numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_10);
    			if numRecs !=1 THEN
					thisError :=  thisError || '; ATTRIBUTE_DETERMINER_10 [ ' || rec.ATTRIBUTE_DETERMINER_10 || ' ] matches ' || numRecs || ' agents';
				end if;
    		end if;
    		     
    		if rec.PART_NAME_1 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_1 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_1 is invalid';
				END IF;
				if rec.PART_CONDITION_1 is null then
    				thisError :=  thisError || '; PART_CONDITION_1 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_1 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_1;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_1 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_1;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_1 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_1 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_1 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_1 is null or is_number(rec.PART_LOT_COUNT_1) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_1 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_1;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_1 is invalid';
				END IF;
			end if;
			if rec.PART_NAME_2 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_2 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_2 is invalid';
				END IF;
				if rec.PART_CONDITION_2 is null then
    				thisError :=  thisError || '; PART_CONDITION_2 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_2 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_2;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_2 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_2;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_2 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_2 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_2 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_2 is null or is_number(rec.PART_LOT_COUNT_2) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_2 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_2;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_2 is invalid';
				END IF;
			end if;
			if rec.PART_NAME_3 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_3 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_3 is invalid';
				END IF;
				if rec.PART_CONDITION_3 is null then
    				thisError :=  thisError || '; PART_CONDITION_3 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_3 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_3;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_3 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_3;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_3 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_3 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_3 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_3 is null or is_number(rec.PART_LOT_COUNT_3) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_3 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_3;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_3 is invalid';
				END IF;
			end if;
			if rec.PART_NAME_4 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_4 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_4 is invalid';
				END IF;
				if rec.PART_CONDITION_4 is null then
    				thisError :=  thisError || '; PART_CONDITION_4 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_4 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_4;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_4 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_4;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_4 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_4 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_4 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_4 is null or is_number(rec.PART_LOT_COUNT_4) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_4 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_4;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_4 is invalid';
				END IF;
			end if;   
			if rec.PART_NAME_5 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_5 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_5 is invalid';
				END IF;
				if rec.PART_CONDITION_5 is null then
    				thisError :=  thisError || '; PART_CONDITION_5 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_5 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_5;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_5 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_5;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_5 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_5 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_5 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_5 is null or is_number(rec.PART_LOT_COUNT_5) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_5 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_5;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_5 is invalid';
				END IF;
			end if;
			if rec.PART_NAME_6 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_6 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_6 is invalid';
				END IF;
				if rec.PART_CONDITION_6 is null then
    				thisError :=  thisError || '; PART_CONDITION_6 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_6 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_6;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_6 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_6;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_6 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_6 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_6 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_6 is null or is_number(rec.PART_LOT_COUNT_6) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_6 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_6;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_6 is invalid';
				END IF;
			end if;
			if rec.PART_NAME_7 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_7 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_7 is invalid';
				END IF;
				if rec.PART_CONDITION_7 is null then
    				thisError :=  thisError || '; PART_CONDITION_7 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_7 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_7;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_7 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_7;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_7 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_7 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_7 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_7 is null or is_number(rec.PART_LOT_COUNT_7) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_7 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_7;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_7 is invalid';
				END IF;
			end if;
			if rec.PART_NAME_8 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_8 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_8 is invalid';
				END IF;
				if rec.PART_CONDITION_8 is null then
    				thisError :=  thisError || '; PART_CONDITION_8 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_8 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_8;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_8 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_8;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_8 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_8 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_8 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_8 is null or is_number(rec.PART_LOT_COUNT_8) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_8 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_8;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_8 is invalid';
				END IF;
			end if;
			if rec.PART_NAME_9 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_9 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_9 is invalid';
				END IF;
				if rec.PART_CONDITION_9 is null then
    				thisError :=  thisError || '; PART_CONDITION_9 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_9 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_9;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_9 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_9;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_9 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_9 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_9 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_9 is null or is_number(rec.PART_LOT_COUNT_9) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_9 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_9;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_9 is invalid';
				END IF;
			end if;
			if rec.PART_NAME_10 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_10 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_10 is invalid';
				END IF;
				if rec.PART_CONDITION_10 is null then
    				thisError :=  thisError || '; PART_CONDITION_10 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_10 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_10;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_10 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_10;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_10 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_10 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_10 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_10 is null or is_number(rec.PART_LOT_COUNT_10) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_10 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_10;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_10 is invalid';
				END IF;
			end if;           
			if rec.PART_NAME_11 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_11 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_11 is invalid';
				END IF;
				if rec.PART_CONDITION_11 is null then
    				thisError :=  thisError || '; PART_CONDITION_11 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_11 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_11;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_11 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_11;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_11 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_11 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_11 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_11 is null or is_number(rec.PART_LOT_COUNT_11) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_11 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_11;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_11 is invalid';
				END IF;
			end if;
			if rec.PART_NAME_12 is not null then
    			SELECT  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_12 AND collection_cde = r_collection_cde;
				IF (numRecs = 0) THEN
					thisError :=  thisError || '; PART_NAME_12 is invalid';
				END IF;
				if rec.PART_CONDITION_12 is null then
    				thisError :=  thisError || '; PART_CONDITION_12 is invalid';
    			END IF;
    			
    			if rec.PART_BARCODE_12 is not null then
    				SELECT  /*+ RESULT_CACHE */  count(*) INTO numRecs FROM container WHERE barcode = rec.PART_BARCODE_12;
    				if numRecs = 0 then
    					thisError :=  thisError || '; PART_BARCODE_12 is invalid';
    				END IF;
    				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_12;
   					if numRecs != 0 then
   						thisError :=  thisError || '; PART_BARCODE_12 is a label';
   					END IF;
    			else
    				if rec.PART_CONTAINER_LABEL_12 is not null then
    					thisError :=  thisError || '; PART_CONTAINER_LABEL_12 requires barcode';
    				END IF;
    			END IF;
    			if rec.PART_LOT_COUNT_12 is null or is_number(rec.PART_LOT_COUNT_12) = 0 then
    				thisError :=  thisError || '; PART_LOT_COUNT_12 is invalid';
    			END IF;
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_12;
				if numRecs = 0 then
					thisError :=  thisError || '; PART_DISPOSITION_12 is invalid';
				END IF;
			end if;
			
    		if rec.OTHER_ID_NUM_1 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE = rec.OTHER_ID_NUM_TYPE_1;
				if numRecs = 0 then
					thisError :=  thisError || '; OTHER_ID_NUM_TYPE_1 not found';
				END IF;
			END IF;
			if rec.OTHER_ID_NUM_2 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE = rec.OTHER_ID_NUM_TYPE_2;
				if numRecs = 0 then
					thisError :=  thisError || '; OTHER_ID_NUM_TYPE_2 not found';
				END IF;
			END IF;
			if rec.OTHER_ID_NUM_3 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE = rec.OTHER_ID_NUM_TYPE_3;
				if numRecs = 0 then
					thisError :=  thisError || '; OTHER_ID_NUM_TYPE_3 not found';
				END IF;
			END IF;
			if rec.OTHER_ID_NUM_4 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE = rec.OTHER_ID_NUM_TYPE_4;
				if numRecs = 0 then
					thisError :=  thisError || '; OTHER_ID_NUM_TYPE_4 not found';
				END IF;
			END IF;
			if rec.OTHER_ID_NUM_5 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE = rec.OTHER_ID_NUM_TYPE_5;
				if numRecs = 0 then
					thisError :=  thisError || '; OTHER_ID_NUM_TYPE_5 not found';
				END IF;
			END IF;
			
			
	
     		-- horrendous copypasta is much faster than any evaluative loop
    		-- I could write, so deal with it or write something better.
     		
     	
			
			if rec.COLLECTOR_AGENT_1 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcollector_role WHERE collector_role = rec.COLLECTOR_ROLE_1;
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_ROLE_1 is invalid';
				end if;
				numRecs := isValidAgent(rec.COLLECTOR_AGENT_1);
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_AGENT_1 [ ' || rec.COLLECTOR_AGENT_1 || ' ] matches ' || numRecs || ' agents';
				END IF;
			end if;
			
			if rec.COLLECTOR_AGENT_2 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcollector_role WHERE collector_role = rec.COLLECTOR_ROLE_2;
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_ROLE_2 is invalid';
				end if;
				numRecs := isValidAgent(rec.COLLECTOR_AGENT_2);
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_AGENT_2 [ ' || rec.COLLECTOR_AGENT_2 || ' ] matches ' || numRecs || ' agents';
				END IF;
			end if;
			if rec.COLLECTOR_AGENT_3 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcollector_role WHERE collector_role = rec.COLLECTOR_ROLE_3;
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_ROLE_3 is invalid';
				end if;
				numRecs := isValidAgent(rec.COLLECTOR_AGENT_3);
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_AGENT_3 [ ' || rec.COLLECTOR_AGENT_3 || ' ] matches ' || numRecs || ' agents';
				END IF;
			end if;
			if rec.COLLECTOR_AGENT_4 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcollector_role WHERE collector_role = rec.COLLECTOR_ROLE_4;
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_ROLE_4 is invalid';
				end if;
				numRecs := isValidAgent(rec.COLLECTOR_AGENT_4);
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_AGENT_4 [ ' || rec.COLLECTOR_AGENT_4 || ' ] matches ' || numRecs || ' agents';
				END IF;
			end if;
			if rec.COLLECTOR_AGENT_5 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcollector_role WHERE collector_role = rec.COLLECTOR_ROLE_5;
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_ROLE_5 is invalid';
				end if;
				numRecs := isValidAgent(rec.COLLECTOR_AGENT_5);
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_AGENT_5 [ ' || rec.COLLECTOR_AGENT_5 || ' ] matches ' || numRecs || ' agents';
				END IF;
			end if;
			if rec.COLLECTOR_AGENT_6 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcollector_role WHERE collector_role = rec.COLLECTOR_ROLE_6;
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_ROLE_6 is invalid';
				end if;
				numRecs := isValidAgent(rec.COLLECTOR_AGENT_6);
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_AGENT_6 [ ' || rec.COLLECTOR_AGENT_6 || ' ] matches ' || numRecs || ' agents';
				END IF;
			end if;
			if rec.COLLECTOR_AGENT_7 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcollector_role WHERE collector_role = rec.COLLECTOR_ROLE_7;
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_ROLE_7 is invalid';
				end if;
				numRecs := isValidAgent(rec.COLLECTOR_AGENT_7);
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_AGENT_7 [ ' || rec.COLLECTOR_AGENT_7 || ' ] matches ' || numRecs || ' agents';
				END IF;
			end if;
			if rec.COLLECTOR_AGENT_8 is not null then
				SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctcollector_role WHERE collector_role = rec.COLLECTOR_ROLE_8;
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_ROLE_8 is invalid';
				end if;
				numRecs := isValidAgent(rec.COLLECTOR_AGENT_8);
				if numRecs != 1 then
					thisError :=  thisError || '; COLLECTOR_AGENT_8 [ ' || rec.COLLECTOR_AGENT_8 || ' ] matches ' || numRecs || ' agents';
				END IF;
			end if;
			
			
			   
    		if rec.flags is not null then
    			SELECT /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctflags WHERE FLAGS = rec.FLAGS;
    			if numRecs = 0 then
    				thisError :=  thisError || '; FLAGS is invalid';
    			END IF; 
    		end if;
        	IF rec.accn LIKE '[%' AND rec.accn LIKE '%]%' THEN
            	tempStr :=  trim(substr(rec.accn, instr(rec.accn,'[',1,1) + 1,instr(rec.accn,']',1,1) -2));
            	tempStr2 := trim(REPLACE(rec.accn,'['||tempStr||']'));
            	--tempStr:=REPLACE(tempStr,'[');
            	--tempStr:=REPLACE(tempStr,']');
                a_instn := substr(tempStr,1,instr(tempStr,':')-1);
                a_coln := substr(tempStr,instr(tempStr,':')+1);
              ELSE
                -- use same collection	
                tempStr:=rec.guid_prefix;
                tempStr2 := rec.accn;
        	END IF; 
            select /*+ RESULT_CACHE */ count(distinct(accn.transaction_id)) into numRecs from 
            	accn,trans,collection 
            	where 
            	accn.transaction_id = trans.transaction_id and
            	trans.collection_id=collection.collection_id AND
            	collection.guid_prefix = tempStr AND
            	accn_number = tempStr2;
    		if numRecs = 0 then
    			thisError :=  thisError || '; ACCN is invalid';
    		END IF;
		EXCEPTION
		    WHEN OTHERS THEN
		        thisError := SQLERRM || ': ' ||  SQLCODE;
		END;
	END LOOP;
	RETURN thisError;
END;
/
sho err;
CREATE OR REPLACE PUBLIC SYNONYM bulk_stage_check_one FOR bulk_stage_check_one;
GRANT EXECUTE ON bulk_stage_check_one TO PUBLIC;