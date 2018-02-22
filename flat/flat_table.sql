/*
 
  	https://github.com/ArctosDB/arctos/issues/1447
  	
  	 add has_tissues NUMBER for performance
  	 
  	  see migration folder 
 
 */



		

/*
	Code to build table FLAT (with minimal downtime)
	Current 17 Oct 2007
	
	
	this is broken....
	
*/
CREATE TABLE pre_flat AS
	SELECT 
	 	cataloged_item.collection_object_id,
	 	cataloged_item.cat_num,
	 	cataloged_item.accn_id,
	 	collection.collection_id,
	 	collection.institution_acronym,
	 	collection.collection_cde,
	 	collection.collection,
	 	collecting_event.collecting_event_id,
	 	collecting_event.began_date,
	 	collecting_event.ended_date,
	 	collecting_event.verbatim_date,
	 	coll_object.last_edit_date,
	 	coll_object.lot_count individualCount,
	 	coll_object.coll_obj_disposition,
	 	concatColl(cataloged_item.collection_object_id) collectors,
	 	concatSingleOtherId(cataloged_item.collection_object_id, 'Field Num') field_num,
	 	concatOtherId(cataloged_item.collection_object_id) otherCatalogNumbers,
	 	concatGenbank(cataloged_item.collection_object_id) genbankNum,
	 	concatRelations(cataloged_item.collection_object_id) relatedCatalogedItems,
	 	concatTypeStatus(cataloged_item.collection_object_id) typeStatus,
	 	concatAttributeValue(cataloged_item.collection_object_id, 'sex') sex,
	 	concatParts(cataloged_item.collection_object_id) parts,
	 	concatEncumbrances(cataloged_item.collection_object_id) encumbrances,
	 	trans.institution_acronym || ' ' || accn.accn_number accession,
	 	geog_auth_rec.geog_auth_rec_id,
	 	geog_auth_rec.higher_geog,
	 	geog_auth_rec.continent_ocean,
	 	geog_auth_rec.country,
	 	geog_auth_rec.state_prov,
	 	geog_auth_rec.county,
	 	geog_auth_rec.feature,
	 	geog_auth_rec.island,
	 	geog_auth_rec.island_group,
	 	geog_auth_rec.quad,
	 	geog_auth_rec.sea,
		locality.locality_id,
	 	locality.spec_locality,
	 	locality.minimum_elevation,
	 	locality.maximum_elevation,
	 	locality.orig_elev_units,
		to_meters(locality.minimum_elevation, 
		    locality.orig_elev_units) min_elev_in_m,
		to_meters(locality.maximum_elevation, 
		    locality.orig_elev_units) max_elev_in_m,
	 	accepted_lat_long.dec_lat,
	 	accepted_lat_long.dec_long,
	 	accepted_lat_long.datum,
	 	accepted_lat_long.orig_lat_long_units,
	 	decode(accepted_lat_long.orig_lat_long_units,
			'decimal degrees',
				to_char(accepted_lat_long.dec_lat) || 'd',
			'deg. min. sec.', 
				to_char(accepted_lat_long.lat_deg) || 'd ' || 
				to_char(accepted_lat_long.lat_min) || 'm ' || 
				to_char(accepted_lat_long.lat_sec) || 's ' || 
				accepted_lat_long.lat_dir,
			'UTM', 
				'UTM N/S: ' || to_char(accepted_lat_long.UTM_NS) 
				|| '; UTM Zone: ' || 
				decode(accepted_lat_long.UTM_ZONE,
				null,'not given',
				accepted_lat_long.UTM_ZONE
				),
			'degrees dec. minutes', 
				to_char(accepted_lat_long.lat_deg) || 'd ' || 
				to_char(accepted_lat_long.dec_lat_min) || 'm ' || 
				accepted_lat_long.lat_dir) verbatimLatitude,
		decode(accepted_lat_long.orig_lat_long_units,
			'decimal degrees',
				to_char(accepted_lat_long.dec_long) || 'd',
			'deg. min. sec.',
				to_char(accepted_lat_long.long_deg) || 'd ' ||
				to_char(accepted_lat_long.long_min) || 'm ' ||
				to_char(accepted_lat_long.long_sec) || 's ' || 
				accepted_lat_long.long_dir,
			'UTM', 
				'UTM E/W: ' || to_char(accepted_lat_long.UTM_EW) 
				|| '; UTM Zone: ' || 
				decode(accepted_lat_long.UTM_ZONE,
				null,'not given',
				accepted_lat_long.UTM_ZONE
				),
			'degrees dec. minutes',
				to_char(accepted_lat_long.long_deg) || 'd ' ||
				to_char(accepted_lat_long.dec_long_min) || 'm ' || 
				accepted_lat_long.long_dir,
			) verbatimLongitude,
		accepted_lat_long.lat_long_ref_source,
		to_meters(accepted_lat_long.max_error_distance, 
		    accepted_lat_long.max_error_units) coordinateUncertaintyInMeters,
		accepted_lat_long.georefmethod,
	 	accepted_lat_long.lat_long_remarks,
	 	lldetr.agent_name lat_long_determiner,
	 	identification.identification_id,
		identification.scientific_name,
		concatidentifiers(cataloged_item.collection_object_id) identifiedby,
	 	identification.made_date,
	 	coll_object_remark.coll_object_remarks remarks,
	 	coll_object_remark.habitat,
	 	coll_object_remark.associated_species,
	 	taxa_formula,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'full_taxon_name')
    	ELSE
    		full_taxon_name
    	END full_taxon_name,
        CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'phylclass')
    	ELSE
    		phylclass
    	END phylclass,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'Kingdom')
    	ELSE
    		kingdom
    	END kingdom,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'Phylum')
    	ELSE
    		phylum
    	END phylum,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'phylOrder')
    	ELSE
    		phylOrder
    	END phylOrder,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'Family')
    	ELSE
    		family
    	END family,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'Genus')
    	ELSE
    		genus
    	END genus,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'Species')
    	ELSE
    		species
    	END species,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'Subspecies')
    	ELSE
    		subspecies
    	END subspecies,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'author_text')
    	ELSE
    		author_text
    	END author_text,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'nomenclatural_code')
    	ELSE
    		nomenclatural_code
    	END nomenclatural_code,
    	CASE WHEN taxa_formula LIKE '%B' THEN 
    		get_taxonomy(cataloged_item.collection_object_id,'infraspecific_rank')
    	ELSE
    		infraspecific_rank
    	END infraspecific_rank,
	 	' ' identificationModifier,
	 	collection.institution_acronym || ':' || 
	 	    collection.collection_cde || ':' || 
	 	    cataloged_item.cat_num guid,
	 	decode(coll_object.coll_object_type,
             'CI','PreservedSpecimen',
             'HO','HumanObservation',
             'OtherSpecimen') basisOfRecord,
        depth_units,
        min_depth,
        max_depth,
        to_meters(min_depth,depth_units) min_depth_in_m,
        to_meters(max_depth,depth_units) max_depth_in_m,
	 	collecting_method,
	 	collecting_source,
	 	decode(began_date,
            ended_date,
            to_number(to_char(began_date,'DDD')),
            NULL) dayOfYear,
        concatAttributeValue(cataloged_item.collection_object_id,
            'age_class') age_class,
        concatattribute(cataloged_item.collection_object_id) attributes,
        verificationStatus,
        '<a href="http://arctos.database.museum/SpecimenDetail.cfm?GUID=' || 
            collection.institution_acronym || ':' || 
            collection.collection_cde || ':' || 
            cataloged_item.cat_num || '">' || 
            collection.institution_acronym || ':' || 
            collection.collection_cde || ':' || 
            cataloged_item.cat_num || '</a>',
        'http://arctos.database.museum/SpecimenDetail.cfm?GUID=' || 
            collection.institution_acronym || ':' || 
            collection.collection_cde || ':' || 
            cataloged_item.cat_num imageUrl,
        'http://arctos.database.museum/SpecimenDetail.cfm?GUID=' || 
            collection.institution_acronym || ':' || 
            collection.collection_cde || ':' || 
            cataloged_item.cat_num fieldNotesUrl,
        to_char(cataloged_item.cat_num) catalogNumberText,
        concatSingleOtherId(cataloged_item.collection_object_id,
            'collector number') collectorNumber,
        decode(orig_elev_units,
            NULL,
            NULL,
            minimum_elevation ||'-'||
                maximum_elevation ||' '||
                orig_elev_units) verbatimElevation,
        decode(to_number(to_char(began_date,'YYYY')),
            to_number(to_char(ended_date,'YYYY')),
            to_number(to_char(began_date,'YYYY')),
            NULL) year,
        decode(to_number(to_char(began_date,'MM')),
            to_number(to_char(ended_date,'MM')),
            to_number(to_char(began_date,'MM')),
            NULL) month,
        decode (to_number(to_char(began_date,'DD')),
            to_number(to_char(ended_date,'DD')),
            to_number(to_char(began_date,'DD')),
            NULL) day,
        0 stale_flag
 	FROM 
 		cataloged_item, 
 		collection,
 		collecting_event,
 		coll_object,
 		trans,
 		accn,
 		geog_auth_rec,
 		locality,
 		accepted_lat_long,
 		identification,
 		coll_object_remark,
 		preferred_agent_name lldetr,
 		identification_taxonomy,
 		taxonomy
 	WHERE cataloged_item.collection_object_id = coll_object.collection_object_id 
 	    AND cataloged_item.accn_id = accn.transaction_id 
 	    AND accn.transaction_id = trans.transaction_id 
 	    AND cataloged_item.collection_id = collection.collection_id 
 	    AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id 
 	    AND collecting_event.locality_id = locality.locality_id 
 	    AND locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id 
 	    AND locality.locality_id = accepted_lat_long.locality_id (+) 
 	    AND accepted_lat_long.determined_by_agent_id = lldetr.agent_id (+) 
 	    AND cataloged_item.collection_object_id = identification.collection_object_id 
        AND identification.accepted_id_fg = 1 
        AND identification.identification_id = identification_taxonomy.identification_id 
 		AND identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id 
        AND identification_taxonomy.variable = 'A' 
        AND cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+)
