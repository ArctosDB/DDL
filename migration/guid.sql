ALTER TABLE collection ADD guid_prefix VARCHAR2(20);
UPDATE collection SET guid_prefix=institution_acronym || ':' || collection_cde;
ALTER TABLE collection MODIFY guid_prefix NOT NULL;

