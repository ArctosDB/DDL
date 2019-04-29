
alter table filtered_flat add  locality_search_terms varchar2(4000);

-- filtered_flat is a table
-- should look a lot like flat


-- job to call the procedure that calls the procedure that syncs filtered flat

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'j_is_filtered_flat_stale',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'is_filtered_flat_stale',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'check recently updated records in flat; push to filtered_flat');
END;
/


select START_DATE,REPEAT_INTERVAL,END_DATE,ENABLED,STATE,RUN_COUNT,FAILURE_COUNT,LAST_START_DATE,LAST_RUN_DURATION,NEXT_RUN_DATE from all_scheduler_jobs where lower(job_name)='j_is_filtered_flat_stale';

 
 
-- procedure to call the update procedure
-- separate just for readability; no real cost to this so whatever
-- 15K rows takes ~40s in TEST
-- may need to adjust 
CREATE OR REPLACE PROCEDURE is_filtered_flat_stale IS 
    aid NUMBER;
BEGIN
	FOR r IN (
		SELECT 
		    collection_object_id
		FROM 
		    flat 
		WHERE 
		    stale_flag = 0 AND 
		    ROWNUM < 15000
	) LOOP
			BEGIN
		--dbms_output.put_line(r.collection_object_id);
		-- update flat_media set stale_fg=1 where collection_object_id = r.collection_object_id;
		update_filtered_flat(r.collection_object_id);
		
		--EXCEPTION
		----    WHEN OTHERS THEN
		--        NULL;
		END;
		-- this is in hte procedure, not needed here??
		--	UPDATE flat SET stale_flag = 0	WHERE collection_object_id = r.collection_object_id;
	END LOOP;
END;
/
sho err;



-- procedure to sync filtered_flat

CREATE OR REPLACE PROCEDURE update_filtered_flat (collobjid IN NUMBER) IS
	c number;
BEGIN
	-- the comparison thing is a pain to maintain, and gets confused by virtual columns
	-- do this is a procedure so we can debug easier
	-- things that trigger flat changes set stale_flag to 1
	-- is_flat_stale looks for stale_flag=1 
	-- update_flat set stale_flag to 0 when it's done
	-- grab things with stale_flag=0 (=updated in flat)
	-- push them to filtered_flat with this procedure
	-- set stale_flag to 2
	
	--dbms_output.put_line('collobjid:' || collobjid);
	-- see if it's an encumbered record
	select count(*) into c from flat where encumbrances LIKE '%mask record%' and collection_object_id=collobjid;
	if c=1 then
		-- this isn't supposed to be in filtered_flat, delete and mark as done
		delete from filtered_flat where collection_object_id=collobjid;
		update flat set stale_flag=2 where collection_object_id=collobjid;
		--dbms_output.put_line('all done with isencumbered');
		return;
	end if;
	-- see if it's an insert
	select count(*) into c from filtered_flat where collection_object_id=collobjid;
	if c=0 then
		-- just insert the required stuff, then continue
		--	dbms_output.put_line('inserting seed');

		insert into filtered_flat(
			collection_object_id,
			ACCN_ID,
			COLLECTION_ID
		) (
			select collection_object_id,ACCN_ID,COLLECTION_ID from flat where collection_object_id=collobjid
		);
	end if;
	--- now we should have at least a seed record in filtered_flat; continue
	
	--dbms_output.put_line('making main update');
		
	update filtered_flat set (
		flags,
        cataloged_item_type,
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
        collectors,
        preparators,
        field_num,
        otherCatalogNumbers,
        genbankNum,
        relatedCatalogedItemS,
        typeStatus,
        sex,
        parts, 
        partdetail,
        accession,
        began_date,
        ended_date,
        verbatim_date,
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
        dec_lat,
        dec_long,
        datum,
        orig_lat_long_units,
        verbatim_coordinates,
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
        SUBFAMILY,
        TRIBE,
        SUBTRIBE,
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
        RelatedInformation,
        collectorNumber,
        verbatimelEvation,
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
		collecting_event_name,
		georeference_source,
		georeference_protocol,
		locality_name,
		previousidentifications,
		use_license_url,
		IDENTIFICATION_REMARKS,
		LOCALITY_REMARKS,
		formatted_scientific_name,
		ISPUBLISHED,
        has_tissues,
        taxon_rank,
        locality_search_terms
	) = (
	 SELECT
        flags,
        cataloged_item_type,
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
         CASE
            WHEN encumbrances LIKE '%mask original field number%'
            THEN 'Anonymous'
            ELSE otherCatalogNumbers
        END otherCatalogNumbers,
        genbankNum,
        relatedCatalogedItemS,
        typeStatus,
        sex,
        parts, 
        CASE
            WHEN encumbrances LIKE '%mask part attribute%'
            THEN 'not available'
            ELSE partdetail
        END partdetail,
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
        CASE
            WHEN encumbrances LIKE '%mask specimen remarks%'
            THEN 'Masked'
            ELSE remarks
        END remarks,
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
        SUBFAMILY,
        TRIBE,
        SUBTRIBE,
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
         CASE
            WHEN encumbrances is not null
            THEN 
            	--call the caoncatenation function with the flag to force-mask attributes 
            	CONCATATTRIBUTE(collection_object_id,1)
            ELSE 
            	-- just use the data from flat
            	attributes
        END attributes,
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
        verbatim_locality,
		event_assigned_by_agent,
		event_assigned_date,
		specimen_event_remark,
		specimen_event_type,
		COLL_EVENT_REMARKS,
		collecting_event_name,
		georeference_source,
		georeference_protocol,
		locality_name,
		previousidentifications,
		use_license_url,
		IDENTIFICATION_REMARKS,
		LOCALITY_REMARKS,
		formatted_scientific_name,
		ISPUBLISHED,
        has_tissues,
        taxon_rank,
        locality_search_terms
    FROM
        flat
    WHERE
    	guid is not null and
        (encumbrances is null OR encumbrances NOT LIKE '%mask record%') and
        collection_object_id=collobjid
   ) where collection_object_id=collobjid;
   -- mark as done 
    update flat set stale_flag=2 where collection_object_id=collobjid;
