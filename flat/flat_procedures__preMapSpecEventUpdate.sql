/* 
	last edit explanation:
	
	Updating anything that triggers to FLAT puts the Oracle system user in flat.lastuser.
	
	"Anything" includes coll_object, so we can't just update in the FLAT procedures or we get the mutating trigger.
	
	We want a lastuser formatted as preferred agent name, but need "lastuser" for the triggers/to avoid the mutation thing
	
	Solution: New temp table, rebuild all the flat triggers.
	
	Keep a history while we're here - why not?
	
	create table edit_history (
		collection_object_id number,
		lastuser varchar2(255),
		lastdate date,
		action varchar2(38),
		pushed_to_flat number(1)
	);
	
	
	-- 20130412 - add IPT stuff
	alter table flat add previousIdentifications varchar2(4000);
	alter table flat add use_license_url varchar2(4000);
	alter table flat add IDENTIFICATION_REMARKS  varchar2(4000);
	alter table flat add LOCALITY_REMARKS  varchar2(4000);
	
	
	LOCALITY_REMARKS
	alter table flat add last_edited_agent varchar2(255);
	
	update flat set last_edited_agent = (select preferred_agent_name.agent_name from preferred_agent_name,agent_name where 
	preferred_agent_name.agent_id=agent_name.agent_id and
	upper(agent_name.agent_name)=flat.lastuser);
	
	
	CREATE OR REPLACE PROCEDURE update_lastedited IS 
    aid NUMBER;
BEGIN
	FOR r IN (
		SELECT 
		    collection_object_id,
		    lastuser,
		    lastdate 
		FROM 
		    flat 
		WHERE 
		    stale_flag = 1 AND 
		    ROWNUM < 5000
	) LOOP
			BEGIN
		--dbms_output.put_line(r.collection_object_id);
		-- update flat_media set stale_fg=1 where collection_object_id = r.collection_object_id;
		update_flat(r.collection_object_id);
		
		EXCEPTION
		    WHEN OTHERS THEN
		        NULL;
		END;
		UPDATE flat 
		SET stale_flag = 0 
		WHERE collection_object_id = r.collection_object_id;
	END LOOP;
END;
/
sho err;


*/

CREATE OR REPLACE PROCEDURE is_flat_stale IS 
    aid NUMBER;
BEGIN
	FOR r IN (
		SELECT 
		    collection_object_id,
		    lastuser,
		    lastdate 
		FROM 
		    flat 
		WHERE 
		    stale_flag = 1 AND 
		    ROWNUM < 500
	) LOOP
			BEGIN
		dbms_output.put_line(r.collection_object_id);
		-- update flat_media set stale_fg=1 where collection_object_id = r.collection_object_id;
		update_flat(r.collection_object_id);
		
		--EXCEPTION
		----    WHEN OTHERS THEN
		--        NULL;
		END;
		UPDATE flat 
		SET stale_flag = 0 
		WHERE collection_object_id = r.collection_object_id;
	END LOOP;
END;
/
sho err;



CREATE UNIQUE INDEX flat_collection_object_id ON flat(collection_object_id) TABLESPACE uam_idx_1;






  /*
		   
	
		    IF r.lastuser='UAM' THEN
		        aid:=0;
		    ELSE
		        SELECT RESULT_CACHE agent_id INTO aid FROM agent_name WHERE agent_name_type='login' AND upper(agent_name)=upper(r.lastuser);
		    END IF;
		   UPDATE coll_object SET     LAST_EDITED_PERSON_ID=aid,
		        LAST_EDIT_DATE=r.lastdate
		    WHERE
		        collection_object_id = r.collection_object_id;
		      */
--SELECT dbms_metadata.get_ddl('PROCEDURE','UPDATE_FLAT') from dual;



