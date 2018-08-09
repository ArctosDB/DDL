


create table ctcopyright_status (
	copyright_status varchar2(60) not null,
	description varchar2(4000) not null
);


create public synonym ctcopyright_status for ctcopyright_status;

grant select on ctcopyright_status to public;

grant all on ctcopyright_status to manage_codetables;

create unique index ix_u_ctcopyright_status_cs on ctcopyright_status (copyright_status) tablespace uam_idx_1;

create table log_ctcopyright_status ( 
	username varchar2(60),	
	when date default sysdate,
	n_copyright_status varchar2(60),
	n_DESCRIPTION varchar2(4000),
	o_copyright_status varchar2(60),
	o_DESCRIPTION varchar2(4000)
);


create or replace public synonym log_ctcopyright_status for log_ctcopyright_status;


grant select on log_ctcopyright_status to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_ctcopyright_status
	AFTER INSERT or update or delete ON ctcopyright_status
	FOR EACH ROW 
BEGIN 
	insert into log_ctcopyright_status ( 
		username, 
		when,
		n_copyright_status,
		n_DESCRIPTION,
		o_copyright_status,
		o_DESCRIPTION
	) values (
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.copyright_status,
		:NEW.DESCRIPTION,
		:OLD.copyright_status,
		:OLD.DESCRIPTION
	);
END;
/


insert into ctcopyright_status (copyright_status,DESCRIPTION) values ('in copyright','Item is protected by copyright and/or related rights.');
insert into ctcopyright_status (copyright_status,DESCRIPTION) values ('in copyright, rights-holder unlocatable or unidentifiable','Item is protected by copyright and/or related rights. However, for this Item, either (a) no rights-holder(s) have been identified or (b) one or more rights-holder(s) have been identified but none have been located. See also: http://rightsstatements.org/vocab/InC-RUU/1.0/');
insert into ctcopyright_status (copyright_status,DESCRIPTION) values ('copyright undetermined','The copyright and related rights status of this Item has been reviewed by the organization that has made the Item available, but the organization was unable to make a conclusive determination as to the copyright status of the Item. See also: http://rightsstatements.org/vocab/UND/1.0/');
insert into ctcopyright_status (copyright_status,DESCRIPTION) values ('copyright not evaluated','The copyright and related rights status of this Item has not been evaluated. See also: http://rightsstatements.org/vocab/CNE/1.0/');
insert into ctcopyright_status (copyright_status,DESCRIPTION) values ('public domain','Item is in the Public Domain.');
insert into ctcopyright_status (copyright_status,DESCRIPTION) values ('license agreement','Item is in copyright and a license agreement is secured with copyright holder.');
