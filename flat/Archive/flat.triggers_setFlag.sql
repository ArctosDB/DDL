/*	25-Jan-2008:
	Running into issues with instead of triggers. New strategy:
		triggers create a stale flag in flat
		scheduler updates flat periodically 
		
ALTER TABLE flat ADD taxa_formula VARCHAR2(25);
ALTER TABLE flat ADD full_taxon_name VARCHAR2(4000);
ALTER TABLE flat ADD phylclass   VARCHAR2(4000);
ALTER TABLE flat ADD kingdom VARCHAR2(4000);
ALTER TABLE flat ADD phylum  VARCHAR2(4000);
ALTER TABLE flat ADD phylorder   VARCHAR2(4000);
ALTER TABLE flat ADD family  VARCHAR2(4000);
ALTER TABLE flat ADD genus   VARCHAR2(4000);
ALTER TABLE flat ADD species VARCHAR2(4000);
ALTER TABLE flat ADD subspecies  VARCHAR2(4000);
ALTER TABLE flat ADD author_text VARCHAR2(4000);
ALTER TABLE flat ADD nomenclatural_code  VARCHAR2(4000);
ALTER TABLE flat ADD infraspecific_rank  VARCHAR2(4000);
ALTER TABLE flat ADD identificationmodifier  CHAR(1);
ALTER TABLE flat ADD guid    VARCHAR2(67);
ALTER TABLE flat ADD basisofrecord   VARCHAR2(17);
ALTER TABLE flat ADD depth_units VARCHAR2(20);
ALTER TABLE flat ADD min_depth   NUMBER;
ALTER TABLE flat ADD max_depth   NUMBER;
ALTER TABLE flat ADD min_depth_in_m  NUMBER;
ALTER TABLE flat ADD max_depth_in_m  NUMBER;
ALTER TABLE flat ADD collecting_method VARCHAR2(255);
ALTER TABLE flat ADD collecting_source   VARCHAR2(15);
ALTER TABLE flat ADD dayofyear   NUMBER;
ALTER TABLE flat ADD age_class   VARCHAR2(4000);
ALTER TABLE flat ADD attributes  VARCHAR2(4000);
ALTER TABLE flat ADD verificationstatus  VARCHAR2(40);
ALTER TABLE flat ADD specimendetailurl   VARCHAR2(255);
ALTER TABLE flat ADD imageurl    VARCHAR2(121);
ALTER TABLE flat ADD fieldnotesurl   VARCHAR2(121);
ALTER TABLE flat ADD catalognumbertext   VARCHAR2(40);
ALTER TABLE flat ADD collectornumber VARCHAR2(4000);
ALTER TABLE flat ADD verbatimelevation   VARCHAR2(84);
ALTER TABLE flat ADD year NUMBER;
ALTER TABLE flat ADD month NUMBER;
ALTER TABLE flat ADD day NUMBER;
    
UPDATE flat 
SET (
        taxa_formula,
        full_taxon_name,
        phylclass,
        kingdom,
        phylum,
        phylOrder,
        family,
        genus,
        species,
        subspecies,
        author_text,
        nomenclatural_code,
        infraspecific_rank,
        identificationModifier,
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
        collectorNumber,
        verbatimElevation,
        year,
        month,
        day) = (
    SELECT
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
	    '<a href="http://mvzarctos.berkeley.edu/SpecimenDetail.cfm?GUID=' || 
			collection.institution_acronym || ':' || 
			collection.collection_cde || ':' || 
			cataloged_item.cat_num || '">' || 
			collection.institution_acronym || ':' || 
			collection.collection_cde || ':' || 
			cataloged_item.cat_num || '</a>',
        'http://mvzarctos.berkeley.edu/SpecimenDetail.cfm?GUID=' ||
            collection.institution_acronym || ':' ||
            collection.collection_cde || ':' ||
            cataloged_item.cat_num imageUrl,
        'http://mvzarctos.berkeley.edu/SpecimenDetail.cfm?GUID=' ||
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
            NULL) day
    FROM
        cataloged_item,
        collection,
        collecting_event,
        coll_object,
        locality,
        accepted_lat_long,
        identification,
        identification_taxonomy
    WHERE
    	flat.collection_object_id = cataloged_item.collection_object_id
        AND cataloged_item.collection_object_id = coll_object.collection_object_id
        AND cataloged_item.collection_id = collection.collection_id
        AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id
        AND collecting_event.locality_id = locality.locality_id
        AND locality.locality_id = accepted_lat_long.locality_id (+)
        AND cataloged_item.collection_object_id = identification.collection_object_id
        AND identification.accepted_id_fg = 1
        AND identification.identification_id = identification_taxonomy.identification_id
        AND identification_taxonomy.variable = 'A');
	
ALTER TABLE flat ADD stale_flag NUMBER;
UPDATE flat SET stale_flag = 0;
ALTER TABLE flat modify stale_flag NOT NULL;
ALTER TABLE flat modify stale_flag DEFAULT 0;
CREATE INDEX flat_stale_flag ON flat(stale_flag);

--run this after creating the new update_flat to insert missing cat items.
BEGIN
    FOR cit IN (
        select
            ci.collection_object_id,
            ci.cat_num,
            ci.accn_id,
            ci.collecting_event_id,
            c.collection_cde,
            ci.collection_id
        from cataloged_item ci, collection c, flat f
        where ci.collection_object_id = f.collection_object_id (+)
        and ci.collection_id = c.collection_id (+)
        and f.collection_object_id is null
    ) LOOP
        INSERT INTO flat (
            collection_object_id,
            cat_num,
            accn_id,
            collecting_event_id,
            collection_cde,
            collection_id,
            catalognumbertext)
        VALUES (
            cit.collection_object_id,
            cit.cat_num,
            cit.accn_id,
            cit.collecting_event_id,
            cit.collection_cde,
            cit.collection_id,
            to_char(cit.cat_num));
        dbms_output.put_line('inserted into flat coid: ' || cit.collection_object_id);
        update_flat(cit.collection_object_id);
        dbms_output.put_line('updated flat coid: ' || cit.collection_object_id);
    END LOOP;
END;
/
*/

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'check_flat_stale',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'is_flat_stale',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'check flat for records marked as stale and update them');
END;
/

