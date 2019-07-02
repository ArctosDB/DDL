/*
 
  	::::::::::::::::IMPORTANT::::::::::::::::
	
	Do not modify this function without also updating http://handbook.arctosdb.org/documentation/json.html
	
  	New Version: Follow http://handbook.arctosdb.org/documentation/json.html with short field names
  	
  	Input: cataloged_item.collection_object_id
  	 
  	Output: Parts and their attributes as JSON 
 
 */


CREATE OR REPLACE function concatpartsdetail (collobjid in integer)
    return varchar2
    as
        --tmp varchar2(32767);
        -- varchar2 in SQL is limited to 4K and this gets 
        -- called in SQL, so...
        tmp varchar2(4000);
    begin
      tmp:='[';
        FOR opts IN (
	        select
					collection_object_id part_id,
			 		level,
			 		part_name
				from (
			 		SELECT
						SAMPLED_FROM_OBJ_ID,
						collection_object_id,
						part_name
					FROM
						specimen_part
			 		where
						derived_from_cat_item=collobjid
			 		)
				START WITH SAMPLED_FROM_OBJ_ID is null
				CONNECT BY PRIOR collection_object_id = SAMPLED_FROM_OBJ_ID
				ORDER SIBLINGS BY part_name
			) loop
				for r in (			
		        	select 
		       		        specimen_part.collection_object_id,
		       		        specimen_part.SAMPLED_FROM_OBJ_ID,
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
		                    --SAMPLED_FROM_OBJ_ID is NULL and
		                    specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id (+) AND
		                    coll_obj_cont_hist.container_id=c.container_id (+) AND
		                    c.parent_container_id=p.container_id (+) AND
		                    specimen_part.collection_object_id = opts.part_id
		                ORDER BY 
		                    partname,
		                    part_name
		                ) loop
	                   		tmp:= tmp || '{';
	                   		tmp:= tmp || '"ID":"' || r.collection_object_id || '",';
	                       	tmp:= tmp || '"SF":"' || r.SAMPLED_FROM_OBJ_ID || '",';
	                        tmp:= tmp || '"PN":"' || r.part_name || '",';
	                        tmp:= tmp || '"LC":"' || r.lot_count || '",';
	                        tmp:= tmp || '"DP":"' || r.coll_obj_disposition || '",';
	                        tmp:= tmp || '"CD":"' || r.condition || '",';
	                        tmp:= tmp || '"BC":"' || r.barcode || '",';
	                        tmp:= tmp || '"CP":"' || r.containerPath || '",';
	                        tmp:= tmp || '"RK":"' || r.coll_object_remarks || '",';
	                        tmp:= tmp || '"PA":[' ;
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
                                    tmp:= tmp || '"AT":"' || a.attribute_type || '",';
                                    tmp:= tmp || '"AV":"' || a.attribute_value || '",';
                                    tmp:= tmp || '"AU":"' || a.attribute_units || '",';
                                    tmp:= tmp || '"DD":"' || a.determined_date || '",';
                                    tmp:= tmp || '"DR":"' || a.determiner || '",';
                                    tmp:= tmp || '"AR":"' || a.attribute_remark || '"';
                                  	tmp:= tmp || '},';
                           	END LOOP;
                        tmp:= tmp || ']' ;
                     	tmp:= tmp || '},';
                    end loop;
               end loop;
        tmp:= tmp || ']';
        tmp:=replace(tmp,'},]','}]');
       return tmp;
       exception when others then
       	 tmp:='[{"STATUS":"ERROR CREATING JSON"}]';    
       	 return tmp;
   end;
/

sho err;



























CREATE OR REPLACE function concatpartsdetail__oldNBusted (collobjid in integer)
    return varchar2
    as
        --tmp varchar2(32767);
        -- varchar2 in SQL is limited to 4K and this gets 
        -- called in SQL, so...
        tmp varchar2(4000);
    begin
      tmp:='[';
        FOR opts IN (
	        select
					collection_object_id part_id,
			 		level,
			 		part_name
				from (
			 		SELECT
						SAMPLED_FROM_OBJ_ID,
						collection_object_id,
						part_name
					FROM
						specimen_part
			 		where
						derived_from_cat_item=collobjid
			 		)
				START WITH SAMPLED_FROM_OBJ_ID is null
				CONNECT BY PRIOR collection_object_id = SAMPLED_FROM_OBJ_ID
				ORDER SIBLINGS BY part_name
			) loop
				for r in (			
		        	select 
		       		        specimen_part.collection_object_id,
		       		        specimen_part.SAMPLED_FROM_OBJ_ID,
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
		                    --SAMPLED_FROM_OBJ_ID is NULL and
		                    specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id (+) AND
		                    coll_obj_cont_hist.container_id=c.container_id (+) AND
		                    c.parent_container_id=p.container_id (+) AND
		                    specimen_part.collection_object_id = opts.part_id
		                ORDER BY 
		                    partname,
		                    part_name
		                ) loop

	                   		tmp:= tmp || '{';
	                   		tmp:= tmp || '"partID" : "' || r.collection_object_id || '",';
	                       	tmp:= tmp || '"SampledFromPartID" : "' || r.SAMPLED_FROM_OBJ_ID || '",';
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




create or replace public synonym concatpartsdetail for concatpartsdetail;
grant execute on concatpartsdetail to public;
