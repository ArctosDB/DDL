// this has been replaced by the JSON version
CREATE OR REPLACE function concatpartsdetail__old( collobjid in integer)
    return varchar2
    as
        tmp    varchar2(4000);
        ta     varchar2(4000);
        sep    varchar2(10);
        ts    varchar2(2);
        ret    varchar2(4000);
    begin
        FOR r IN (select 
       		        specimen_part.collection_object_id,
       		        part_name,
       		        condition,
				    lot_count,
				    coll_obj_disposition,
				    coll_object_remarks,
				    nvl(p.barcode,'NO BARCODE') barcode
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
               tmp:=r.part_name || ' {' || r.lot_count || '; ' || r.coll_obj_disposition || '; ' || r.condition || '; ' || r.barcode;
               IF r.coll_object_remarks IS NOT NULL THEN
                  tmp:=tmp || '; ' || r.coll_object_remarks;
               END IF;
               tmp := tmp || '}';
               ta:='';
               FOR a IN (SELECT 
                           attribute_type,
                           attribute_value,
                           attribute_units
                       FROM
                           specimen_part_attribute
                       WHERE
                           collection_object_id=r.collection_object_id) LOOP
                   ta:=ta || ts || a.attribute_type || ': ' || a.attribute_value;
                   ts:='; ';
                   IF a.attribute_units IS NOT NULL THEN
                       ta:=ta || ' ' || a.attribute_units;
                   END IF;
               END LOOP;
               IF ta IS NOT NULL THEN
                   tmp:= tmp || ' [' || ta || ']';
               END IF;
               ret := ret || sep || tmp;
               sep := chr(10);
       end loop;
       IF ret IS NULL THEN
            ret:=' ';
        END IF;
       return ret;
   end;
/


sho err;



--create public synonym concatpartsdetail for concatpartsdetail;
--grant execute on concatpartsdetail to public;


--  select concatpartsdetail(12) from dual;
--  select concatpartsdetail(2578556) from dual;

 -- select concatpartsdetail(12) from dual;

