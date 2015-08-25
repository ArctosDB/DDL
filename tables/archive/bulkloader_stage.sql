DROP TABLE bulkloader_stage;
CREATE TABLE bulkloader_stage AS SELECT * FROM bulkloader WHERE 1 = 2;
DROP PUBLIC SYNONYM bulkloader_stage;
CREATE PUBLIC SYNONYM bulkloader_stage FOR bulkloader_stage;
GRANT INSERT, UPDATE, DELETE, SELECT ON bulkloader_stage TO uam_query;
