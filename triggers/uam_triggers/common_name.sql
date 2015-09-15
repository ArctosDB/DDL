CREATE OR REPLACE TRIGGER common_name_key before insert  ON common_name  
    for each row 
    begin     
	    if :NEW.common_name_id is null then                                                                                      
	    	select sq_common_name_id.nextval into :new.common_name_id from dual;
	    end if;                       
    end;                                                                                            
/
sho err
