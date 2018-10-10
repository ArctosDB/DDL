-- for https://github.com/ArctosDB/arctos/issues/1692
-- no version required; back-end only

alter table media_relations add created_on_date date;
alter table media_labels add assigned_on_date date;

CREATE OR REPLACE TRIGGER TR_MEDIA_LABELS_SQ...
CREATE OR REPLACE TRIGGER TR_MEDIA_RELATIONS_SQ....