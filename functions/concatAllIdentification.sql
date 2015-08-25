CREATE OR REPLACE FUNCTION concatAllIdentification (p_key_val  in number, rfmt in varchar DEFAULT 'html')
return varchar2
as
l_str    varchar2(4000);
l_sep    varchar2(6);
temp varchar2(4000);
strlen number;
cursor cur is
    select 
    	SCIENTIFIC_NAME,
    	NATURE_OF_ID,
    	ACCEPTED_ID_FG,
    	MADE_DATE,
    	SHORT_CITATION,
    	identification.publication_id,
    	identification_remarks,
    	NVL (concatidagent(identification.identification_id),'not recorded') idby
    FROM
        identification,
        publication
    WHERE
        identification.publication_id=publication.publication_id (+) and 
        identification.collection_object_id=p_key_val
    ORDER BY
        ACCEPTED_ID_FG DESC,
        made_date;
begin
	if rfmt = 'html' then
	    FOR r IN cur loop
	        temp:='<i>' || r.scientific_name || '</i>';
	        IF r.accepted_id_fg=1 THEN
	            temp:=temp || ' (accepted ID)';
	        END IF;
	        temp:=temp || ' identified by ' || r.idby;
	        IF r.MADE_DATE IS NOT NULL THEN
	            temp:=temp || ' on ' || r.made_date;
	        END IF; 
	        IF r.SHORT_CITATION IS NOT NULL THEN
	            temp:=temp || ' <i>sensu</i> <a href="http://arctos.database.museum/publication/' || r.publication_id || '">' || r.SHORT_CITATION || '</a>';
	        END IF;
	        temp:=temp || '; method: ' || r.nature_of_id;
	         IF r.identification_remarks IS NOT NULL THEN
	            temp:=temp || ' Remark: ' || r.identification_remarks;
	        END IF;
	        strlen := nvl(length(temp) + length(l_str) + length(l_sep),0);       	
	        if strlen < 4000 then
	           	l_str:=l_str  || l_sep || temp;
	        else
	        	-- too long - see if we've been here already
	        	if l_str not like '%truncated%' then
	        		l_str:=l_str  || l_sep || ' - result truncated - see Arctos for full information.';
	        	end if;
	        end if;
	        l_sep:='<br>';
	    end loop;
	elsif rfmt = 'json' then
		l_str:='{"Records":[';
		FOR r IN cur loop
			temp:=temp || '{"scientific_name":"' || r.scientific_name || '",';
			temp:=temp || '"accepted_id_fg":"' || r.accepted_id_fg || '",';
			temp:=temp || '"identified_by":"' || r.idby || '",';
			temp:=temp || '"made_date":"' || r.made_date || '",';
			temp:=temp || '"sensu":"' || 'http://arctos.database.museum/publication/' || r.publication_id || '",';
			temp:=temp || '"nature_of_id":"' || r.nature_of_id || '",';
			temp:=temp || '"identification_remarks":"' || r.identification_remarks || '"}';
		end loop;
		l_str:=l_str || temp || ']}"';

	end if;
    return l_str;
end;
/
sho err;


create or replace public synonym concatAllIdentification for concatAllIdentification;
grant execute on concatAllIdentification to public;

