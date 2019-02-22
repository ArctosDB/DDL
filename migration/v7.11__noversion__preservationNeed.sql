-- https://github.com/ArctosDB/arctos/issues/1517
-- 
create table ctpart_preservation_need (
	preservation_need varchar2(60) not null,
	description varchar2(4000) not null
);


create public synonym ctpart_preservation_need for ctpart_preservation_need;

grant all on ctpart_preservation_need to manage_codetables;

grant select on ctpart_preservation_need to public;

																							
drop table log_ctpart_preservation_need;

create table log_ctpart_preservation_need (
username varchar2(60),
when date default sysdate,
n_DESCRIPTION VARCHAR2(4000),
n_preservation_need VARCHAR2(255),
o_DESCRIPTION VARCHAR2(4000),
o_preservation_need VARCHAR2(255)
);


create or replace public synonym log_ctpart_preservation_need for log_ctpart_preservation_need;

grant select on log_ctpart_preservation_need to coldfusion_user;

drop trigger TR_log_ctpart_presn_need;


CREATE OR REPLACE TRIGGER TR_log_ctpart_presn_need AFTER INSERT or update or delete ON ctpart_preservation_need
FOR EACH ROW
BEGIN
insert into log_ctpart_preservation_need (
username,
when,
n_DESCRIPTION,
n_preservation_need,
o_DESCRIPTION,
o_preservation_need
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.preservation_need,
:OLD.DESCRIPTION,
:OLD.preservation_need
);
END;
/ 
Table values:
 - 
 - 
unframe - 
 - 
 - 
 - 
 - 

insert into ctpart_preservation_need (preservation_need,description) values ('professional conservator','Object needs examination by a professional conservator.');
insert into ctpart_preservation_need (preservation_need,description) values ('rehouse','The current storage housing for the object is inadequate. Needs new housing (box, folder, matting, framing, etc.) or improvements to the current housing.');
insert into ctpart_preservation_need (preservation_need,description) values ('unframe','Object needs to be removed from its current mat and/or frame.');
insert into ctpart_preservation_need (preservation_need,description) values ('minor cleaning','Object needs minor cleaning such as dusting.');
insert into ctpart_preservation_need (preservation_need,description) values ('refill','Refill with existing preservative solution.');
insert into ctpart_preservation_need (preservation_need,description) values ('replace solution','Requires a change of preservative solution.');
insert into ctpart_preservation_need (preservation_need,description) values ('remount','Replace existing mount and mounting medium; for example, microscope slides.');
 
 