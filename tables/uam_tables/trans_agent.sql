CREATE TABLE TRANS_AGENT (
	TRANS_AGENT_ID NUMBER NOT NULL,
	TRANSACTION_ID NUMBER NOT NULL,
	AGENT_ID NUMBER NOT NULL,
	TRANS_AGENT_ROLE VARCHAR2(60) NOT NULL,
		CONSTRAINT PK_TRANS_AGENT
			PRIMARY KEY (TRANS_AGENT_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_TRANSAGENT_AGENT
			FOREIGN KEY (AGENT_ID)
			REFERENCES AGENT (AGENT_ID),
		CONSTRAINT FK_TRANSAGENT_TRANS
			FOREIGN KEY (TRANSACTION_ID)
			REFERENCES TRANS (TRANSACTION_ID),
		CONSTRAINT FK_CCTTRANS_AGENT_ROLE
			FOREIGN KEY (TRANS_AGENT_ROLE)
			REFERENCES CTTRANS_AGENT_ROLE (TRANS_AGENT_ROLE)
) TABLESPACE UAM_DAT_1;
