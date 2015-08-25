CREATE TABLE GREF_REFSET_NG (
    ID NUMBER NOT NULL,
    TITLE VARCHAR2(4000 CHAR),
    PAGE_ID NUMBER,
        CONSTRAINT PK_GREF_REFSET_NG
            PRIMARY KEY (ID)
            USING INDEX TABLESPACE UAM_IDX_1,
        CONSTRAINT FK_REFSETNG_PAGE
            FOREIGN KEY (PAGE_ID)
            REFERENCES PAGE (PAGE_ID)
) TABLESPACE UAM_DAT_1;
