-- PlanC-or-so: Occurrences are part-at-specimen,
-- some parts are mapped to specimen_event via table specimen_event_links
-- some parts are not mapped to events, use https://github.com/ArctosDB/DDL/blob/master/functions/getPrioritySpecimenEvent.sql for them
-- use  v_part_event_path (DDL inline) to select

create view v_part_event_path as select
	specimen_part.collection_object_id part_id,
	nvl(specimen_event_links.specimen_event_id,getPrioritySpecimenEvent(specimen_part.derived_from_cat_item)) specimen_event_id
from
	specimen_part,
	specimen_event_links
where
	specimen_part.collection_object_id=specimen_event_links.part_id (+)
;

create public synonym v_part_event_path for v_part_event_path;

grant select on v_part_event_path to public;

set define off;
select
	'institutionCode=' ||
 	substr(guid,1,instr(guid,':')-1) ||
 	'&collectionCode=' ||
	 substr(guid,instr(guid,':')+1,instr(guid,':',1,2)-instr(guid,':')-1)  ||
	 '&catalogNumber='||
	 cat_num ||
	 '&accesspoint=http://ipt.vertnet.org:8080/ipt/archive.do?r=msbmammalggbntest&guid=http://arctos.database.museum/guid/' || guid
 	from flat where rownum=1;
 	
institutionCode=MSB&
collectionCode=Mamm&catalogNumber=299265&accesspoint=http://ipt.vertnet.org:8080/ipt/archive.do?r=msbmammalggbntest&guid= http://arctos.database.museum/guid/MSB:Mamm:299265