CREATE OR REPLACE PROCEDURE is_flat_stale IS 
BEGIN
    FOR r IN (SELECT collection_object_id FROM flat WHERE stale_flag = 1) LOOP
        update_flat(r.collection_object_id);
        UPDATE flat 
        SET stale_flag = 0 
        WHERE collection_object_id = r.collection_object_id;
    END LOOP;
END;
/
sho err;
   
--SELECT dbms_metadata.get_ddl('PROCEDURE','UPDATE_FLAT') from dual;
-- MVZ ONLY!!! specimendetailurl has site hard coded.
-- see next procedure for UAM.
CREATE OR REPLACE PROCEDURE update_flat (collobjid IN NUMBER) IS
BEGIN
	UPDATE flat
	SET (
            cat_num,
		    accn_id,
            collecting_event_id,
            collection_cde,
            collection_id,
            catalognumbertext,
            institution_acronym,
		 	collection,
		 	began_date,
		 	ended_date,
		 	verbatim_date,
		 	last_edit_date,
		 	individualCount,
		 	coll_obj_disposition,
		 	collectors,
		 	field_num,
		 	otherCatalogNumbers,
		 	genbankNum,
		 	relatedCatalogedItems,
		 	typeStatus,
		 	sex,
            parts,
		 	encumbrances,
		 	accession,
		 	geog_auth_rec_id,
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
			locality_id,
		 	spec_locality,
		 	minimum_elevation,
		 	maximum_elevation,
		 	orig_elev_units,
		 	min_elev_in_m,
		 	max_elev_in_m,
		 	dec_lat,
		 	dec_long,
		 	datum,
		 	orig_lat_long_units,
		 	verbatimLatitude,
			verbatimLongitude,
			lat_long_ref_source,
			coordinateUncertaintyInMeters,
			georefMethod,
		 	lat_long_remarks,
		 	lat_long_determiner,
		 	identification_id,
			scientific_name,
			identifiedby,
		 	made_date,
		 	remarks,
		 	habitat,
		 	associated_species,
		 	taxa_formula,
		 	full_taxon_name,
	        phylclass,
	    	kingdom,
	    	phylum,
	    	phylOrder,
	    	family,
	    	genus,
	    	species,
	    	subspecies,
	    	author_text,
	    	nomenclatural_code,
	    	infraspecific_rank,
		 	identificationModifier,
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
	        collectorNumber,
	        verbatimElevation,
	        year,
	        month,
	        day) = (
	    SELECT
            cataloged_item.cat_num,
		    cataloged_item.accn_id,
            cataloged_item.collecting_event_id,
            collection.collection_cde,
            cataloged_item.collection_id,
            to_char(cataloged_item.cat_num),
	  	 	collection.institution_acronym,
		 	collection.collection,
		 	collecting_event.began_date,
		 	collecting_event.ended_date,
		 	collecting_event.verbatim_date,
		 	coll_object.last_edit_date,
		 	coll_object.lot_count,
		 	coll_object.coll_obj_disposition,
		 	concatColl(cataloged_item.collection_object_id),
		 	concatSingleOtherId(cataloged_item.collection_object_id,'Field Num'),
		 	concatOtherId(cataloged_item.collection_object_id),
		 	concatGenbank(cataloged_item.collection_object_id),
		 	concatRelations(cataloged_item.collection_object_id),
		 	concatTypeStatus(cataloged_item.collection_object_id),
		 	concatAttributeValue(cataloged_item.collection_object_id,'sex'),
		 	concatParts(cataloged_item.collection_object_id),
		 	concatEncumbrances(cataloged_item.collection_object_id),
		 	trans.institution_acronym || ' ' || accn.accn_number,
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
			    locality.orig_elev_units),
			to_meters(locality.maximum_elevation, 
			    locality.orig_elev_units),
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
				'degrees dec. minutes', 
					to_char(accepted_lat_long.lat_deg) || 'd ' || 
					to_char(accepted_lat_long.dec_lat_min) || 'm ' || 
					accepted_lat_long.lat_dir),
			decode(accepted_lat_long.orig_lat_long_units,
				'decimal degrees',
					to_char(accepted_lat_long.dec_long) || 'd',
				'deg. min. sec.',
					to_char(accepted_lat_long.long_deg) || 'd ' ||
					to_char(accepted_lat_long.long_min) || 'm ' ||
					to_char(accepted_lat_long.long_sec) || 's ' || 
					accepted_lat_long.long_dir,
				'degrees dec. minutes',
					to_char(accepted_lat_long.long_deg) || 'd ' ||
					to_char(accepted_lat_long.dec_long_min) || 'm ' || 
					accepted_lat_long.long_dir),
			accepted_lat_long.lat_long_ref_source,
			to_meters(accepted_lat_long.max_error_distance,
			    accepted_lat_long.max_error_units),
			accepted_lat_long.georefmethod,
		 	accepted_lat_long.lat_long_remarks,
		 	lldetr.agent_name,
		 	identification.identification_id,
			identification.scientific_name,
			concatidentifiers(cataloged_item.collection_object_id),
		 	identification.made_date,
		 	coll_object_remark.coll_object_remarks,
		 	coll_object_remark.habitat,
		 	coll_object_remark.associated_species,
		 	taxa_formula,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'full_taxon_name')
	    	    ELSE full_taxon_name
	    	END,
	        CASE WHEN taxa_formula LIKE '%B' 
	            THEN  get_taxonomy(cataloged_item.collection_object_id,'phylclass')
	    	    ELSE phylclass
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN  get_taxonomy(cataloged_item.collection_object_id,'Kingdom')
	    	    ELSE kingdom
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'Phylum')
	    	    ELSE phylum
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'phylOrder')
	    	    ELSE phylOrder
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'Family')
	    	    ELSE family
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'Genus')
	    	    ELSE genus
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'Species')
	    	    ELSE species
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'Subspecies')
	    	    ELSE subspecies
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'author_text')
	    	    ELSE author_text
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'nomenclatural_code')
	    	    ELSE nomenclatural_code
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'infraspecific_rank')
	    	    ELSE infraspecific_rank
	    	END,
		 	' ',
		 	collection.institution_acronym || ':' || 
		 	    collection.collection_cde || ':' || 
		 	    cataloged_item.cat_num,
		 	decode(coll_object.coll_object_type,
	             'CI','PreservedSpecimen',
	             'HO','HumanObservation',
	             'OtherSpecimen'),
	        locality.depth_units,
	        locality.min_depth,
	        locality.max_depth,
	        to_meters(locality.min_depth,locality.depth_units),
	        to_meters(locality.max_depth,locality.depth_units),
		 	collecting_event.collecting_method,
		 	collecting_event.collecting_source,
		 	decode(collecting_event.began_date,
	            collecting_event.ended_date,to_number(to_char(collecting_event.began_date,'DDD')),
	            NULL),
	        concatAttributeValue(cataloged_item.collection_object_id,'age_class'),
	        concatattribute(cataloged_item.collection_object_id),
	        accepted_lat_long.verificationstatus,
	        '<a href="http://mvzarctos.berkeley.edu/SpecimenDetail.cfm?GUID=' || 
	            collection.institution_acronym || ':' || 
	            collection.collection_cde || ':' || 
	            cataloged_item.cat_num || '">' || 
	            collection.institution_acronym || ':' || 
	            collection.collection_cde || ':' || 
	            cataloged_item.cat_num || '</a>',
	        'http://mvzarctos.berkeley.edu/SpecimenDetail.cfm?GUID=' || 
	            collection.institution_acronym || ':' || 
	            collection.collection_cde || ':' || 
	            cataloged_item.cat_num,
	        'http://mvzarctos.berkeley.edu/SpecimenDetail.cfm?GUID=' || 
	            collection.institution_acronym || ':' || 
	            collection.collection_cde || ':' || 
	            cataloged_item.cat_num,
	        concatSingleOtherId(cataloged_item.collection_object_id,'collector number'),
	        decode(locality.orig_elev_units,
	            NULL,
	            NULL,
	            locality.minimum_elevation ||'-'|| 
	                locality.maximum_elevation||' '|| 
	                locality.orig_elev_units),
	        decode(to_number(to_char(collecting_event.began_date,'YYYY')),
	            to_number(to_char(collecting_event.ended_date,'YYYY')),
	            to_number(to_char(collecting_event.began_date,'YYYY')),
	            NULL),
	        decode(to_number(to_char(collecting_event.began_date,'MM')),
	            TO_number(to_char(collecting_event.ended_date,'MM')),
	            TO_number(to_char(collecting_event.began_date,'MM')),
	            NULL),
	        decode(to_number(to_char(collecting_event.began_date,'DD')),
	            to_number(to_char(collecting_event.ended_date,'DD')),
	            to_number(to_char(collecting_event.began_date,'DD')),
	            NULL)
	 	FROM
	 		cataloged_item,
	 		coll_object,
	 		collection,
	 		accn,
	 		trans,
	 		collecting_event,
	 		locality,
	 		geog_auth_rec,
	 		accepted_lat_long,
	 		identification,
	 		coll_object_remark,
	 		preferred_agent_name lldetr,
	 		identification_taxonomy,
	 		taxonomy
	 	WHERE flat.collection_object_id = cataloged_item.collection_object_id 
	 	    AND cataloged_item.collection_object_id = coll_object.collection_object_id 
	 	    AND cataloged_item.collection_id = collection.collection_id 
	 	    AND cataloged_item.accn_id = accn.transaction_id 
	 	    AND accn.transaction_id = trans.transaction_id 
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
	 	    AND coll_object.collection_object_id = coll_object_remark.collection_object_id (+))
    WHERE flat.collection_object_id = collobjid;
