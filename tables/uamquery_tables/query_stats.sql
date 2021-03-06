CREATE TABLE UAM_QUERY.QUERY_STATS (
    QUERY_ID NUMBER,
    QUERY_TYPE VARCHAR2(10),
    CREATE_DATE DATE,
    SUM_COUNT NUMBER,
    USERNAME VARCHAR2(30),
        CONSTRAINT PK_QUERY_STATS
            PRIMARY KEY (QUERY_ID)
            USING INDEX TABLESPACE UAM_IDX_1
) TABLESPACE UAM_DAT_1;