create or replace view ggbn_tissue as select distinct
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?pid=' || specimen_part.collection_object_id occurrenceID,
 	-- not sure this is needed?? May be necessary to link permits?
 	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?pid=' || specimen_part.collection_object_id UnitID,
 	'institutionCode=' ||
 	substr(guid,1,instr(guid,':')-1) ||
 		'&collectionCode=' ||
		 substr(guid,instr(guid,':')+1,instr(guid,':',1,2)-instr(guid,':')-1)  ||
		 '&catalogNumber='||
		 cat_num ||
	 	'&accesspoint=http://ipt.vertnet.org:8080/ipt/archive.do?r=msbmammalggbntest&guid=http://arctos.database.museum/guid/' || guid
	 AS relatedResourceID,
	'tissue' materialSampleType,
	specimen_part.part_name preparationType,
	part_coll_object.COLL_OBJECT_ENTERED_DATE preparationDate,
	-- preparationMaterials is 
	--    "Materials and chemicals used in the preparation of the specimen, tissue, DNA or RNA sample"
	-- it should become available as we do more with part attributes
	' ' preparationMaterials,
	-- this isn't quite correct, but I have no better data at the moment
	-- will update with more Attributes as collections begin using them
	getPreferredAgentName(part_coll_object.ENTERED_PERSON_ID) preparationStaff,
	filtered_flat.collection_id collection_id,
	'en' language,
	use_license_url rights, -- not sure this is the right dwc concept
	CATALOGED_ITEM_TYPE type, -- what is this again?
	CATALOGED_ITEM_TYPE basisOfRecord, 
	filtered_flat.COLLECTION_CDE collectionCode,
	decode(collectors,
		null,'',
		'Collector(s): ' || collectors ||
		decode(preparators,
			null,'',
			'; Preparator(s): ' || preparators
		)
	) recordedBy,
	ENCUMBRANCES informationWithheld,
	INDIVIDUALCOUNT individualCount,
	INSTITUTION_ACRONYM institutionCode,
	LASTDATE modified,
	RELATEDCATALOGEDITEMS associatedOccurrences,
	'http://arctos.database.museum/guid/' || GUID references,
	REMARKS occurrenceRemarks,
	TYPESTATUS typeStatus,
	ASSOCIATED_SPECIES associatedTaxa,
	--------------------------- identifiers ---------------------------
	OTHERCATALOGNUMBERS otherCatalogNumbers,
	'http://arctos.database.museum/guid/' || GUID individualID,
	CATALOGNUMBERTEXT catalogNumber,
	GENBANKNUM associatedSequences,
	COLLECTORNUMBER recordNumber, -- I think this is a very incomplete mapping
	FIELD_NUM fieldNumber, -- also incomplete/incorrect
	--------------------------- attribute-like gunk ---------------------------
	SEX	 sex,
	AGE_CLASS lifeStage,
	ATTRIBUTES dynamicProperties,
	--------------------------- taxonomy and identification ---------------------------
	IDENTIFICATION_REMARKS identificationRemarks,
	FAMILY family,
	trim(replace(full_taxon_name,scientific_name)) higherClassification,
	GENUS genus,
	ID_SENSU identificationReferences,
	TAXA_FORMULA identificationQualifier,
	IDENTIFIEDBY identifiedBy,
	INFRASPECIFIC_RANK taxonRank,
	KINGDOM kingdom,
	MADE_DATE dateIdentified,
	NATURE_OF_ID IDVerificationStatus,
	NOMENCLATURAL_CODE nomenclaturalCode,
	PARTS preparations,
	PHYLCLASS pclass,
	PHYLORDER porder,
	PHYLUM phylum,
	SCIENTIFIC_NAME scientificName,
	trim(replace(species,genus)) specificEpithet,
	trim(replace(subspecies,species))  infraspecificEpithet,
	previousidentifications previousidentifications,
	--------------------------- media ---------------------------
	IMAGEURL associatedMedia,
	-- event stuff
	-- we have to apply encumbrances here because this is NOT from filtered_flat
	-- we are getting ALL specimen_event-->geog_auth_rec here
	-- we are NOT getting geology here. We should be.
	--------------------------- specimen_event -------------------------------
	specimen_event.SPECIMEN_EVENT_TYPE SpecimenEventType, -- I'm asking
	specimen_event.COLLECTING_METHOD samplingProtocol,
	specimen_event.COLLECTING_SOURCE establishmentMeans,
	getPreferredAgentName(specimen_event.ASSIGNED_BY_AGENT_id) locationAccordingTo,
	getPreferredAgentName(specimen_event.ASSIGNED_BY_AGENT_id) georeferencedBy,
	specimen_event.ASSIGNED_DATE georeferencedDate,
	specimen_event.HABITAT habitat,
	specimen_event.VERIFICATIONSTATUS georeferenceVerificationStatus,
	specimen_event.SPECIMEN_EVENT_REMARK eventRemarks,
	--------------------------- collecting_event -------------------------------
	locality.DATUM geodeticDatum,
	collecting_event.VERBATIM_DATE  verbatimEventDate,
	collecting_event.VERBATIM_LOCALITY verbatimLocality,
	collecting_event.ORIG_LAT_LONG_UNITS verbatimCoordinateSystem,
	-- check for encumbrances
	case when
		collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
		then collecting_event.BEGAN_DATE
	else
		collecting_event.BEGAN_DATE || '/' || collecting_event.ENDED_DATE
	END eventDate,
	-- no encumbrance check necessary at time
	case when collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE
		then substr(collecting_event.began_date,12)
	else
		collecting_event.BEGAN_DATE || '/' || collecting_event.ENDED_DATE
	end eventTime,
	case when collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
		then substr( collecting_event.BEGAN_DATE, 9, 2 )
	end day,
	case when collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
		then substr( collecting_event.BEGAN_DATE, 6, 2 )
	end month,
	CASE WHEN encumbrances LIKE '%mask year collected%'
		THEN '8888' -- deal with it....
	ELSE 
		case when collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
			then substr( filtered_flat.BEGAN_DATE, 1, 4 )
		end 
	END year,
	case when collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
		then case when isdate(collecting_event.BEGAN_DATE)=1
			then to_number(to_char(to_date(collecting_event.began_date,'YYYY-MM-DD'),'DDD'))
		end
	end endDayOfYear,
	CASE WHEN encumbrances LIKE '%mask coordinates%'
		THEN NULL
	ELSE 
		collecting_event.VERBATIM_COORDINATES
	END verbatimCoordinates,
	--------------------------- locality -------------------------------
	to_meters(locality.max_error_distance,locality.max_error_units) coordinateUncertaintyInMeters,
	CASE WHEN encumbrances LIKE '%mask coordinates%'
		THEN NULL
	ELSE locality.DEC_LAT
	END decimalLatitude,
	CASE WHEN encumbrances LIKE '%mask coordinates%'
		THEN NULL
	ELSE locality.DEC_LONG
	END decimalLongitude,
	locality.SPEC_LOCALITY locality,
	locality.GEOREFERENCE_PROTOCOL georeferenceProtocol,
	locality.GEOREFERENCE_SOURCE georeferenceSources,
	to_meters(locality.MIN_DEPTH,locality.DEPTH_UNITS) minimumDepthInMeters,
	to_meters(locality.MAX_DEPTH,locality.DEPTH_UNITS) maximumDepthInMeters,
	to_meters(locality.MINIMUM_ELEVATION,locality.ORIG_ELEV_UNITS) minimumElevationInMeters,
	to_meters(locality.MAXIMUM_ELEVATION,locality.ORIG_ELEV_UNITS) maximumElevationInMeters,
	locality.locality_remarks locationRemarks,
	--------------------------- geog_auth_rec -------------------------------
	geog_auth_rec.CONTINENT_OCEAN continent,
	geog_auth_rec.COUNTRY country,
	geog_auth_rec.COUNTY county,
	geog_auth_rec.ISLAND island,
	geog_auth_rec.ISLAND_GROUP islandGroup,
	geog_auth_rec.QUAD Quad,
	geog_auth_rec.SEA waterBody,
	geog_auth_rec.FEATURE Feature,	
	geog_auth_rec.STATE_PROV stateProvince,
	geog_auth_rec.HIGHER_GEOG higherGeography,	
	replace(replace(INSTITUTION_ACRONYM,'Obs'),'UAMb','UAM') institution,
	collection,
	EARLIESTEONORLOWESTEONOTHEM,
	EARLIESTPERIODORLOWESTSYSTEM,
	EARLIESTEPOCHORLOWESTSERIES,
	EARLIESTAGEORLOWESTSTAGE,
	EARLIESTERAORLOWESTERATHEM,
	FORMATION
