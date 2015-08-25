/*
11/14/2008 LKV
this file is obsolete and replaced by flat.triggers_setFlag.sql.
see flat.triggers_setFlag.sql for current procedures and triggers.
*/

/* 
	This file serves as a convenient way to group all triggers and some procedures used to maintain 
	table FLAT. 
	
	Current as of 17 Oct 2007
	
*/
--------------------------------------------------- current UAM --------------------------------------------------------

CREATE PROCEDURE "UAM"."UPDATE_FLAT" (collobjid IN NUMBER) IS
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
cataloged_item.collection_cde,
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
     THEN get_taxonomy(cataloged_item.collection_object_id,'phylclass')
          ELSE phylclass
         END,
         CASE WHEN taxa_formula LIKE '%B'
          THEN get_taxonomy(cataloged_item.collection_object_id,'Kingdom')
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
             flat.cat_num,
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

--------------------------------------------------------------------------------------------------------------------------
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
    	case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'full_taxon_name')
    	else
    		full_taxon_name
    	end,
        case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'phylclass')
    	else
    		phylclass
    	end,
    	case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'Kingdom')
    	else
    		Kingdom
    	end,
    	case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'Phylum')
    	else
    		Phylum
    	end,
    	case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'phylOrder')
    	else
    		phylOrder
    	end,
    	case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'Family')
    	else
    		Family
    	end,
    	case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'Genus')
    	else
    		Genus
    	end,
    	case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'Species')
    	else
    		Species
    	end,
    	case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'Subspecies')
    	else
    		Subspecies
    	end,
    	case when TAXA_FORMULA like '%B' then 
    		get_taxonomy(collobjid,'author_text')
    	else
    		author_text
    	end author_text,
    	case when TAXA_FORMULA like '%B' then 
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
        '<a href="http://arctos.database.museum/SpecimenDetail.cfm?GUID=' || collection.institution_acronym || ':' || collection.collection_cde || ':' || flat.cat_num || '">' || collection.institution_acronym || ':' || collection.collection_cde || ':' || flat.cat_num || '</a>',
        'http://arctos.database.museum/SpecimenDetail.cfm?GUID=' || collection.institution_acronym || ':' || collection.collection_cde || ':' || flat.cat_num,
        'http://arctos.database.museum/SpecimenDetail.cfm?GUID=' || collection.institution_acronym || ':' || collection.collection_cde || ':' || flat.cat_num,
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
/* end update_flat procedure */

/* begin update_flat_locid procedure */
CREATE OR REPLACE PROCEDURE update_flat_locid (locid IN number) IS
BEGIN
	UPDATE flat
	SET (
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
			DEPTH_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			min_depth_in_m,
			max_depth_in_m,
			VerbatimElevation,
			verificationstatus
			) = (
		SELECT
			locality.spec_locality,
			locality.minimum_elevation,
			locality.maximum_elevation,
			locality.orig_elev_units,
			to_meters(locality.minimum_elevation, locality.orig_elev_units),
			to_meters(locality.maximum_elevation, locality.orig_elev_units),
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
			to_meters(accepted_lat_long.max_error_distance, accepted_lat_long.max_error_units),
			accepted_lat_long.georefmethod,
			accepted_lat_long.lat_long_remarks,
			preferred_agent_name.agent_name,
			DEPTH_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			to_meters(MIN_DEPTH,DEPTH_UNITS),
            to_meters(MAX_DEPTH,DEPTH_UNITS),
			DECODE(ORIG_ELEV_UNITS,
              NULL,NULL,
              MINIMUM_ELEVATION ||'-'||MAXIMUM_ELEVATION||' '||ORIG_ELEV_UNITS),
            verificationstatus
		FROM
			locality,
			accepted_lat_long,
			preferred_agent_name
		WHERE
			locality.locality_id = accepted_lat_long.locality_id(+)
		AND	accepted_lat_long.determined_by_agent_id = preferred_agent_name.agent_id(+)
		AND	locality.locality_id = locid)
	WHERE locality_id = locid;
END;
/
sho err
/* begin update_flat_locid procedure */

/* begin accn triggers*/
CREATE OR REPLACE TRIGGER b_flat_accn
BEFORE INSERT OR UPDATE ON accn
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_accn
AFTER INSERT OR UPDATE ON accn
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.transaction_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_accn
AFTER INSERT OR UPDATE ON accn
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET (accession) = (
			SELECT trans.institution_acronym || ' ' || accn.accn_number
			FROM trans, accn
			WHERE
				trans.transaction_id = accn.transaction_id
			AND	accn.transaction_id = state_pkg.newRows(i))
		WHERE accn_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err
