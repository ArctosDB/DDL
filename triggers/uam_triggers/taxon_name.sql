CREATE OR REPLACE TRIGGER trg_taxon_name_biu
BEFORE UPDATE OR INSERT ON taxon_name
FOR EACH ROW
declare
	sts varchar2(255);
BEGIN
	select isValidTaxonName(:new.scientific_name) into sts from dual;
	if sts != 'valid' then
    	Raise_application_error(-20013,'Save rejected: ' || sts);
    END IF;
    
    -- allow creation from command line
    if sys_context('USERENV', 'SESSION_USER')='UAM' then
    	 select
	    	0,
	    	sysdate
	    into 
	    	:NEW.created_by_agent_id,
	    	:NEW.created_date
	    from
	    	dual
	    ;
	else
	    select
	    	agent_id,
	    	sysdate
	    into 
	    	:NEW.created_by_agent_id,
	    	:NEW.created_date
	    from
	    	agent_name 
	    where 
	    	agent_name_type='login' and 
	    	upper(agent_name)=sys_context('USERENV', 'SESSION_USER')
	    ;
	end if;
END;
/


CREATE OR REPLACE TRIGGER trg_taxon_name_nochangeused before update or delete ON taxon_NAME
    for each row 
      DECLARE 
        c INTEGER;
    begin     
	    select count(*) into c from identification_taxonomy where taxon_name_id=:OLD.taxon_name_id;
	     if c > 0 then
	    	Raise_application_error(-20012,'Used names may not be altered.');
	    end if;
	    select count(*) into c from media_relations where media_relationship like '% taxonomy' and related_primary_key=:OLD.taxon_name_id;
	    if c > 0 then
	    	Raise_application_error(-20012,'Used names may not be altered.');
	    end if;  
	    
	    select count(*) into c from PROJECT_TAXONOMY where taxon_name_id=:OLD.taxon_name_id;
	    if c > 0 then
	    	Raise_application_error(-20012,'Used names may not be altered.');
	    end if;  
    end;                                                                                            
/
sho err


