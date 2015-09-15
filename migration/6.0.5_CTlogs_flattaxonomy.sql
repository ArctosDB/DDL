drop table log_geog_auth_rec;


create table log_geog_auth_rec (
	GEOG_AUTH_REC_ID NUMBER,
	username varchar2(60),
	action_type varchar2(60),
	when date default sysdate,
	n_CONTINENT_OCEAN VARCHAR2(50),
	n_COUNTRY VARCHAR2(50),
	n_STATE_PROV VARCHAR2(75),
	n_COUNTY VARCHAR2(50),
	n_QUAD VARCHAR2(30),
	n_FEATURE VARCHAR2(50),
	n_ISLAND VARCHAR2(50),
	n_ISLAND_GROUP VARCHAR2(50),
	n_SEA VARCHAR2(50),
	o_CONTINENT_OCEAN VARCHAR2(50),
	o_COUNTRY VARCHAR2(50),
	o_STATE_PROV VARCHAR2(75),
	o_COUNTY VARCHAR2(50),
	o_QUAD VARCHAR2(30),
	o_FEATURE VARCHAR2(50),
	o_ISLAND VARCHAR2(50),
	o_ISLAND_GROUP VARCHAR2(50),
	o_SEA VARCHAR2(50)
);


CREATE OR REPLACE TRIGGER TR_LOG_GEOG_UPDATE
AFTER INSERT or update or delete ON geog_auth_rec
FOR EACH ROW
	declare
		action_type varchar2(255);		
BEGIN
   moved to /DDL/triggers/uam_triggers/geog_auth_rec.sql
END;
/
sho err;

------------------------------------ flat taxonomy updates ------------------------------------------------------
alter table flat add subfamily varchar2(255);
alter table flat add tribe varchar2(255);
alter table flat add subtribe varchar2(255);


CREATE OR REPLACE PROCEDURE UPDATE_FLAT (collobjid IN NUMBER) IS
	v_full_taxon_name varchar2(4000);
	v_kingdom varchar2(4000);
	v_phylum varchar2(4000);
	v_phylorder varchar2(4000);
	v_phylclass varchar2(4000);
	v_family varchar2(4000);
	v_subfamily varchar2(4000);
	v_tribe varchar2(4000);
	v_subtribe varchar2(4000);
	v_genus varchar2(4000);
	v_species varchar2(4000);
	v_subspecies varchar2(4000);
	v_author_text varchar2(4000);
	v_nomenclatural_code varchar2(4000);
	v_infraspecific_rank varchar2(4000);
	v_infraspecific_author varchar2(4000);
	v_display_name varchar2(4000);
