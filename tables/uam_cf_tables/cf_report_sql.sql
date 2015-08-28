CREATE TABLE CF_REPORT_SQL (
	REPORT_ID NUMBER NOT NULL,
	REPORT_NAME VARCHAR2(38) NOT NULL,
	REPORT_TEMPLATE VARCHAR2(38) NOT NULL,
	SQL_TEXT VARCHAR2(4000),
	PRE_FUNCTION VARCHAR2(50),
	REPORT_FORMAT VARCHAR2(50) DEFAULT 'PDF' NOT NULL,
		CONSTRAINT PK_CF_REPORT_SQL
			PRIMARY KEY (REPORT_ID)
			USING INDEX TABLESPACE UAM_IDX_1
) TABLESPACE UAM_DAT_1;