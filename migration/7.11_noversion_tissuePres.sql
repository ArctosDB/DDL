-- https://github.com/ArctosDB/arctos/issues/1460
-- this is not tied to any version and uses long-established functionality

create table ctpart_preservation (
  part_preservation varchar2(255) not null,
  description varchar2(4000) not null
);

create public synonym ctpart_preservation for ctpart_preservation;

grant all on ctpart_preservation to manage_codetables;

grant select on ctpart_preservation to public;																		

create table log_ctpart_preservation (
username varchar2(60),
when date default sysdate,
n_DESCRIPTION VARCHAR2(255),
n_part_preservation VARCHAR2(255),
o_DESCRIPTION VARCHAR2(255),
o_part_preservation VARCHAR2(255)
);


create or replace public synonym log_ctpart_preservation for log_ctpart_preservation;

grant select on log_ctpart_preservation to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_part_preservation AFTER INSERT or update or delete ON ctpart_preservation
	FOR EACH ROW
	BEGIN
		insert into log_ctpart_preservation (
			username,
			when,
			n_DESCRIPTION,
			n_part_preservation,
			o_DESCRIPTION,
			o_part_preservation
		) values (
			SYS_CONTEXT('USERENV','SESSION_USER'),
			sysdate,
			:NEW.DESCRIPTION,
			:NEW.part_preservation,
			:OLD.DESCRIPTION,
			:OLD.part_preservation
		);
	END;
/ 
sho err;