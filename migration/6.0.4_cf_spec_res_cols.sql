update cf_spec_res_cols set DISP_ORDER=DISP_ORDER+1 where DISP_ORDER>63;

insert into cf_spec_res_cols (COLUMN_NAME,SQL_ELEMENT,CATEGORY,CF_SPEC_RES_COLS_ID,DISP_ORDER) values (
'skull_yn',
'decode(instr(flatTableName.parts,''skull''),NULL,''false'',0,''false'',''true'')',
'curatorial',
SOMERANDOMSEQUENCE.nextval,
64
);


drop table exit_link;
drop sequence sq_exit_link_id;
drop trigger exit_link_trg;


create table exit_link (
	exit_link_id number not null,
	username varchar2(255),
	ipaddress varchar2(255),
	from_page varchar2(255),
	target varchar2(255),
	http_target varchar2(255),
	when_date date,
	status varchar2(255)
);

create or replace public synonym exit_link for exit_link;

grant insert, select on exit_link to public;

create sequence sq_exit_link_id;

 CREATE OR REPLACE TRIGGER exit_link_trg                                         
 before insert  ON exit_link  
 for each row 
    begin     
    	if :NEW.exit_link_id is null then                                                                                      
    		select sq_exit_link_id.nextval into :new.exit_link_id from dual;
    	end if;                       
    end;                                                                                            
/
sho err
      