BEGIN
	--- split this up into some smaller, more manageable calls
	-- cataloged item 1:1 stuff
	update flat set (
		CAT_NUM,
		ACCN_ID,
		COLLECTION_ID,
		INSTITUTION_ACRONYM,
		COLLECTION_CDE,
		COLLECTION,
		CATALOGED_ITEM_TYPE,
		LAST_EDIT_DATE,
		SPECIMENDETAILURL,
		ASSOCIATED_SPECIES,
		REMARKS,
		GUID,
		ENTEREDBY,
		ENTEREDDATE,
		COLLECTORS,
		PREPARATORS,
		FLAGS,
		ACCESSION,
		USE_LICENSE_URL,
		PARTDETAIL,
		COLLECTORNUMBER,
		CATALOGNUMBERTEXT,
		GENBANKNUM,
		OTHERCATALOGNUMBERS,
		RELATEDCATALOGEDITEMS,
		FIELD_NUM,
		TYPESTATUS,
		SEX,
		AGE_CLASS,
		ATTRIBUTES,
		ENCUMBRANCES,
		PARTS
	) = (SELECT
			cataloged_item.CAT_NUM,
			cataloged_item.ACCN_ID,
			cataloged_item.COLLECTION_ID,
			collection.INSTITUTION_ACRONYM,
			collection.COLLECTION_CDE,
			collection.COLLECTION,
			cataloged_item.CATALOGED_ITEM_TYPE,
			coll_object.LAST_EDIT_DATE,
			'<a href="http://arctos.database.museum/guid/' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num || '">' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num || '</a>',
			coll_object_remark.ASSOCIATED_SPECIES,
			coll_object_remark.COLL_OBJECT_REMARKS,
			collection.guid_prefix || ':' || cataloged_item.cat_num,
			getPreferredAgentName(coll_object.ENTERED_PERSON_ID),
			coll_object.COLL_OBJECT_ENTERED_DATE,
			concatColl(cataloged_item.collection_object_id),
			concatPrep(cataloged_item.collection_object_id),
			coll_object.FLAGS,
			accn.ACCN_NUMBER,
			ctmedia_license.URI,
			concatPartsDetail(cataloged_item.collection_object_id),
			concatSingleOtherId(cataloged_item.collection_object_id,'collector number'),
			cataloged_item.CAT_NUM,
			concatGenbank(cataloged_item.collection_object_id),
			concatOtherId(cataloged_item.collection_object_id),
			concatRelations(cataloged_item.collection_object_id),
			concatSingleOtherId(cataloged_item.collection_object_id, 'Field Num'),
			concatTypeStatus(cataloged_item.collection_object_id),
			concatAttributeValue(cataloged_item.collection_object_id, 'sex'),
			concatAttributeValue(cataloged_item.collection_object_id, 'age class'),
			concatattribute(cataloged_item.collection_object_id),
			concatEncumbrances(cataloged_item.collection_object_id),
			concatParts(cataloged_item.collection_object_id)
		from
			cataloged_item,
			collection,
			coll_object,
			coll_object_remark,
			accn,
			ctmedia_license
		where
			cataloged_item.collection_id=collection.collection_id and
			cataloged_item.collection_object_id=coll_object.collection_object_id and
			cataloged_item.collection_object_id=coll_object_remark.collection_object_id (+) and
			cataloged_item.accn_id=accn.transaction_id (+) and
			collection.USE_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+) and
			cataloged_item.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID
	) where COLLECTION_OBJECT_ID=collobjid;

	update 
		flat 
	set 
		IMAGEURL=(select distinct(decode(
			media_relations.media_id,
			NULL,NULL,
			'http://arctos.database.museum/MediaSearch.cfm?collection_object_id=' || collobjid))
		from media_relations where media_relationship like '% cataloged_item' and
		related_primary_key=collobjid)
	 where COLLECTION_OBJECT_ID=collobjid;

	-- stuff that relies on map_specimen_event
	update flat set (
		COLLECTING_EVENT_ID,
		VERBATIM_DATE,
		GEOG_AUTH_REC_ID,
		HIGHER_GEOG,
		CONTINENT_OCEAN,
		COUNTRY,
		STATE_PROV,
		COUNTY,
		FEATURE,
		ISLAND,
		ISLAND_GROUP,
		QUAD,
		SEA,
		LOCALITY_ID,
		HABITAT,
		SPEC_LOCALITY,
		MINIMUM_ELEVATION,
		MAXIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		MIN_ELEV_IN_M,
		MAX_ELEV_IN_M,
		DEC_LAT,
		DEC_LONG,
		DATUM,
		ORIG_LAT_LONG_UNITS,
		COORDINATEUNCERTAINTYINMETERS,
		VERBATIM_LOCALITY,
		EVENT_ASSIGNED_BY_AGENT,
		EVENT_ASSIGNED_DATE,
		SPECIMEN_EVENT_REMARK,
		SPECIMEN_EVENT_TYPE,
		COLL_EVENT_REMARKS,
		VERBATIM_COORDINATES,
		COLLECTING_EVENT_NAME,
		GEOREFERENCE_SOURCE,
		GEOREFERENCE_PROTOCOL,
		LOCALITY_NAME,
		LOCALITY_REMARKS,
		DEPTH_UNITS,
		MIN_DEPTH,
		MAX_DEPTH,
		MIN_DEPTH_IN_M,
		MAX_DEPTH_IN_M,
		COLLECTING_METHOD,
		COLLECTING_SOURCE,
		YEAR,
		MONTH,
		DAY,
		VERIFICATIONSTATUS,
		BEGAN_DATE,
		ENDED_DATE,
		VERBATIMELEVATION
	) = (SELECT
			collecting_event.COLLECTING_EVENT_ID,
			collecting_event.VERBATIM_DATE,
			geog_auth_rec.GEOG_AUTH_REC_ID,
			geog_auth_rec.HIGHER_GEOG,
			geog_auth_rec.CONTINENT_OCEAN,
			geog_auth_rec.COUNTRY,
			geog_auth_rec.STATE_PROV,
			geog_auth_rec.COUNTY,
			geog_auth_rec.FEATURE,
			geog_auth_rec.ISLAND,
			geog_auth_rec.ISLAND_GROUP,
			geog_auth_rec.QUAD,
			geog_auth_rec.SEA,
			locality.LOCALITY_ID,
			SPECIMEN_EVENT.HABITAT,
			locality.SPEC_LOCALITY,
			locality.MINIMUM_ELEVATION,
			locality.MAXIMUM_ELEVATION,
			locality.ORIG_ELEV_UNITS,
			to_meters(locality.minimum_elevation, locality.orig_elev_units),
			to_meters(locality.maximum_elevation, locality.orig_elev_units),
			locality.DEC_LAT,
			locality.DEC_LONG,
			locality.DATUM,
			collecting_event.ORIG_LAT_LONG_UNITS,
			to_meters(locality.max_error_distance, locality.max_error_units),
			collecting_event.VERBATIM_LOCALITY,
			getPreferredAgentName(specimen_event.assigned_by_agent_id),
			specimen_event.ASSIGNED_DATE,
			specimen_event.SPECIMEN_EVENT_REMARK,
			specimen_event.SPECIMEN_EVENT_TYPE,
			collecting_event.COLL_EVENT_REMARKS,
			collecting_event.VERBATIM_COORDINATES,
			collecting_event.COLLECTING_EVENT_NAME,
			locality.GEOREFERENCE_SOURCE,
			locality.GEOREFERENCE_PROTOCOL,
			locality.LOCALITY_NAME,
			locality.LOCALITY_REMARKS,
			locality.DEPTH_UNITS,
			locality.MIN_DEPTH,
			locality.MAX_DEPTH,
			to_meters(locality.min_depth,locality.depth_units),
			to_meters(locality.max_depth,locality.depth_units),
			specimen_event.COLLECTING_METHOD,
			specimen_event.COLLECTING_SOURCE,
			substr(collecting_event.began_date,1,4),
			substr(collecting_event.began_date,6,2),
			substr(collecting_event.began_date,9,2),
			specimen_event.VERIFICATIONSTATUS,
			collecting_event.BEGAN_DATE,
			collecting_event.ENDED_DATE,
			decode(locality.orig_elev_units,
				NULL, NULL,
				locality.minimum_elevation || '-' || 
					locality.maximum_elevation || ' ' ||
					locality.orig_elev_units)
		from
			map_specimen_event,
			SPECIMEN_EVENT,
			collecting_event,
			locality,
			geog_auth_rec
		where
			map_specimen_event.SPECIMEN_EVENT_ID=SPECIMEN_EVENT.SPECIMEN_EVENT_ID and
			SPECIMEN_EVENT.collecting_event_id=collecting_event.collecting_event_id and
			collecting_event.locality_id=locality.locality_id and
			locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
			map_specimen_event.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID
	) where COLLECTION_OBJECT_ID=collobjid;
	--- identification/taxonomy

	FOR r IN ( select 
      upper(term_type) term_type,
      term 
    from 
      collection,
      cataloged_item,
      identification,
      identification_taxonomy,
      taxon_name,
      taxon_term
    where 
      collection.collection_id=cataloged_item.collection_id and
      cataloged_item.collection_object_id=identification.collection_object_id and 
      identification.identification_id = identification_taxonomy.identification_id AND
      identification.accepted_id_fg=1 AND
      identification_taxonomy.taxon_name_id = taxon_name.taxon_name_id AND
      collection.preferred_taxonomy_source=taxon_term.source and
      taxon_name.taxon_name_id=taxon_term.taxon_name_id AND 
      cataloged_item.collection_object_id = collobjid) LOOP
		case r.term_type
    		when 'KINGDOM' then v_kingdom := r.term;
    		when 'PHYLUM' then v_phylum := r.term;
    		when 'CLASS' then v_phylclass := r.term;
    		when 'ORDER' then v_phylorder := r.term;
    		when 'FAMILY' then v_family := r.term;
    		when 'SUBFAMILY' then v_subfamily := r.term;
    		when 'TRIBE' then v_tribe := r.term;
    		when 'SUBTRIBE' then v_subtribe := r.term;
    		when 'GENUS' then v_genus := r.term;
    		when 'SPECIES' then v_species := r.term;
    		when 'SUBSPECIES' then v_subspecies := r.term;
    		when 'AUTHOR_TEXT' then v_author_text := r.term;
    		when 'NOMENCLATURAL_CODE' then v_nomenclatural_code := r.term;
    		when 'INFRASPECIFIC_RANK' then v_infraspecific_rank := r.term;
    		when 'DISPLAY_NAME' then v_display_name := r.term;
    		when 'INFRASPECIFIC_AUTHOR' then v_infraspecific_author := r.term;
  			else
     			null;
  		END case;
  		
	
	END LOOP;
	v_full_taxon_name := v_kingdom || ' ' ||  v_phylum || ' ' ||  v_phylclass  || ' ' ||  v_phylorder  || ' ' ||    v_family  || ' ' ||  v_subfamily  || ' ' || v_tribe  || ' ' || v_subtribe;
	if v_display_name is not null then
		v_full_taxon_name := v_full_taxon_name || ' ' || v_display_name;
	else
		-- the name doesn't have a display name, so let's half-bake this here instead
		v_full_taxon_name := v_full_taxon_name  || ' ' ||   v_genus  || ' ' ||   v_species  || ' ' ||  v_author_text || ' ' ||  v_infraspecific_rank || ' ' || v_subspecies;
	end if;
	-- double spaces
    v_full_taxon_name := trim(regexp_replace(v_full_taxon_name, '( ){2,}','\1' ));
    -- and HTML from display_name
	v_full_taxon_name:= regexp_replace(v_full_taxon_name,'<.*?>') ;
   
    update flat set (
		IDENTIFICATION_ID,
		SCIENTIFIC_NAME,
		MADE_DATE,
		NATURE_OF_ID,
		IDENTIFIEDBY,
		TAXA_FORMULA,
		IDENTIFICATION_REMARKS,
		PHYLCLASS,
		GENUS,
		FULL_TAXON_NAME,
		KINGDOM,
		PHYLUM,
		PHYLORDER,
		FAMILY,
		SUBFAMILY,
		TRIBE,
		SUBTRIBE,
		SPECIES,
		SUBSPECIES,
		AUTHOR_TEXT,
		NOMENCLATURAL_CODE,
		INFRASPECIFIC_RANK,
		FORMATTED_SCIENTIFIC_NAME,
		ID_SENSU,
		PREVIOUSIDENTIFICATIONS,
		STALE_FLAG
	) = (SELECT
			identification.IDENTIFICATION_ID,
			identification.SCIENTIFIC_NAME,
			identification.MADE_DATE,
			identification.NATURE_OF_ID,
			concatidentifiers(identification.collection_object_id),
			identification.TAXA_FORMULA,
			identification.IDENTIFICATION_REMARKS,
			v_phylclass,
			v_genus,
			v_full_taxon_name,
			v_kingdom,
			v_phylum,
			v_phylorder,
			v_family,
			v_subfamily,
			v_tribe,
			v_subtribe,
			v_species,
			v_subspecies,
			v_author_text,
			v_nomenclatural_code,
			v_infraspecific_rank,
			nvl(v_display_name,identification.SCIENTIFIC_NAME),
			decode(identification.publication_id,NULL,NULL,'<a href="http://arctos.database.museum/publication/' || publication.publication_id || '">' || publication.short_citation || '</a>'),
			concatAllIdentification(identification.collection_object_id),
			0
		from
			identification,
			publication
		where
			identification.accepted_id_fg=1 and 
			identification.publication_id=publication.publication_id (+) and
			identification.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID
	) where COLLECTION_OBJECT_ID=collobjid;

	-- stuff we are explicitly ignoring but that is still in the table for mysterious reasons
		-- IDENTIFICATIONMODIFIER
		-- DATE_BEGAN_DATE
		-- DATE_ENDED_DATE
		-- INDIVIDUALCOUNT
			-- this needs to come from parts, or something
			-- need guidance from AC on how to handle it
		-- COLL_OBJ_DISPOSITION
		-- DATE_MADE_DATE
		-- BASISOFRECORD
			-- sufficiently replaced by CATALOGED_ITEM_TYPE?
		-- LASTUSER
			-- added to flat, not maintained there
		-- LASTDATE
			-- ditto
		-- DAYOFYEAR
			-- might be able to math this one up
		-- FIELDNOTESURL
