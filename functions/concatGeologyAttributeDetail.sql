CREATE OR REPLACE function concatGeologyAttributeDetail(locid  in number )
    return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
       l_sep    varchar2(30);
       l_val    varchar2(4000);
/*
	returns a pipe-delimited list of geology attribute determinations
	
	IMPORTANT: this is used to find and merge duplicate localities. Order is critical. Do not change...
	
	... 
		order by geology_attribute,geo_att_value
	...
	
	
*/
   begin
    FOR r IN (
              select geology_attribute || '=' || geo_att_value ||
      case when agent_name is not null then
	    '; Determined by ' || agent_name
	   end
	   ||
	    case when geo_att_determined_date is not null then
	    ' on ' || geo_att_determined_date
	   end
	   ||
	    case when geo_att_determined_method is not null then
	    '; Method: ' || geo_att_determined_method
	   end ||
	    case when geo_att_remark is not null then
	    '; Remark: ' || geo_att_remark
	   end oneAtt
	    from geology_attributes,preferred_agent_name
	   where
	   geology_attributes.geo_att_determiner_id=preferred_agent_name.agent_id (+) and
	   locality_id=locid 
	   order by geology_attribute,geo_att_value )
	 LOOP
	     l_str := l_str || l_sep || r.oneAtt;
           l_sep := '|';
    END LOOP;
   
             
     

       return l_str;
  end;
/
CREATE or replace PUBLIC SYNONYM concatGeologyAttributeDetail FOR concatGeologyAttributeDetail;
GRANT EXECUTE ON concatGeologyAttributeDetail TO PUBLIC;
