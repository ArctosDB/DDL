CREATE OR REPLACE FUNCTION concat_ss_typestatus (colobjod in NUMBER, tsl in varchar2 )
	return varchar2
	
	-- function concat_ss_typestatus - the ss is for short and sweet, not some crazy thing.
	-- accepts:
	--  specimen.collection_object_id
	--  comma-separated list of type statuses
	
	-- returns
	-- comma-separated list of bare "typestatus"
	AS
		result varchar2(4000);
		tresult varchar2(4000);
		sep varchar2(2) :='';
		s varchar2(4000);
	BEGIN
		
		s:=tsl;
		dbms_output.put_line(s);
		
		
		
		FOR r IN (
			SELECT 
				type_status
			FROM
				citation,
				identification
			WHERE
				citation.identification_id=identification.identification_id AND
				citation.collection_object_id=colobjod and
				citation.type_status in (
          			select regexp_substr(tsl,'[^,]+', 1, level) from dual
					connect by regexp_substr(tsl, '[^,]+', 1, level) is not null 
        		 )
        	GROUP BY
        		type_status
		) LOOP
			tresult:=r.type_status;
			result:=result || sep || tresult;
			sep:=', ';      
		END LOOP;
		RETURN result;
	END;
/


create public synonym concat_ss_typestatus for concat_ss_typestatus;
grant execute on concat_ss_typestatus to public;
                        
                        

select concat_ss_typestatus(21619993,'holotype,lectotype') from dual;