END;
/
sho err

-- FOR UAM ONLY!!!! specimendetailurl has site hard coded.
-- seee previous procedure for MVZ.
CREATE OR REPLACE PROCEDURE update_flat (collobjid IN NUMBER) IS
BEGIN
	UPDATE flat
	SET (
            cat_num,
		    accn_id,
            collecting_event_id,
            collection_cde,
            collection_id,
            catalognumbertext,
            institution_acronym,
		 	collection,
		 	began_date,
		 	ended_date,
		 	verbatim_date,
		 	last_edit_date,
		 	individualCount,
		 	coll_obj_disposition,
		 	collectors,
		 	field_num,
		 	otherCatalogNumbers,
		 	genbankNum,
		 	relatedCatalogedItems,
		 	typeStatus,
		 	sex,
            parts,
		 	encumbrances,
		 	accession,
		 	geog_auth_rec_id,
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
			locality_id,
		 	spec_locality,
		 	minimum_elevation,
		 	maximum_elevation,
		 	orig_elev_units,
		 	min_elev_in_m,
		 	max_elev_in_m,
		 	dec_lat,
		 	dec_long,
		 	datum,
		 	orig_lat_long_units,
		 	verbatimLatitude,
			verbatimLongitude,
			lat_long_ref_source,
			coordinateUncertaintyInMeters,
			georefMethod,
		 	lat_long_remarks,
		 	lat_long_determiner,
		 	identification_id,
			scientific_name,
			identifiedby,
		 	made_date,
		 	remarks,
		 	habitat,
		 	associated_species,
		 	taxa_formula,
		 	full_taxon_name,
	        phylclass,
	    	kingdom,
	    	phylum,
	    	phylOrder,
	    	family,
	    	genus,
	    	species,
	    	subspecies,
	    	author_text,
	    	nomenclatural_code,
	    	infraspecific_rank,
		 	identificationModifier,
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
	        collectorNumber,
	        verbatimElevation,
	        year,
	        month,
	        day) = (
	    SELECT
            cataloged_item.cat_num,
		    cataloged_item.accn_id,
            cataloged_item.collecting_event_id,
            collection.collection_cde,
            cataloged_item.collection_id,
            to_char(cataloged_item.cat_num),
	  	 	collection.institution_acronym,
		 	collection.collection,
		 	collecting_event.began_date,
		 	collecting_event.ended_date,
		 	collecting_event.verbatim_date,
		 	coll_object.last_edit_date,
		 	coll_object.lot_count,
		 	coll_object.coll_obj_disposition,
		 	concatColl(cataloged_item.collection_object_id),
		 	concatSingleOtherId(cataloged_item.collection_object_id,'Field Num'),
		 	concatOtherId(cataloged_item.collection_object_id),
		 	concatGenbank(cataloged_item.collection_object_id),
		 	concatRelations(cataloged_item.collection_object_id),
		 	concatTypeStatus(cataloged_item.collection_object_id),
		 	concatAttributeValue(cataloged_item.collection_object_id,'sex'),
		 	concatParts(cataloged_item.collection_object_id),
		 	concatEncumbrances(cataloged_item.collection_object_id),
		 	trans.institution_acronym || ' ' || accn.accn_number,
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
			    locality.orig_elev_units),
			to_meters(locality.maximum_elevation, 
			    locality.orig_elev_units),
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
				'degrees dec. minutes', 
					to_char(accepted_lat_long.lat_deg) || 'd ' || 
					to_char(accepted_lat_long.dec_lat_min) || 'm ' || 
					accepted_lat_long.lat_dir),
			decode(accepted_lat_long.orig_lat_long_units,
				'decimal degrees',
					to_char(accepted_lat_long.dec_long) || 'd',
				'deg. min. sec.',
					to_char(accepted_lat_long.long_deg) || 'd ' ||
					to_char(accepted_lat_long.long_min) || 'm ' ||
					to_char(accepted_lat_long.long_sec) || 's ' || 
					accepted_lat_long.long_dir,
				'degrees dec. minutes',
					to_char(accepted_lat_long.long_deg) || 'd ' ||
					to_char(accepted_lat_long.dec_long_min) || 'm ' || 
					accepted_lat_long.long_dir),
			accepted_lat_long.lat_long_ref_source,
			to_meters(accepted_lat_long.max_error_distance,
			    accepted_lat_long.max_error_units),
			accepted_lat_long.georefmethod,
		 	accepted_lat_long.lat_long_remarks,
		 	lldetr.agent_name,
		 	identification.identification_id,
			identification.scientific_name,
			concatidentifiers(cataloged_item.collection_object_id),
		 	identification.made_date,
		 	coll_object_remark.coll_object_remarks,
		 	coll_object_remark.habitat,
		 	coll_object_remark.associated_species,
		 	taxa_formula,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'full_taxon_name')
	    	    ELSE full_taxon_name
	    	END,
	        CASE WHEN taxa_formula LIKE '%B' 
	            THEN  get_taxonomy(cataloged_item.collection_object_id,'phylclass')
	    	    ELSE phylclass
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN  get_taxonomy(cataloged_item.collection_object_id,'Kingdom')
	    	    ELSE kingdom
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'Phylum')
	    	    ELSE phylum
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'phylOrder')
	    	    ELSE phylOrder
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'Family')
	    	    ELSE family
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'Genus')
	    	    ELSE genus
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'Species')
	    	    ELSE species
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'Subspecies')
	    	    ELSE subspecies
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'author_text')
	    	    ELSE author_text
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'nomenclatural_code')
	    	    ELSE nomenclatural_code
	    	END,
	    	CASE WHEN taxa_formula LIKE '%B' 
	    	    THEN get_taxonomy(cataloged_item.collection_object_id,'infraspecific_rank')
	    	    ELSE infraspecific_rank
	    	END,
		 	' ',
		 	collection.institution_acronym || ':' || 
		 	    collection.collection_cde || ':' || 
		 	    cataloged_item.cat_num,
		 	decode(coll_object.coll_object_type,
	             'CI','PreservedSpecimen',
	             'HO','HumanObservation',
	             'OtherSpecimen'),
	        locality.depth_units,
	        locality.min_depth,
	        locality.max_depth,
	        to_meters(locality.min_depth,locality.depth_units),
	        to_meters(locality.max_depth,locality.depth_units),
		 	collecting_event.collecting_method,
		 	collecting_event.collecting_source,
		 	decode(collecting_event.began_date,
	            collecting_event.ended_date,to_number(to_char(collecting_event.began_date,'DDD')),
	            NULL),
	        concatAttributeValue(cataloged_item.collection_object_id,'age_class'),
	        concatattribute(cataloged_item.collection_object_id),
	        accepted_lat_long.verificationstatus,
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
	            cataloged_item.cat_num,
	        'http://arctos.database.museum/SpecimenDetail.cfm?GUID=' || 
	            collection.institution_acronym || ':' || 
	            collection.collection_cde || ':' || 
	            cataloged_item.cat_num,
	        concatSingleOtherId(cataloged_item.collection_object_id,'collector number'),
	        decode(locality.orig_elev_units,
	            NULL,
	            NULL,
	            locality.minimum_elevation ||'-'|| 
	                locality.maximum_elevation||' '|| 
	                locality.orig_elev_units),
	        decode(to_number(to_char(collecting_event.began_date,'YYYY')),
	            to_number(to_char(collecting_event.ended_date,'YYYY')),
	            to_number(to_char(collecting_event.began_date,'YYYY')),
	            NULL),
	        decode(to_number(to_char(collecting_event.began_date,'MM')),
	            TO_number(to_char(collecting_event.ended_date,'MM')),
	            TO_number(to_char(collecting_event.began_date,'MM')),
	            NULL),
	        decode(to_number(to_char(collecting_event.began_date,'DD')),
	            to_number(to_char(collecting_event.ended_date,'DD')),
	            to_number(to_char(collecting_event.began_date,'DD')),
	            NULL)
	 	FROM
	 		cataloged_item,
	 		coll_object,
	 		collection,
	 		accn,
	 		trans,
	 		collecting_event,
	 		locality,
	 		geog_auth_rec,
	 		accepted_lat_long,
	 		identification,
	 		coll_object_remark,
	 		preferred_agent_name lldetr,
	 		identification_taxonomy,
	 		taxonomy
	 	WHERE flat.collection_object_id = cataloged_item.collection_object_id 
	 	    AND cataloged_item.collection_object_id = coll_object.collection_object_id 
	 	    AND cataloged_item.collection_id = collection.collection_id 
	 	    AND cataloged_item.accn_id = accn.transaction_id 
	 	    AND accn.transaction_id = trans.transaction_id 
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
	 	    AND coll_object.collection_object_id = coll_object_remark.collection_object_id (+))
    WHERE flat.collection_object_id = collobjid;
