CREATE OR REPLACE PROCEDURE REMOVE_NOBARCODE_LEGACY_CONTNR IS
    s varchar2(4000);
begin
    for r in (
        select container_id,parent_container_id 
        from container 
        where container_type='legacy container' 
        and barcode is null
    ) loop
        begin
            --dbms_output.put_line(r.container_id);
            -- now loop over all the children
            for c in (
                select container_id,parent_container_id 
                from container 
                where parent_container_id=r.container_id
            ) loop
                if r.parent_container_id is null then
                    s := 'update container set parent_container_id = null where container_id = ' 
                        || c.container_id;
                    --dbms_output.put_line(s);
                    
                    execute immediate(s);
                else
                    s := 'update container set parent_container_id = ' 
                        || r.parent_container_id 
                        || ' where container_id = '|| c.container_id;
                    --dbms_output.put_line(s);
                    
                    execute immediate(s);
                end if;
            end loop;
            
            s := 'delete from container_history where container_id = ' || r.container_id;
            --dbms_output.put_line(s);
            
            execute immediate(s);
            
            s := 'delete from container where container_id = ' || r.container_id;
            --dbms_output.put_line(s);
            
            execute immediate(s);
        exception when others then
            -- ignore for now
            dbms_output.put_line(sqlerrm);
        end;
    end loop;
end;
/