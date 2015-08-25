CREATE TABLE AGENT_RANK (
	AGENT_RANK_ID NUMBER NOT NULL,
	AGENT_ID NUMBER NOT NULL,
	AGENT_RANK VARCHAR2(50) NOT NULL,
	RANKED_BY_AGENT_ID NUMBER NOT NULL,
	REMARK VARCHAR2(255),
	TRANSACTION_TYPE VARCHAR2(18) NOT NULL,
	RANK_DATE DATE DEFAULT SYSDATE NOT NULL,
        CONSTRAINT PK_AGENT_RANK
            PRIMARY KEY (AGENT_RANK_ID)
            USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_AR_TRANSTYPE
			FOREIGN KEY (TRANSACTION_TYPE)
			REFERENCES CTTRANSACTION_TYPE (TRANSACTION_TYPE),
		CONSTRAINT FK_CTAGENT_RANK
			FOREIGN KEY (AGENT_RANK)
			REFERENCES CTAGENT_RANK (AGENT_RANK),
		CONSTRAINT FK_AR_AGENT_ID
			FOREIGN KEY (AGENT_ID)
			REFERENCES AGENT (AGENT_ID),
		CONSTRAINT FK_AR_RANKER_AGENT_ID
			FOREIGN KEY (RANKED_BY_AGENT_ID)
			REFERENCES AGENT (AGENT_ID)
) TABLESPACE UAM_DAT_1;