from
	filtered_flat,
	coll_object part_coll_object,
	specimen_part,
	v_part_event_path,
	specimen_event,
	collecting_event,
	locality,
	geog_auth_rec,
	ctspecimen_part_name,
	ipt_geology
where
	--hard join here
	filtered_flat.collection_object_id=specimen_part.derived_from_cat_item and
	specimen_part.collection_object_id=v_part_event_path.part_id and
	v_part_event_path.specimen_event_id=specimen_event.specimen_event_id and
	specimen_event.collecting_event_id=collecting_event.collecting_event_id and
	collecting_event.locality_id=locality.locality_id and
	locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and	
	specimen_part.collection_object_id=part_coll_object.collection_object_id and
	specimen_part.part_name=ctspecimen_part_name.part_name and
	ctspecimen_part_name.is_tissue=1 and
	locality.locality_id=ipt_geology.locality_id (+)
;

create table ggbn_tissue_tbl as select * from ggbn_tissue where 1=2;

-- table needs refreshed periodically
CREATE OR REPLACE PROCEDURE proc_ref_ggbn_tbl IS
BEGIN
	delete from  ggbn_tissue_tbl;
	insert into ggbn_tissue_tbl ( select * from ggbn_tissue);
end;
/
sho err;

 exec proc_ref_ggbn_tbl;
 
 
 
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'j_ref_ggbn_tbl',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'proc_ref_ggbn_tbl',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 


select count(*) from ggbn_tissue_tbl;

drop view digir_query.ggbn_tissue;
drop table digir_query.ggbn_tissue_tbl;

grant select on ggbn_tissue_tbl to digir_query;

create or replace view digir_query.v_ggbn_tissue_tbl as select * from uam.ggbn_tissue_tbl;

select count(*) from digir_query.v_ggbn_tissue_tbl;


select count(*) from digir_query.ggbn_tissue_tbl;
select count(*) from ggbn_tissue;

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_REF_GGBN_TBL';