exception when others then
	dbms_output.put_line(sqlerrm);
	update flat set STALE_FLAG=-1 where  COLLECTION_OBJECT_ID=collobjid;
end;
/
sho err;





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
		locality_name,
		previousidentifications,
		use_license_url,
		IDENTIFICATION_REMARKS,
		LOCALITY_REMARKS,
		formatted_scientific_name
    FROM
        flat
    WHERE
    -- exclude masked records
        (encumbrances is null OR encumbrances NOT LIKE '%mask record%');	
        
        
        
 uam@arctos> SELECT * FROM CF_SPEC_RES_COLS WHERE UPPER(COLUMN_NAME)='FAMILY';

COLUMN_NAME
------------------------------------------------------------------------------------------------------------------
SQL_ELEMENT
------------------------------------------------------------------------------------------------------------------------
CATEGORY
------------------------------------------------------------------------------------------------------------------------
CF_SPEC_RES_COLS_ID DISP_ORDER
------------------- ----------
family
flatTableName.family
specimen
	    1579175	    14


1 row selected.



UPDATE CF_SPEC_RES_COLS set DISP_ORDER=DISP_ORDER+3 where DISP_ORDER > 14;

insert into CF_SPEC_RES_COLS (COLUMN_NAME,SQL_ELEMENT,CATEGORY,CF_SPEC_RES_COLS_ID,DISP_ORDER) values 
	('subfamily','flatTableName.subfamily','specimen',someRandomSequence.nextval,15);
	