/* end accn triggers */

/* begin collector triggers */
CREATE OR REPLACE TRIGGER b_flat_collector
BEFORE INSERT OR UPDATE OR DELETE ON collector
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_collector
AFTER INSERT OR UPDATE ON collector
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER ad_flat_collector
AFTER DELETE ON collector
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_collector
AFTER INSERT OR UPDATE OR DELETE ON collector
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET collectors = concatColl(collection_object_id)
	 	WHERE collection_object_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err
/* begin collector triggers */

/* begin biol_indiv_relations triggers */
CREATE OR REPLACE TRIGGER b_flat_reln
BEFORE INSERT OR UPDATE OR DELETE ON biol_indiv_relations
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_reln
AFTER INSERT OR UPDATE ON biol_indiv_relations
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER ad_flat_reln
AFTER DELETE ON biol_indiv_relations
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_reln
AFTER INSERT OR UPDATE OR DELETE ON biol_indiv_relations
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET relatedCatalogedItems = concatRelations(collection_object_id)
		WHERE collection_object_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err
/* end biol_indiv_relations triggers */

/* begin specimen_part triggers */
CREATE OR REPLACE TRIGGER b_flat_part
BEFORE INSERT OR UPDATE OR DELETE ON specimen_part
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_part
AFTER INSERT OR UPDATE ON specimen_part
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.derived_from_cat_item;
END;
/
sho err

CREATE OR REPLACE TRIGGER ad_flat_part
AFTER DELETE ON specimen_part
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.derived_from_cat_item;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_part
AFTER INSERT OR UPDATE OR DELETE ON specimen_part
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET parts = concatParts(collection_object_id)
		WHERE collection_object_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err
/* end specimen_part triggers */

/* begin coll_object triggers */
CREATE OR REPLACE TRIGGER b_flat_collobj
BEFORE INSERT OR UPDATE ON coll_object
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_collobj
AFTER INSERT OR UPDATE ON coll_object
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
END;
/
sho err



CREATE OR REPLACE TRIGGER up_flat_collobj
AFTER INSERT OR UPDATE ON coll_object
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET (
				last_edit_date,
				individualcount,
 				coll_obj_disposition,
 				basisOfrecord
 				) = (
			SELECT
				last_edit_date,
				lot_count,
				coll_obj_disposition,
				DECODE (coll_object.coll_object_type,
                     'CI','PreservedSpecimen',
                     'HO','HumanObservation',
                     'OtherSpecimen')
			FROM coll_object
			WHERE collection_object_id = state_pkg.newRows(i))
		WHERE collection_object_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err
/* end coll_object triggers */


/* begin collecting_event triggers
	Possibilities:
		update collecting event data ==>update flat
		update collecting event.locality_id ==> call procedure to update flat
 */
CREATE OR REPLACE TRIGGER b_flat_collevnt
BEFORE UPDATE ON collecting_event
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_collevnt
AFTER UPDATE ON collecting_event
FOR EACH ROW
BEGIN
	IF :NEW.locality_id != :OLD.locality_id THEN
	    UPDATE flat
	    SET locality_id = :new.locality_id
	    WHERE collecting_event_id = :old.collecting_event_id;
	END IF;
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collecting_event_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_collevnt
AFTER UPDATE ON collecting_event
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET (
				locality_id,
				began_date,
				ended_date,
				verbatim_date,
				collecting_method,
				COLLECTING_SOURCE,
				dayOfYear,
				year,
				month,
				day
				) = (
			SELECT
				locality_id,
				began_date,
				ended_date,
				verbatim_date,
				collecting_method,
				COLLECTING_SOURCE,
				DECODE (began_date,
                  ended_date,to_number(to_char(began_date,'DDD')),
                  NULL),
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
			FROM collecting_event
			WHERE collecting_event_id = state_pkg.newRows(i))
		WHERE collecting_event_id = state_pkg.newRows(i);

		FOR r IN (
			SELECT locality_id
			FROM flat
			WHERE collecting_event_id = state_pkg.newRows(i)
	 		GROUP BY locality_id) LOOP
	 		update_flat_locid(r.locality_id);
	 	END LOOP;
	END LOOP;
END;
/
sho err

