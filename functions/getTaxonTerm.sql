CREATE OR REPLACE function getTaxonTerm (v_cid in varchar2,v_rank in varchar2)
return varchar2
as
	v_trm varchar2(4000);
BEGIN
	select NVL(max(term),null) into v_trm from taxon_term where term_type=v_rank and classification_id=v_cid;
	return v_trm;
end;
/
sho err;

create or replace public synonym getTaxonTerm for getTaxonTerm;
grant execute on getTaxonTerm to public;