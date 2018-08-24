
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
        taxon_rank
		--DATE_ENDED_DATE,
		--LAST_EDIT_DATE,
		--STALE_FLAG,
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


------------------------------------------------------------------------------------------------------------------------
IX_FLAT_U_CLASS
SYS_NC00145$

IX_FLAT_U_FAMILY
SYS_NC00146$

IX_FLAT_U_GENUS
SYS_NC00147$

IX_FLAT_U_CATNUM
SYS_NC00148$

IX_UPR_FLAT_ACCN
SYS_NC00149$

IX_FLAT_BEGANDATE
DATE_BEGAN_DATE

IX_FLAT_ENDEDDATE
DATE_ENDED_DATE

IX_FLAT_STALEFLAG
STALE_FLAG

IX_FLAT_YEAR
YEAR

IX_FLAT_MONTH
MONTH

IX_FLAT_DAY
DAY

IX_FLAT_GEOGAUTHRECID
GEOG_AUTH_REC_ID


 
select column_name from user_tab_cols where table_name='FILTERED_FLAT' and column_name not in (
	select column_name from user_tab_cols where table_name='PRE_FILTERED_FLAT'
);
 


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
  			, object_name     => 'pre_filtered_flat'
  			, dblink_name     => null
  			, remote_schema_name=>'UAM'
  			, remote_object_name=>'filtered_flat'
  		);
	END;
 	/
*/


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
	
	
select 
	* from all_scheduler_jobs where lower(JOB_NAME)='j_refresh_filtered_flat';

-- dats all, folks....



