CREATE TABLE SPECIMEN_ANNOTATIONS (
	ANNOTATION_ID NUMBER NOT NULL,
	ANNOTATE_DATE DATE,
	CF_USERNAME VARCHAR2(255),
	COLLECTION_OBJECT_ID NUMBER NOT NULL,
	SCIENTIFIC_NAME VARCHAR2(255),
	HIGHER_GEOGRAPHY VARCHAR2(255),
	SPECIFIC_LOCALITY VARCHAR2(255),
	ANNOTATION_REMARKS VARCHAR2(255),
	REVIEWER_AGENT_ID NUMBER,
	REVIEWED_FG NUMBER(1,0) DEFAULT 0,
	REVIEWER_COMMENT VARCHAR2(255),
		CONSTRAINT PK_SPECIMEN_ANNOTATIONS
			PRIMARY KEY (ANNOTATION_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_SPECIMENANNO_CATITEM
			FOREIGN KEY (COLLECTION_OBJECT_ID)
			REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID)
) TABLESPACE UAM_DAT_1;