/* end collecting_event triggers */

/* begin sex attributes triggers */
CREATE OR REPLACE TRIGGER b_flat_sex
BEFORE INSERT OR UPDATE OR DELETE ON attributes
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_sex
AFTER INSERT OR UPDATE ON attributes
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER ad_flat_sex
AFTER DELETE ON attributes
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_sex
AFTER INSERT OR UPDATE OR DELETE ON attributes
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET 
		    sex = concatAttributeValue(collection_object_id, 'sex'),
		    age_class = concatAttributeValue(collection_object_id, 'age class'),
		    attributes = concatattribute(collection_object_id)
		WHERE collection_object_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err
/* end sex attributes triggers */

/* begin cataloged_item triggers */
CREATE OR REPLACE TRIGGER b_flat_catitem
BEFORE INSERT OR UPDATE OR DELETE ON cataloged_item
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_catitem
AFTER UPDATE ON cataloged_item
FOR EACH ROW
BEGIN
    UPDATE flat 
    SET
        collecting_event_id = :new.collecting_event_id,
        collection_id = :new.collection_id,
        cat_num = :new.cat_num,
        accn_id = :new.accn_id,
        collection_cde = :new.collection_cde
    WHERE collection_object_id = :old.collection_object_id;
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
END;
/
sho err

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
		catalognumbertext
		)
	VALUES (
		:new.collection_object_id,
		:new.cat_num,
		:new.accn_id,
		:new.collecting_event_id,
		:new.collection_cde,
		:new.collection_id,
		to_char(:NEW.cat_num)
		);
	update_flat(:new.collection_object_id);
END;
/
sho err
/* DLM 18 Jan 08 - not updating properly with collection change */
CREATE OR REPLACE TRIGGER up_flat_catitem
AFTER UPDATE ON cataloged_item
FOR EACH ROW
BEGIN
    UPDATE flat SET
        cat_num = :new.cat_num,
		accn_id = :new.accn_id,
		collecting_event_id = :new.collecting_event_id,
		collection_cde = :new.collection_cde,
		collection_id =:new.collection_id,
		catalognumbertext = to_char(:NEW.cat_num)
    WHERE
        collection_object_id = :new.collection_object_id;
	update_flat(:new.collection_object_id);
END;
/
sho err
/*
CREATE OR REPLACE TRIGGER up_flat_catitem
AFTER UPDATE ON cataloged_item
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		update_flat(state_pkg.newRows(i));
	END LOOP;
END;
/
sho err
*/
CREATE OR REPLACE TRIGGER ad_flat_catitem
AFTER DELETE ON cataloged_item
FOR EACH ROW
BEGIN
	DELETE FROM flat
	WHERE collection_object_id = :old.collection_object_id;
END;
/
sho err


CREATE OR REPLACE TRIGGER up_flat_geog
AFTER UPDATE ON geog_auth_rec
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET (
				higher_geog,
				continent_ocean,
				country,
				state_prov,
				county,
				feature,
				island,
				island_group,
				quad,
				sea) = (
			SELECT
				higher_geog,
				continent_ocean,
				country,
				state_prov,
				county,
				feature,
				island,
				island_group,
				quad,
				sea
			FROM geog_auth_rec
			WHERE geog_auth_rec_id = state_pkg.newRows(i))
		WHERE geog_auth_rec_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_geog
