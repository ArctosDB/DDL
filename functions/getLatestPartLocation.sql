CREATE OR REPLACE FUNCTION getLatestPartLocation(cid IN number)
 -- grab the latest part location for each part
 -- for UAM:EH; may not make much sense in other contexts
RETURN varchar2
AS
  ret varchar2(4000);
  s varchar2(10);
begin
	for r in (select part_name,COLLECTION_OBJECT_ID from specimen_part where specimen_part.derived_from_cat_item=cid) loop
		dbms_output.put_line(r.part_name);
		for a in (
			SELECT ATTRIBUTE_VALUE FROM (
    			select 
      				rownum as rnum, 
      				ATTRIBUTE_VALUE,
      				DETERMINED_DATE 
    			FROM 
       				specimen_part_attribute
    			where
      				specimen_part_attribute.COLLECTION_OBJECT_ID=r.COLLECTION_OBJECT_ID and
     				specimen_part_attribute.ATTRIBUTE_TYPE='location'
				ORDER BY 
					DETERMINED_DATE DESC
			)
 			WHERE rnum = 1
		) loop
			dbms_output.put_line(a.ATTRIBUTE_VALUE);
			ret:=ret||s||r.part_name || ':' || a.ATTRIBUTE_VALUE;
			s:=';';
		end loop;
	end loop;
	return ret;
end;
/
sho err;

CREATE or replace PUBLIC SYNONYM getLatestPartLocation FOR getLatestPartLocation;
GRANT EXECUTE ON getLatestPartLocation TO PUBLIC;