CREATE TABLE CF_COLLECTION_APPEARANCE (
	COLLECTION_ID NUMBER NOT NULL,
	HEADER_COLOR VARCHAR2(20) NOT NULL,
	HEADER_IMAGE VARCHAR2(255) NOT NULL,
	COLLECTION_URL VARCHAR2(255) NOT NULL,
	COLLECTION_LINK_TEXT VARCHAR2(60) NOT NULL,
	INSTITUTION_URL VARCHAR2(255) NOT NULL,
	INSTITUTION_LINK_TEXT VARCHAR2(60) NOT NULL,
	META_DESCRIPTION VARCHAR2(255) NOT NULL,
	META_KEYWORDS VARCHAR2(255) NOT NULL,
	STYLESHEET VARCHAR2(60) NOT NULL,
	HEADER_CREDIT VARCHAR2(255),
        CONSTRAINT FK_CFCOLLAPPEARANCE_COLLECTION
            FOREIGN KEY (COLLECTION_ID)
            REFERENCES COLLECTION (COLLECTION_ID)
) TABLESPACE UAM_DAT_1;