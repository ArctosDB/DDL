--  update for https://github.com/ArctosDB/arctos/issues/2160#issuecomment-510675631




----------------------------------------- main IPT table -----------------------------------------------------------------
-- view of the stuff we need, in UAM tablespace
create or replace view ipt_view_v2 as select
	--------------------------- "specimen gunk" ---------------------------
	filtered_flat.collection_id collectionID,
	'en' language,
	use_license_url license, -- not sure this is the right dwc concept
	--CATALOGED_ITEM_TYPE type, -- what is this again?
	decode(CATALOGED_ITEM_TYPE,
		'specimen','PreservedSpecimen',
		'observation','HumanObservation',
		NULL) basisOfRecord,
	-- 20190611: If we ever get preservation out of parts and into part attributes we might be able to use it here
	--CATALOGED_ITEM_TYPE basisOfRecord, 
	--COLLECTION_CDE collectionCode,
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
	--INSTITUTION_ACRONYM institutionCode,
	LASTDATE modified,
	RELATEDCATALOGEDITEMS associatedOccurrences,
	'http://arctos.database.museum/guid/' || GUID references,
	REMARKS occurrenceRemarks,
	TYPESTATUS typeStatus,
	ASSOCIATED_SPECIES associatedTaxa,
	--------------------------- identifiers ---------------------------
	OTHERCATALOGNUMBERS otherCatalogNumbers,
	'http://arctos.database.museum/guid/' || GUID organismID,
	filtered_flat.guid catalogNumber,
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
	taxon_rank taxonRank,
	--INFRASPECIFIC_RANK taxonRank,
	KINGDOM kingdom,
	MADE_DATE dateIdentified,
	NATURE_OF_ID IDVerificationStatus, -- toobookoo: "identificationVerificationStatus",
	NOMENCLATURAL_CODE nomenclaturalCode,
	PARTS preparations,
	PHYLCLASS "class",
	PHYLORDER "order",
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
   -- 'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || specimen_event.specimen_event_id occurrenceID,
	--specimen_event.SPECIMEN_EVENT_TYPE SpecimenEventType, -- I'm asking
	decode(specimen_event.SPECIMEN_EVENT_TYPE,
		'collection','PhysicalObject',
		'encounter','PhysicalObject',
		'Event') type,	
	specimen_event.COLLECTING_METHOD samplingProtocol,
	specimen_event.COLLECTING_SOURCE establishmentMeans,
	getPreferredAgentName(specimen_event.ASSIGNED_BY_AGENT_ID) locationAccordingTo,
	getPreferredAgentName(specimen_event.ASSIGNED_BY_AGENT_ID) georeferencedBy,
	specimen_event.ASSIGNED_DATE georeferencedDate,
	specimen_event.HABITAT habitat,
	specimen_event.VERIFICATIONSTATUS georeferenceVerificationStatus,
	----------------------------concat -----------------------------------------
	decode (specimen_event.SPECIMEN_EVENT_REMARK || collecting_event.COLL_EVENT_REMARKS,
		null,null, -- both are null - move on
		decode (specimen_event.SPECIMEN_EVENT_REMARK,
			null,collecting_event.COLL_EVENT_REMARKS,
			specimen_event.SPECIMEN_EVENT_REMARK || decode(
				collecting_event.COLL_EVENT_REMARKS,
				null,'',
				'; ' || collecting_event.COLL_EVENT_REMARKS
			)
		)
	) eventRemarks,
	--------------------------- collecting_event -------------------------------
	collecting_event.DATUM geodeticDatum,
	collecting_event.VERBATIM_DATE  verbatimEventDate,
	collecting_event.VERBATIM_LOCALITY verbatimLocality,
	collecting_event.ORIG_LAT_LONG_UNITS verbatimCoordinateSystem,
	-- check for encumbrances
	CASE WHEN encumbrances LIKE '%mask year collected%'
		THEN replace(collecting_event.began_date,substr(collecting_event.began_date,1,4),'8888')
	ELSE 
		case when
			collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
			then collecting_event.BEGAN_DATE
		else
			collecting_event.BEGAN_DATE || '/' || collecting_event.ENDED_DATE
		end 
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
			then substr( collecting_event.BEGAN_DATE, 1, 4 )
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
	to_meters(locality.MAX_ERROR_DISTANCE,locality.MAX_ERROR_UNITS) coordinateUncertaintyInMeters,
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
	--geog_auth_rec.QUAD Quad,
	geog_auth_rec.SEA waterBody,
	--geog_auth_rec.FEATURE Feature,	
	geog_auth_rec.STATE_PROV stateProvince,
	geog_auth_rec.HIGHER_GEOG higherGeography,	
	--replace(replace(INSTITUTION_ACRONYM,'Obs'),'UAMb','UAM') institutionCode,
	INSTITUTION_ACRONYM institutionCode,
	collection collectionCode,
	getGeologyForDWC(locality.locality_id,'Erathem/Era') as earliestEraOrLowestErathem,
	getGeologyForDWC(locality.locality_id,'Eon/Eonothem') as earliestEonOrLowestEonothem,
	getGeologyForDWC(locality.locality_id,'Series/Epoch') as earliestEpochOrLowestSeries,
	getGeologyForDWC(locality.locality_id,'Stage/Age') as earliestAgeOrLowestStage,
	getGeologyForDWC(locality.locality_id,'System/Period') as earliestPeriodOrLowestSystem,
	getGeologyForDWC(locality.locality_id,'formation') as formation,
	getGeologyForDWC(locality.locality_id,'group') as "group",
	getGeologyForDWC(locality.locality_id,'member') as member,
	'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id occurrenceID,
	replace(replace(INSTITUTION_ACRONYM,'Obs'),'UAMb','UAM') institutionID,
	'http://vertnet.org/resources/norms.html' accessRights
	--taxon_rank taxonRank