insert into CF_SPEC_RES_COLS (COLUMN_NAME,SQL_ELEMENT,CATEGORY,CF_SPEC_RES_COLS_ID,DISP_ORDER) values 
	('tribe','flatTableName.tribe','specimen',someRandomSequence.nextval,16);
insert into CF_SPEC_RES_COLS (COLUMN_NAME,SQL_ELEMENT,CATEGORY,CF_SPEC_RES_COLS_ID,DISP_ORDER) values 
	('subtribe','flatTableName.subtribe','specimen',someRandomSequence.nextval,17);
        
-- already done; here for completeness
create table taxon_term_updated (
	TAXON_NAME_ID number,
	TERM_TYPE varchar2(255),
	SOURCE varchar2(255)
);


-- already done; here for completeness
create or replace trigger trg_pushtaxontermtoflat after insert or update or delete on taxon_term
	FOR EACH ROW 
	begin
		// moved to DDL/triggers/uam_triggers/taxon_term.sql
	end;
/

--- STILL RUNING MANUALLY
BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'check_update_flat_taxonomy',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'update_flat_taxonomy',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=hourly; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'check taxonomy for changes and push them to flat');
END;
/



exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'check_update_flat_taxonomy', FORCE => TRUE);











------------------------ TEMP TAXONOMY RANDOMNESS --------------------
create table att as select
	taxon_name.taxon_name_id,
	KINDGOM.term KINDGOM,
	PHYLUM.term PHYLUM,
	PHYLCLASS.term PHYLCLASS,
	PHYLORDER.term PHYLORDER,
	FAMILY.term FAMILY,
	GENUS.term GENUS,
	SPECIES.term SPECIES,
	SUBSPECIES.term SUBSPECIES,
	AUTHOR_TEXT.term AUTHOR_TEXT,
	NOMENCLATURAL_CODE.term NOMENCLATURAL_CODE,
	INFRASPECIFIC_RANK.term INFRASPECIFIC_RANK,
	DISPLAY_NAME.term DISPLAY_NAME,
	INFRASPECIFIC_AUTHOR.term INFRASPECIFIC_AUTHOR