END;
/

/*
CREATE OR REPLACE PROCEDURE update_flat (collobjid IN number) IS
BEGIN
	dbms_output.put_line(collobjid);
	UPDATE flat
	SET (
		institution_acronym,
	 	collection_cde,
	 	collection,
	 	began_date,
	 	ended_date,
	 	verbatim_date,
	 	last_edit_date,
	 	individualCount,
	 	coll_obj_disposition,
	 	collectors,
	 	field_num,
	 	otherCatalogNumbers,
	 	genbankNum,
	 	relatedCatalogedItems,
	 	typeStatus,
	 	sex,
	 	parts,
	 	encumbrances,
	 	accession,
	 	geog_auth_rec_id,
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
		locality_id,
	 	spec_locality,
	 	minimum_elevation,
	 	maximum_elevation,
	 	orig_elev_units,
	 	min_elev_in_m,
	 	max_elev_in_m,
	 	dec_lat,
	 	dec_long,
	 	datum,
	 	orig_lat_long_units,
	 	verbatimLatitude,
		verbatimLongitude,
		lat_long_ref_source,
		coordinateUncertaintyInMeters,
		georefmethod,
	 	lat_long_remarks,
	 	lat_long_determiner,
	 	identification_id,
		scientific_name,
		identifiedby,
	 	made_date,
	 	remarks,
	 	habitat,
	 	associated_species,
	 	full_taxon_name,
        phylclass,
    	Kingdom,
    	Phylum,
    	phylOrder,
    	Family,
    	Genus,
    	Species,
    	Subspecies,
    	author_text,
    	NOMENCLATURAL_CODE,
    	infraspecific_rank,
	 	IdentificationModifier,
	 	GUID,
	 	basisOfrecord,
        DEPTH_UNITS,
        MIN_DEPTH,
        MAX_DEPTH,
        min_depth_in_m,
        max_depth_in_m,
	 	collecting_method,
	 	COLLECTING_SOURCE,
	 	dayOfYear,
        age_class,
        attributes,
        verificationstatus,
        SpecimenDetailUrl,
        ImageUrl,
        FieldNotesUrl,
        CollectorNumber,
        VerbatimElevation,
        year,
        MONTH,
        DAY
    )=(
    SELECT
  	 	collection.institution_acronym,
	 	collection.collection_cde,
	 	collection.collection,
	 	collecting_event.began_date,
	 	collecting_event.ended_date,
	 	collecting_event.verbatim_date,
	 	coll_object.last_edit_date,
	 	coll_object.lot_count,
	 	coll_object.coll_obj_disposition,
	 	concatColl(collobjid),
	 	concatSingleOtherId(collobjid, 'Field Num'),
	 	concatOtherId(collobjid),
	 	concatGenbank(collobjid),
	 	concatRelations(collobjid),
	 	concatTypeStatus(collobjid),
	 	concatAttributeValue(collobjid, 'sex'),
	 	concatParts(collobjid),
	 	concatEncumbrances(collobjid),
	 	trans.institution_acronym || ' ' || accn.accn_number,
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
		    locality.orig_elev_units),
		to_meters(locality.maximum_elevation, 
		    locality.orig_elev_units),
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
			'degrees dec. minutes', 
				to_char(accepted_lat_long.lat_deg) || 'd ' || 
				to_char(accepted_lat_long.dec_lat_min) || 'm ' || 
				accepted_lat_long.lat_dir),
		decode(accepted_lat_long.orig_lat_long_units,
			'decimal degrees',
				to_char(accepted_lat_long.dec_long) || 'd',
			'deg. min. sec.',
				to_char(accepted_lat_long.long_deg) || 'd ' ||
				to_char(accepted_lat_long.long_min) || 'm ' ||
				to_char(accepted_lat_long.long_sec) || 's ' || 
				accepted_lat_long.long_dir,
			'degrees dec. minutes',
				to_char(accepted_lat_long.long_deg) || 'd ' ||
				to_char(accepted_lat_long.dec_long_min) || 'm ' || 
				accepted_lat_long.long_dir),
		accepted_lat_long.lat_long_ref_source,
		to_meters(accepted_lat_long.max_error_distance, 
		    accepted_lat_long.max_error_units),
		accepted_lat_long.georefmethod,
	 	accepted_lat_long.lat_long_remarks,
	 	lldetr.agent_name,
	 	identification.identification_id,
		identification.scientific_name,
		concatidentifiers(collobjid),
	 	identification.made_date,
	 	coll_object_remark.coll_object_remarks,
	 	coll_object_remark.habitat,
	 	coll_object_remark.associated_species,
    	case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'full_taxon_name')
    	else
    		full_taxon_name
    	end,
        case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'phylclass')
    	else
    		phylclass
    	end,
    	case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'Kingdom')
    	else
    		Kingdom
    	end,
    	case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'Phylum')
    	else
    		Phylum
    	end,
    	case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'phylOrder')
    	else
    		phylOrder
    	end,
    	case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'Family')
    	else
    		Family
    	end,
    	case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'Genus')
    	else
    		Genus
    	end,
    	case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'Species')
    	else
    		Species
    	end,
    	case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'Subspecies')
    	else
    		Subspecies
    	end,
    	case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'author_text')
    	else
    		author_text
    	end author_text,
    	case when taxa_formula like '%B' then 
    		get_taxonomy(collobjid,'nomenclatural_code')
    	else
    		nomenclatural_code
    	end,
    	case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'infraspecific_rank')
    	else
    		infraspecific_rank
    	end,
	 	' ',
	 	collection.institution_acronym || ':' || collection.collection_cde || ':' || flat.cat_num,
	 	DECODE (coll_object.coll_object_type,
             'CI','PreservedSpecimen',
             'HO','HumanObservation',
             'OtherSpecimen'),
        DEPTH_UNITS,
        MIN_DEPTH,
        MAX_DEPTH,
        to_meters(MIN_DEPTH,DEPTH_UNITS),
        to_meters(MAX_DEPTH,DEPTH_UNITS),
	 	collecting_method,
	 	COLLECTING_SOURCE,
	 	DECODE (began_date,
          ended_date,to_number(to_char(began_date,'DDD')),
          NULL),
        concatAttributeValue(collobjid, 'age_class'),
        concatattribute(collobjid),
        verificationstatus,
        '<a href="http://mvzarctos.berkeley.edu/SpecimenDetail.cfm?GUID=' || collection.institution_acronym || ':' || collection.collection_cde || ':' || flat.cat_num || '">' || collection.institution_acronym || ':' || collection.collection_cde || ':' || flat.cat_num || '</a>',
        'http://mvzarctos.berkeley.edu/SpecimenDetail.cfm?GUID=' || collection.institution_acronym || ':' || collection.collection_cde || ':' || flat.cat_num,
        'http://mvzarctos.berkeley.edu/SpecimenDetail.cfm?GUID=' || collection.institution_acronym || ':' || collection.collection_cde || ':' || flat.cat_num,
        concatSingleOtherId(collobjid, 'collector number'),
        DECODE(ORIG_ELEV_UNITS,
              NULL,NULL,
              MINIMUM_ELEVATION ||'-'||MAXIMUM_ELEVATION||' '||ORIG_ELEV_UNITS),
        DECODE (TO_number(to_char(began_date,'YYYY')),
            TO_number(to_char(ended_date,'YYYY')),
            TO_number(to_char(began_date,'YYYY')),
            NULL),
         DECODE (TO_number(to_char(began_date,'MM')),
            TO_number(to_char(ended_date,'MM')),
            TO_number(to_char(began_date,'MM')),
            NULL),
        DECODE (TO_number(to_char(began_date,'DD')),
            TO_number(to_char(ended_date,'DD')),
            TO_number(to_char(began_date,'DD')),
            NULL)
 	FROM
 		coll_object, 
 		collection,
 		accn,
 		trans,
 		collecting_event,
 		locality,
 		geog_auth_rec,
 		accepted_lat_long,
 		identification,
 		coll_object_remark,
 		preferred_agent_name lldetr,
 		identification_taxonomy,
 		taxonomy
 	WHERE 
 		collobjid = coll_object.collection_object_id AND 
 		flat.collection_id = collection.collection_id AND 
 		flat.accn_id = accn.transaction_id AND 
 		accn.transaction_id = trans.transaction_id AND 
 		flat.collecting_event_id = collecting_event.collecting_event_id AND
 		collecting_event.locality_id = locality.locality_id AND 
 		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND 
 		locality.locality_id = accepted_lat_long.locality_id (+) AND 
 		accepted_lat_long.determined_by_agent_id = lldetr.agent_id (+) AND 
 		collobjid = identification.collection_object_id AND 
 		identification.accepted_id_fg = 1 AND 
 		identification.identification_id = identification_taxonomy.identification_id AND
 		identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id and
	    identification_taxonomy.VARIABLE='A' AND
	     coll_object.collection_object_id = coll_object_remark.collection_object_id (+))
	WHERE collection_object_id = collobjid
;
end;
/
sho err
*/