AFTER UPDATE ON geog_auth_rec
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.geog_auth_rec_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER b_flat_geog
BEFORE UPDATE ON geog_auth_rec
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_lat_long
AFTER INSERT OR UPDATE OR DELETE ON lat_long
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET (
				dec_lat,
				dec_long,
				datum,
				orig_lat_long_units,
				verbatimlatitude,
				verbatimlongitude,
				georefmethod,
				coordinateuncertaintyinmeters,
				lat_long_remarks,
				lat_long_determiner,
				verificationstatus) = (
			SELECT
				lat_long.dec_lat,
				lat_long.dec_long,
				lat_long.datum,
				lat_long.orig_lat_long_units,
				decode(lat_long.orig_lat_long_units,
					'decimal degrees',
						to_char(lat_long.dec_lat) || 'd',
					'deg. min. sec.',
						to_char(lat_long.lat_deg) || 'd ' ||
						to_char(lat_long.lat_min) || 'm ' ||
						to_char(lat_long.lat_sec) || 's ' || lat_long.lat_dir,
					'degrees dec. minutes',
						to_char(lat_long.lat_deg) || 'd ' ||
						to_char(lat_long.dec_lat_min) || 'm ' || lat_long.lat_dir),
				decode(lat_long.orig_lat_long_units,
			 		'decimal degrees',
			 			to_char(lat_long.dec_long) || 'd',
					'deg. min. sec.',
						to_char(lat_long.long_deg) || 'd ' ||
						to_char(lat_long.long_min) || 'm ' ||
						to_char(lat_long.long_sec) || 's ' || lat_long.long_dir,
					'degrees dec. minutes',
						to_char(lat_long.long_deg) || 'd ' ||
						to_char(lat_long.dec_long_min) || 'm ' || lat_long.long_dir),
				lat_long.georefmethod,
				to_meters(lat_long.max_error_distance, lat_long.max_error_units),
  				lat_long.lat_long_remarks,
  				preferred_agent_name.agent_name,
  				verificationstatus
			FROM
 				lat_long,
 				preferred_agent_name
			WHERE
 				accepted_lat_long_fg = 1
 				AND lat_long.determined_by_agent_id = preferred_agent_name.agent_id
 				AND locality_id = state_pkg.newRows(i))
		WHERE locality_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err

CREATE OR REPLACE TRIGGER ad_flat_lat_long
AFTER DELETE ON LAT_LONG
FOR EACH ROW
WHEN (old.accepted_lat_long_fg = 1)
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.locality_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_lat_long
AFTER UPDATE OR INSERT ON lat_long
FOR EACH ROW
WHEN (new.accepted_lat_long_fg = 1)
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.locality_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER b_flat_lat_long
BEFORE UPDATE OR INSERT OR DELETE ON lat_long
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_locality
AFTER UPDATE ON locality
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		update_flat_locid(state_pkg.newRows(i))	;
		update_flat_geoglocid(state_pkg.newRows(i))	;
	END LOOP;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_locality
AFTER UPDATE ON locality
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.locality_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER b_flat_locality
BEFORE UPDATE ON locality
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_agentname
AFTER INSERT OR UPDATE OR DELETE ON agent_name
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET collectors = concatcoll(collection_object_id)
		WHERE collection_object_id IN (
			SELECT collection_object_id
			FROM collector
			WHERE agent_id = state_pkg.newRows(i));
	END LOOP;
END;
/
sho err

CREATE OR REPLACE TRIGGER ad_flat_agentname
AFTER DELETE ON agent_name
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.agent_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_agentname
AFTER INSERT OR UPDATE ON agent_name
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.agent_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER b_flat_agentname
BEFORE INSERT OR UPDATE OR DELETE ON agent_name
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_otherids
AFTER INSERT OR UPDATE OR DELETE ON coll_obj_other_id_num
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET
			genbankNum = concatGenbank(collection_object_id),
			otherCatalogNumbers = concatOtherId(collection_object_id),
			field_num = concatSingleOtherId(collection_object_id,'Field Num'),
			CollectorNumber = concatSingleOtherId(collection_object_id, 'collector number')
		WHERE collection_object_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err

CREATE OR REPLACE TRIGGER ad_flat_otherids
AFTER DELETE ON coll_obj_other_id_num
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_otherids
AFTER INSERT OR UPDATE ON coll_obj_other_id_num
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER b_flat_otherids
BEFORE INSERT OR UPDATE OR DELETE ON coll_obj_other_id_num
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_citation
AFTER INSERT OR UPDATE OR DELETE ON citation
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET typestatus = concatTypeStatus(collection_object_id)
		WHERE collection_object_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err

CREATE OR REPLACE TRIGGER ad_flat_citation
AFTER DELETE ON citation
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_citation
AFTER INSERT OR UPDATE ON citation
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER b_flat_citation
BEFORE INSERT OR UPDATE OR DELETE ON citation
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_id
AFTER INSERT OR UPDATE ON identification
FOR EACH ROW
BEGIN
	UPDATE flat
	SET
		scientific_name = :new.scientific_name,
		made_date = :new.made_date,
		identification_id = :NEW.identification_id
	WHERE collection_object_id = :new.collection_object_id;
END;
/

