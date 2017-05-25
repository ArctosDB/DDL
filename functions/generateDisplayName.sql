CREATE OR REPLACE function generateDisplayName (v_cid in varchar2 )
return varchar2
AS
	-- stuff we need to generate a display name
	v_author_text varchar2(4000);
	v_nomenclatural_code varchar2(4000);
	v_infraspecific_author varchar2(4000);
	v_superkingdom varchar2(4000);
	v_kingdom varchar2(4000);
	v_subkingdom varchar2(4000);
	v_infrakingdom varchar2(4000);
	v_superphylum varchar2(4000);
	v_phylum varchar2(4000);
	v_subphylum varchar2(4000);
	v_subdivision varchar2(4000);
	v_infraphylum varchar2(4000);
	v_superclass varchar2(4000);
	v_class varchar2(4000);
	v_subclass varchar2(4000);
	v_infraclass varchar2(4000);
	v_hyperorder varchar2(4000);
	v_superorder varchar2(4000);
	v_order varchar2(4000);
	v_suborder varchar2(4000);
	v_infraorder varchar2(4000);
	v_hyporder varchar2(4000);
	v_subhyporder varchar2(4000);
	v_superfamily varchar2(4000);
	v_family varchar2(4000);
	v_subfamily varchar2(4000);
	v_supertribe varchar2(4000);
	v_tribe varchar2(4000);
	v_subtribe varchar2(4000);
	v_genus varchar2(4000);
	v_subgenus varchar2(4000);
	v_species varchar2(4000);
	v_subspecies varchar2(4000);
	v_forma varchar2(4000);
	v_variety varchar2(4000);
	v_scientific_name varchar2(4000);
	c number;
	v_fmttype varchar2(4000);
	rtn varchar2(4000);
	v_irank varchar2(4000);
	v_ssterm varchar2(4000);
	v_ssrank varchar2(4000);
BEGIN
	rtn:='';
	-- for most names, we'll get what we need from these
	-- make as few expensive queries as possible
	select
		getTaxonTerm(v_cid,'author_text'),
		getTaxonTerm(v_cid,'infraspecific_author'),
		getTaxonTerm(v_cid,'nomenclatural_code'),
		getTaxonTerm(v_cid,'kingdom'),
		getTaxonTerm(v_cid,'scientific_name'),
		getTaxonTerm(v_cid,'genus'),
		getTaxonTerm(v_cid,'species'),
		getTaxonTerm(v_cid,'subspecies'),
		getTaxonTerm(v_cid,'forma'),
		getTaxonTerm(v_cid,'variety')
	into
		v_author_text,
		v_infraspecific_author,
		v_nomenclatural_code,
		v_kingdom,
		v_scientific_name,
		v_genus,
		v_species,
		v_subspecies,
		v_forma,
		v_variety
	from
		dual;
		
		
	dbms_output.put_line('v_nomenclatural_code: ' || v_nomenclatural_code);
	if v_nomenclatural_code is not null then
		if v_nomenclatural_code='ICBN' then
			v_fmttype:='icbn';
		else
			v_fmttype:='iczn';
		end if;
	elsif v_kingdom is not null then
		if v_kingdom='Plantae' then
			v_fmttype:='icbn';
		else
			v_fmttype:='iczn';
		end if;
	else
		v_fmttype:='not_enough_info';
	end if;

	if v_fmttype='iczn' then
		if v_subspecies is not null then
 			rtn:= '<i>' || v_subspecies || '</i> ' || v_author_text;
 		elsif v_species is not null then
 			rtn:= '<i>' || v_species || '</i> ' || v_author_text;
 		elsif v_genus is not null then
 			rtn:= '<i>' || v_genus || '</i> ' || v_author_text;
 		elsif v_scientific_name is not null then
 			rtn:= v_scientific_name || ' ' || v_author_text;
 		else
 			-- try taxon_name.scientific_name
 			select 
 				count(distinct(taxon_name.taxon_name_id)) 
 			into 
 				c 
 			from 
 				taxon_name,
 				taxon_term 
 			where 
 				taxon_name.taxon_name_id=taxon_term.taxon_name_id and
 				taxon_term.classification_id=v_cid;
 			if c=1 then
 				select distinct
 					taxon_name.scientific_name
 				into 
 					rtn 
 				from 
 					taxon_name,
 					taxon_term 
 				where 
 					taxon_name.taxon_name_id=taxon_term.taxon_name_id and
 					taxon_term.classification_id=v_cid;
 			else
 				rtn:='not_enough_info';
 			end if;
 		end if;
 	elsif v_fmttype = 'icbn' then
 		-- see if we have any infraspecific stuff
		if v_subspecies is not null then
		
			--dbms_output.put_line('v_subspecies: ' || v_subspecies);
			v_ssterm:=trim(replace(v_subspecies,v_species));
			--dbms_output.put_line('v_ssterm: ' || v_ssterm);
			v_ssrank:='subsp.';
			v_ssterm:=trim(replace(v_ssterm,v_ssrank));
			--dbms_output.put_line('v_ssterm: ' || v_ssterm);
		elsif v_forma is not null then
			v_ssterm:=trim(replace(v_forma,v_species));
			v_ssrank:='forma';
			v_ssterm:=trim(replace(v_ssterm,v_ssrank));
		elsif v_variety is not null then
			v_ssterm:=trim(replace(v_variety,v_species));
			v_ssrank:='var.';
			v_ssterm:=trim(replace(v_ssterm,v_ssrank));
		end if;
		if v_ssterm is not null then
			rtn:='<i>' || v_species || '</i> ' || v_author_text || ' ' || v_ssrank || ' <i>' ||  v_ssterm || '</i>' || ' ' || v_infraspecific_author;
		elsif v_species is not null then
 			rtn:= '<i>' || v_species || '</i> ' || v_author_text;
 		elsif v_genus is not null then
 			rtn:= '<i>' || v_genus || '</i> ' || v_author_text;
 		elsif v_scientific_name is not null then
 			rtn:= v_scientific_name || ' ' || v_author_text;
 		else
 			-- try taxon_name.scientific_name
 			select count(distinct(taxon_name.taxon_name_id)) into c from taxon_name,taxon_term where taxon_name.taxon_name_id=taxon_term.taxon_name_id and
 				taxon_term.classification_id=v_cid;
 			if c=1 then
 				select distinct taxon_name.scientific_name into rtn from taxon_name,taxon_term where taxon_name.taxon_name_id=taxon_term.taxon_name_id and
 				taxon_term.classification_id=v_cid;
 			else
 				rtn:='not_enough_info';
 			end if;
 		end if;

 	else
 		rtn:='not_enough_info';
 	end if;

 	-- for testing only
 	if rtn is null then
 		rtn:='FAIL COULD NOT GENERATE';
 	end if;
 	-- end testing return something dealio
	rtn:=trim(rtn);
	rtn:=replace(rtn,' ,',',');
	rtn:=replace(rtn,'<i></i>','');
	rtn:=regexp_replace(rtn,'\s+',' ');
	

 	return rtn;

 end;
 /

 sho err;

--exec generateDisplayName ('1075055');

select generateDisplayName('8E59308D-D265-ADDC-46F4860E3027F9C1') from dual;
