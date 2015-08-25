/*

copy over
/SpecimenImages
/Reports/templates
/mediaUploads



check svn for A lines, set form permissions

rebuild bulkloader

bring cumv over



*//

-- cataloged item type

alter table cataloged_item drop constraint FK_CTCATALOGED_ITEM_TYPE;
drop table ctcataloged_item_type;
create table ctcataloged_item_type (
    cataloged_item_type varchar2(20) not null,
    description varchar2(4000) not null
);
create or replace public synonym ctcataloged_item_type for ctcataloged_item_type;
grant select on ctcataloged_item_type to public;
grant all on ctcataloged_item_type to manage_codetables;
ALTER TABLE ctcataloged_item_type ADD CONSTRAINT ctcat_item_type_pkey PRIMARY KEY (cataloged_item_type);
insert into ctcataloged_item_type (CATALOGED_ITEM_TYPE,description) values ('specimen','Record representing physical material in archival storage.');
insert into ctcataloged_item_type (CATALOGED_ITEM_TYPE,description) values ('observation','Record not documented with biological material.');
alter trigger TR_CATITEM_AU_FLAT disable;
alter table cataloged_item modify cataloged_item_type varchar2(20);
update cataloged_item set cataloged_item_type='specimen' where collection_id in (select collection_id from collection where lower(collection) not like '%obs%');
update cataloged_item set cataloged_item_type='observation' where collection_id in (select collection_id from collection where lower(collection) like '%obs%');
ALTER TABLE cataloged_item ADD CONSTRAINT FK_CTCATALOGED_ITEM_TYPE FOREIGN KEY (cataloged_item_type) REFERENCES ctcataloged_item_type(cataloged_item_type);
alter trigger TR_CATITEM_AU_FLAT enable;

ALTER TABLE flat ADD cataloged_item_type varchar2(20);

CREATE OR REPLACE TRIGGER TR_CATITEM_AI_FLAT
AFTER INSERT ON cataloged_item
FOR EACH ROW
BEGIN
	INSERT INTO flat (
		collection_object_id,
		cat_num,
		accn_id,
		collection_cde,
		collection_id,
		catalognumbertext,
		cataloged_item_type,
		stale_flag)
	VALUES (
		:NEW.collection_object_id,
		:NEW.cat_num,
		:NEW.accn_id,
		:NEW.collection_cde,
		:NEW.collection_id,
		to_char(:NEW.cat_num),
		:NEW.cataloged_item_type,
		1);
END;
/




