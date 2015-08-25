-- function to concatenate details of a single attribute
-- Pass in 1 for forceEncumbrance to force the function to consider attributes, regardless of current user
-- eg, return encumbered records __AS UAM__ for eg, the purposes of maintaining filtered_flat
CREATE OR REPLACE FUNCTION CONCATATTRIBUTEDETAIL (cid in varchar2,attribute in varchar2,forceEncumbrance in number default null)
return varchar2 as
	l_str    varchar2(4000);
	l_sep    varchar2(30);
	l_val    varchar2(4000);
	is_encumbered number := 0;
	is_operator number;
begin
	for r in (select attribute_detail,is_encumbered from v_attributes where collection_object_id=cid and ATTRIBUTE_TYPE=attribute) loop
		is_encumbered := is_encumbered + r.is_encumbered;
		l_str := l_str || l_sep || r.attribute_detail;
		l_sep := '; ';
	end loop;
	if is_encumbered > 0 then
		if forceEncumbrance is null then
			select count(*) into is_operator from dba_role_privs where GRANTED_ROLE='COLDFUSION_USER' AND GRANTEE=sys_context('USERENV', 'SESSION_USER');
		else
			is_operator:=0;
		end if;		
		IF is_operator=0 THEN
			l_str := attribute || '=MASKED';
		end if;
	end if;
	return l_str;
  end;
/