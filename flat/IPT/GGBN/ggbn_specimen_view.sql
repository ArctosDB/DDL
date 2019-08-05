
create or replace view digir_query.ggbn_specimen_view as select
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
   	'http://arctos.database.museum/guid/' || GUID occurrenceID,
   	COUNTRY
from
	filtered_flat
where
	guid is not null
;

