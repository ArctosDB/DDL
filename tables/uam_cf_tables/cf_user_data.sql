CREATE TABLE CF_USER_DATA (
	USER_ID NUMBER NOT NULL,
	FIRST_NAME VARCHAR2(60) NOT NULL,
	MIDDLE_NAME VARCHAR2(60),
	LAST_NAME VARCHAR2(60) NOT NULL,
	AFFILIATION VARCHAR2(255) NOT NULL,
	EMAIL VARCHAR2(255)
) TABLESPACE UAM_DAT_1;
