
CREATE OR REPLACE TRIGGER tr_taxon_term_id before insert ON taxon_term for each row
   begin    
       IF :new.taxon_term_id IS NULL THEN
           select sq_taxon_term_id.nextval into :new.taxon_term_id from dual;
       END IF;
   end;                                                                                           
/
sho err




create or replace trigger trg_taxon_term_cts before insert or update on taxon_term
	FOR EACH ROW
	declare
		c number;
	begin
		-- only care if local
		select /*+ RESULT_CACHE */ count(*) into c from CTTAXONOMY_SOURCE where source=:NEW.source;
		if c=1 then
			-- it's local, check stuff
			-- known term type?
			select /*+ RESULT_CACHE */ count(*) into c from CTTAXON_TERM where TAXON_TERM=:NEW.term_type;
			if c=0 then
				raise_application_error(
	                -20001,
	                :NEW.term_type || ' is not in CTTAXON_TERM'
	            );
			end if;
			if :NEW.term_type = 'nomenclatural_code' then
				select /*+ RESULT_CACHE */ count(*) into c from CTNOMENCLATURAL_CODE where NOMENCLATURAL_CODE=:NEW.term;
				if c=0 then
					raise_application_error(
		                -20001,
		                'When term type is nomenclatural_code term must be in CTNOMENCLATURAL_CODE'
		            );
				end if;
			end if;
			if :NEW.term_type = 'taxon_status' then
				select /*+ RESULT_CACHE */ count(*) into c from CTTAXON_STATUS where TAXON_STATUS=:NEW.term;
				if c=0 then
					raise_application_error(
		                -20001,
		                'When term type is taxon_status term must be in CTTAXON_STATUS'
		            );
				end if;
			end if;
			
			if :NEW.term_type = 'valid_catalog_term_fg' then
				if :NEW.term not in ('0','1') then
					raise_application_error(
		                -20001,
		                'When term type is valid_catalog_term_fg term must be 0 or 1'
		            );
				end if;
			end if;
			
			insert into cf_automaintain_taxonterms  (classification_id) values (:NEW.classification_id);

		END IF;
	end;
/
sho err;


-- check





select * from taxon_term where source='Arctos' and taxon_name_id=12;



update taxon_term set term=term where TAXON_TERM_ID=116;
update taxon_term set term_type=term_type where TAXON_TERM_ID=116;
update taxon_term set term='ICZN' where TAXON_TERM_ID=118;



update taxon_term set term=term where TAXON_TERM_ID=55751185;

		116
		
		
		UAM@ARCTEST> desc taxon_term
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_TERM_ID							   NOT NULL NUMBER
 TAXON_NAME_ID							   NOT NULL NUMBER
 CLASSIFICATION_ID							    VARCHAR2(4000)
 TERM								   NOT NULL VARCHAR2(255)
 TERM_TYPE								    VARCHAR2(255)
 SOURCE 							   NOT NULL VARCHAR2(255)
 GN_SCORE								    NUMBER
 POSITION_IN_CLASSIFICATION						    NUMBER
 LASTDATE							   NOT NULL DATE
 MATCH_TYPE								    VARCHAR2(255)

UAM@ARCTEST> 

		
create or replace trigger trg_pushtaxontermtoflat after insert or update or delete on taxon_term
	FOR EACH ROW 
	begin
		-- capture insert and changes
		-- push them to flat as necessary

		if inserting then
			-- there is no OLD data
			-- flat always deals with ranked terms, so just ignore anything that's not
			if :NEW.term_type is not null THEN
				insert into taxon_term_updated (
					taxon_name_id,
					term_type,
					source
				) values (
					:NEW.taxon_name_id,
					:NEW.term_type,
					:NEW.source
				);
			end if;
		elsif deleting then
			-- there is no NEW data 
			-- flat always deals with ranked terms, so just ignore anything that's not
			if :OLD.term_type is not null THEN
				insert into taxon_term_updated (
					taxon_name_id,
					term_type,
					source
				) values (
					:OLD.taxon_name_id,
					:OLD.term_type,
					:OLD.source
				);
			end if;
		elsif updating then
			--dbms_output.put_line(:NEW.term_type);
			--dbms_output.put_line(:OLD.term_type);
			--dbms_output.put_line(:NEW.term);
			--dbms_output.put_line(:OLD.term);

			-- flat always deals with ranked terms, so just ignore anything that's not
			-- and we can ignore anything where term_type AND term did not change
			if (:NEW.term_type != :OLD.term_type or :NEW.term != :OLD.term) then
				--dbms_output.put_line(:NEW.term_type || '!=' || :OLD.term_type || ' OR ' || :NEW.term || '!=' || :OLD.term);
				-- and we can ignore anything where new and old term type are NULL
				if (:NEW.term_type is not null or :OLD.term_type is not null) THEN
					insert into taxon_term_updated (
						taxon_name_id,
						term_type,
						source
					) values (
						:NEW.taxon_name_id,
						:NEW.term_type,
						:NEW.source
					);
				end if;
			end if;
		end if;
	end;
/
