-- used by getMakeCollectingEvent
CREATE OR REPLACE function bl_concatGeoAttDetail(v_key  in number )
    return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
       l_sep    varchar2(30);
       l_val    varchar2(4000);
/*
	returns a pipe-delimited list of geology attribute determinations
*/
   begin
    FOR r IN (
              select geology_attribute || '=' || geo_att_value ||
      case when determiner is not null then
	    '; Determined by ' || determiner
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
	    from bl_geology_attributes
	   where
	   key=v_key order by geology_attribute,geo_att_value )
	 LOOP
	     l_str := l_str || l_sep || r.oneAtt;
           l_sep := '|';
    END LOOP;
   
             
     

       return l_str;
  end;
/
CREATE or replace PUBLIC SYNONYM bl_concatGeoAttDetail FOR bl_concatGeoAttDetail;
GRANT EXECUTE ON bl_concatGeoAttDetail TO PUBLIC;
