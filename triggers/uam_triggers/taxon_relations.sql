CREATE OR REPLACE TRIGGER taxon_relations_key before insert or update ON taxon_relations  
    for each row 
    begin
	    if :NEW.taxon_relations_id is null then 
   			:NEW.stale_fg:=1;
   		end if;
	    if :NEW.taxon_relations_id is null then                                                                                      
	    	select sq_taxon_relations_id.nextval into :new.taxon_relations_id from dual;
	    end if;                       
    end;
/
sho err