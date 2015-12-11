CREATE TABLE COLL_OBJ_OTHER_ID_NUM (
	COLLECTION_OBJECT_ID NUMBER NOT NULL,
	OTHER_ID_TYPE VARCHAR2(75) NOT NULL,
	OTHER_ID_PREFIX VARCHAR2(60),
	OTHER_ID_NUMBER NUMBER,
	OTHER_ID_SUFFIX VARCHAR2(60),
	DISPLAY_VALUE VARCHAR2(255) NOT NULL,
	COLL_OBJ_OTHER_ID_NUM_ID NUMBER NOT NULL,
		CONSTRAINT PK_COLL_OBJ_OTHER_ID_NUM
			PRIMARY KEY (COLL_OBJ_OTHER_ID_NUM_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_COLLOBJOTHERIDNUM_CATITEM
			FOREIGN KEY (COLLECTION_OBJECT_ID)
			REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID),
		CONSTRAINT FK_CTCOLL_OTHER_ID_TYPE
			FOREIGN KEY (OTHER_ID_TYPE)
			REFERENCES CTCOLL_OTHER_ID_TYPE (OTHER_ID_TYPE)
) TABLESPACE UAM_DAT_1;



select dbms_metadata.get_ddl('TABLE','COLL_OBJ_OTHER_ID_NUM') from dual;
