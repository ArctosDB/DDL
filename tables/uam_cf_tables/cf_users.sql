CREATE TABLE CF_USERS (
	USERNAME VARCHAR2(30) NOT NULL,
	PASSWORD VARCHAR2(255) NOT NULL,
	TARGET VARCHAR2(10),
	DISPLAYROWS NUMBER,
	MAPSIZE VARCHAR2(255),
	PARTS NUMBER(1,0),
	ACCN_NUM NUMBER(1,0),
	HIGHER_TAXA NUMBER(1,0),
	AF_NUM NUMBER(1,0),
	RIGHTS VARCHAR2(255),
	USER_ID NUMBER NOT NULL,
	ACTIVE_LOAN_ID NUMBER,
	COLLECTION VARCHAR2(255),
	IMAGES NUMBER(1,0),
	PERMIT NUMBER(1,0),
	CITATION NUMBER(1,0),
	PROJECT NUMBER(1,0),
	PRESMETH NUMBER(1,0),
	ATTRIBUTES NUMBER(1,0),
	COLLS NUMBER(1,0),
	PHYLCLASS NUMBER(1,0),
	SCINAMEOPERATOR NUMBER(1,0),
	DATES NUMBER(1,0),
	DETAIL_LEVEL NUMBER(1,0),
	COLL_ROLE NUMBER(1,0),
	CURATORIAL_STUFF NUMBER(1,0),
	IDENTIFIER NUMBER(1,0),
	BOUNDINGBOX NUMBER(1,0),
	KILLROW NUMBER(1,0),
	APPROVED_TO_REQUEST_LOANS NUMBER(1,0),
	BIGSEARCHBOX NUMBER(1,0),
	COLLECTING_SOURCE NUMBER(1,0),
	SCIENTIFIC_NAME NUMBER(1,0),
	CUSTOMOTHERIDENTIFIER VARCHAR2(255),
	CHRONOLOGICAL_EXTENT NUMBER(1,0),
	MAX_ERROR_IN_METERS NUMBER(1,0),
	SHOWOBSERVATIONS NUMBER(1,0),
	COLLECTION_IDS VARCHAR2(255),
	EXCLUSIVE_COLLECTION_ID NUMBER,
	LOAN_REQUEST_COLL_ID VARCHAR2(255),
	MISCELLANEOUS NUMBER(1,0),
	LOCALITY NUMBER(1,0),
	RESULTCOLUMNLIST VARCHAR2(4000),
	PW_CHANGE_DATE DATE NOT NULL,
	LAST_LOGIN DATE,
	SPECSRCHPREFS VARCHAR2(4000),
	FANCYCOID NUMBER(1,0),
	RESULT_SORT VARCHAR2(255),
	LOCSRCHPREFS VARCHAR2(4000),
		CONSTRAINT PK_CF_USERS
			PRIMARY KEY (USER_ID)
			USING INDEX TABLESPACE UAM_IDX_1
) TABLESPACE UAM_DAT_1;
