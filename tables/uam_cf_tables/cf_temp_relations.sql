CREATE TABLE CF_TEMP_RELATIONS (
	COLLECTION_OBJECT_ID NUMBER NOT NULL,
	RELATIONSHIP VARCHAR2(60) NOT NULL,
	RELATED_TO_NUMBER VARCHAR2(60) NOT NULL,
	RELATED_TO_NUM_TYPE VARCHAR2(255) NOT NULL,
	LASTTRYDATE DATE,
	FAIL_REASON VARCHAR2(255),
	RELATED_COLLECTION_OBJECT_ID NUMBER,
	INSERT_DATE DATE DEFAULT SYSDATE NOT NULL,
	CF_TEMP_RELATIONS_ID NUMBER NOT NULL
) TABLESPACE UAM_DAT_1;