------------------------------------------------------------------------------------------------------------------------------
-- TEST: MSB:Mamm only
create or replace view digir_query.msb_mamm_ggbn_tissue as select distinct
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?pid=' || specimen_part.collection_object_id occurrenceID,
 	-- not sure this is needed?? May be necessary to link permits?
 	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?pid=' || specimen_part.collection_object_id UnitID,
	'tissue' materialSampleType,
	specimen_part.part_name preparationType,
	part_coll_object.COLL_OBJECT_ENTERED_DATE preparationDate,
	-- preparationMaterials is 
	--    "Materials and chemicals used in the preparation of the specimen, tissue, DNA or RNA sample"
	-- it should become available as we do more with part attributes
	' ' preparationMaterials,
	-- this isn't quite correct, but I have no better data at the moment
	-- will update with more Attributes as collections begin using them
	getPreferredAgentName(part_coll_object.ENTERED_PERSON_ID) preparationStaff,
	filtered_flat.collection_id collection_id,
	'en' language,
	use_license_url rights, -- not sure this is the right dwc concept
	CATALOGED_ITEM_TYPE type, -- what is this again?
	CATALOGED_ITEM_TYPE basisOfRecord, 
	filtered_flat.COLLECTION_CDE collectionCode,
	decode(collectors,
		null,'',
		'Collector(s): ' || collectors ||
		decode(preparators,
			null,'',
			'; Preparator(s): ' || preparators
		)
	) recordedBy,
	ENCUMBRANCES informationWithheld,
	INDIVIDUALCOUNT individualCount,
	INSTITUTION_ACRONYM institutionCode,
	LASTDATE modified,
	RELATEDCATALOGEDITEMS associatedOccurrences,
	'http://arctos.database.museum/guid/' || GUID references,
	REMARKS occurrenceRemarks,
	TYPESTATUS typeStatus,
	ASSOCIATED_SPECIES associatedTaxa,
	--------------------------- identifiers ---------------------------
	OTHERCATALOGNUMBERS otherCatalogNumbers,
	'http://arctos.database.museum/guid/' || GUID individualID,
	CATALOGNUMBERTEXT catalogNumber,
	GENBANKNUM associatedSequences,
	COLLECTORNUMBER recordNumber, -- I think this is a very incomplete mapping
	FIELD_NUM fieldNumber, -- also incomplete/incorrect
	--------------------------- attribute-like gunk ---------------------------
	SEX	 sex,
	AGE_CLASS lifeStage,
	ATTRIBUTES dynamicProperties,
	--------------------------- taxonomy and identification ---------------------------
	IDENTIFICATION_REMARKS identificationRemarks,
	FAMILY family,
	trim(replace(full_taxon_name,scientific_name)) higherClassification,
	GENUS genus,
	ID_SENSU identificationReferences,
	TAXA_FORMULA identificationQualifier,
	IDENTIFIEDBY identifiedBy,
	INFRASPECIFIC_RANK taxonRank,
	KINGDOM kingdom,
	MADE_DATE dateIdentified,
	NATURE_OF_ID IDVerificationStatus,
	NOMENCLATURAL_CODE nomenclaturalCode,
	PARTS preparations,
	PHYLCLASS pclass,
	PHYLORDER porder,
	PHYLUM phylum,
	SCIENTIFIC_NAME scientificName,
	trim(replace(species,genus)) specificEpithet,
	trim(replace(subspecies,species))  infraspecificEpithet,
	previousidentifications previousidentifications,
	--------------------------- media ---------------------------
	IMAGEURL associatedMedia,
	-- event stuff
	-- we have to apply encumbrances here because this is NOT from filtered_flat
	-- we are getting ALL specimen_event-->geog_auth_rec here
	-- we are NOT getting geology here. We should be.
	--------------------------- specimen_event -------------------------------
	specimen_event.SPECIMEN_EVENT_TYPE SpecimenEventType, -- I'm asking
	specimen_event.COLLECTING_METHOD samplingProtocol,
	specimen_event.COLLECTING_SOURCE establishmentMeans,
	getPreferredAgentName(specimen_event.ASSIGNED_BY_AGENT_id) locationAccordingTo,
	getPreferredAgentName(specimen_event.ASSIGNED_BY_AGENT_id) georeferencedBy,
	specimen_event.ASSIGNED_DATE georeferencedDate,
	specimen_event.HABITAT habitat,
	specimen_event.VERIFICATIONSTATUS georeferenceVerificationStatus,
	specimen_event.SPECIMEN_EVENT_REMARK eventRemarks,
	--------------------------- collecting_event -------------------------------
	locality.DATUM geodeticDatum,
	collecting_event.VERBATIM_DATE  verbatimEventDate,
	collecting_event.VERBATIM_LOCALITY verbatimLocality,
	collecting_event.ORIG_LAT_LONG_UNITS verbatimCoordinateSystem,
	-- check for encumbrances
	case when
		collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
		then collecting_event.BEGAN_DATE
	else
		collecting_event.BEGAN_DATE || '/' || collecting_event.ENDED_DATE
	END eventDate,
	-- no encumbrance check necessary at time
	case when collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE
		then substr(collecting_event.began_date,12)
	else
		collecting_event.BEGAN_DATE || '/' || collecting_event.ENDED_DATE
	end eventTime,
	case when collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
		then substr( collecting_event.BEGAN_DATE, 9, 2 )
	end day,
	case when collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
		then substr( collecting_event.BEGAN_DATE, 6, 2 )
	end month,
	CASE WHEN encumbrances LIKE '%mask year collected%'
		THEN '8888' -- deal with it....
	ELSE 
		case when collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
			then substr( filtered_flat.BEGAN_DATE, 1, 4 )
		end 
	END year,
	case when collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
		then case when isdate(collecting_event.BEGAN_DATE)=1
			then to_number(to_char(to_date(collecting_event.began_date,'YYYY-MM-DD'),'DDD'))
		end
	end endDayOfYear,
	CASE WHEN encumbrances LIKE '%mask coordinates%'
		THEN NULL
	ELSE 
		collecting_event.VERBATIM_COORDINATES
	END verbatimCoordinates,
	--------------------------- locality -------------------------------
	to_meters(locality.max_error_distance,locality.max_error_units) coordinateUncertaintyInMeters,
	CASE WHEN encumbrances LIKE '%mask coordinates%'
		THEN NULL
	ELSE locality.DEC_LAT
	END decimalLatitude,
	CASE WHEN encumbrances LIKE '%mask coordinates%'
		THEN NULL
	ELSE locality.DEC_LONG
	END decimalLongitude,
	locality.SPEC_LOCALITY locality,
	locality.GEOREFERENCE_PROTOCOL georeferenceProtocol,
	locality.GEOREFERENCE_SOURCE georeferenceSources,
	to_meters(locality.MIN_DEPTH,locality.DEPTH_UNITS) minimumDepthInMeters,
	to_meters(locality.MAX_DEPTH,locality.DEPTH_UNITS) maximumDepthInMeters,
	to_meters(locality.MINIMUM_ELEVATION,locality.ORIG_ELEV_UNITS) minimumElevationInMeters,
	to_meters(locality.MAXIMUM_ELEVATION,locality.ORIG_ELEV_UNITS) maximumElevationInMeters,
	locality.locality_remarks locationRemarks,
	--------------------------- geog_auth_rec -------------------------------
	geog_auth_rec.CONTINENT_OCEAN continent,
	geog_auth_rec.COUNTRY country,
	geog_auth_rec.COUNTY county,
	geog_auth_rec.ISLAND island,
	geog_auth_rec.ISLAND_GROUP islandGroup,
	geog_auth_rec.QUAD Quad,
	geog_auth_rec.SEA waterBody,
	geog_auth_rec.FEATURE Feature,	
	geog_auth_rec.STATE_PROV stateProvince,
	geog_auth_rec.HIGHER_GEOG higherGeography,	
	replace(replace(INSTITUTION_ACRONYM,'Obs'),'UAMb','UAM') institution,
	collection,
	EARLIESTEONORLOWESTEONOTHEM,
	EARLIESTPERIODORLOWESTSYSTEM,
	EARLIESTEPOCHORLOWESTSERIES,
	EARLIESTAGEORLOWESTSTAGE,
	EARLIESTERAORLOWESTERATHEM,
	FORMATION