;
 		
DROP TABLE flat;
RENAME pre_flat TO flat;
 		
CREATE OR REPLACE PUBLIC SYNONYM flat FOR flat;
GRANT SELECT ON flat TO uam_query, uam_update;

ALTER TABLE flat MODIFY identification_id null;
ALTER TABLE flat MODIFY collection_cde null;
ALTER TABLE flat MODIFY collection null;
ALTER TABLE flat MODIFY collecting_event_id null;
ALTER TABLE flat MODIFY geog_auth_rec_id null;
ALTER TABLE flat MODIFY individualcount null;
ALTER TABLE flat MODIFY coll_obj_disposition null;
ALTER TABLE flat MODIFY began_date null;
ALTER TABLE flat MODIFY ended_date null;
ALTER TABLE flat MODIFY verbatim_date null;
ALTER TABLE flat MODIFY locality_id null;
ALTER TABLE flat MODIFY scientific_name null;
ALTER TABLE flat MODIFY taxa_formula null;
ALTER TABLE flat MODIFY collecting_source null;
ALTER TABLE flat modify stale_flag NOT NULL;
ALTER TABLE flat modify stale_flag DEFAULT 0;

CREATE UNIQUE INDEX PK_FLAT
	ON FLAT (COLLECTION_OBJECT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_BEGANDATE
	ON FLAT (BEGAN_DATE)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_BEGANDATE_YEAR
	ON FLAT (TO_NUMBER(TO_CHAR (BEGAN_DATE,'yyyy')))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_CATNUM
	ON FLAT (CAT_NUM)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_COLLECTIONID
	ON FLAT (COLLECTION_ID)
	TABLESPACE UAM_IDX_1;
	
CREATE INDEX IX_FLAT_geogauthrecid ON FLAT (geog_auth_rec_id) TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_COLLECTORS
	ON FLAT (COLLECTORS)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_ENDEDDATE
	ON FLAT (ENDED_DATE)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_ENDEDDATE_YEAR
	ON FLAT (TO_NUMBER(TO_CHAR (ENDED_DATE,'yyyy')))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_IDENTIFICATIONID
	ON FLAT (IDENTIFICATION _ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_STALEFLAG
	ON FLAT (STALE_FLAG)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_COLLEVENTID
	ON FLAT (COLLECTING_EVENT_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_CONTINENTOCEAN_UPR
	ON FLAT (UPPER(CONTINENT_OCEAN))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_COUNTRY_UPR
	ON FLAT (UPPER(COUNTRY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_COUNTY_UPR
	ON FLAT (UPPER(COUNTY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_FEATURE_UPR
	ON FLAT (UPPER(FEATURE))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_HIGHER_GEOG_UPR
	ON FLAT (UPPER(HIGHER_GEOG))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_ISLAND_UPR
	ON FLAT (UPPER(ISLAND))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_ISLANDGROUP_UPR
	ON FLAT (UPPER(ISLAND_GROUP))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_LOCALITYID
	ON FLAT (LOCALITY_ID)
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_PARTS_UPR
	ON FLAT (UPPER(PARTS))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_QUAD_UPR
	ON FLAT (UPPER(QUAD))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_SCIENTIFICNAME_UPR
	ON FLAT (UPPER(SCIENTIFIC_NAME))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_SEA_UPR
	ON FLAT (UPPER(SEA))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_SPECLOCALITY_UPR
	ON FLAT (UPPER(SPEC_LOCALITY))
	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_STATEPROV_UPR ON FLAT (UPPER(STATE_PROV))	TABLESPACE UAM_IDX_1;

CREATE INDEX IX_FLAT_TYPESTATUS_UPR
	ON FLAT (UPPER(TYPESTATUS))
	TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_FLAT_GUID_UPR
	ON FLAT (UPPER(GUID))
	TABLESPACE UAM_IDX_1;

CREATE INDEX FLAT_COUNTRY
	ON FLAT (COUNTRY)
	TABLESPACE UAM_IDX_1;

CREATE INDEX FLAT_DEC_LAT
    ON FLAT (DEC_LAT)
    TABLESPACE UAM_IDX_1;

CREATE INDEX FLAT_DEC_LONG
    ON FLAT (DEC_LONG)
    TABLESPACE UAM_IDX_1;
    
    
CREATE INDEX ix_FLAT_year ON FLAT (year) TABLESPACE UAM_IDX_1;
CREATE INDEX ix_FLAT_month ON FLAT (month) TABLESPACE UAM_IDX_1;
CREATE INDEX ix_FLAT_day ON FLAT (day) TABLESPACE UAM_IDX_1;



ANALYZE TABLE flat COMPUTE STATISTICS;

/* CREATE partitioned TABLE flat 
 * also see migration/vpd_partition_tables.sql
 */

CREATE TABLE FLAT (
    COLLECTION_OBJECT_ID NUMBER,
    CAT_NUM NUMBER NOT NULL,
	ACCN_ID NUMBER NOT NULL,
	COLLECTION_ID NUMBER NOT NULL,
	INSTITUTION_ACRONYM VARCHAR2(20),
	COLLECTION_CDE VARCHAR2(5),
	COLLECTION VARCHAR2(30),
	COLLECTING_EVENT_ID NUMBER,
	BEGAN_DATE DATE,
	ENDED_DATE DATE,
	VERBATIM_DATE VARCHAR2(60),
	LAST_EDIT_DATE DATE,
	INDIVIDUALCOUNT NUMBER,
	COLL_OBJ_DISPOSITION VARCHAR2(20),
	COLLECTORS VARCHAR2(4000),
	FIELD_NUM VARCHAR2(4000),
	OTHERCATALOGNUMBERS VARCHAR2(4000),
	GENBANKNUM VARCHAR2(4000),
	RELATEDCATALOGEDITEMS VARCHAR2(4000),
	TYPESTATUS VARCHAR2(4000),
	SEX VARCHAR2(4000),
	PARTS VARCHAR2(4000),
    ENCUMBRANCES VARCHAR2(4000),
	ACCESSION VARCHAR2(81),
	GEOG_AUTH_REC_ID NUMBER,
	HIGHER_GEOG VARCHAR2(255),
	CONTINENT_OCEAN VARCHAR2(50),
	COUNTRY VARCHAR2(50),
	STATE_PROV VARCHAR2(75),
	COUNTY VARCHAR2(50),
	FEATURE VARCHAR2(50),
	ISLAND VARCHAR2(50),
	ISLAND_GROUP VARCHAR2(50),
	QUAD VARCHAR2(30),
	SEA VARCHAR2(50),
	LOCALITY_ID NUMBER,
	SPEC_LOCALITY VARCHAR2(255),
	MINIMUM_ELEVATION NUMBER,
	MAXIMUM_ELEVATION NUMBER,
	ORIG_ELEV_UNITS VARCHAR2(2),
	MIN_ELEV_IN_M NUMBER,
	MAX_ELEV_IN_M NUMBER,
	DEC_LAT NUMBER(12,10),
	DEC_LONG NUMBER(13,10),
	DATUM VARCHAR2(55),
	ORIG_LAT_LONG_UNITS VARCHAR2(20),
	VERBATIMLATITUDE VARCHAR2(127),
	VERBATIMLONGITUDE VARCHAR2(127),
	LAT_LONG_REF_SOURCE VARCHAR2(255),
	COORDINATEUNCERTAINTYINMETERS NUMBER,
	GEOREFMETHOD VARCHAR2(255),
	LAT_LONG_REMARKS VARCHAR2(4000),
	LAT_LONG_DETERMINER VARCHAR2(184),
	IDENTIFICATION_ID NUMBER,
	SCIENTIFIC_NAME VARCHAR2(255),
	IDENTIFIEDBY VARCHAR2(4000),
	MADE_DATE DATE,
	REMARKS VARCHAR2(4000),
	HABITAT VARCHAR2(4000),
	ASSOCIATED_SPECIES VARCHAR2(4000),
	TAXA_FORMULA VARCHAR2(25),
	FULL_TAXON_NAME VARCHAR2(4000),
	PHYLCLASS VARCHAR2(4000),
	KINGDOM VARCHAR2(4000),
	PHYLUM VARCHAR2(4000),
	PHYLORDER VARCHAR2(4000),
	FAMILY VARCHAR2(4000),
	GENUS VARCHAR2(4000),
	SPECIES VARCHAR2(4000),
	SUBSPECIES VARCHAR2(4000),
	AUTHOR_TEXT VARCHAR2(4000),
	NOMENCLATURAL_CODE VARCHAR2(4000),
	INFRASPECIFIC_RANK VARCHAR2(4000),
	IDENTIFICATIONMODIFIER CHAR(1),
	GUID VARCHAR2(67),
	BASISOFRECORD VARCHAR2(17),
	DEPTH_UNITS VARCHAR2(20),
	MIN_DEPTH NUMBER,
	MAX_DEPTH NUMBER,
	MIN_DEPTH_IN_M NUMBER,
	MAX_DEPTH_IN_M NUMBER,
	COLLECTING_METHOD VARCHAR2(255),
	COLLECTING_SOURCE VARCHAR2(15),
	DAYOFYEAR NUMBER,
	AGE_CLASS VARCHAR2(4000),
	ATTRIBUTES VARCHAR2(4000),
	VERIFICATIONSTATUS VARCHAR2(40),
	SPECIMENDETAILURL VARCHAR2(255),
	IMAGEURL VARCHAR2(121),
	FIELDNOTESURL VARCHAR2(121),
	CATALOGNUMBERTEXT VARCHAR2(40),
	COLLECTORNUMBER VARCHAR2(4000),
	VERBATIMELEVATION VARCHAR2(84),
	YEAR NUMBER,
	MONTH NUMBER,
	DAY NUMBER,
	STALE_FLAG NUMBER DEFAULT 0 NOT NULL,
	LASTUSER VARCHAR2(38),
	LASTDATE DATE,
    CONSTRAINT PK_FLAT
        PRIMARY KEY (COLLECTION_OBJECT_ID)
        TABLESPACE UAM_IDX_1
    )
    TABLESPACE UAM_DAT_1
    PARTITION BY LIST (COLLECTION_ID) (
        PARTITION UAM_MAMM  VALUES (1),
        PARTITION UAM_BIRD  VALUES (2),
        PARTITION UAM_HERP  VALUES (3),
		PARTITION UAM_ENTO  VALUES (4),
		PARTITION UAM_HERB  VALUES (6),
		PARTITION NBSB_BIRD  VALUES (7),
		PARTITION UAM_BRYO  VALUES (8),
		PARTITION UAM_CRUS  VALUES (9),
		PARTITION UAM_FISH  VALUES (10),
		PARTITION UAM_MOLL  VALUES (11),
		PARTITION KWP_ENTO  VALUES (12),
		PARTITION UAMOBS_MAMM  VALUES (13),
		PARTITION MSB_MAMM  VALUES (14),
		PARTITION DGR_ENTO  VALUES (15),
		PARTITION DGR_BIRD  VALUES (16),
		PARTITION DGR_MAMM  VALUES (17),
		PARTITION DGR_HERP  VALUES (18),
		PARTITION DGR_FISH  VALUES (19),
		PARTITION MSB_BIRD  VALUES (20),
		PARTITION UAM_ES  VALUES (21),
		PARTITION WNMU_BIRD  VALUES (22),
		PARTITION WNMU_FISH  VALUES (23),
		PARTITION WNMU_MAMM  VALUES (24),
		PARTITION PSU_MAMM  VALUES (25),
		PARTITION CRCM_BIRD  VALUES (26),
		PARTITION GOD_HERB  VALUES (27),
		PARTITION MVZ_MAMM  VALUES (28),
		PARTITION MVZ_BIRD  VALUES (29),
		PARTITION MVZ_HERP  VALUES (30),
		PARTITION MVZ_EGG  VALUES (31),
		PARTITION MVZ_HILD  VALUES (32),
		PARTITION MVZ_IMG  VALUES (33),
		PARTITION MVZ_PAGE  VALUES (34),
		PARTITION MVZOBS_BIRD  VALUES (35),
		PARTITION MVZOBS_HERP  VALUES (36),
		PARTITION MVZOBS_MAMM  VALUES (37),
		PARTITION MVZOBS_MAMM  VALUES (37),
        PARTITION UAM_ART  VALUES (39),
        PARTITION UAMB_HERB  VALUES (40),
        PARTITION MSBOBS_MAMM  VALUES (41)
    );
    
ALTER TABLE flat DROP PARTITION uam_bryo;
ALTER TABLE flat DROP PARTITION uam_crus;

ALTER TABLE flat RENAME PARTITION uam_moll TO uam_inv;
ALTER TABLE flat RENAME PARTITION god_herb TO msb_para;

ALTER TABLE flat ADD PARTITION uam_art VALUES (39);
ALTER TABLE flat ADD PARTITION uamb_herb VALUES (40);    