from
	filtered_flat,
	specimen_event,
	collecting_event,
	locality,
	geog_auth_rec
where
	filtered_flat.collection_object_id=specimen_event.collection_object_id (+) and
	--specimen_event.specimen_event_type != 'unaccepted place of collection' and
	specimen_event.verificationstatus != 'unaccepted' and
	specimen_event.collecting_event_id=collecting_event.collecting_event_id (+) and
	collecting_event.locality_id=locality.locality_id (+) and
	locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id (+) and
	not exists (select locality_id from geology_attributes where geology_attributes.locality_id=locality.locality_id and GEOLOGY_ATTRIBUTE='access' and GEO_ATT_VALUE='private')
;



-- doesn't seem to be any real advantage to demand-refresh MV, so go simple/portable route.
-- NOLOGGING and insert /*+ APPEND */ make huge performance difference

-- seed, still in UAM
drop table ipt_tbl;
create table ipt_tbl NOLOGGING as select * from ipt_view_v2 where 1=2 ;


create or replace public synonym ipt_tbl for ipt_tbl;
grant select on ipt_tbl to public;

-- and a view on the table for query
drop view digir_query.occurrence;
create or replace view digir_query.occurrence as select * from ipt_tbl;



-- refresh
-- this takes a little over an hour
-- run it at 1AM on the first day of every month

CREATE OR REPLACE PROCEDURE proc_ref_ipt_tbl IS
BEGIN
	execute immediate 'truncate table ipt_tbl';
	insert /*+ APPEND */ into ipt_tbl ( select * from ipt_view_v2);
end;
/
sho err;


BEGIN
  DBMS_SCHEDULER.drop_job (
   job_name => 'j_proc_ref_ipt_tbl',
   force    => TRUE);
END;
/

-- refresh
-- previous: proc_ref_ipt_relt_resrce runs at 10:30PM on the 26th and takes minutes
-- run this at 11PM on the 26th
-- takes ~2 hours
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'j_proc_ref_ipt_tbl',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'proc_ref_ipt_tbl',
    enabled     => TRUE,
    start_date  =>  '26-AUG-17 11.00.00 PM -05:00',
   repeat_interval    =>  'freq=monthly; bymonthday=26'
  );
END;
/ 

 select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where lower(JOB_NAME)='j_proc_ref_ipt_tbl';



-- immediate refresh

 BEGIN
  DBMS_SCHEDULER.drop_job (
   job_name => 'j_proc_ref_ipt_tbl',
   force    => TRUE);
END;
/



BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_temp_update_junk',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'proc_ref_ipt_tbl',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 
select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION,systimestamp from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';

----------------------------------------- /main IPT table -----------------------------------------------------------------






































----------------------------------------------------- this is old legacy stuff
----------------------------------------------------- might be useful for something
----------------------------------------------------- like figuring out why something works like it does
----------------------------------------------------- keep it around
----------------------------------------------------- don't update or try to use






--- UPDATE 2015-04-15
-- change format of OccurrenceID from
-- 'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || specimen_event.specimen_event_id occurrenceID,
-- to
-- http://arctos.database.museum/guid/{GUID}?seid={specimen_event_id}

