
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
		formatted_scientific_name
    FROM
        flat
    WHERE
        (encumbrances is null OR encumbrances NOT LIKE '%mask record%');
        
   
 --- now we have what we want in a view, make a snapshot of it....
 create table filtered_flat as select * from pre_filtered_flat;
 -- prod runtime @ 2015-05-21: Elapsed: 00:04:03.47

 
 create or replace public synonym filtered_flat for filtered_flat;
 
 grant select on filtered_flat to public;
 
 
 -- need indexes to run the compare
 

CREATE UNIQUE INDEX PK_FILTERED_FLAT ON FILTERED_FLAT (COLLECTION_OBJECT_ID) TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FILTERED_FLAT_BEGANDATE	ON FILTERED_FLAT (BEGAN_DATE) TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_BEGANDATE_YEAR ON FILTERED_FLAT (substr(began_date,1,4))	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_CATNUM ON FILTERED_FLAT (CAT_NUM) TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_COLLECTIONID
	ON FILTERED_FLAT (COLLECTION_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_COLLECTORS
	ON FILTERED_FLAT (COLLECTORS)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_ENDEDDATE
	ON FILTERED_FLAT (ENDED_DATE)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_ENDEDDATE_YEAR
	ON FILTERED_FLAT (substr(ENDED_DATE,1,4))
	TABLESPACE UAM_IDX_1;


CREATE INDEX IX_F_FLAT_IDENTIFICATIONID
	ON FILTERED_FLAT (IDENTIFICATION_ID)
	TABLESPACE UAM_IDX_1;


CREATE INDEX IX_F_FLAT_COLLEVENTID
	ON FILTERED_FLAT (COLLECTING_EVENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_CONTINENTOCEAN_UPR
	ON FILTERED_FLAT (UPPER(CONTINENT_OCEAN))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_COUNTRY_UPR
	ON FILTERED_FLAT (UPPER(COUNTRY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_COUNTY_UPR
	ON FILTERED_FLAT (UPPER(COUNTY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_FEATURE_UPR
	ON FILTERED_FLAT (UPPER(FEATURE))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_HIGHER_GEOG_UPR
	ON FILTERED_FLAT (UPPER(HIGHER_GEOG))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_ISLAND_UPR
	ON FILTERED_FLAT (UPPER(ISLAND))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_ISLANDGROUP_UPR
	ON FILTERED_FLAT (UPPER(ISLAND_GROUP))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_LOCALITYID
	ON FILTERED_FLAT (LOCALITY_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_PARTS_UPR
	ON FILTERED_FLAT (UPPER(PARTS))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_QUAD_UPR
	ON FILTERED_FLAT (UPPER(QUAD))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_SCIENTIFICNAME_UPR
	ON FILTERED_FLAT (UPPER(SCIENTIFIC_NAME))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_SEA_UPR
	ON FILTERED_FLAT (UPPER(SEA))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_SPECLOCALITY_UPR
	ON FILTERED_FLAT (UPPER(SPEC_LOCALITY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_STATEPROV_UPR ON FLAT (UPPER(STATE_PROV))	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_TYPESTATUS_UPR
	ON FILTERED_FLAT (UPPER(TYPESTATUS))
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_F_FLAT_GUID_UPR
	ON FILTERED_FLAT (UPPER(GUID))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_COUNTRY
	ON FILTERED_FLAT (COUNTRY)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_DEC_LAT
    ON FILTERED_FLAT (DEC_LAT)
    TABLESPACE UAM_IDX_1;

CREATE INDEX ID_F_FLAT_DEC_LONG ON FILTERED_FLAT (DEC_LONG)  TABLESPACE UAM_IDX_1;


CREATE INDEX IX_UPR_F_FLAT_ACCN ON FILTERED_FLAT (accession)  TABLESPACE UAM_IDX_1;


CREATE INDEX IX_f_FLAT_U_CATNUM ON FILTERED_FLAT (upper(cat_num))  TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_SCIENTIFICNAME ON FILTERED_FLAT (scientific_name)  TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_U_PORDER ON FILTERED_FLAT (upper(phylorder))  TABLESPACE UAM_IDX_1;
CREATE INDEX IX_F_FLAT_U_KINGDOM ON FILTERED_FLAT (upper(kingdom))  TABLESPACE UAM_IDX_1;
CREATE INDEX IX_F_FLAT_U_PHYLUM ON FILTERED_FLAT (upper(phylum))  TABLESPACE UAM_IDX_1;
CREATE INDEX IX_F_FLAT_U_CLASS ON FILTERED_FLAT (upper(phylclass))  TABLESPACE UAM_IDX_1;
CREATE INDEX IX_F_FLAT_U_FAMILY ON FILTERED_FLAT (upper(family))  TABLESPACE UAM_IDX_1;
CREATE INDEX IX_F_FLAT_U_GENUS ON FILTERED_FLAT (upper(genus))  TABLESPACE UAM_IDX_1;

CREATE INDEX IF_F_FLAT_SPEC_LOC ON FILTERED_FLAT (spec_locality)  TABLESPACE UAM_IDX_1;

CREATE INDEX IX_F_FLAT_GUID ON FILTERED_FLAT (guid)  TABLESPACE UAM_IDX_1;




ANALYZE TABLE FILTERED_FLAT COMPUTE STATISTICS;

-- did we miss anything?

select index_name,column_name from all_ind_columns where table_name='FLAT' and column_name not in (
	select column_name from all_ind_columns where table_name='FILTERED_FLAT'
);
 

/*
 	-- to get rid of old comparison
	exec DBMS_COMPARISON.DROP_COMPARISON('compare_filtered_flat');
	-- to create comparison, on which this is based
	
	BEGIN
		DBMS_COMPARISON.CREATE_COMPARISON ( 
			comparison_name => 'compare_filtered_flat'
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

create public synonym DBMS_COMPARISON for DBMS_COMPARISON;

grant execute on DBMS_COMPARISON to uam;

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
		comparison_name => 'compare_filtered_flat'
        , scan_info       => scan_info
        , perform_row_dif => TRUE
    );
    IF consistent != TRUE THEN
    	DBMS_COMPARISON.CONVERGE (
    		comparison_name  => 'compare_filtered_flat'
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
    job_name           =>  'j_refresh_filtered_flat',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'refresh_filtered_flat',
	repeat_interval    =>  'freq=daily; byhour=2',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'synchronize filtered_flat');
END;
/


-- dats all, folks....



