/*
	Get taxon term, or a comma-delimited list of them, but a specimen's collection_object_id
	
	** IMPORTANT ** : this runs against accepted ID only
	
	Parameters
		cataloged_item.collection_object_id
		taxon_term.term_type
		
	Examples
		-- get taxon_status from flat
		select getTaxonTermBySpecimen(flat.collection_object_id,'taxon_status') from flat where ....;


 * 
 */

CREATE OR REPLACE function getTaxonTermBySpecimen (
  v_coid IN number,
  v_trmtyp in varchar2
)
return varchar2
as
  v_trm varchar2(4000);
  v_trm_sep varchar2(2);
  src collection.PREFERRED_TAXONOMY_SOURCE%type;
BEGIN
  select PREFERRED_TAXONOMY_SOURCE into src from collection,cataloged_item where collection.collection_id=cataloged_item.collection_id and cataloged_item.collection_object_id=v_coid;

  dbms_output.put_line(src);
for x in (
  select 
    term 
  into
    v_trm
  from 
    cataloged_item,
    identification,
    identification_taxonomy,
    taxon_term
  where
    cataloged_item.collection_object_id=identification.collection_object_id and
    identification.identification_id=identification_taxonomy.identification_id and
     identification.accepted_id_fg=1 and
    identification_taxonomy.taxon_name_id=taxon_term.taxon_name_id and
    taxon_term.source = src and
    taxon_term.term_type=v_trmtyp and
    cataloged_item.collection_object_id=v_coid
  ) loop
    dbms_output.put_line(x.term);
    v_trm := v_trm || v_trm_sep || x.term;
    v_trm_sep:=', ';
  end loop;

  return v_trm;
end;
/
sho err;


create or replace public synonym getTaxonTermBySpecimen for getTaxonTermBySpecimen;

grant execute on getTaxonTermBySpecimen to public;