--SELECT dbms_metadata.get_ddl('PROCEDURE','UPDATE_FLAT_LOCID') FROM dual;
DROP PROCEDURE update_flat_locid;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_CATITEM') FROM dual;
CREATE OR REPLACE TRIGGER a_flat_catitem
AFTER UPDATE ON cataloged_item
FOR EACH ROW
BEGIN
	UPDATE flat 
	SET stale_flag = 1
    WHERE collection_object_id = :OLD.collection_object_id;
END;
/
show errors;

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_ACCN') FROM dual;
DROP TRIGGER b_flat_accn;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_ACCN') FROM dual;
DROP TRIGGER a_flat_accn;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_ACCN') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_accn
AFTER INSERT OR UPDATE ON accn
FOR EACH ROW
BEGIN
	IF :NEW.accn_number != :OLD.accn_number THEN
    	UPDATE flat
    	SET stale_flag = 1 
    	WHERE accn_id = :new.transaction_id;
	END IF;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_COLLECTOR') FROM dual;
DROP TRIGGER b_flat_collector;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_COLLECTOR') FROM dual;
DROP TRIGGER a_flat_collector;

--SELECT dbms_metadata.get_ddl('TRIGGER','AD_FLAT_COLLECTOR') FROM dual;
DROP TRIGGER ad_flat_collector;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_COLLECTOR') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_collector
AFTER INSERT OR UPDATE OR DELETE ON collector
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting
        THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
    UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_RELN') FROM dual;
