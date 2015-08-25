drop view tt;
drop public synonym tt;


create view tt as
select
identification.collection_object_id,
scientific_name taxa_term
from
identification
where accepted_id_fg=1
UNION
select
identification.collection_object_id,
full_taxon_name taxa_term
from
identification,
identification_taxonomy,
taxonomy
where
accepted_id_fg=1 AND
identification.identification_id = identification_taxonomy.identification_id AND
identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id
UNION
select
identification.collection_object_id,
common_name taxa_term
from
identification,
identification_taxonomy,
taxonomy,
common_name
where
accepted_id_fg=1 AND
identification.identification_id = identification_taxonomy.identification_id AND
identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id AND
taxonomy.taxon_name_id = common_name.taxon_name_id
;

create public synonym tt for tt;
grant select on tt to public;