from
	filtered_flat,
	coll_object part_coll_object,
	specimen_part,
	v_part_event_path,
	specimen_event,
	collecting_event,
	locality,
	geog_auth_rec,
	ctspecimen_part_name,
	ipt_geology
where
	--hard join here
	filtered_flat.collection_object_id=specimen_part.derived_from_cat_item and
	specimen_part.collection_object_id=v_part_event_path.part_id and
	v_part_event_path.specimen_event_id=specimen_event.specimen_event_id and
	specimen_event.collecting_event_id=collecting_event.collecting_event_id and
	collecting_event.locality_id=locality.locality_id and
	locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and	
	specimen_part.collection_object_id=part_coll_object.collection_object_id and
	specimen_part.part_name=ctspecimen_part_name.part_name and
	ctspecimen_part_name.is_tissue=1 and
	locality.locality_id=ipt_geology.locality_id (+) and
	filtered_flat.guid like 'MSB:Mamm%'
;



select count(*) from digir_query.msb_mamm_ggbn_tissue;

-- so slow

 create table  digir_query.msb_mamm_ggbn_tissue_tbl as select * from digir_query.msb_mamm_ggbn_tissue ;
 
 -- END PlanC-or-so


select count(*) from digir_query.msb_mamm_ggbn_tissue_tbl;