DROP TRIGGER b_flat_reln;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_RELN') FROM dual;
DROP TRIGGER a_flat_reln;

--SELECT dbms_metadata.get_ddl('TRIGGER','AD_FLAT_RELN') FROM dual;
DROP TRIGGER ad_flat_reln;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_RELN') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_reln
AFTER INSERT OR UPDATE OR DELETE ON biol_indiv_relations
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting 
        THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_PART') FROM dual;
DROP TRIGGER b_flat_part;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_PART') FROM dual;
DROP TRIGGER a_flat_part;

--SELECT dbms_metadata.get_ddl('TRIGGER','AD_FLAT_PART') FROM dual;
DROP TRIGGER ad_flat_part;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_PART') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_part
AFTER INSERT OR UPDATE OR DELETE ON specimen_part
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.derived_from_cat_item;
	    ELSE id := :NEW.derived_from_cat_item;
	END IF;
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/
sho err
	    
--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_COLLOBJ') FROM dual;
DROP TRIGGER b_flat_collobj;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_COLLOBJ') FROM dual;
DROP TRIGGER a_flat_collobj;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_COLLOBJ') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_collobj
AFTER INSERT OR UPDATE ON coll_object
FOR EACH ROW
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET stale_flag = 1
        WHERE collection_object_id = :NEW.collection_object_id;
	END LOOP;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_COLLEVNT') FROM dual;
