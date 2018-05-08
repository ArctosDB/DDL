-- return the sex determination with the most recent attribute date
CREATE  or replace FUNCTION getLatestSex ( collobjid in integer )
	return varchar2
as
	result varchar2(4000);
begin
	select 
	  attribute_value into result
	from (
	    select 
	      attribute_value 
	    from 
	      attributes  
	    where 
	      attributes.collection_object_id=collobjid and 
	      ATTRIBUTE_TYPE='sex' and 
	      DETERMINED_DATE=(
	        select 
	          max(DETERMINED_DATE) 
	        from 
	          attributes 
	        where 
	          ATTRIBUTE_TYPE='sex' and 
	          attributes.collection_object_id=collobjid
	      )
	    ) 
	where rownum=1;
	return result;	
end;
/
sho err;


CREATE or replace PUBLIC SYNONYM getLatestSex FOR getLatestSex;
GRANT EXECUTE ON getLatestSex TO PUBLIC;
