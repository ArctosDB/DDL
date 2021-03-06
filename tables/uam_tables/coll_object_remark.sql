CREATE TABLE COLL_OBJECT_REMARK (
	COLLECTION_OBJECT_ID NUMBER NOT NULL,
	DISPOSITION_REMARKS VARCHAR2(255),
	COLL_OBJECT_REMARKS VARCHAR2(4000),
	HABITAT VARCHAR2(4000),
	ASSOCIATED_SPECIES VARCHAR2(4000),
		CONSTRAINT PK_COLL_OBJECT_REMARK
			PRIMARY KEY (COLLECTION_OBJECT_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_COLLOBJREM_COLLOBJECT
			FOREIGN KEY (COLLECTION_OBJECT_ID)
			REFERENCES COLL_OBJECT (COLLECTION_OBJECT_ID) ON DELETE CASCADE
) TABLESPACE UAM_DAT_1;
