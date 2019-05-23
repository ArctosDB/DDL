/*
	get some geology-stuff in DWC format
*/
CREATE OR REPLACE function getGeologyForDWC(colobjid  in number,rnk in varchar2 )
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
	              geology_attributes,
	              locality,
	              collecting_event,
	              specimen_event,
	              cataloged_item
	          where
	           geology_attributes.locality_id=locality.locality_id AND
	           locality.locality_id=collecting_event.locality_id AND
	           collecting_event.collecting_event_id=specimen_event.collecting_event_id and
	           specimen_event.collection_object_id=cataloged_item.collection_object_id AND
	           geology_attribute=rnk and
	           cataloged_item.collection_object_id=colobjid)
	 LOOP
	     l_str := l_str || l_sep || r.geo_att_value;
           l_sep := '; ';
    END LOOP;
   
             
     

       return l_str;
  end;
/
CREATE PUBLIC SYNONYM getGeologyForDWC FOR getGeologyForDWC;
GRANT EXECUTE ON getGeologyForDWC TO PUBLIC;	
