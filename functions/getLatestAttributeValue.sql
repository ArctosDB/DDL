/*
 	old
 		drop public synonym getLatestSex;
		drop function getLatestSex;
		
	new
		find and return most recent attribute (and units if relevant) by attribute date.
		
		accepts: cataloged_item.collection_object_id, attribute_type
		
		examples:
		
		
			UAM@ARCTOS> select getLatestAttributeValue(flat.collection_object_id,'weight') lwt from flat where guid='MSB:Mamm:300271';
			
			LWT
			------------------------------------------------------------------------------------------------------------------------
			111 g
			
			1 row selected.
			
			Elapsed: 00:00:00.03
			UAM@ARCTOS> select getLatestAttributeValue(flat.collection_object_id,'sex') lsex from flat where guid='MSB:Mamm:300271';
			
			LSEX
			------------------------------------------------------------------------------------------------------------------------
			male
			
			1 row selected.


 */: 


-- return the sex determination with the most recent attribute date
CREATE  or replace FUNCTION getLatestAttributeValue ( collobjid in integer, atyp in varchar2 )
	return varchar2
as
	result varchar2(4000);
begin
	select 
	  attr into result
	from (
	    select 
	      trim(attribute_value || ' ' || attribute_units) attr 
	    from 
	      attributes  
	    where 
	      attributes.collection_object_id=collobjid and 
	      ATTRIBUTE_TYPE=atyp and 
	      DETERMINED_DATE=(
	        select 
	          max(DETERMINED_DATE) 
	        from 
	          attributes 
	        where 
	          ATTRIBUTE_TYPE=atyp and 
	          attributes.collection_object_id=collobjid
	      )
	    ) 
	where rownum=1;
	return result;	
end;
/
sho err;


CREATE or replace PUBLIC SYNONYM getLatestAttributeValue FOR getLatestAttributeValue;
GRANT EXECUTE ON getLatestAttributeValue TO PUBLIC;
