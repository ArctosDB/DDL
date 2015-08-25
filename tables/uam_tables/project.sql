CREATE TABLE PROJECT (
	PROJECT_ID NUMBER NOT NULL,
	START_DATE DATE,
	END_DATE DATE,
	PROJECT_NAME VARCHAR2(255) NOT NULL,
	PROJECT_DESCRIPTION VARCHAR2(4000),
	PROJECT_REMARKS VARCHAR2(4000),
		CONSTRAINT PK_PROJECT
			PRIMARY KEY (PROJECT_ID)
			USING INDEX TABLESPACE UAM_IDX_1
) TABLESPACE UAM_DAT_1;
