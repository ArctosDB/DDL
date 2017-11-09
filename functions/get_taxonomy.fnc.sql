CREATE OR REPLACE function get_taxonomy(collobjid IN number, rank in varchar2 )
    return varchar2
    as
        l_str  varchar2(4000);
        sep varchar2(20);
	begin
		for r in (
			select distinct 
				taxon_term.term  
			from 
				collection, 
				cataloged_item,
				identification, 
				identification_taxonomy, 
				taxon_term
			where 
				collection.collection_id=cataloged_item.collection_id and
				collection.PREFERRED_TAXONOMY_SOURCE=taxon_term.source and
				cataloged_item.collection_object_id=identification.collection_object_id and
				identification.identification_id = identification_taxonomy.identification_id AND
				identification_taxonomy.taxon_name_id = taxon_term.taxon_name_id AND
				collection.PREFERRED_TAXONOMY_SOURCE=taxon_term.source and
				identification.accepted_id_fg=1 AND
				taxon_term.term_type=rank and
				cataloged_item.collection_object_id = collobjid
		) loop
			l_str:=l_str || sep || r.term;
			sep:='; ';
		end loop;
	return l_str;
	
	EXCEPTION
	when TOO_MANY_ROWS then
		l_str := 'undefinable';
		return  l_str;
	when NO_DATA_FOUND then
		l_str := 'not recorded';
		return  l_str;
	when others then
		l_str := 'error!';
		return  trim(l_str);
  end;
 /
  --create public synonym get_taxonomy for get_taxonomy;
  --grant execute on get_taxonomy to public;

