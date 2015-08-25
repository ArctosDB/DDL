CREATE TABLE CORRESPONDENCE (
	CORRESPONDENCE_ID NUMBER(38,0) NOT NULL,
	CORRESPONDENCE_TYPE NUMBER(25,0) NOT NULL,
	FROM_AGENT_ADDR_ID NUMBER(15,0),
	TO_AGENT_ADDR_ID NUMBER(15,0),
	WRITTEN_DATE DATE,
	FOLDER_LABEL VARCHAR2(40),
	FILED_UNDER_NAME VARCHAR2(120) NOT NULL,
	CORRESPONDENCE_REMARKS VARCHAR2(255)
        CONSTRAINT PK_CORRESPONDENCE
            PRIMARY KEY (CORRESPONDENCE_ID)
            USING INDEX TABLESPACE UAM_IDX_1
) TABLESPACE UAM_DAT_1;
