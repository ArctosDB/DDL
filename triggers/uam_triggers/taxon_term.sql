
CREATE OR REPLACE TRIGGER tr_taxon_term_id before insert ON taxon_term for each row
   begin    
       IF :new.taxon_term_id IS NULL THEN
           select sq_taxon_term_id.nextval into :new.taxon_term_id from dual;
       END IF;
   end;                                                                                           
/
sho err



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
