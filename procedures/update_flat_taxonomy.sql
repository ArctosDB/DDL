
CREATE OR REPLACE PROCEDURE "UAM"."UPDATE_FLAT_TAXONOMY" is
BEGIN
-- just get rid of anything that's not a collection's preferred source
delete from taxon_term_updated where source not in (select PREFERRED_TAXONOMY_SOURCE from collection);
-- and get rid of anything that's not a column in FLAT
delete from taxon_term_updated where upper(term_type) not in (
'KINDGOM',
'PHYLUM',
'PHYLCLASS',
'PHYLORDER',
'FAMILY',
'SUBFAMILY',
'TRIBE',
'SUBTRIBE',
'GENUS',
'SPECIES',
'SUBSPECIES',
'AUTHOR_TEXT',
'NOMENCLATURAL_CODE',
'INFRASPECIFIC_RANK',
'DISPLAY_NAME',
'INFRASPECIFIC_AUTHOR'
);
-- delete anything that's not used for identifications
delete from taxon_term_updated where taxon_name_id not in (select taxon_name_id from identification_taxonomy);
-- and refresh flat for whatever's left
update flat set stale_flag=1 where collection_object_id in (
select
identification.collection_object_id
from
identification,
identification_taxonomy,
taxon_term_updated
where
identification.identification_id=identification_taxonomy.identification_id and
identification_taxonomy.taxon_name_id=taxon_term_updated.taxon_name_id and
identification.accepted_id_fg=1
);
--- and clean out the temp table; we're done here
delete from taxon_term_updated;
end;