select occurrenceID from digir_query.msb_mamm_ggbn_tissue_tbl having count(*) > 1 group by occurrenceID;

select occurrenceID from digir_query.msb_mamm_ggbn_tissue_tbl where rownum<5;


select occurrenceID,preparationType,eventDate from digir_query.msb_mamm_ggbn_tissue_tbl where references='http://arctos.database.museum/guid/MSB:Mamm:292063' order by eventDate














create or replace view digir_query.ggbn_tissue_view as select distinct
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?pid=' || specimen_part.collection_object_id occurrenceID,
 	-- not sure this is needed?? May be necessary to link permits?
 	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?pid=' || specimen_part.collection_object_id UnitID,
	'tissue' materialSampleType,
	specimen_part.part_name preparationType,
	part_coll_object.COLL_OBJECT_ENTERED_DATE preparationDate,
	-- preparationMaterials is 
	--    "Materials and chemicals used in the preparation of the specimen, tissue, DNA or RNA sample"
	-- it should become available as we do more with part attributes
	' ' preparationMaterials,
	-- this isn't quite correct, but I have no better data at the moment
	-- will update with more Attributes as collections begin using them
	getPreferredAgentName(part_coll_object.ENTERED_PERSON_ID) preparationStaff,
	filtered_flat.collection_id collection_id,
	'en' language,
	use_license_url rights, -- not sure this is the right dwc concept
	CATALOGED_ITEM_TYPE type, -- what is this again?
	CATALOGED_ITEM_TYPE basisOfRecord, 
	filtered_flat.COLLECTION_CDE collectionCode,
	decode(collectors,
		null,'',
		'Collector(s): ' || collectors ||
		decode(preparators,
			null,'',
			'; Preparator(s): ' || preparators
		)
	) recordedBy,
	ENCUMBRANCES informationWithheld,
	INDIVIDUALCOUNT individualCount,
	INSTITUTION_ACRONYM institutionCode,
	LASTDATE modified,
	RELATEDCATALOGEDITEMS associatedOccurrences,
	'http://arctos.database.museum/guid/' || GUID references,
	REMARKS occurrenceRemarks,
	TYPESTATUS typeStatus,
	ASSOCIATED_SPECIES associatedTaxa,
	--------------------------- identifiers ---------------------------
	OTHERCATALOGNUMBERS otherCatalogNumbers,
	'http://arctos.database.museum/guid/' || GUID individualID,
	CATALOGNUMBERTEXT catalogNumber,
	GENBANKNUM associatedSequences,
	COLLECTORNUMBER recordNumber, -- I think this is a very incomplete mapping
	FIELD_NUM fieldNumber, -- also incomplete/incorrect
	--------------------------- attribute-like gunk ---------------------------
	SEX	 sex,
	AGE_CLASS lifeStage,
	ATTRIBUTES dynamicProperties,
	--------------------------- taxonomy and identification ---------------------------
	IDENTIFICATION_REMARKS identificationRemarks,
	FAMILY family,
	trim(replace(full_taxon_name,scientific_name)) higherClassification,
	GENUS genus,
	ID_SENSU identificationReferences,
	TAXA_FORMULA identificationQualifier,
	IDENTIFIEDBY identifiedBy,
	INFRASPECIFIC_RANK taxonRank,
	KINGDOM kingdom,
	MADE_DATE dateIdentified,
	NATURE_OF_ID IDVerificationStatus,
	NOMENCLATURAL_CODE nomenclaturalCode,
	PARTS preparations,
	PHYLCLASS pclass,
	PHYLORDER porder,
	PHYLUM phylum,
	SCIENTIFIC_NAME scientificName,
	trim(replace(species,genus)) specificEpithet,
	trim(replace(subspecies,species))  infraspecificEpithet,
	previousidentifications previousidentifications,
	--------------------------- media ---------------------------
	IMAGEURL associatedMedia,
	-- event stuff
	-- we have to apply encumbrances here because this is NOT from filtered_flat
	-- we are getting ALL specimen_event-->geog_auth_rec here
	-- we are NOT getting geology here. We should be.
	--------------------------- specimen_event -------------------------------
	filtered_flat.SPECIMEN_EVENT_TYPE SpecimenEventType, -- I'm asking
	filtered_flat.COLLECTING_METHOD samplingProtocol,
	filtered_flat.COLLECTING_SOURCE establishmentMeans,
	filtered_flat.EVENT_ASSIGNED_BY_AGENT locationAccordingTo,
	filtered_flat.EVENT_ASSIGNED_BY_AGENT georeferencedBy,
	filtered_flat.EVENT_ASSIGNED_DATE georeferencedDate,
	filtered_flat.HABITAT habitat,
	filtered_flat.VERIFICATIONSTATUS georeferenceVerificationStatus,
	filtered_flat.SPECIMEN_EVENT_REMARK eventRemarks,
	--------------------------- collecting_event -------------------------------
	filtered_flat.DATUM geodeticDatum,
	filtered_flat.VERBATIM_DATE  verbatimEventDate,
	filtered_flat.VERBATIM_LOCALITY verbatimLocality,
	filtered_flat.ORIG_LAT_LONG_UNITS verbatimCoordinateSystem,
	-- check for encumbrances
	case when
		filtered_flat.BEGAN_DATE=filtered_flat.ENDED_DATE 
		then filtered_flat.BEGAN_DATE
	else
		filtered_flat.BEGAN_DATE || '/' || filtered_flat.ENDED_DATE
	END eventDate,
	-- no encumbrance check necessary at time
	case when filtered_flat.BEGAN_DATE=filtered_flat.ENDED_DATE
		then substr(filtered_flat.began_date,12)
	else
		filtered_flat.BEGAN_DATE || '/' || filtered_flat.ENDED_DATE
	end eventTime,
	case when filtered_flat.BEGAN_DATE=filtered_flat.ENDED_DATE 
		then substr( filtered_flat.BEGAN_DATE, 9, 2 )
	end day,
	case when filtered_flat.BEGAN_DATE=filtered_flat.ENDED_DATE 
		then substr( filtered_flat.BEGAN_DATE, 6, 2 )
	end month,
	CASE WHEN encumbrances LIKE '%mask year collected%'
		THEN '8888' -- deal with it....
	ELSE 
		case when filtered_flat.BEGAN_DATE=filtered_flat.ENDED_DATE 
			then substr( filtered_flat.BEGAN_DATE, 1, 4 )
		end 
	END year,
	case when filtered_flat.BEGAN_DATE=filtered_flat.ENDED_DATE 
		then case when isdate(filtered_flat.BEGAN_DATE)=1
			then to_number(to_char(to_date(filtered_flat.began_date,'YYYY-MM-DD'),'DDD'))
		end
	end endDayOfYear,
	CASE WHEN encumbrances LIKE '%mask coordinates%'
		THEN NULL
	ELSE 
		filtered_flat.VERBATIM_COORDINATES
	END verbatimCoordinates,
	--------------------------- locality -------------------------------
	filtered_flat.coordinateUncertaintyInMeters,
	CASE WHEN encumbrances LIKE '%mask coordinates%'
		THEN NULL
	ELSE filtered_flat.DEC_LAT
	END decimalLatitude,
	CASE WHEN encumbrances LIKE '%mask coordinates%'
		THEN NULL
	ELSE filtered_flat.DEC_LONG
	END decimalLongitude,
	filtered_flat.SPEC_LOCALITY locality,
	filtered_flat.GEOREFERENCE_PROTOCOL georeferenceProtocol,
	filtered_flat.GEOREFERENCE_SOURCE georeferenceSources,
	to_meters(filtered_flat.MIN_DEPTH,filtered_flat.DEPTH_UNITS) minimumDepthInMeters,
	to_meters(filtered_flat.MAX_DEPTH,filtered_flat.DEPTH_UNITS) maximumDepthInMeters,
	to_meters(filtered_flat.MINIMUM_ELEVATION,filtered_flat.ORIG_ELEV_UNITS) minimumElevationInMeters,
	to_meters(filtered_flat.MAXIMUM_ELEVATION,filtered_flat.ORIG_ELEV_UNITS) maximumElevationInMeters,
	filtered_flat.locality_remarks locationRemarks,
	--------------------------- geog_auth_rec -------------------------------
	filtered_flat.CONTINENT_OCEAN continent,
	filtered_flat.COUNTRY country,
	filtered_flat.COUNTY county,
	filtered_flat.ISLAND island,
	filtered_flat.ISLAND_GROUP islandGroup,
	filtered_flat.QUAD Quad,
	filtered_flat.SEA waterBody,
	filtered_flat.FEATURE Feature,	
	filtered_flat.STATE_PROV stateProvince,
	filtered_flat.HIGHER_GEOG higherGeography,	
	replace(replace(INSTITUTION_ACRONYM,'Obs'),'UAMb','UAM') institution,
	collection,
	EARLIESTEONORLOWESTEONOTHEM,
	EARLIESTPERIODORLOWESTSYSTEM,
	EARLIESTEPOCHORLOWESTSERIES,
	EARLIESTAGEORLOWESTSTAGE,
	EARLIESTERAORLOWESTERATHEM,
	FORMATION