from
	taxon_name,
	identification_taxonomy,
	(select term,taxon_name_id from taxon_term where source='Arctos' and upper(term_type)='KINDGOM') KINDGOM,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='PHYLUM') PHYLUM,
	(select term ,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='PHYLCLASS') PHYLCLASS,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='PHYLORDER') PHYLORDER,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='FAMILY') FAMILY,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='GENUS') GENUS,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='SPECIES') SPECIES,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='SUBSPECIES') SUBSPECIES,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='AUTHOR_TEXT') AUTHOR_TEXT,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='NOMENCLATURAL_CODE') NOMENCLATURAL_CODE,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='INFRASPECIFIC_RANK') INFRASPECIFIC_RANK,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='DISPLAY_NAME') DISPLAY_NAME,
	(select term,taxon_name_id from taxon_term where  source='Arctos' and upper(term_type)='INFRASPECIFIC_AUTHOR') INFRASPECIFIC_AUTHOR
where
	taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
	taxon_name.taxon_name_id=KINDGOM.taxon_name_id (+) and
	taxon_name.taxon_name_id=PHYLUM.taxon_name_id (+) and
	taxon_name.taxon_name_id=PHYLCLASS.taxon_name_id (+) and
	taxon_name.taxon_name_id=PHYLORDER.taxon_name_id (+) and
	taxon_name.taxon_name_id=FAMILY.taxon_name_id (+) and
	taxon_name.taxon_name_id=GENUS.taxon_name_id (+) and
	taxon_name.taxon_name_id=SPECIES.taxon_name_id (+) and
	taxon_name.taxon_name_id=SUBSPECIES.taxon_name_id (+) and
	taxon_name.taxon_name_id=AUTHOR_TEXT.taxon_name_id (+) and
	taxon_name.taxon_name_id=NOMENCLATURAL_CODE.taxon_name_id (+) and
	taxon_name.taxon_name_id=INFRASPECIFIC_RANK.taxon_name_id (+) and
	taxon_name.taxon_name_id=DISPLAY_NAME.taxon_name_id (+) and
	taxon_name.taxon_name_id=INFRASPECIFIC_AUTHOR.taxon_name_id (+)
group by
	taxon_name.taxon_name_id,
	KINDGOM.term ,
	PHYLUM.term ,
	PHYLCLASS.term ,
	PHYLORDER.term ,
	FAMILY.term ,
	GENUS.term ,
	SPECIES.term ,
	SUBSPECIES.term ,
	AUTHOR_TEXT.term ,
	NOMENCLATURAL_CODE.term ,
	INFRASPECIFIC_RANK.term ,
	DISPLAY_NAME.term ,
	INFRASPECIFIC_AUTHOR.term 
;



