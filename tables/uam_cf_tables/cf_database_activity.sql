CREATE TABLE CF_DATABASE_ACTIVITY (
	ACTIVITY_ID NUMBER NOT NULL,
	USER_ID NUMBER NOT NULL,
	DATE_STAMP DATE NOT NULL,
	SQL_STATEMENT VARCHAR2(4000)
) TABLESPACE UAM_DAT_1;