------------------------------------
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
		ispublished,
		SEX,
		AGE_CLASS,
		ATTRIBUTES,
		ENCUMBRANCES,
		PARTS,
		INDIVIDUALCOUNT
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
			decode(concatTypeStatus(cataloged_item.collection_object_id),NULL,0,1),
			concatAttributeValue(cataloged_item.collection_object_id, 'sex'),
			concatAttributeValue(cataloged_item.collection_object_id, 'age class'),
			concatattribute(cataloged_item.collection_object_id),
			concatEncumbrances(cataloged_item.collection_object_id),
			concatParts(cataloged_item.collection_object_id),
			getIndividualCount(cataloged_item.collection_object_id)
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
			getYearCollected(collecting_event.began_date,collecting_event.ended_date),
			getMonthCollected(collecting_event.began_date,collecting_event.ended_date),
			getDayCollected(collecting_event.began_date,collecting_event.ended_date),
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
      cataloged_item.collection_object_id = collobjid
     group by term,term_type) LOOP
      
      	--dbms_output.put_line(r.term_type);
      	
		case r.term_type
    		when 'KINGDOM' then v_kingdom := CASE when v_kingdom is null then r.term else v_kingdom || ', ' || r.term end;
    		when 'PHYLUM' then v_phylum := CASE when v_phylum is null then r.term else v_phylum || ', ' || r.term end;
    		when 'CLASS' then v_phylclass := CASE when v_phylclass is null then r.term else v_phylclass || ', ' || r.term end;
    		when 'ORDER' then v_phylorder := CASE when v_phylorder is null then r.term else v_phylorder || ', ' || r.term end;
    		when 'FAMILY' then v_family := CASE when v_family is null then r.term else v_family || ', ' || r.term end;
    		when 'SUBFAMILY' then v_subfamily := CASE when v_subfamily is null then r.term else v_subfamily || ', ' || r.term end;
    		when 'TRIBE' then v_tribe := CASE when v_tribe is null then r.term else v_tribe || ', ' || r.term end;
    		when 'SUBTRIBE' then v_subtribe := CASE when v_subtribe is null then r.term else v_subtribe || ', ' || r.term end;
    		when 'GENUS' then v_genus := CASE when v_genus is null then r.term else v_genus || ', ' || r.term end;
    		when 'SPECIES' then v_species := CASE when v_species is null then r.term else v_species || ', ' || r.term end;
    		when 'SUBSPECIES' then v_subspecies := CASE when v_subspecies is null then r.term else v_subspecies || ', ' || r.term end;
    		when 'AUTHOR_TEXT' then v_author_text := CASE when v_author_text is null then r.term else v_author_text || ', ' || r.term end;
    		when 'NOMENCLATURAL_CODE' then v_nomenclatural_code := CASE when v_nomenclatural_code is null then r.term else v_nomenclatural_code || ', ' || r.term end;
    		when 'INFRASPECIFIC_RANK' then v_infraspecific_rank := CASE when v_infraspecific_rank is null then r.term else v_infraspecific_rank || ', ' || r.term end;
    		when 'DISPLAY_NAME' then v_display_name := CASE when v_display_name is null then r.term else v_display_name || ', ' || r.term end;
    		when 'INFRASPECIFIC_AUTHOR' then v_infraspecific_author := CASE when v_infraspecific_author is null then r.term else v_infraspecific_author || ', ' || r.term end;
  			else
     			null;
  		END case;
  		
	
	END LOOP;
	v_full_taxon_name := v_kingdom || '; ' ||  v_phylum || '; ' ||  v_phylclass  || '; ' ||  v_phylorder  || '; ' ||    v_family  || '; ' ||  v_subfamily  || '; ' || v_tribe  || '; ' || v_subtribe;
	if v_display_name is not null then
		v_full_taxon_name := v_full_taxon_name || '; ' || v_display_name;
	else
		-- the name doesn't have a display name, so let's half-bake this here instead
		v_full_taxon_name := v_full_taxon_name  || '; ' ||   v_genus  || ' ' ||   v_species  || ' ' ||  v_author_text || ' ' ||  v_infraspecific_rank || ' ' || v_subspecies;
	end if;
	-- double spaces
    v_full_taxon_name := trim(regexp_replace(v_full_taxon_name, '(; ){2,}','\1' ));
    -- and HTML from display_name
	v_full_taxon_name:= regexp_replace(v_full_taxon_name,'<.*?>') ;
   	--dbms_output.put_line('v_genus: ' || v_genus);

	--dbms_output.put_line(v_full_taxon_name);
		
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
			decode(identification.TAXA_FORMULA,'A {string}',identification.SCIENTIFIC_NAME,nvl(v_display_name,identification.SCIENTIFIC_NAME)),
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



