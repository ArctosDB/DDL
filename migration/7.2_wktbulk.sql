alter table bulkloader add WKT_POLYGON CLOB;

-- update http://arctosdb.org/bulkloader/#fields

alter table bulkloader_stage add WKT_POLYGON CLOB;
alter table bulkloader_deletes add WKT_POLYGON CLOB;



CREATE OR REPLACE TRIGGER TD_BULKLOADER
AFTER DELETE ON BULKLOADER....