begin
	for r in (select taxon_name_id,KINDGOM,PHYLUM,PHYLCLASS,PHYLORDER,FAMILY,GENUS,SPECIES,SUBSPECIES,AUTHOR_TEXT,NOMENCLATURAL_CODE,INFRASPECIFIC_RANK,DISPLAY_NAME from att) loop
		update flat set 
			kingdom=r.KINDGOM, 
			PHYLUM=r.PHYLUM, 
			PHYLCLASS=r.PHYLCLASS, 
			PHYLORDER=r.PHYLORDER, 
			FAMILY=r.FAMILY, 
			GENUS=r.GENUS, 
			SPECIES=r.SPECIES, 
			SUBSPECIES=r.SUBSPECIES, 
			AUTHOR_TEXT=r.AUTHOR_TEXT, 
			NOMENCLATURAL_CODE=r.NOMENCLATURAL_CODE, 
			INFRASPECIFIC_RANK=r.INFRASPECIFIC_RANK, 
			FORMATTED_SCIENTIFIC_NAME=r.DISPLAY_NAME
		where
			collection_object_id in (
				select 
					collection_object_id 
				from 
					identification,
					identification_taxonomy 
				where
					identification.identification_id=identification_taxonomy.identification_id and
					ACCEPTED_ID_FG=1 and
					TAXA_FORMULA not like '%B%' and
					identification_taxonomy.taxon_name_id=r.taxon_name_id
			)
		;
	end loop;
end;
/

-- dammit - missed full_taxon_name!

select KINDGOM || ', ' ||  PHYLUM || ', ' ||  PHYLCLASS || ', ' ||  PHYLORDER=r.PHYLORDER, 
			FAMILY=r.FAMILY, 
			GENUS=r.GENUS, 
			SPECIES=r.SPECIES, 
			SUBSPECIES=r.SUBSPECIES, 
			AUTHOR_TEXT=r.AUTHOR_TEXT, 
			NOMENCLATURAL_CODE=r.NOMENCLATURAL_CODE, 
			INFRASPECIFIC_RANK=r.INFRASPECIFIC_RANK, 
			FORMATTED_SCIENTIFIC_NAME=r.DISPLAY_NAME
full_taxon_name := 

update flat set full_taxon_name= regexp_replace(regexp_replace(regexp_replace(
kingdom || ', ' ||  phylum || ', ' ||  phylclass  || ', ' ||  phylorder  || ', ' ||    family  || ', ' ||   genus  || ', ' ||   species  || ', ' ||  author_text || ', ' ||  infraspecific_rank || ', ' || subspecies 
, '(, ){2,}', ', '),'(^, )+',''),'(, $)+','');

  from flat where guid='UAM:Ento:237886';


select family from tt where taxon_name_id=2;



drop table att;

create table att as select
	taxon_name.taxon_name_id
from
	taxon_name,
	identification_taxonomy,
	(select term,taxon_name_id from taxon_term where source='Arctos' and upper(term_type)='KINDGOM') KINDGOM
where
	taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
	taxon_name.taxon_name_id=KINDGOM.taxon_name_id (+)
;




	'KINDGOM',
			'PHYLUM',
			'PHYLCLASS',
			'PHYLORDER',
			'FAMILY',
			'GENUS',
			'SPECIES',
			'SUBSPECIES',
			'AUTHOR_TEXT',
			'NOMENCLATURAL_CODE',
			'INFRASPECIFIC_RANK',
			'DISPLAY_NAME',
			'INFRASPECIFIC_AUTHOR'

begin
	for r in (select taxon_name_id from identification_taxonomy) 













--- build a smaller, easier to work with table
create table arctosterms as select * from taxon_term where source='Arctos';

select count(*) from arctosterms;

create index ix_temp_att_tt on arctosterms (term_type) tablespace uam_idx_1;
-- pare it down some more
-- all we need is genus, species, and "subspecies" variations

delete from arctosterms where term_type not in (
	'genus',
	'species',
	'forma',
	'infraspecies',
	'nothosubsp.',
	'race',
	'subsp.',
	'subspecies',
	'var.',
	'agamosp.',
	'agamovar.',
	'convar.',
	'f.juv.',
	'l. var.',
	'lus.',
	'modif.',
	'monstr.',
	'mut.',
	'nm.',
	'nothof.',
	'nothosubsp.',
	'nothovar.',
	'prol.',
	'proles',
	'psp.',
	'subf.',
	'subhybr.',
	'sublus.',
	'subsp.',
	'subspecies',
	'subsubforma',
	'subsubvar.',
	'subvar.',
	'var.',
	'subfamily',
	'tribe',
	'subtribe'
);





create table newspssp (
	taxon_name_id number,
	species varchar2(255),
	sub varchar2(255),
	subrank varchar2(255)
);



