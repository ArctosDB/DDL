ALTER TABLE bulkloader DROP column DISPOSITION_REMARKS;
ALTER TABLE bulkloader DROP column CONDITION;
ALTER TABLE bulkloader DROP column COLL_OBJ_DISPOSITION;

-- rebuild bulkload.sql

-- rebuild functions/bulk_check_one.sql
-- rebuid procedures/bulkloader_check.sql
-- rebuid procedures/bulkloader_stage_check.sql
-- rebuild TRIGGER TD_BULKLOADER

-- AND ADD verbatim loclaity TO flat

ALTER TABLE flat ADD verbatim_locality VARCHAR2(4000);

UPDATE flat SET verbatim_locality = (SELECT verbatim_locality FROM collecting_event WHERE flat.collecting_event_id=collecting_event.collecting_event_id);

-- REBUILD UPDATE_FLAT

SELECT DISP_ORDER FROM cf_spec_res_cols WHERE COLUMN_NAME='spec_locality';

UPDATE cf_spec_res_cols SET DISP_ORDER=DISP_ORDER+1 WHERE DISP_ORDER > 42;

INSERT INTO cf_spec_res_cols (
    CATEGORY,
    COLUMN_NAME,
    DISP_ORDER,
    SQL_ELEMENT
   ) VALUES (
   'locality',
   'verbatim_locality',
   43,
   'flatTableName.verbatim_locality'
   );
 
 DELETE FROM cf_spec_res_cols WHERE COLUMN_NAME = 'coll_obj_disposition';
 