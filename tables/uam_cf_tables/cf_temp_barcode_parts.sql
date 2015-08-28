CREATE TABLE CF_TEMP_BARCODE_PARTS (
	KEY NUMBER NOT NULL,
	OTHER_ID_TYPE VARCHAR2(255),
	OTHER_ID_NUMBER VARCHAR2(60),
	COLLECTION_CDE VARCHAR2(5),
	INSTITUTION_ACRONYM VARCHAR2(20),
	PART_NAME VARCHAR2(255),
	BARCODE VARCHAR2(255),
	COLLECTION_OBJECT_ID NUMBER,
	CONTAINER_ID NUMBER,
	PRINT_FG VARCHAR2(10),
	NEW_CONTAINER_TYPE VARCHAR2(60)
) TABLESPACE UAM_DAT_1;