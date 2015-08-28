CREATE TABLE CF_CANNED_SEARCH (
	CANNED_ID NUMBER NOT NULL,
	USER_ID NUMBER NOT NULL,
	SEARCH_NAME VARCHAR2(60) NOT NULL,
	URL VARCHAR2(4000) NOT NULL,
		CONSTRAINT PK_CF_CANNED_SEARCH
			PRIMARY KEY (CANNED_ID)
			USING INDEX TABLESPACE UAM_IDX_1
) TABLESPACE UAM_DAT_1;