exception when others then
	dbms_output.put_line(sqlerrm);
	update flat set STALE_FLAG=-2 where  COLLECTION_OBJECT_ID=collobjid;
end;
/


--END procedure to sync filtered_flat


/*


what follows is old-n-busted

comparison was hard to maintain, virtual columns confused it

do this with a pair of procedures and a job

*/













/*
 * 
 *  filtered flat view was slow because of inline processing.
 * 
 * This replaces the view. This "package" contsists of:
 * 		-- a view with encumbrances applied, same as old filtered_flat
 * 		-- a table which is an exact copy of the view
 * 		-- a comparison, which allows Oracle to detect differences
 * 		-- a procedure to suck differences out of pre_filtered_flat (view) into filtered_flat (table)
 * 		-- indexes, so performance does not suck
 * 
 * 
 * 
 *         alter table filtered_flat add ISPUBLISHED VARCHAR2(10);

 * 
 */


drop view filtered_flat;
drop view pre_filtered_flat_2;
drop table filtered_flat2;


-- first the view, same as old filtered_flat

CREATE or replace view pre_filtered_flat AS
    SELECT
        flags,
        cataloged_item_type,
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
         CASE
            WHEN encumbrances LIKE '%mask original field number%'
            THEN 'Anonymous'
            ELSE otherCatalogNumbers
        END otherCatalogNumbers,
        genbankNum,
        relatedCatalogedItemS,
        typeStatus,
        sex,
        parts, 
        CASE
            WHEN encumbrances LIKE '%mask part attribute%'
            THEN 'not available'
            ELSE partdetail
        END partdetail,
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
        CASE
            WHEN encumbrances LIKE '%mask specimen remarks%'
            THEN 'Masked'
            ELSE remarks
        END remarks,
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
        SUBFAMILY,
        TRIBE,
        SUBTRIBE,
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
         CASE
            WHEN encumbrances is not null
            THEN 
            	--call the caoncatenation function with the flag to force-mask attributes 
            	CONCATATTRIBUTE(collection_object_id,1)
            ELSE 
            	-- just use the data from flat
            	attributes
        END attributes,
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
        verbatim_locality,
		event_assigned_by_agent,
		event_assigned_date,
		specimen_event_remark,
		specimen_event_type,
		COLL_EVENT_REMARKS,
		collecting_event_name,
		georeference_source,
		georeference_protocol,
		locality_name,
		previousidentifications,
		use_license_url,
		IDENTIFICATION_REMARKS,
		LOCALITY_REMARKS,
		formatted_scientific_name,
		ISPUBLISHED,
        has_tissues,
        taxon_rank,
		--DATE_ENDED_DATE,
		--LAST_EDIT_DATE,
		STALE_FLAG
		--VERBATIMLATITUDE,
		--DATE_MADE_DATE,
		--DATE_BEGAN_DATE
    FROM
        flat
    WHERE
    	guid is not null and
        (encumbrances is null OR encumbrances NOT LIKE '%mask record%');
        
   
        
        
        

                
                
 --- now we have what we want in a view, make a snapshot of it....
 create table filtered_flat as select * from pre_filtered_flat;
 -- prod runtime @ 2015-05-21: Elapsed: 00:04:03.47

 
 create or replace public synonym filtered_flat for filtered_flat;
 
 grant select on filtered_flat to public;
 
 
 -- need indexes to run the compare
 -- see flat_indexes.sql


