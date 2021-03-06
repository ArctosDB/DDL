CREATE TABLE MEDIA_LABELS (
	MEDIA_LABEL_ID NUMBER NOT NULL,
	MEDIA_ID NUMBER NOT NULL,
	MEDIA_LABEL VARCHAR2(255) NOT NULL,
	LABEL_VALUE VARCHAR2(255) NOT NULL,
	ASSIGNED_BY_AGENT_ID NUMBER NOT NULL,
		CONSTRAINT PK_MEDIA_LABELS
			PRIMARY KEY (MEDIA_LABEL_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_MEDIALABELS_AGENT
			FOREIGN KEY (ASSIGNED_BY_AGENT_ID)
			REFERENCES AGENT (AGENT_ID),
		CONSTRAINT FK_MEDIALABELS_MEDIA
			FOREIGN KEY (MEDIA_ID)
			REFERENCES MEDIA (MEDIA_ID),
		CONSTRAINT FK_CTMEDIA_LABEL
			FOREIGN KEY (MEDIA_LABEL)
			REFERENCES CTMEDIA_LABEL (MEDIA_LABEL)
) TABLESPACE UAM_DAT_1;
