CREATE TABLE ctabundance(collection_cde VARCHAR2(5) NOT NULL, abundance varchar2(60) NOT NULL);
CREATE UNIQUE INDEX u_ctabundance ON ctabundance (collection_cde,abundance);
CREATE PUBLIC SYNONYM ctabundance FOR ctabundance;
GRANT SELECT ON ctabundance TO PUBLIC;
GRANT INSERT,UPDATE,DELETE ON ctabundance TO manage_codetables;