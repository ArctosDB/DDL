
revoke delete on container from manage_container;

CREATE OR REPLACE procedure deleteContainer (
    v_container_id IN number
   ) is 
   	c number;
    begin
        -- disallow if the container is a parent of anything
        select count(*) into c from container where parent_container_id=v_container_id;
        if c != 0 then
        	 raise_application_error(-20000, 'FAIL: Containers which are parents may not be deleted.');
       	else
       		DELETE FROM container_history WHERE container_id = v_container_id;
       		delete from  container where container_id=v_container_id;
       		DELETE FROM container_check WHERE container_id = v_container_id;
        end if;
    end;
/
sho err;

CREATE OR REPLACE PUBLIC SYNONYM deleteContainer FOR deleteContainer;
GRANT EXECUTE ON deleteContainer TO manage_container;

   
   
   