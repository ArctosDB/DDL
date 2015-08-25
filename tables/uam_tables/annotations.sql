CREATE TABLE ANNOTATIONS (
    ANNOTATION_ID NUMBER NOT NULL ENABLE,
    ANNOTATE_DATE DATE DEFAULT SYSDATE NOT NULL ENABLE,
	CF_USERNAME VARCHAR2(255),
	COLLECTION_OBJECT_ID NUMBER,
	TAXON_NAME_ID NUMBER,
	PROJECT_ID NUMBER,
	PUBLICATION_ID NUMBER,
	ANNOTATION VARCHAR2(255) NOT NULL ENABLE,
	REVIEWER_AGENT_ID NUMBER,
	REVIEWED_FG NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,
	REVIEWER_COMMENT VARCHAR2(255),
    CONSTRAINT PK_ANNOTATIONS
        PRIMARY KEY (ANNOTATION_ID)
        USING INDEX TABLESPACE UAM_IDX_1  ENABLE,
    CONSTRAINT FK_ANNOTATIONS_CATITEM
        FOREIGN KEY (COLLECTION_OBJECT_ID)
        REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID)
        ON DELETE CASCADE ENABLE,
	CONSTRAINT FK_ANNOTATIONS_TAXONOMY
	    FOREIGN KEY (TAXON_NAME_ID)
		REFERENCES TAXONOMY (TAXON_NAME_ID)
		ON DELETE CASCADE ENABLE,
	CONSTRAINT FK_ANNOTATIONS_PROJECT
	    FOREIGN KEY (PROJECT_ID)
		REFERENCES PROJECT (PROJECT_ID)
		ON DELETE CASCADE ENABLE,
	CONSTRAINT FK_ANNOTATIONS_PUBLICATION
	    FOREIGN KEY (PUBLICATION_ID)
		REFERENCES PUBLICATION (PUBLICATION_ID)
		ON DELETE CASCADE ENABLE,
    CONSTRAINT FK_ANNOTATIONS_AGENT
        FOREIGN KEY (REVIEWER_AGENT_ID)
		REFERENCES AGENT (AGENT_ID)
		ON DELETE CASCADE ENABLE
) TABLESPACE UAM_DAT_1;