declare
	g varchar2(255);
	sp varchar2(255);
	sspr varchar2(255);
	ssp varchar2(255);
	species varchar2(255);
	subspecies varchar2(255);
begin
	for r in (select taxon_name_id from arctosterms where taxon_name_id not in (select taxon_name_id from newspssp) group by taxon_name_id) loop
		g:='';
		sp:='';
		ssp:='';
		sspr:='';
		species:='';
		subspecies:='';

		for thisrec in (select term,term_type,taxon_name_id from arctosterms where taxon_name_id=r.taxon_name_id group by term,term_type,taxon_name_id) loop
			if thisrec.term_type = 'genus' then
				g:=thisrec.term;
			elsif thisrec.term_type = 'species' then
				sp:=thisrec.term;
			else
				ssp:=thisrec.term;
				sspr:=thisrec.term_type;
			end if; 			
		end loop;
		-- only care if we have genus and species
		if g is not null and sp is not null then
			species:=g || ' ' || sp;
			if ssp is not null and sspr is not null then
				if sspr = 'subspecies' then
					subspecies := species || ' ' || ssp;
				else
					subspecies := species || ' ' || sspr || ' ' || ssp;
				end if;
			end if;
			insert into newspssp (taxon_name_id,species,sub,subrank) values (r.taxon_name_id,species,subspecies,sspr);
		end if;
	end loop;
end;
/

select count(*) from newspssp;

commit;





lock table taxon_term in exclusive mode nowait;

alter trigger trg_pushtaxontermtoflat disable;


update taxon_term set term_type='class' where source='Arctos' and term_type='phylclass';

update taxon_term set term_type='order' where source='Arctos' and term_type='phylorder';

	alter trigger trg_pushtaxontermtoflat enable;

commit;







select taxon_name_id,species,sub,subrank from newspssp having count(*) > 1 group by taxon_name_id,species,sub,subrank;

create table taxon_term_bak as select * from taxon_term;

create index ix_yunothere_tt_tid on taxon_term (taxon_name_id) tablespace uam_idx_1;

create index ix_yunothere_tt_termtype on taxon_term (term_type) tablespace uam_idx_1;



lock table taxon_term in exclusive mode nowait;

	alter trigger trg_pushtaxontermtoflat disable;


select count(*) from newspssp where taxon_name_id between 3500000 and 4000000 ;

begin
	for r in (select * from newspssp where taxon_name_id between 3500000 and 4000000 ) loop
		update 
			taxon_term 
		set 
			term=r.species 
		where 
			taxon_name_id=r.taxon_name_id and 
			source='Arctos' and
			term_type='species'
		;
		if r.sub is not null then
			update 
				taxon_term 
			set 
				term=r.sub 
			where 
				taxon_name_id=r.taxon_name_id and 
				source='Arctos' and
				term_type=r.subrank
			;
		end if;

	end loop;
end;
/

	alter trigger trg_pushtaxontermtoflat enable;


select subrank,count(*) from newspssp group by subrank;

select count(*) from newspssp;

select state_prov from geog_auth_rec where county=state_prov group by state_prov order by state_prov;


select * from newspssp where subrank='subsp';


select taxon_name_id,classification_id from taxon_term where source='Arctos' having count(*) > 1 group by taxon_name_id,classification_id 

drop index ix_temp_tt_tid;
drop table tt;

create table tt as select taxon_name_id, term genus from taxon_term where source='Arctos' and term_type='genus' group by taxon_name_id, term;

Elapsed: 00:00:02.15

alter table tt add species varchar2(255);

create index ix_temp_att_tid on arctosterms (taxon_name_id) tablespace uam_idx_1;
create index ix_temp_tt_tid on tt (taxon_name_id) tablespace uam_idx_1;
	create index ix_temp_at_tt on arctosterms (term_type) tablespace uam_idx_1;



-- may have some duplication to deal with - this may or may not be necessary @prod
-- these need dealt with one by one
-- ORA-01427: single-row subquery returns more than one row

select taxon_name_id,term from arctosterms where term_type='species' having count(*) > 1 group by  taxon_name_id,term ;
select taxon_term_id from arctosterms where TAXON_NAME_ID=72408 and term_type='species';
delete from arctosterms where taxon_term_id=5688394;
	select taxon_term_id from arctosterms where TAXON_NAME_ID=1100896 and term_type='species';
delete from arctosterms where taxon_term_id=5688646;
	select taxon_term_id from arctosterms where TAXON_NAME_ID=1100894 and term_type='species';
delete from arctosterms where taxon_term_id=5688562;
delete from arctosterms where taxon_term_id=5688598;

	select taxon_term_id from arctosterms where TAXON_NAME_ID=72058 and term_type='species';
  
  delete from arctosterms where taxon_term_id=5688463;

