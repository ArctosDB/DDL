CREATE OR REPLACE function concatpartsdetail (collobjid in integer)
    return varchar2
    as
        tmp varchar2(32767);
    begin
      tmp:='[';
        FOR r IN (select 
       		        specimen_part.collection_object_id,
       		        part_name,
       		        escape_json(condition) condition,
				    lot_count,
				    coll_obj_disposition,
				    escape_json(coll_object_remarks) coll_object_remarks,
				    p.barcode,
            		getContainerParentage(p.container_id) containerPath
			    from 
			        specimen_part,
			        ctspecimen_part_list_order,
			        coll_object,
			        coll_object_remark,
			        coll_obj_cont_hist,
			        container c,
			        container p
                where 
                    specimen_part.collection_object_id =  coll_object.collection_object_id AND
                    specimen_part.collection_object_id =  coll_object_remark.collection_object_id (+) AND
                    specimen_part.part_name =  ctspecimen_part_list_order.partname (+) and 
                    SAMPLED_FROM_OBJ_ID is NULL and
                    specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id (+) AND
                    coll_obj_cont_hist.container_id=c.container_id (+) AND
                    c.parent_container_id=p.container_id (+) AND
                    derived_from_cat_item = collobjid
                ORDER BY 
                    partname,
                    part_name) loop
	                    tmp:= tmp || '{';
	                        tmp:= tmp || '"part_name" : "' || r.part_name || '",';
	                        tmp:= tmp || '"lot_count" : "' || r.lot_count || '",';
	                        tmp:= tmp || '"disposition" : "' || r.coll_obj_disposition || '",';
	                        tmp:= tmp || '"condition" : "' || r.condition || '",';
	                        tmp:= tmp || '"barcode" : "' || r.barcode || '",';
	                        tmp:= tmp || '"container_path" : "' || r.containerPath || '",';
	                        tmp:= tmp || '"remark" : "' || r.coll_object_remarks || '",';
	                        tmp:= tmp || '"attributes" : [' ;
                             FOR a IN (SELECT 
                                   attribute_type,
                                   escape_json(attribute_value) attribute_value,
                                   attribute_units,
                                   DETERMINED_DATE,
                                   getPreferredAgentName(DETERMINED_BY_AGENT_ID) determiner,
                                   escape_json(ATTRIBUTE_REMARK) ATTRIBUTE_REMARK
                               FROM
                                   specimen_part_attribute
                               WHERE
                                   collection_object_id=r.collection_object_id
                               ORDER BY
								attribute_type ASC,
								DETERMINED_DATE DESC
                               ) LOOP
								tmp:= tmp || '{';
                                    tmp:= tmp || '"attribute_type" : "' || a.attribute_type || '",';
                                    tmp:= tmp || '"attribute_value" : "' || a.attribute_value || '",';
                                    tmp:= tmp || '"attribute_units" : "' || a.attribute_units || '",';
                                    tmp:= tmp || '"determined_date" : "' || a.determined_date || '",';
                                    tmp:= tmp || '"determiner" : "' || a.determiner || '",';
                                    tmp:= tmp || '"attribute_remark" : "' || a.attribute_remark || '"';
                                  tmp:= tmp || '},';
                           END LOOP;
                        tmp:= tmp || ']' ;
                     tmp:= tmp || '},';
                    end loop;
        tmp:= tmp || ']';
        tmp:=replace(tmp,'},]','}]');
       return tmp;
       exception when others then
       	 tmp:='{"error":"see specimen detail page"}';    
       	 return tmp;
   end;
/

sho err;




--create public synonym concatpartsdetail for concatpartsdetail;
--grant execute on concatpartsdetail to public;


--  select concatpartsdetail(12) from dual;
--  select concatpartsdetail(2578556) from dual;

 -- select concatpartsdetail(12) from dual;