CREATE OR REPLACE TRIGGER up_flat_id_tax
AFTER INSERT OR UPDATE ON identification_taxonomy
FOR EACH ROW
    DECLARE tf VARCHAR2(255);
    coid NUMBER;
    aidf NUMBER;
    full_taxon_name VARCHAR2(4000);
    phylclass VARCHAR2(255);
    Kingdom VARCHAR2(255);
    Phylum VARCHAR2(255);
    phylOrder VARCHAR2(255);
    Family VARCHAR2(255);
    Genus VARCHAR2(255);
    Species VARCHAR2(255);
    Subspecies VARCHAR2(255);
    author_text VARCHAR2(255);
    nomenclatural_code VARCHAR2(255);
    infraspecific_rank VARCHAR2(255);
BEGIN
   
    -- NOTE: this trigger will NOT produce the correct data for sub-divergence
    -- levels on multi-taxa identifications. It WILL work 
    -- most of the time for most things. You have been warned. Feel free to fix it....
    SELECT 
        taxa_formula,
        collection_object_id,
        accepted_id_fg
    INTO 
        tf,
        coid,
        aidf
    FROM 
        identification 
    WHERE 
        identification_id=:NEW.identification_id;
    IF aidf = 1 THEN
    	SELECT
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
            nomenclatural_code,
            infraspecific_rank
        INTO
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
            nomenclatural_code,
            infraspecific_rank
       FROM
           taxonomy
       WHERE
           taxon_name_id = :NEW.taxon_name_id;
      UPDATE flat SET 
          full_taxon_name = full_taxon_name,
          phylclass = phylclass,
          Kingdom = Kingdom,
          Phylum = Phylum,
          phylOrder = phylOrder,
          Family = Family,
          Genus = Genus,
          Species = Species,
          Subspecies = Subspecies,
          author_text = author_text,
          nomenclatural_code = nomenclatural_code,
          infraspecific_rank = infraspecific_rank
      WHERE
          collection_object_id = coid;    
	END IF;         
END;
/
sho err


CREATE OR REPLACE TRIGGER b_flat_agnt_id
BEFORE INSERT OR UPDATE ON identification_agent
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
CREATE OR REPLACE TRIGGER a_flat_agnt_id
AFTER INSERT OR UPDATE ON identification_agent
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.identification_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_agnt_id
AFTER INSERT OR UPDATE OR DELETE ON identification_agent
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET identifiedby = concatIdrByIdId(state_pkg.newRows(i))
		WHERE identification_id = state_pkg.newRows(i);
		   -- dbms_output.put_line('updated' || state_pkg.newRows(i));
	END LOOP;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_remark
AFTER INSERT OR UPDATE OR DELETE ON coll_object_remark
BEGIN
	FOR i IN 1 .. state_pkg.newRows.count LOOP
		UPDATE flat
		SET (
				remarks,
				habitat,
				associated_species) = (
			SELECT
				coll_object_remarks,
				habitat,
				associated_species
			FROM coll_object_remark
		   	WHERE collection_object_id = state_pkg.newRows(i))
		WHERE collection_object_id = state_pkg.newRows(i);
	END LOOP;
END;
/
sho err

CREATE OR REPLACE TRIGGER b_flat_remark
BEFORE INSERT OR UPDATE OR DELETE ON coll_object_remark
BEGIN
	state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER ad_flat_remark
AFTER DELETE ON coll_object_remark
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER A_FLAT_REMARK
AFTER INSERT OR UPDATE ON coll_object_remark
FOR EACH ROW
BEGIN
	state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
END;
/
sho err

-- added 09 Jan 2008

CREATE OR REPLACE TRIGGER b_flat_coll_obj_encumber
BEFORE INSERT OR UPDATE OR DELETE ON coll_object_encumbrance
BEGIN
    state_pkg.newRows := state_pkg.empty;
END;
/
sho err

CREATE OR REPLACE TRIGGER a_flat_coll_obj_encumber
AFTER INSERT OR UPDATE OR DELETE ON coll_object_encumbrance
FOR EACH ROW
BEGIN
    state_pkg.newRows( state_pkg.newRows.count + 1 ) := :new.collection_object_id;
END;
/
sho err

CREATE OR REPLACE TRIGGER up_flat_coll_obj_encumber
AFTER INSERT OR UPDATE OR DELETE ON coll_object_encumbrance
BEGIN
    FOR i IN 1 .. state_pkg.newRows.count LOOP
        UPDATE flat
        SET encumbrances = concatEncumbrances(state_pkg.newRows(i))
        WHERE collection_object_id = state_pkg.newRows(i);
    END LOOP;
END;
/
sho err