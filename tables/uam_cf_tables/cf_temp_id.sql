CREATE TABLE CF_TEMP_ID (
    KEY NUMBER,
    COLLECTION_OBJECT_ID NUMBER,
	COLLECTION_CDE VARCHAR2(4),
	INSTITUTION_ACRONYM VARCHAR2(6),
	OTHER_ID_TYPE VARCHAR2(60),
	OTHER_ID_NUMBER VARCHAR2(60),
	SCIENTIFIC_NAME VARCHAR2(255),
	MADE_DATE DATE,
	NATURE_OF_ID VARCHAR2(30),
	ACCEPTED_FG NUMBER(1,0),
	IDENTIFICATION_REMARKS VARCHAR2(255),
	AGENT_1 VARCHAR2(60),
	AGENT_2 VARCHAR2(60),
	STATUS VARCHAR2(255),
	TAXON_NAME_ID NUMBER,
	TAXA_FORMULA VARCHAR2(10),
	AGENT_1_ID NUMBER,
	AGENT_2_ID NUMBER
) TABLESPACE UAM_DAT_1
;