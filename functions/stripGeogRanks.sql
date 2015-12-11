CREATE OR REPLACE FUNCTION stripGeogRanks (term in varchar2)
	return varchar2 
	deterministic
	as
	terms_to_strip varchar2(4000);
	l_str    varchar2(4000);
	v_tab parse_list.varchar2_table;
    v_nfields integer;

begin
	terms_to_strip:= 'autonomous,ATOLL,';
	terms_to_strip:=terms_to_strip || 'Borough,';
	terms_to_strip:=terms_to_strip || 'Capitol,Community,county,City,CO,changwat,';
	terms_to_strip:=terms_to_strip || 'Departamento,DEPARTMENT,Depto,District,Dist,Del,De,di,';
	
	terms_to_strip:=terms_to_strip || 'FEDERAL,';
	terms_to_strip:=terms_to_strip || 'Governorate,';
	terms_to_strip:=terms_to_strip || 'Islands,Island,IAN,is,isl,';
	terms_to_strip:=terms_to_strip || 'Kabupaten,kray,KINGDOM,kraj,Kreis,';
	terms_to_strip:=terms_to_strip || 'La,LAND,';
	terms_to_strip:=terms_to_strip || 'Municipality,';
	terms_to_strip:=terms_to_strip || 'National,';
	terms_to_strip:=terms_to_strip || 'oblast,okrug,of,Okres,';
	terms_to_strip:=terms_to_strip || 'Parish,Prefecture,Pref,Province,Provincia,Provincia,Prov,';
	terms_to_strip:=terms_to_strip || 'Republic,REGION,REPUBBLICA,';
	terms_to_strip:=terms_to_strip || 'SOCIALIST,';
	
	terms_to_strip:=terms_to_strip || 'Territory,TERR,';
	
	terms_to_strip:=terms_to_strip || 'UNION,';
	terms_to_strip:=terms_to_strip || 'Ward,';
	
	
	 
				
	l_str:=	upper(term);
	l_str:=REGEXP_REPLACE(l_str,'\(.*\)','');
	l_str:=replace(l_str,'-',' ');
	l_str:=replace(l_str,'  ',' ');
	l_str:=trim(l_str);
	--dbms_output.put_line('start l_str ' || l_str);
	parse_list.delimstring_to_table (terms_to_strip, v_tab, v_nfields);
	for i in 1..v_nfields loop
		--dbms_output.put_line('stripping ' || upper(v_tab(i)));
 		--l_str:=replace(l_str,upper(v_tab(i)));
 		
		l_str:=REGEXP_REPLACE(l_str,'(^|\s|\W)' || trim(upper(v_tab(i))) || '($|\s|\W)',' ');
 		
                      
                      
	end loop;
	return trim(l_str);
	---dbms_output.put_line('final l_str ' || l_str);
  end;
/
sho err;


CREATE or replace PUBLIC SYNONYM stripGeogRanks FOR stripGeogRanks;
GRANT EXECUTE ON stripGeogRanks TO PUBLIC;


--select SEARCH_TERM ,stripGeogRanks(SEARCH_TERM) from geog_search_term where upper(SEARCH_TERM) like '%PROVINCE%';
-- select SEARCH_TERM ,stripGeogRanks(SEARCH_TERM) from geog_search_term order by SEARCH_TERM;