---- end species dup cleanup


update tt set species=(select term from arctosterms where term_type='species' and arctosterms.taxon_name_id=tt.taxon_name_id group by term ) where taxon_name_id=tt.taxon_name_id;

forma
genus
infraspecies
infraspecific_author
kingdom
name string
nomenclatural_code
nothosubsp.
order
phylclass
phylorder
phylum
race
sdafs
source_authority
species
subclass
subfamily
subgenus
suborder
subsp.
subspecies
superfamily
taxon_remarks
test3
tribe
unranked
valid_catalog_term_fg
var.



IX_FLAT_U_SUBSPECIES
SYS_NC00145$

IX_FLAT_U_GENUS
SYS_NC00143$

IX_FLAT_U_SPECIES
SYS_NC00144$


drop index IX_FLAT_U_SUBSPECIES;
drop index IX_FLAT_U_SPECIES;



update flat set 
		(species,
		subspecies)=(select newspssp.SPECIES,newspssp.SUB from
newspssp,identification, identification_taxonomy
where 
identification.identification_id=identification_taxonomy.identification_id and
identification_taxonomy.taxon_name_id=newspssp.taxon_name_id and
identification.collection_object_id=flat.collection_object_id and
TAXA_FORMULA not like '%B%' and 
ACCEPTED_ID_FG=1
)
;


create index IX_FLAT_U_SUBSPECIES on flat (upper(subspecies)) tablespace uam_idx_1;

create index IX_FLAT_U_SPECIES on flat (upper(species)) tablespace uam_idx_1;
-- flat update

create table gotit (tid number);


create table temp_ft as select taxon_name_id
		from 
			identification, 
			identification_taxonomy
		where 
			identification.identification_id=identification_taxonomy.identification_id and 
			TAXA_FORMULA not like '%B%' and 
			ACCEPTED_ID_FG=1 
			group by taxon_name_id;

create table temp_ft_ssp as select * from newspssp where taxon_name_id in (select taxon_name_id from temp_ft);


select count(*) from temp_ft_ssp where taxon_name_id not in (select tid from gotit);

begin
	for r in (
		select 
			*
		from 
			temp_ft_ssp
		where 
			taxon_name_id not in (select tid from gotit) and rownum < 5000) loop
		insert into gotit(tid) values (r.taxon_name_id);
		update flat set 
			species=r.species,
			subspecies=r.sub
		where
			collection_object_id in (select collection_object_id from identification, 
			identification_taxonomy
			where 
			identification.identification_id=identification_taxonomy.identification_id and
			identification_taxonomy.taxon_name_id=r.taxon_name_id
		);
	end loop;
end;
/


begin
	for r in (
		select 
			*
		from 
			temp_ft
		where 
			taxon_name_id not in (select tid from gotit) and rownum < 5000) loop
		insert into gotit(tid) values (r.taxon_name_id);
		update flat set 
			FULL_TAXON_NAME=r.ftn
		where
			collection_object_id in (select collection_object_id from identification, 
			identification_taxonomy
			where 
			identification.identification_id=identification_taxonomy.identification_id and
			identification_taxonomy.taxon_name_id=r.taxon_name_id
		);
	end loop;
end;
/









c 
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_NAME_ID								    NUMBER
 SPECIES								    VARCHAR2(255)
 SUB									    VARCHAR2(255)
 SUBRANK			




IDENTIFICATION_ID						   NOT NULL NUMBER
 COLLECTION_OBJECT_ID						   NOT NULL NUMBER
 DATE_MADE_DATE 							    DATE
 NATURE_OF_ID							   NOT NULL VARCHAR2(30)
 ACCEPTED_ID_FG 						   NOT NULL NUMBER
 IDENTIFICATION_REMARKS 						    VARCHAR2(4000)
 TAXA_FORMULA							   NOT NULL VARCHAR2(25)
 SCIENTIFIC_NAME						   NOT NULL VARCHAR2(255)
 PUBLICATION_ID 							    NUMBER
 MADE_DATE								    VARCHAR2(22)

uam@ARCTOSNEW> desc newspssp
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_NAME_ID								    NUMBER
 SPECIES								    VARCHAR2(255)
 SUB									    VARCHAR2(255)
 SUBRANK								    VARCHAR2(255)



drop index ix_temp_att_tt;

drop index ix_temp_att_tid;
drop index ix_temp_att_tid;



create index  on arctosterms (taxon_name_id) tablespace uam_idx_1;
create index ix_temp_tt_tid on tt (taxon_name_id) tablespace uam_idx_1;
	create index ix_temp_at_tt on arctosterms (term_type) tablespace uam_idx_1;
------------------------ END TEMP TAXONOMY RANDOMNESS --------------------

	
	