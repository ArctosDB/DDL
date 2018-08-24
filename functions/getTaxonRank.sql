/*
 Attempt to get DWC:taxonRank (http://rs.tdwg.org/dwc/terms/taxonRank) for iDigBio
 Ignore:
 	scientific_name, which should always be a replication of the lowest classification term (which is not necessarily ranked)
 	display_name, which is sometimes a replication of the lowest classification term (which is not necessarily ranked)
 	
 Match:
 	exact ID string <--> taxon_term.term
 
 */

CREATE OR REPLACE function getTaxonRank(collobjid IN number)
    return varchar2
    as
    tterm  varchar2(4000);
  begin
	select
		taxon_term.term_type
	into
		tterm
	from
		taxon_term,
		identification,
		identification_taxonomy,
		collection,
		cataloged_item
	where
		taxon_term.term=replace(replace(replace(replace(replace(identification.scientific_name,' sp.'),' ssp.'),' ?'),' aff.'),' cf.') and
		taxon_term.source=collection.PREFERRED_TAXONOMY_SOURCE and
		identification.identification_id=identification_taxonomy.identification_id and
		identification_taxonomy.taxon_name_id=taxon_term.taxon_name_id and
		cataloged_item.collection_id=collection.collection_id and
		cataloged_item.collection_object_id=identification.collection_object_id and
		identification.accepted_id_fg=1 and
		taxon_term.term_type != 'scientific_name' and
		taxon_term.term_type != 'display_name' and
		taxon_term.POSITION_IN_CLASSIFICATION is not null and
		cataloged_item.collection_object_id = collobjid
	;
    return tterm;
    EXCEPTION
    	when others then
        	--tterm := 'error!: ' || sqlerrm;
        	--return trim(tterm);
        	return NULL;
  end;
 /

 
 
CREATE or replace PUBLIC SYNONYM getTaxonRank FOR getTaxonRank;
GRANT EXECUTE ON getTaxonRank TO PUBLIC;