DROP TRIGGER b_flat_collevnt;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_COLLEVNT') FROM dual;
CREATE OR REPLACE TRIGGER a_flat_collevnt
AFTER UPDATE ON collecting_event
FOR EACH ROW
BEGIN
    UPDATE flat
	SET stale_flag = 1
	WHERE collecting_event_id = :NEW.collecting_event_id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_COLLEVNT') FROM dual;
DROP TRIGGER up_flat_collevnt;

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_SEX') FROM dual;
DROP TRIGGER b_flat_sex;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_SEX') FROM dual;
DROP TRIGGER a_flat_sex;

--SELECT dbms_metadata.get_ddl('TRIGGER','AD_FLAT_SEX') FROM dual;
DROP TRIGGER ad_flat_sex;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_SEX') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_sex
AFTER INSERT OR UPDATE OR DELETE ON attributes
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_CATITEM') FROM dual;
DROP TRIGGER b_flat_catitem;

--SELECT dbms_metadata.get_ddl('TRIGGER','TI_FLAT_CATITEM') FROM dual;
CREATE OR REPLACE TRIGGER ti_flat_catitem
AFTER INSERT ON cataloged_item
FOR EACH ROW
BEGIN
	INSERT INTO flat (
		collection_object_id,
		cat_num,
		accn_id,
		collecting_event_id,
		collection_cde,
		collection_id,
		catalognumbertext,
		stale_flag)
	VALUES (
		:NEW.collection_object_id,
		:NEW.cat_num,
		:NEW.accn_id,
		:NEW.collecting_event_id,
		:NEW.collection_cde,
		:NEW.collection_id,
		to_char(:NEW.cat_num),
		1);
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','TU_FLAT_CATITEM') FROM dual;
CREATE OR REPLACE TRIGGER tu_flat_catitem
AFTER UPDATE ON cataloged_item
FOR EACH ROW
BEGIN
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = :NEW.collection_object_id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','AD_FLAT_CATITEM') FROM dual;
CREATE OR REPLACE TRIGGER ad_flat_catitem
AFTER DELETE ON cataloged_item
FOR EACH ROW
BEGIN
	DELETE FROM flat
	WHERE collection_object_id = :OLD.collection_object_id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_CATITEM') FROM dual;
