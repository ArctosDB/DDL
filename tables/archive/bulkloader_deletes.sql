-- 10 Jan 2008 change:
ALTER TABLE bulkoader_deletes MODIFY associated_species VARCHAR2(4000;

-- 10 Jan 2008 ddl:    

CREATE TABLE BULKLOADER_DELETES (
    COLLECTION_OBJECT_ID NUMBER,
	LOADED VARCHAR2(255),
	ENTEREDBY VARCHAR2(255),
	CAT_NUM VARCHAR2(20),
	OTHER_ID_NUM_5 VARCHAR2(255),
	OTHER_ID_NUM_TYPE_5 VARCHAR2(255),
	OTHER_ID_NUM_1 VARCHAR2(255),
	OTHER_ID_NUM_TYPE_1 VARCHAR2(255),
	ACCN VARCHAR2(20),
	TAXON_NAME VARCHAR2(255),
	NATURE_OF_ID VARCHAR2(255),
	ID_MADE_BY_AGENT VARCHAR2(255),
	MADE_DATE VARCHAR2(20),
	IDENTIFICATION_REMARKS VARCHAR2(255),
	VERBATIM_DATE VARCHAR2(255),
	BEGAN_DATE VARCHAR2(20),
	ENDED_DATE VARCHAR2(20),
	HIGHER_GEOG VARCHAR2(255),
	SPEC_LOCALITY VARCHAR2(255),
	VERBATIM_LOCALITY VARCHAR2(255),
	ORIG_LAT_LONG_UNITS VARCHAR2(255),
	DEC_LAT VARCHAR2(255),
	DEC_LONG VARCHAR2(255),
	LATDEG VARCHAR2(20),
	DEC_LAT_MIN VARCHAR2(255),
	LATMIN VARCHAR2(255),
	LATSEC VARCHAR2(255),
	LATDIR VARCHAR2(50),
	LONGDEG VARCHAR2(20),
	DEC_LONG_MIN VARCHAR2(255),
	LONGMIN VARCHAR2(255),
	LONGSEC VARCHAR2(255),
	LONGDIR VARCHAR2(50),
	DATUM VARCHAR2(255),
	LAT_LONG_REF_SOURCE VARCHAR2(255),
	MAX_ERROR_DISTANCE VARCHAR2(255),
	MAX_ERROR_UNITS VARCHAR2(255),
	GEOREFMETHOD VARCHAR2(255),
	DETERMINED_BY_AGENT VARCHAR2(255),
	DETERMINED_DATE VARCHAR2(20),
	LAT_LONG_REMARKS VARCHAR2(4000),
	VERIFICATIONSTATUS VARCHAR2(255),
	MAXIMUM_ELEVATION VARCHAR2(20),
	MINIMUM_ELEVATION VARCHAR2(20),
	ORIG_ELEV_UNITS VARCHAR2(255),
	LOCALITY_REMARKS VARCHAR2(255),
	HABITAT_DESC VARCHAR2(255),
	COLL_EVENT_REMARKS VARCHAR2(255),
	COLLECTOR_AGENT_1 VARCHAR2(255),
	COLLECTOR_ROLE_1 VARCHAR2(255),
	COLLECTOR_AGENT_2 VARCHAR2(255),
	COLLECTOR_ROLE_2 VARCHAR2(255),
	COLLECTOR_AGENT_3 VARCHAR2(255),
	COLLECTOR_ROLE_3 VARCHAR2(255),
	COLLECTOR_AGENT_4 VARCHAR2(50),
	COLLECTOR_ROLE_4 VARCHAR2(50),
	COLLECTOR_AGENT_5 VARCHAR2(255),
	COLLECTOR_ROLE_5 VARCHAR2(255),
	COLLECTOR_AGENT_6 VARCHAR2(255),
	COLLECTOR_ROLE_6 VARCHAR2(255),
	COLLECTOR_AGENT_7 VARCHAR2(255),
	COLLECTOR_ROLE_7 VARCHAR2(255),
	COLLECTOR_AGENT_8 VARCHAR2(255),
	COLLECTOR_ROLE_8 VARCHAR2(255),
	COLLECTION_CDE VARCHAR2(255),
	INSTITUTION_ACRONYM VARCHAR2(50),
	FLAGS VARCHAR2(20),
	COLL_OBJ_DISPOSITION VARCHAR2(255),
	CONDITION VARCHAR2(255),
	COLL_OBJECT_REMARKS VARCHAR2(4000),
	DISPOSITION_REMARKS VARCHAR2(255),
	OTHER_ID_NUM_2 VARCHAR2(255),
	OTHER_ID_NUM_TYPE_2 VARCHAR2(255),
	OTHER_ID_NUM_3 VARCHAR2(255),
	OTHER_ID_NUM_TYPE_3 VARCHAR2(255),
	OTHER_ID_NUM_4 VARCHAR2(255),
	OTHER_ID_NUM_TYPE_4 VARCHAR2(255),
	PART_NAME_1 VARCHAR2(255),
	PART_MODIFIER_1 VARCHAR2(255),
	PRESERV_METHOD_1 VARCHAR2(255),
	PART_CONDITION_1 VARCHAR2(255),
	PART_BARCODE_1 VARCHAR2(50),
	PART_CONTAINER_LABEL_1 VARCHAR2(50),
	PART_LOT_COUNT_1 VARCHAR2(2),
	PART_DISPOSITION_1 VARCHAR2(255),
	PART_REMARK_1 VARCHAR2(255),
	PART_NAME_2 VARCHAR2(255),
	PART_MODIFIER_2 VARCHAR2(255),
	PRESERV_METHOD_2 VARCHAR2(255),
	PART_CONDITION_2 VARCHAR2(255),
	PART_BARCODE_2 VARCHAR2(50),
	PART_CONTAINER_LABEL_2 VARCHAR2(50),
	PART_LOT_COUNT_2 VARCHAR2(2),
	PART_DISPOSITION_2 VARCHAR2(255),
	PART_REMARK_2 VARCHAR2(255),
	PART_NAME_3 VARCHAR2(255),
	PART_MODIFIER_3 VARCHAR2(255),
	PRESERV_METHOD_3 VARCHAR2(255),
	PART_CONDITION_3 VARCHAR2(255),
	PART_BARCODE_3 VARCHAR2(50),
	PART_CONTAINER_LABEL_3 VARCHAR2(50),
	PART_LOT_COUNT_3 VARCHAR2(2),
	PART_DISPOSITION_3 VARCHAR2(255),
	PART_REMARK_3 VARCHAR2(255),
	PART_NAME_4 VARCHAR2(255),
	PART_MODIFIER_4 VARCHAR2(255),
	PRESERV_METHOD_4 VARCHAR2(255),
	PART_CONDITION_4 VARCHAR2(255),
	PART_BARCODE_4 VARCHAR2(50),
	PART_CONTAINER_LABEL_4 VARCHAR2(50),
	PART_LOT_COUNT_4 VARCHAR2(2),
	PART_DISPOSITION_4 VARCHAR2(255),
	PART_REMARK_4 VARCHAR2(255),
	PART_NAME_5 VARCHAR2(255),
	PART_MODIFIER_5 VARCHAR2(255),
	PRESERV_METHOD_5 VARCHAR2(255),
	PART_CONDITION_5 VARCHAR2(255),
	PART_BARCODE_5 VARCHAR2(50),
	PART_CONTAINER_LABEL_5 VARCHAR2(50),
	PART_LOT_COUNT_5 VARCHAR2(2),
	PART_DISPOSITION_5 VARCHAR2(255),
	PART_REMARK_5 VARCHAR2(255),
	PART_NAME_6 VARCHAR2(255),
	PART_MODIFIER_6 VARCHAR2(255),
	PRESERV_METHOD_6 VARCHAR2(255),
	PART_CONDITION_6 VARCHAR2(255),
	PART_BARCODE_6 VARCHAR2(50),
	PART_CONTAINER_LABEL_6 VARCHAR2(50),
	PART_LOT_COUNT_6 VARCHAR2(2),
	PART_DISPOSITION_6 VARCHAR2(255),
	PART_REMARK_6 VARCHAR2(255),
	PART_NAME_7 VARCHAR2(255),
	PART_MODIFIER_7 VARCHAR2(255),
	PRESERV_METHOD_7 VARCHAR2(255),
	PART_CONDITION_7 VARCHAR2(255),
	PART_BARCODE_7 VARCHAR2(50),
	PART_CONTAINER_LABEL_7 VARCHAR2(50),
	PART_LOT_COUNT_7 VARCHAR2(2),
	PART_DISPOSITION_7 VARCHAR2(255),
	PART_REMARK_7 VARCHAR2(255),
	PART_NAME_8 VARCHAR2(255),
	PART_MODIFIER_8 VARCHAR2(255),
	PRESERV_METHOD_8 VARCHAR2(255),
	PART_CONDITION_8 VARCHAR2(255),
	PART_BARCODE_8 VARCHAR2(50),
	PART_CONTAINER_LABEL_8 VARCHAR2(50),
	PART_LOT_COUNT_8 VARCHAR2(2),
	PART_DISPOSITION_8 VARCHAR2(255),
	PART_REMARK_8 VARCHAR2(255),
	PART_NAME_9 VARCHAR2(255),
	PART_MODIFIER_9 VARCHAR2(255),
	PRESERV_METHOD_9 VARCHAR2(255),
	PART_CONDITION_9 VARCHAR2(255),
	PART_BARCODE_9 VARCHAR2(50),
	PART_CONTAINER_LABEL_9 VARCHAR2(50),
	PART_LOT_COUNT_9 VARCHAR2(50),
	PART_DISPOSITION_9 VARCHAR2(255),
	PART_REMARK_9 VARCHAR2(255),
	PART_NAME_10 VARCHAR2(255),
	PART_MODIFIER_10 VARCHAR2(255),
	PRESERV_METHOD_10 VARCHAR2(255),
	PART_CONDITION_10 VARCHAR2(255),
	PART_BARCODE_10 VARCHAR2(50),
	PART_CONTAINER_LABEL_10 VARCHAR2(50),
	PART_LOT_COUNT_10 VARCHAR2(50),
	PART_DISPOSITION_10 VARCHAR2(255),
	PART_REMARK_10 VARCHAR2(255),
	PART_NAME_11 VARCHAR2(255),
	PART_MODIFIER_11 VARCHAR2(255),
	PRESERV_METHOD_11 VARCHAR2(255),
	PART_CONDITION_11 VARCHAR2(255),
	PART_BARCODE_11 VARCHAR2(50),
	PART_CONTAINER_LABEL_11 VARCHAR2(50),
	PART_LOT_COUNT_11 VARCHAR2(50),
	PART_DISPOSITION_11 VARCHAR2(255),
	PART_REMARK_11 VARCHAR2(255),
	PART_NAME_12 VARCHAR2(255),
	PART_MODIFIER_12 VARCHAR2(255),
	PRESERV_METHOD_12 VARCHAR2(255),
	PART_CONDITION_12 VARCHAR2(255),
	PART_BARCODE_12 VARCHAR2(50),
	PART_CONTAINER_LABEL_12 VARCHAR2(50),
	PART_LOT_COUNT_12 VARCHAR2(50),
	PART_DISPOSITION_12 VARCHAR2(255),
	PART_REMARK_12 VARCHAR2(255),
	ATTRIBUTE_1 VARCHAR2(50),
	ATTRIBUTE_VALUE_1 VARCHAR2(255),
	ATTRIBUTE_UNITS_1 VARCHAR2(255),
	ATTRIBUTE_REMARKS_1 VARCHAR2(255),
	ATTRIBUTE_DATE_1 VARCHAR2(20),
	ATTRIBUTE_DET_METH_1 VARCHAR2(50),
	ATTRIBUTE_DETERMINER_1 VARCHAR2(50),
	ATTRIBUTE_2 VARCHAR2(50),
	ATTRIBUTE_VALUE_2 VARCHAR2(255),
	ATTRIBUTE_UNITS_2 VARCHAR2(50),
	ATTRIBUTE_REMARKS_2 VARCHAR2(255),
	ATTRIBUTE_DATE_2 VARCHAR2(20),
	ATTRIBUTE_DET_METH_2 VARCHAR2(50),
	ATTRIBUTE_DETERMINER_2 VARCHAR2(50),
	ATTRIBUTE_3 VARCHAR2(50),
	ATTRIBUTE_VALUE_3 VARCHAR2(255),
	ATTRIBUTE_UNITS_3 VARCHAR2(50),
	ATTRIBUTE_REMARKS_3 VARCHAR2(255),
	ATTRIBUTE_DATE_3 VARCHAR2(20),
	ATTRIBUTE_DET_METH_3 VARCHAR2(50),
	ATTRIBUTE_DETERMINER_3 VARCHAR2(50),
	ATTRIBUTE_4 VARCHAR2(50),
	ATTRIBUTE_VALUE_4 VARCHAR2(255),
	ATTRIBUTE_UNITS_4 VARCHAR2(50),
	ATTRIBUTE_REMARKS_4 VARCHAR2(255),
	ATTRIBUTE_DATE_4 VARCHAR2(20),
	ATTRIBUTE_DET_METH_4 VARCHAR2(50),
	ATTRIBUTE_DETERMINER_4 VARCHAR2(50),
	ATTRIBUTE_5 VARCHAR2(50),
	ATTRIBUTE_VALUE_5 VARCHAR2(255),
	ATTRIBUTE_UNITS_5 VARCHAR2(50),
	ATTRIBUTE_REMARKS_5 VARCHAR2(255),
	ATTRIBUTE_DATE_5 VARCHAR2(20),
	ATTRIBUTE_DET_METH_5 VARCHAR2(50),
	ATTRIBUTE_DETERMINER_5 VARCHAR2(50),
	ATTRIBUTE_6 VARCHAR2(50),
	ATTRIBUTE_VALUE_6 VARCHAR2(255),
	ATTRIBUTE_UNITS_6 VARCHAR2(50),
	ATTRIBUTE_REMARKS_6 VARCHAR2(255),
	ATTRIBUTE_DATE_6 VARCHAR2(20),
	ATTRIBUTE_DET_METH_6 VARCHAR2(50),
	ATTRIBUTE_DETERMINER_6 VARCHAR2(50),
	ATTRIBUTE_7 VARCHAR2(50),
	ATTRIBUTE_VALUE_7 VARCHAR2(255),
	ATTRIBUTE_UNITS_7 VARCHAR2(50),
	ATTRIBUTE_REMARKS_7 VARCHAR2(255),
	ATTRIBUTE_DATE_7 VARCHAR2(20),
	ATTRIBUTE_DET_METH_7 VARCHAR2(50),
	ATTRIBUTE_DETERMINER_7 VARCHAR2(50),
	ATTRIBUTE_8 VARCHAR2(50),
	ATTRIBUTE_VALUE_8 VARCHAR2(255),
	ATTRIBUTE_UNITS_8 VARCHAR2(50),
	ATTRIBUTE_REMARKS_8 VARCHAR2(255),
	ATTRIBUTE_DATE_8 VARCHAR2(20),
	ATTRIBUTE_DET_METH_8 VARCHAR2(50),
	ATTRIBUTE_DETERMINER_8 VARCHAR2(50),
	ATTRIBUTE_9 VARCHAR2(50),
	ATTRIBUTE_VALUE_9 VARCHAR2(255),
	ATTRIBUTE_UNITS_9 VARCHAR2(50),
	ATTRIBUTE_REMARKS_9 VARCHAR2(255),
	ATTRIBUTE_DATE_9 VARCHAR2(50),
	ATTRIBUTE_DET_METH_9 VARCHAR2(50),
	ATTRIBUTE_DETERMINER_9 VARCHAR2(50),
	ATTRIBUTE_10 VARCHAR2(50),
	ATTRIBUTE_VALUE_10 VARCHAR2(255),
	ATTRIBUTE_UNITS_10 VARCHAR2(50),
	ATTRIBUTE_REMARKS_10 VARCHAR2(255),
	ATTRIBUTE_DATE_10 VARCHAR2(50),
	ATTRIBUTE_DET_METH_10 VARCHAR2(50),
	ATTRIBUTE_DETERMINER_10 VARCHAR2(50),
	RELATIONSHIP VARCHAR2(60),
	RELATED_TO_NUMBER VARCHAR2(60),
	RELATED_TO_NUM_TYPE VARCHAR2(60),
	MIN_DEPTH VARCHAR2(20),
	MAX_DEPTH VARCHAR2(20),
	DEPTH_UNITS VARCHAR2(30),
	VESSEL VARCHAR2(255),
	STATION_NAME VARCHAR2(255),
	STATION_NUMBER VARCHAR2(255),
	COLLECTING_METHOD VARCHAR2(255),
	COLLECTING_SOURCE VARCHAR2(255),
	COLL_OBJECT_HABITAT VARCHAR2(255),
	ASSOCIATED_SPECIES VARCHAR2(4000),
	LOCALITY_ID VARCHAR2(20),
	UTM_ZONE VARCHAR2(3),
	UTM_EW VARCHAR2(60),
	UTM_NS VARCHAR2(60),
	EXTENT VARCHAR2(60),
	GPSACCURACY VARCHAR2(60)
);

-- 08 Apr 2008 change:
ALTER TABLE bulkloader MODIFY identification_remarks VARCHAR2(4000);