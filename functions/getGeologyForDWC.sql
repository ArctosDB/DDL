/*
	get some geology-stuff in DWC format
	EDIT: need locality_id not specimen-stuff
*/
CREATE OR REPLACE function getGeologyForDWC(locid in number,rnk in varchar2 )
    return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
       l_sep    varchar2(30);
       l_val    varchar2(4000);
   begin
    FOR r IN (
              select distinct geo_att_value
	          from 
	              geology_attributes
	          where
	           geology_attributes.locality_id=locid AND
	           geology_attribute=rnk
	          )
	 LOOP
	     l_str := l_str || l_sep || r.geo_att_value;
           l_sep := '; ';
    END LOOP;
   
             
     

       return l_str;
  end;
/
CREATE PUBLIC SYNONYM getGeologyForDWC FOR getGeologyForDWC;
GRANT EXECUTE ON getGeologyForDWC TO PUBLIC;	
