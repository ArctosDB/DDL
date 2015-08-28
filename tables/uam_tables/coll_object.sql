CREATE TABLE COLL_OBJECT (
	COLLECTION_OBJECT_ID NUMBER NOT NULL,
	COLL_OBJECT_TYPE CHAR(2) NOT NULL,
	ENTERED_PERSON_ID NUMBER NOT NULL,
	COLL_OBJECT_ENTERED_DATE DATE NOT NULL,
	LAST_EDITED_PERSON_ID NUMBER,
	LAST_EDIT_DATE DATE,
	COLL_OBJ_DISPOSITION VARCHAR2(20) NOT NULL,
	LOT_COUNT NUMBER NOT NULL,
	CONDITION VARCHAR2(255) NOT NULL,
	FLAGS VARCHAR2(20),
		CONSTRAINT PK_COLL_OBJECT
			PRIMARY KEY (COLLECTION_OBJECT_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_COLLOBJECT_AGENT_EDITED
			FOREIGN KEY (LAST_EDITED_PERSON_ID)
			REFERENCES AGENT (AGENT_ID),
		CONSTRAINT FK_COLLOBJECT_AGENT_ENTERED
			FOREIGN KEY (ENTERED_PERSON_ID)
			REFERENCES AGENT (AGENT_ID),
		CONSTRAINT FK_CTCOLL_OBJECT_TYPE
			FOREIGN KEY (COLL_OBJECT_TYPE)
			REFERENCES CTCOLL_OBJECT_TYPE (COLL_OBJECT_TYPE),
		CONSTRAINT FK_CTCOLL_OBJ_DISP
			FOREIGN KEY (COLL_OBJ_DISPOSITION)
			REFERENCES CTCOLL_OBJ_DISP (COLL_OBJ_DISPOSITION),
		CONSTRAINT FK_CTFLAGS
			FOREIGN KEY (FLAGS)
			REFERENCES CTFLAGS (FLAGS)
) TABLESPACE UAM_DAT_1 ENABLE ROW MOVEMENT;