from
	filtered_flat,
	coll_object part_coll_object,
	specimen_part,
	ctspecimen_part_name,
	ipt_geology
where
	--hard join here
	filtered_flat.collection_object_id=specimen_part.derived_from_cat_item and
	specimen_part.collection_object_id=part_coll_object.collection_object_id and
	specimen_part.part_name=ctspecimen_part_name.part_name and
	ctspecimen_part_name.is_tissue=1 and
	filtered_flat.locality_id=ipt_geology.locality_id (+)
;
























-- old; didn't work
create or replace view digir_query.ggbn_flat_tissue as select
	-- primary key for tissue samples
	-- barcode is not unique in this context - a barcode may contain multiple tissues
	--   so use the only unique (if ephemeral) ID we have available 
	specimen_part.collection_object_id UnitID,
	-- because DWC wants it
	filtered_flat.collection_id,
	-- key to Occurrences; this is a foreign key here
	'http://arctos.database.museum/guid/' || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id OccurrenceID2,
	-- the only type of materialSample we have at the moment
	'tissue' materialSampleType,
	specimen_part.part_name preparationType,
	part_coll_object.COLL_OBJECT_ENTERED_DATE preparationDate,
	-- preparationMaterials is 
	--    "Materials and chemicals used in the preparation of the specimen, tissue, DNA or RNA sample"
	-- it should become available as we do more with part attributes
	' ' preparationMaterials,
	-- this isn't quite correct, but I have no better data at the moment
	-- will update with more Attributes as collections begin using them
	getPreferredAgentName(part_coll_object.ENTERED_PERSON_ID) preparationStaff
from
	filtered_flat,
	specimen_event,
	specimen_part,
	ctspecimen_part_name,
	coll_object part_coll_object
where
	filtered_flat.collection_object_id=specimen_part.derived_from_cat_item and	
	specimen_part.part_name=ctspecimen_part_name.part_name and
	ctspecimen_part_name.IS_TISSUE=1 and
	filtered_flat.collection_object_id=specimen_event.collection_object_id and
	specimen_part.collection_object_id=part_coll_object.collection_object_id
;



'http://arctos.database.museum/guid/' || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id || ':' || specimen_part.collection_object_id