CREATE OR REPLACE PROCEDURE UPDATE_FLAT (collobjid IN NUMBER) IS
BEGIN
	UPDATE flat
	SET (
			cataloged_item_type,
			nature_of_id,
			flags,
			enteredby,
			entereddate,
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
			individualCount,
			coll_obj_disposition,
			collectors,
			preparators,
			field_num,
			otherCatalogNumbers,
			genbankNum,
			relatedCatalogedItems,
			typeStatus,
			sex,
			parts,
			partdetail,
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
			coordinateUncertaintyInMeters,
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
			day,
			id_sensu,
			verbatim_locality,
			event_assigned_by_agent,
			event_assigned_date,
			specimen_event_remark,
			specimen_event_type,
			COLL_EVENT_REMARKS,
			verbatim_coordinates,
			collecting_event_name,
			georeference_source,
			georeference_protocol,
			locality_name
			) = (
		SELECT
			cataloged_item.cataloged_item_type,
			nature_of_id,
			flags,
			getPreferredAgentName(coll_object.ENTERED_PERSON_ID),
			COLL_OBJECT_ENTERED_DATE,
			cataloged_item.cat_num,
			cataloged_item.accn_id,
			specimen_event.collecting_event_id,
			collection.collection_cde,
			cataloged_item.collection_id,
			to_char(cataloged_item.cat_num),
			collection.institution_acronym,
			collection.collection,
			collecting_event.began_date,
			collecting_event.ended_date,
			collecting_event.verbatim_date,
			coll_object.lot_count,
			coll_object.coll_obj_disposition,
			concatColl(cataloged_item.collection_object_id),
			concatPrep(cataloged_item.collection_object_id),
			concatSingleOtherId(cataloged_item.collection_object_id, 'Field Num'),
			concatOtherId(cataloged_item.collection_object_id),
			concatGenbank(cataloged_item.collection_object_id),
			concatRelations(cataloged_item.collection_object_id),
			concatTypeStatus(cataloged_item.collection_object_id),
			concatAttributeValue(cataloged_item.collection_object_id, 'sex'),
			concatParts(cataloged_item.collection_object_id),
			concatPartsDetail(cataloged_item.collection_object_id),
			concatEncumbrances(cataloged_item.collection_object_id),
			accn.accn_number,
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
			to_meters(locality.minimum_elevation, locality.orig_elev_units),
			to_meters(locality.maximum_elevation, locality.orig_elev_units),
			locality.dec_lat,
			locality.dec_long,
			collecting_event.datum,
			collecting_event.orig_lat_long_units,
			to_meters(locality.max_error_distance, locality.max_error_units),
			identification.identification_id,
			identification.scientific_name,
			concatidentifiers(cataloged_item.collection_object_id),
			identification.made_date,
			coll_object_remark.coll_object_remarks,
			specimen_event.habitat,
			coll_object_remark.associated_species,
			taxa_formula,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'full_taxon_name')
				ELSE full_taxon_name
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'phylclass')
				ELSE phylclass
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Kingdom')
				ELSE kingdom
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Phylum')
				ELSE phylum
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'phylOrder')
				ELSE phylOrder
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Family')
				ELSE family
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Genus')
				ELSE genus
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Species')
				ELSE species
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Subspecies')
				ELSE subspecies
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'author_text')
				ELSE author_text
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'nomenclatural_code')
				ELSE nomenclatural_code
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'infraspecific_rank')
				ELSE infraspecific_rank
			END,
			' ',
			collection.guid_prefix || ':' ||
			cataloged_item.cat_num,
			decode(coll_object.coll_object_type,
				'CI', 'PreservedSpecimen',
				'HO', 'HumanObservation',
				'OtherSpecimen'),
			locality.depth_units,
			locality.min_depth,
			locality.max_depth,
			to_meters(locality.min_depth,locality.depth_units),
			to_meters(locality.max_depth,locality.depth_units),
			specimen_event.collecting_method,
			specimen_event.collecting_source,
			--decode(collecting_event.began_date,
			--	collecting_event.ended_date, to_number(to_char(collecting_event.began_date, 'DDD')),
			--	NULL),
			0,
			concatAttributeValue(cataloged_item.collection_object_id, 'age class'),
			concatattribute(cataloged_item.collection_object_id),
			specimen_event.verificationstatus,
			'<a href="http://arctos.database.museum/guid/' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num || '">' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num || '</a>',
			'http://arctos.database.museum/guid/' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num,
			'http://arctos.database.museum/guid/' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num,
			concatSingleOtherId(cataloged_item.collection_object_id,'collector number'),
			decode(locality.orig_elev_units,
				NULL, NULL,
				locality.minimum_elevation || '-' || 
					locality.maximum_elevation || ' ' ||
					locality.orig_elev_units),
			-- decode(to_number(to_char(collecting_event.began_date,'YYYY')),to_number(to_char(collecting_event.ended_date,'YYYY')),to_number(to_char(collecting_event.began_date,'YYYY')),NULL),
			substr(collecting_event.began_date,1,4),
			substr(collecting_event.began_date,6,2),
			substr(collecting_event.began_date,9,2),
			'<a href="http://arctos.database.museum/publication/' || idpub.publication_id || '">' || idpub.short_citation || '</a>',
			collecting_event.verbatim_locality,
			getPreferredAgentName(specimen_event.assigned_by_agent_id),
			assigned_date,
			specimen_event_remark,
			specimen_event_type,
			COLL_EVENT_REMARKS,
			verbatim_coordinates,
			collecting_event_name,
			georeference_source,
			georeference_protocol,
			locality_name
		FROM
			cataloged_item,
			coll_object,
			collection,
			accn,
			trans,
			map_specimen_event,
			specimen_event,
			collecting_event,
			locality,
			geog_auth_rec,
			identification,
			coll_object_remark,
			(SELECT * FROM identification_taxonomy WHERE variable = 'A') identification_taxonomy,
			taxonomy,
			publication idpub
		WHERE flat.collection_object_id = cataloged_item.collection_object_id
			AND cataloged_item.collection_object_id = coll_object.collection_object_id
			AND cataloged_item.collection_id = collection.collection_id
			AND cataloged_item.accn_id = accn.transaction_id
			AND accn.transaction_id = trans.transaction_id
			AND cataloged_item.collection_object_id = map_specimen_event.collection_object_id (+)
			AND map_specimen_event.specimen_event_id=specimen_event.specimen_event_id (+)
			AND specimen_event.collecting_event_id=collecting_event.collecting_event_id (+)
			AND collecting_event.locality_id = locality.locality_id (+)
			AND locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id (+)
			AND cataloged_item.collection_object_id = identification.collection_object_id
			AND identification.accepted_id_fg = 1
			AND identification.publication_id=idpub.publication_id (+)
			AND identification.identification_id = identification_taxonomy.identification_id (+)
			AND identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id (+)
			AND coll_object.collection_object_id = coll_object_remark.collection_object_id (+))
	WHERE flat.collection_object_id = collobjid;
EXCEPTION WHEN OTHERS THEN
    UPDATE flat SET stale_flag=-1 WHERE collection_object_id = collobjid;
END;
/




CREATE OR REPLACE VIEW filtered_flat AS
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
        otherCatalogNumbers,
        genbankNum,
        relatedCatalogedItemS,
        typeStatus,
        sex,
        parts,
        partdetail,
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
        '' emptystring,
        verbatim_locality,
		event_assigned_by_agent,
		event_assigned_date,
		specimen_event_remark,
		specimen_event_type,
		COLL_EVENT_REMARKS,
		collecting_event_name,
		georeference_source,
		georeference_protocol,
		locality_name
    FROM
        flat
    WHERE
    -- exclude masked records
        (encumbrances is null OR encumbrances NOT LIKE '%mask record%');	
        
    
 
 
 
update flat set cataloged_item_type='specimen' where lower(collection) not like '%obs%';
update flat set cataloged_item_type='observation' where lower(collection) like '%obs%';

   