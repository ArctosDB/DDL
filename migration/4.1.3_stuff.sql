select * FROM cf_spec_res_cols WHERE column_name='family';

UPDATE cf_spec_res_cols SET DISP_ORDER=DISP_ORDER+1 WHERE DISP_ORDER > 13;


INSERT INTO cf_spec_res_cols (
    CATEGORY,
    COLUMN_NAME,
    DISP_ORDER,
    SQL_ELEMENT
   ) VALUES (
   'specimen',
   'phylclass',
   14,
   'get_taxonomy(cataloged_item.collection_object_id,''phylclass'')'
   );
   
select * FROM cf_spec_res_cols WHERE column_name='verbatim_locality';

UPDATE cf_spec_res_cols SET DISP_ORDER=DISP_ORDER+1 WHERE DISP_ORDER > 45;

INSERT INTO cf_spec_res_cols (
    CATEGORY,
    COLUMN_NAME,
    DISP_ORDER,
    SQL_ELEMENT
   ) VALUES (
   'specimen',
   'collecting_method',
   46,
   'flatTableName.collecting_method'
);

select * FROM cf_spec_res_cols WHERE column_name='id_sensu';

UPDATE cf_spec_res_cols SET DISP_ORDER=DISP_ORDER+1 WHERE DISP_ORDER > 7;

INSERT INTO cf_spec_res_cols (
    CATEGORY,
    COLUMN_NAME,
    DISP_ORDER,
    SQL_ELEMENT
   ) VALUES (
   'specimen',
   'id_date',
   8,
   'flatTableName.made_date'
);

select * FROM cf_spec_res_cols WHERE column_name='othercatalognumbers';
16

UPDATE cf_spec_res_cols SET DISP_ORDER=DISP_ORDER+1 WHERE DISP_ORDER > 16;


INSERT INTO cf_spec_res_cols (
    CATEGORY,
    COLUMN_NAME,
    DISP_ORDER,
    SQL_ELEMENT
   ) VALUES (
   'specimen',
   'relatedcatalogeditems',
   17,
   'flatTableName.relatedcatalogeditems'
);
