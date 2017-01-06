CREATE TABLE ATTRIBUTES (
	ATTRIBUTE_ID NUMBER NOT NULL,
	COLLECTION_OBJECT_ID NUMBER NOT NULL,
	DETERMINED_BY_AGENT_ID NUMBER NOT NULL,
	ATTRIBUTE_TYPE VARCHAR2(60) NOT NULL,
	ATTRIBUTE_VALUE VARCHAR2(255) NOT NULL,
	ATTRIBUTE_UNITS VARCHAR2(60),
	ATTRIBUTE_REMARK VARCHAR2(255),
	DETERMINED_DATE DATE,
	DETERMINATION_METHOD VARCHAR2(255),
		CONSTRAINT PK_ATTRIBUTES
		    PRIMARY KEY (ATTRIBUTE_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_ATTRIBUTES_AGENT
			FOREIGN KEY (DETERMINED_BY_AGENT_ID)
			REFERENCES AGENT (AGENT_ID),
		CONSTRAINT FK_ATTRIBUTES_CATITEM
			FOREIGN KEY (COLLECTION_OBJECT_ID)
			REFERENCES CATALOGED_ITEM (COLLECTION_OBJECT_ID)
) TABLESPACE UAM_DAT_1 ENABLE ROW MOVEMENT;

CREATE OR REPLACE TRIGGER TRG_ATTRIBUTES_fkct_UD
BEFORE UPDATE OR INSERT ON ATTRIBUTES
FOR EACH ROW declare
	c number;
BEGIN
	select /*+ RESULT_CACHE */ count(*) into c from ctattribute_type where attribute_type=:NEW.attribute_type;
    IF c = 0 THEN
    	raise_application_error(
        	-20001,
            :NEW.attribute_type || ' is not in the code table');
    END IF;
END;
/



ALTER TABLE ATTRIBUTES
ADD CONSTRAINT FK_ATTRIBUTE_CT_ATTR_TYPE
   FOREIGN KEY (ATTRIBUTE_TYPE)
   REFERENCES CTATTRIBUTE_TYPE (ATTRIBUTE_TYPE);