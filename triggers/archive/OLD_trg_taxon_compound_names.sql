CREATE OR REPLACE TRIGGER trg_taxon_compound_names
BEFORE INSERT OR UPDATE ON taxonomy
FOR EACH ROW
DECLARE
	nScientificName varchar2(4000);
	nFullTaxonomy varchar2(4000);
	nDisplayName varchar2(4000);
	c NUMBER;
BEGIN
    if :new.taxon_name_id is null then
    	select sq_taxon_name_id.nextval into :new.taxon_name_id from dual;
    end if;
    
    if :NEW.nomenclatural_code='ICBN' then
    	nDisplayName:=prependTaxonomy(nDisplayName, :NEW.INFRASPECIFIC_AUTHOR);
    end if;
    if :NEW.nomenclatural_code='ICZN' then
    	nDisplayName:=prependTaxonomy(nDisplayName, :NEW.AUTHOR_TEXT);
    end if;
    nScientificName:=prependTaxonomy(nScientificName, :NEW.subspecies);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.subspecies);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.subspecies,1);
    
    if :NEW.nomenclatural_code='ICBN' then
    	nScientificName:=prependTaxonomy(nScientificName, :NEW.infraspecific_rank);
    	nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.infraspecific_rank);
    	nDisplayName:=prependTaxonomy(nDisplayName, :NEW.infraspecific_rank);
    end if;
    if :NEW.nomenclatural_code='ICBN' then
    	nDisplayName:=prependTaxonomy(nDisplayName, :NEW.AUTHOR_TEXT);
    end if;
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.species);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.species);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.species,1);
    
    if :new.subgenus is not null then
    	nScientificName:=prependTaxonomy(nScientificName, '(' || :NEW.subgenus || ')');
    	nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, '(' || :NEW.subgenus || ')');
    	nDisplayName:=prependTaxonomy(nDisplayName, '(' || :NEW.subgenus || ')',1);
    end if;
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.genus);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.genus);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.genus,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.tribe,0,1);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.tribe);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.tribe,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.subfamily,0,1);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.subfamily);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.subfamily,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.family,0,1);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.family);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.family,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.superfamily,0,1);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.superfamily);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.superfamily,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.suborder,0,1);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.suborder);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.suborder,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.phylorder,0,1);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.phylorder);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.phylorder,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.subclass,0,1);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.subclass);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.subclass,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.phylclass,0,1);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.phylclass);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.phylclass,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.phylum,0,1);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.phylum);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.phylum,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.kingdom,0,1);
    nFullTaxonomy:=prependTaxonomy(nFullTaxonomy, :NEW.kingdom);
    nDisplayName:=prependTaxonomy(nDisplayName, :NEW.kingdom,0,1);
    
    :new.scientific_name:=nScientificName;
    :new.full_taxon_name:=nFullTaxonomy;
    :new.display_name:=nDisplayName;
    
    IF :new.scientific_name != :OLD.scientific_name THEN
        SELECT COUNT(*) INTO c FROM identification_taxonomy WHERE taxon_name_id=:NEW.taxon_name_id;
        IF c != 0 THEN
            raise_application_error(
    		    -20001,
    			:old.scientific_name || ' is used in Identifications and cannot be updated.'
    	    );
        END IF;
    END IF;
END;
/
sho err