CREATE TABLE CF_BUGS (
	BUG_ID NUMBER NOT NULL,
	USER_ID NUMBER,
	REPORTED_NAME VARCHAR2(255),
	FORM_NAME VARCHAR2(4000),
	COMPLAINT VARCHAR2(4000),
	SUGGESTED_SOLUTION VARCHAR2(4000),
	ADMIN_SOLUTION VARCHAR2(4000),
	USER_PRIORITY NUMBER,
	ADMIN_PRIORITY NUMBER,
	USER_REMARKS VARCHAR2(4000),
	ADMIN_REMARKS VARCHAR2(4000),
	SOLVED_FG NUMBER(1,0),
	USER_EMAIL VARCHAR2(255),
	SUBMISSION_DATE DATE,
		CONSTRAINT PK_CF_BUGS
			PRIMARY KEY (BUG_ID)
			USING INDEX TABLESPACE UAM_IDX_1
) TABLESPACE UAM_DAT_1;
