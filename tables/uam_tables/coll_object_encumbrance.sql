CREATE TABLE COLL_OBJECT_ENCUMBRANCE (
	ENCUMBRANCE_ID NUMBER NOT NULL,
	COLLECTION_OBJECT_ID NUMBER NOT NULL,
		CONSTRAINT PK_COLL_OBJECT_ENCUMBRANCE
			PRIMARY KEY (ENCUMBRANCE_ID, COLLECTION_OBJECT_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_COLLOBJENC_COLLOBJECT
			FOREIGN KEY (COLLECTION_OBJECT_ID)
			REFERENCES COLL_OBJECT (COLLECTION_OBJECT_ID),
		CONSTRAINT FK_COLLOBJENC_ENCUMBRANCE
			FOREIGN KEY (ENCUMBRANCE_ID)
			REFERENCES ENCUMBRANCE (ENCUMBRANCE_ID)
) TABLESPACE UAM_DAT_1;
