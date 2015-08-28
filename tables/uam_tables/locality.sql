CREATE TABLE LOCALITY (
	LOCALITY_ID NUMBER NOT NULL,
	GEOG_AUTH_REC_ID NUMBER NOT NULL,
	MAXIMUM_ELEVATION NUMBER,
	MINIMUM_ELEVATION NUMBER,
	ORIG_ELEV_UNITS VARCHAR2(2),
	TOWNSHIP NUMBER,
	TOWNSHIP_DIRECTION CHAR(1),
	RANGE NUMBER,
	RANGE_DIRECTION CHAR(1),
	SECTION NUMBER,
	SECTION_PART VARCHAR2(25),
	SPEC_LOCALITY VARCHAR2(255),
	LOCALITY_REMARKS VARCHAR2(255),
	LEGACY_SPEC_LOCALITY_FG NUMBER,
	DEPTH_UNITS VARCHAR2(20),
	MIN_DEPTH NUMBER,
	MAX_DEPTH NUMBER,
	NOGEOREFBECAUSE VARCHAR2(255),
        CONSTRAINT MIN_MORE_MAX_ELEV
            CHECK (MINIMUM_ELEVATION <= MAXIMUM_ELEVATION),
        CONSTRAINT MIN_MORE_MAX_DEPTH
            CHECK (MIN_DEPTH <= MAX_DEPTH),
		CONSTRAINT PK_LOCALITY
		    PRIMARY KEY (LOCALITY_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_LOCALITY_GEOGAUTHREC
			FOREIGN KEY (GEOG_AUTH_REC_ID)
			REFERENCES GEOG_AUTH_REC (GEOG_AUTH_REC_ID),
		CONSTRAINT FK_CTDEPTH_UNITS
			FOREIGN KEY (DEPTH_UNITS)
			REFERENCES CTDEPTH_UNITS (DEPTH_UNITS),
		CONSTRAINT FK_CTORIG_ELEV_UNITS
			FOREIGN KEY (ORIG_ELEV_UNITS)
			REFERENCES CTORIG_ELEV_UNITS (ORIG_ELEV_UNITS)
) TABLESPACE UAM_DAT_1;