create or replace view digir_query.ipt_view as select
	--------------------------- "specimen gunk" ---------------------------
	filtered_flat.collection_id collection_id,
	'en' language,
	use_license_url rights, -- not sure this is the right dwc concept
	CATALOGED_ITEM_TYPE type, -- what is this again?
	CATALOGED_ITEM_TYPE basisOfRecord, 
	COLLECTION_CDE collectionCode,
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
	filtered_flat.guid catalogNumber,
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
	taxon_rank taxonRank,
	--INFRASPECIFIC_RANK taxonRank,
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
    'urn:occurrence:Arctos:' || filtered_flat.guid || ':' || specimen_event.specimen_event_id occurrenceID,
	specimen_event.SPECIMEN_EVENT_TYPE SpecimenEventType, -- I'm asking
	specimen_event.COLLECTING_METHOD samplingProtocol,
	specimen_event.COLLECTING_SOURCE establishmentMeans,
	getPreferredAgentName(specimen_event.ASSIGNED_BY_AGENT_ID) locationAccordingTo,
	getPreferredAgentName(specimen_event.ASSIGNED_BY_AGENT_ID) georeferencedBy,
	specimen_event.ASSIGNED_DATE georeferencedDate,
	specimen_event.HABITAT habitat,
	specimen_event.VERIFICATIONSTATUS georeferenceVerificationStatus,
	----------------------------concat -----------------------------------------
	decode (specimen_event.SPECIMEN_EVENT_REMARK || collecting_event.COLL_EVENT_REMARKS,
		null,null, -- both are null - move on
		decode (specimen_event.SPECIMEN_EVENT_REMARK,
			null,collecting_event.COLL_EVENT_REMARKS,
			specimen_event.SPECIMEN_EVENT_REMARK || decode(
				collecting_event.COLL_EVENT_REMARKS,
				null,'',
				'; ' || collecting_event.COLL_EVENT_REMARKS
			)
		)
	) eventRemarks,
	--------------------------- collecting_event -------------------------------
	collecting_event.DATUM geodeticDatum,
	collecting_event.VERBATIM_DATE  verbatimEventDate,
	collecting_event.VERBATIM_LOCALITY verbatimLocality,
	collecting_event.ORIG_LAT_LONG_UNITS verbatimCoordinateSystem,
	-- check for encumbrances
	CASE WHEN encumbrances LIKE '%mask year collected%'
		THEN replace(collecting_event.began_date,substr(collecting_event.began_date,1,4),'8888')
	ELSE 
		case when
			collecting_event.BEGAN_DATE=collecting_event.ENDED_DATE 
			then collecting_event.BEGAN_DATE
		else
			collecting_event.BEGAN_DATE || '/' || collecting_event.ENDED_DATE
		end 
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
			then substr( collecting_event.BEGAN_DATE, 1, 4 )
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
	to_meters(locality.MAX_ERROR_DISTANCE,locality.MAX_ERROR_UNITS) coordinateUncertaintyInMeters,
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
	getGeologyForDWC(locality.locality_id,'Erathem/Era') as earliestEraOrLowestErathem,
	getGeologyForDWC(locality.locality_id,'Eon/Eonothem') as earliestEonOrLowestEonothem,
	getGeologyForDWC(locality.locality_id,'Series/Epoch') as earliestEpochOrLowestSeries,
	getGeologyForDWC(locality.locality_id,'Stage/Age') as earliestAgeOrLowestStage,
	getGeologyForDWC(locality.locality_id,'System/Period') as earliestPeriodOrLowestSystem,
	getGeologyForDWC(locality.locality_id,'formation') as formation,
	getGeologyForDWC(locality.locality_id,'group') as geo_group,
	getGeologyForDWC(locality.locality_id,'member') as member,
	 'http://arctos.database.museum/guid/'  || filtered_flat.guid || '?seid=' || specimen_event.specimen_event_id occurrenceID2
	 --,
	--taxon_rank taxonRank
from
	filtered_flat,
	specimen_event,
	collecting_event,
	locality,
	geog_auth_rec
where
	filtered_flat.collection_object_id=specimen_event.collection_object_id (+) and
	--specimen_event.specimen_event_type != 'unaccepted place of collection' and
	specimen_event.verificationstatus != 'unaccepted' and
	specimen_event.collecting_event_id=collecting_event.collecting_event_id (+) and
	collecting_event.locality_id=locality.locality_id (+) and
	locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id (+)
;



