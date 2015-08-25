SELECT MAX(DISP_ORDER) + 1 FROM cf_spec_res_cols;

INSERT INTO cf_spec_res_cols (
    CATEGORY,
    COLUMN_NAME,
    DISP_ORDER,
    SQL_ELEMENT
   ) VALUES (
   'curatorial',
   'collecting_event_id',
   1082,
   'flatTableName.collecting_event_id'
   );
   
ALTER TABLE cf_dataentry_settings ADD pickuse_eventid NUMBER(1) DEFAULT(1);
ALTER TABLE cf_dataentry_settings ADD pickuse_collectors NUMBER(1) DEFAULT(1);


ALTER TABLE flat ADD habitat_desc VARCHAR2(255);

UPDATE flat SET habitat_desc= (SELECT habitat_desc FROM collecting_event WHERE collecting_event.collecting_event_id=flat.collecting_event_id);

REBUILD UPDATE_FLAT
REBUILD filtered_flat

SELECT DISP_ORDER FROM cf_spec_res_cols WHERE column_name='habitat';

36

UPDATE cf_spec_res_cols SET DISP_ORDER=DISP_ORDER+1 WHERE DISP_ORDER > 36;


INSERT INTO cf_spec_res_cols (
    CATEGORY,
    COLUMN_NAME,
    DISP_ORDER,
    SQL_ELEMENT
   ) VALUES (
   'locality',
   'habitat_desc',
   37,
   'flatTableName.habitat_desc'
   );
   

/picks/CatalogedItemPickForDataEntry.cfm

/DataServices/SciNameCheck.cfm
/DataServices/geog_lookup.cfm


