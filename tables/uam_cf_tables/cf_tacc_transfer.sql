CREATE TABLE CF_TACC_TRANSFER (
	MEDIA_ID NUMBER,
	SDATE DATE,
	LOCAL_URI VARCHAR2(4000),
	REMOTE_URI VARCHAR2(4000),
	LOCAL_HASH VARCHAR2(255),
	REMOTE_HASH VARCHAR2(255),
	LOCAL_TN VARCHAR2(4000),
	REMOTE_TN VARCHAR2(4000),
	LOCAL_TN_HASH VARCHAR2(255),
	REMOTE_TN_HASH VARCHAR2(255),
	STATUS VARCHAR2(255),
	REMOTEDIRECTORY VARCHAR2(30),
		CONSTRAINT PK_CF_TACC_TRANSFER
			PRIMARY KEY (MEDIA_ID)
			USING INDEX TABLESPACE UAM_IDX_1
) TABLESPACE UAM_DAT_1;