DROP TRIGGER up_flat_catitem;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_GEOG') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_geog
AFTER UPDATE ON geog_auth_rec
FOR EACH ROW
BEGIN
	UPDATE flat
	SET stale_flag = 1
    WHERE geog_auth_rec_id = :NEW.geog_auth_rec_id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_GEOG') FROM dual;
DROP TRIGGER a_flat_geog;

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_GEOG') FROM dual;
DROP TRIGGER b_flat_geog;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_LAT_LONG') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_lat_long
AFTER INSERT OR UPDATE OR DELETE ON lat_long
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.locality_id;
	    ELSE id := :NEW.locality_id;
	END IF;
    UPDATE flat
	SET  stale_flag = 1
    WHERE locality_id = id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','AD_FLAT_LAT_LONG') FROM dual;
DROP TRIGGER ad_flat_lat_long;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_LAT_LONG') FROM dual;
DROP TRIGGER a_flat_lat_long;

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_LAT_LONG') FROM dual;
DROP TRIGGER b_flat_lat_long;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_LOCALITY') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_locality
AFTER UPDATE ON locality
FOR EACH ROW
BEGIN
    UPDATE flat
    SET stale_flag = 1
    WHERE locality_id = :NEW.locality_id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_LOCALITY') FROM dual;
DROP TRIGGER a_flat_locality;

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_LOCALITY') FROM dual;
DROP TRIGGER b_flat_locality;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_AGENTNAME') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_agentname
AFTER INSERT OR UPDATE ON agent_name
FOR EACH ROW
BEGIN
	IF :NEW.agent_name_type = 'preferred' THEN
    	FOR r IN (SELECT collection_object_id FROM collector WHERE agent_id = :NEW.agent_id) LOOP
    	    UPDATE flat
    	    SET stale_flag = 1
    	    WHERE collection_object_id = r.collection_object_id;
    	END LOOP;
	END IF;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','AD_FLAT_AGENTNAME') FROM dual;
DROP TRIGGER ad_flat_agentname;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_AGENTNAME') FROM dual;
DROP TRIGGER a_flat_agentname;

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_AGENTNAME') FROM dual;
DROP TRIGGER b_flat_agentname;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_OTHERIDS') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_otherids
AFTER INSERT OR UPDATE OR DELETE ON coll_obj_other_id_num
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	UPDATE flat
	SET stale_flag = 1
    WHERE collection_object_id = id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','AD_FLAT_OTHERIDS') FROM dual;
DROP TRIGGER ad_flat_otherids;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_OTHERIDS') FROM dual;
DROP TRIGGER a_flat_otherids;

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_OTHERIDS') FROM dual;
DROP TRIGGER b_flat_otherids;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_CITATION') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_citation
AFTER INSERT OR UPDATE OR DELETE ON citation
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
	IF deleting 
	    THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	UPDATE flat
	SET stale_flag = 1
    WHERE collection_object_id = id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','AD_FLAT_CITATION') FROM dual;
DROP TRIGGER ad_flat_citation;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_CITATION') FROM dual;
DROP TRIGGER a_flat_citation;

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_CITATION') FROM dual;
DROP TRIGGER b_flat_citation;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_ID') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_id
AFTER INSERT OR UPDATE ON identification
FOR EACH ROW
BEGIN
    IF :NEW.accepted_id_fg = 1 THEN
    	UPDATE flat
	    SET stale_flag = 1
		WHERE collection_object_id = :NEW.collection_object_id;
    END IF;
END;
/

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_ID_TAX') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_id_tax
AFTER INSERT OR UPDATE OR DELETE ON identification_taxonomy
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting 
        THEN id := :OLD.identification_id;
	    ELSE id := :NEW.identification_id;
	END IF;
    UPDATE flat
    SET stale_flag = 1
	WHERE identification_id = id; 
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_AGNT_ID') FROM dual;
DROP TRIGGER b_flat_agnt_id;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_AGNT_ID') FROM dual;
DROP TRIGGER a_flat_agnt_id;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_AGNT_ID') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_agnt_id
AFTER INSERT OR UPDATE OR DELETE ON identification_agent
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting 
        THEN id := :OLD.identification_id;
	    ELSE id := :NEW.identification_id;
	END IF;
    UPDATE flat
    SET stale_flag = 1
	WHERE identification_id = id; 
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_REMARK') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_remark
AFTER INSERT OR UPDATE OR DELETE ON coll_object_remark
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting 
        THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/
sho err

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_REMARK') FROM dual;
DROP TRIGGER b_flat_remark;

--SELECT dbms_metadata.get_ddl('TRIGGER','AD_FLAT_REMARK') FROM dual;
DROP TRIGGER ad_flat_remark;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_REMARK') FROM dual;
DROP TRIGGER a_flat_remark;

--SELECT dbms_metadata.get_ddl('TRIGGER','B_FLAT_COLL_OBJ_ENCUMBER') FROM dual;
DROP TRIGGER b_flat_coll_obj_encumber;

--SELECT dbms_metadata.get_ddl('TRIGGER','A_FLAT_COLL_OBJ_ENCUMBER') FROM dual;
DROP TRIGGER a_flat_coll_obj_encumber;

--SELECT dbms_metadata.get_ddl('TRIGGER','UP_FLAT_COLL_OBJ_ENCUMBER') FROM dual;
CREATE OR REPLACE TRIGGER up_flat_coll_obj_encumber
AFTER INSERT OR UPDATE OR DELETE ON coll_object_encumbrance
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting 
        THEN id := :OLD.collection_object_id;
	    ELSE id := :NEW.collection_object_id;
	END IF;
	UPDATE flat
	SET stale_flag = 1
	WHERE collection_object_id = id;
END;
/
sho err