ANALYZE TABLE FILTERED_FLAT COMPUTE STATISTICS;

-- did we miss anything?

select index_name,column_name from all_ind_columns where table_name='FLAT' and column_name not in (
	select column_name from all_ind_columns where table_name='FILTERED_FLAT'
);


 
select column_name from user_tab_cols where table_name='FILTERED_FLAT' and column_name not in (
	select column_name from user_tab_cols where table_name='PRE_FILTERED_FLAT'
);
 



alter table FILTERED_FLAT add stale_flag number;

alter table FILTERED_FLAT  drop column stale_flag;

/*
 	-- to get rid of old comparison
	exec DBMS_COMPARISON.DROP_COMPARISON('SYS.COMPARE_FILTERED_FLAT');
		exec DBMS_COMPARISON.DROP_COMPARISON('UAM.COMPARE_FILTERED_FLAT');
		exec DBMS_COMPARISON.DROP_COMPARISON('COMPARE_FILTERED_FLAT2');
		
		
	exec DBMS_COMPARISON.DROP_COMPARISON('SYS.COMPARE_FILTERED_FLAT2');
		exec DBMS_COMPARISON.DROP_COMPARISON('UAM.COMPARE_FILTERED_FLAT2');
		exec DBMS_COMPARISON.DROP_COMPARISON('COMPARE_FILTERED_FLAT2');

	-- to create comparison, on which this is based
	
	BEGIN
		DBMS_COMPARISON.CREATE_COMPARISON ( 
			comparison_name => 'COMPARE_FILTERED_FLAT2'
  			, schema_name     => 'UAM'
  			, object_name     => 'PRE_FILTERED_FLAT'
  			, dblink_name     => null
  			, remote_schema_name=>'UAM'
  			, remote_object_name=>'FILTERED_FLAT'
  		);
	END;
 	/
*/
le shapes of UAM.PRE_FILTERED_FLAT and UAM.FILTERED_FLAT@ did not match

declare
	c number;
begin
	for r in (select * from user_tab_cols where table_name='FILTERED_FLAT') loop
		select count(*) into c from user_tab_cols where table_name='PRE_FILTERED_FLAT' and column_name=r.column_name;
	
			if c!=1 then
				dbms_output.put_line(r.column_name);
			end if;
		end loop;
	end;
	/

-- dammit wtf
connect sys as sysdba;

create or replace public synonym COMPARE_FILTERED_FLAT2 for COMPARE_FILTERED_FLAT2;

grant execute on COMPARE_FILTERED_FLAT2 to uam;

exit

-- back to lil ol UAM

-- this takes about 5 minutes to run on test - should be no problem to run it daily
-- maybe bump the refresh schedule up a bit if it keeps performing as-is
CREATE OR REPLACE PROCEDURE refresh_filtered_flat
IS
	consistent   BOOLEAN;
	scan_info    DBMS_COMPARISON.COMPARISON_TYPE;
BEGIN
	consistent := DBMS_COMPARISON.COMPARE ( 
		comparison_name => 'compare_filtered_flat2'
        , scan_info       => scan_info
        , perform_row_dif => TRUE
    );
    IF consistent != TRUE THEN
    	DBMS_COMPARISON.CONVERGE (
    		comparison_name  => 'compare_filtered_flat2'
  			, scan_id          => scan_info.scan_id
  			, scan_info        => scan_info
  			, converge_options => DBMS_COMPARISON.CMP_CONVERGE_LOCAL_WINS
  		);
	END IF;
END;
/

-- and a job to run the refresh periodically
exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'J_REFRESH_FILTERED_FLAT', FORCE => TRUE);

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'J_REFRESH_FILTERED_FLAT',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'refresh_filtered_flat',
	repeat_interval    =>  'freq=daily; byhour=2',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'synchronize filtered_flat');
END;
/

select count(*) from pre_filtered_flat where guid is null;
select guid from pre_filtered_flat having count(*) > 1 group by guid;

select upper(guid) from filtered_flat having count(*) > 1 group by upper(guid);


select 
	STATE,
	LAST_START_DATE,
	NEXT_RUN_DATE,
	REPEAT_INTERVAL,
	LAST_RUN_DURATION,
	MAX_RUN_DURATION  from all_scheduler_jobs where lower(JOB_NAME)='j_refresh_filtered_flat';
	
	
select 	* from all_scheduler_jobs where lower(JOB_NAME)='j_refresh_filtered_flat';

-- dats all, folks....



