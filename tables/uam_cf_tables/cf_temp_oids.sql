CREATE TABLE CF_TEMP_OIDS (
	KEY NUMBER,
	COLLECTION_OBJECT_ID NUMBER,
	COLLECTION_CDE VARCHAR2(5),
	INSTITUTION_ACRONYM VARCHAR2(6),
	EXISTING_OTHER_ID_TYPE VARCHAR2(60),
	EXISTING_OTHER_ID_NUMBER VARCHAR2(60),
	NEW_OTHER_ID_TYPE VARCHAR2(60),
	NEW_OTHER_ID_NUMBER VARCHAR2(60)
) TABLESPACE UAM_DAT_1;
