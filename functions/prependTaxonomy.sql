CREATE OR REPLACE function prependTaxonomy (str in varchar2, newval in varchar2, italicize in number default 0, onlyIfNull in number default 0)
    return varchar2
    deterministic
    as
    rval   varchar2(4000);
    sepr varchar2(2);
    nval varchar2(4000);
    begin
	 	if str is not null and onlyIfNull=1 then
	 		return str;
	 	end if;
	 	sepr:=' ';
	 	if newval is null OR str is null then
	 		sepr:='';
	 	end if;
	    if italicize=1 and newval is not null then
	    	nval:='<i>' || trim(newval) || '</i>';
	    else
	    	nval:=trim(newval);
	    end if;
	    rval:= nval || sepr || trim(str);
	    rval:=replace(rval,'</i> <i>',' ');
	    rval:=replace(rval,' </i>','</i> ');
	    return rval;
    end;
    /