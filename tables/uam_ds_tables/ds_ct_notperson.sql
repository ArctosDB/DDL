-- ds_ct_notperson is a list of terms which are
-- probably not present in person-agent names.
-- these should never be used for rules, only suggestions/garbage detection
-- there is no interface; add names via SQL.

create table ds_ct_notperson (
	term varchar2(255) not null
);

create or replace public synonym ds_ct_notperson for ds_ct_notperson;
grant select on ds_ct_notperson to public;
create unique index iu_ds_ct_notperson_term on ds_ct_notperson(term);

-- keep terms lowercase; case is never important in comparison
 CREATE OR REPLACE TRIGGER trg_ds_ct_notperson_bui
 before insert  ON ds_ct_notperson
 for each row
    begin
    	:NEW.term := lower(:NEW.term);
    end;
/
sho err