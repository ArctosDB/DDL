CREATE OR REPLACE TRIGGER TRG_MK_SCI_NAME
BEFORE INSERT OR UPDATE ON TAXONOMY
FOR EACH ROW
DECLARE
	nsn varchar2(4000);
	nft varchar2(4000);
BEGIN
	IF :NEW.subspecies IS NOT null THEN
		nsn := :NEW.subspecies;
		nft := :NEW.subspecies;
	END IF;
	    
	IF :NEW.infraspecific_rank IS NOT null THEN
		nsn := :NEW.infraspecIFic_rank || ' ' || nsn;
		nft := :NEW.infraspecIFic_rank || ' ' || nft;
	END IF;
	    
	IF :NEW.species IS NOT null THEN
		nsn := :NEW.species || ' ' || nsn;
		nft := :NEW.species || ' ' || nft;
	END IF;
	    
	IF :NEW.subgenus IS NOT null THEN
	    -- ignore for building scientIFic name
		nft := :NEW.subgenus || ' ' || nft;
	END IF;
	    
	IF :NEW.genus IS NOT null THEN
		nsn := :NEW.genus || ' ' || nsn;
		nft := :NEW.genus || ' ' || nft;
	END IF;
	    
	IF :NEW.tribe IS NOT null THEN
		IF nsn IS NULL THEN
		  nsn := :NEW.tribe;
		END IF;
		    
		-- IF we don't have a scientific name by now,
		-- just use the lowest term that we do have
		nft := :NEW.tribe || ' ' || nft;
	END IF;
	    
	IF :NEW.subfamily IS NOT null THEN
		IF nsn IS NULL THEN
			nsn := :NEW.subfamily;
		END IF;
		    
		nft := :NEW.subfamily || ' ' || nft;
	END IF;
	    
	IF :NEW.family IS NOT null THEN
		IF nsn IS NULL THEN
			nsn := :NEW.family;
		END IF;
		    
		nft := :NEW.family || ' ' || nft;
	END IF;
	    
	IF :NEW.superfamily IS NOT null THEN
		IF nsn IS NULL THEN
			nsn := :NEW.superfamily;
		END IF;
		    
		nft := :NEW.superfamily || ' ' || nft;
	END IF;
	    
	IF :NEW.suborder IS NOT null THEN
		IF nsn IS NULL THEN
			nsn := :NEW.suborder;
		END IF;
		    
		nft := :NEW.suborder || ' ' || nft;
	END IF;
	    
	IF :NEW.phylorder IS NOT null THEN
		IF nsn IS NULL THEN
			nsn := :NEW.phylorder;
		END IF;
		    
		nft := :NEW.phylorder || ' ' || nft;
	END IF;
	    
	IF :NEW.subclass IS NOT null THEN
		IF nsn IS NULL THEN
			nsn := :NEW.subclass;
		END IF;
		    
		nft := :NEW.subclass || ' ' || nft;
	END IF;
	    
	IF :NEW.phylclass IS NOT null THEN
		IF nsn IS NULL THEN
			nsn := :NEW.phylclass;
		END IF;
		    
		nft := :NEW.phylclass || ' ' || nft;
	END IF;
	    
	IF :NEW.phylum IS NOT null THEN
		IF nsn IS NULL THEN
			nsn := :NEW.phylum;
		END IF;
		    
		nft := :NEW.phylum || ' ' || nft;
	END IF;
	    
	IF :NEW.kingdom IS NOT null THEN
		IF nsn IS NULL THEN
			nsn := :NEW.kingdom;
		END IF;
		    
		nft := :NEW.kingdom || ' ' || nft;
	END IF;
	    
	:NEW.scientific_name := trim(nsn);
	    
	:NEW.full_taxon_name := trim(nft);
	-- sci_name_with_auths
	-- dbms_output.put_line(nsn);
	-- dbms_output.put_line(nft);
END;

CREATE OR REPLACE TRIGGER UPDATE_ID_AFTER_TAXON_CHANGE
AFTER UPDATE ON TAXONOMY
FOR EACH ROW
DECLARE r VARCHAR2(4000);
BEGIN
    IF :new.scientific_name != :OLD.scientific_name THEN
        UPDATE identification SET
            scientific_name = replace(scientific_name,
                :OLD.scientific_name,:NEW.scientific_name)
        WHERE identification_id IN (
            SELECT identification_id 
            FROM identification_taxonomy 
            WHERE taxon_name_id = :NEW.taxon_name_id);
    END IF;
END;

CREATE OR REPLACE TRIGGER TRG_UP_TAX
AFTER UPDATE ON TAXONOMY
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
BEGIN
    INSERT INTO taxonomy_archive (
    	when,
		who,
		taxon_name_id,
		phylclass,
		phylorder,
		suborder,
		family,
		subfamily,
		genus,
		subgenus,
		species,
		subspecies,
		valid_catalog_term_fg,
		source_authority,
		full_taxon_name,
		scientific_name,
		author_text,
		tribe,
		infraspecific_rank,
		taxon_remarks,
		phylum,
		kingdom,
		nomenclatural_code,
		infraspecific_author,
		sci_name_with_auths,
		sci_name_no_irank,
		subclass,
		superfamily)
	VALUES (
		sysdate,
		user,
		:OLD.taxon_name_id,
		:OLD.phylclass,
		:OLD.phylorder,
		:OLD.suborder,
		:OLD.family,
		:OLD.subfamily,
		:OLD.genus,
		:OLD.subgenus,
		:OLD.species,
		:OLD.subspecies,
		:OLD.valid_catalog_term_fg,
		:OLD.source_authority,
		:OLD.full_taxon_name,
		:OLD.scientific_name,
		:OLD.author_text,
		:OLD.tribe,
		:OLD.infraspecific_rank,
		:OLD.taxon_remarks,
		:OLD.phylum,
		:OLD.kingdom,
		:OLD.nomenclatural_code,
		:OLD.infraspecific_author,
		:OLD.sci_name_with_auths,
		:OLD.sci_name_no_irank,
		:OLD.subclass,
		:OLD.superfamily);
END;
