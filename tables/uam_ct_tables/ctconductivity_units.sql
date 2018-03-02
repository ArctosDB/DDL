


create table ctconductivity_units (
	conductivity_units varchar2(40) not null,
	description varchar2(4000) not null
);


create public synonym ctconductivity_units for ctconductivity_units;

grant select on ctconductivity_units to public;

grant all on ctconductivity_units to manage_codetables;

create unique index ix_u_ctconductivity_units_cu on ctconductivity_units (conductivity_units) tablespace uam_idx_1;

create table log_ctconductivity_units ( 
	username varchar2(60),	
	when date default sysdate,
	n_conductivity_units varchar2(60),
	n_DESCRIPTION varchar2(4000),
	o_conductivity_units varchar2(60),
	o_DESCRIPTION varchar2(4000)
);


create or replace public synonym log_ctconductivity_units for log_ctconductivity_units;


grant select on log_ctconductivity_units to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_ctconductivity_units 
	AFTER INSERT or update or delete ON ctconductivity_units
	FOR EACH ROW 
BEGIN 
	insert into log_ctconductivity_units ( 
		username, 
		when,
		n_conductivity_units,
		n_DESCRIPTION,
		o_conductivity_units,
		o_DESCRIPTION
	) values (
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.conductivity_units,
		:NEW.DESCRIPTION,
		:OLD.conductivity_units,
		:OLD.DESCRIPTION
	);
END;
/


insert into ctconductivity_units (conductivity_units,DESCRIPTION) values ('µS/cm','microsiemens per centimeter');
insert into ctconductivity_units (conductivity_units,DESCRIPTION) values ('S/m','siemens per meter');
insert into ctconductivity_units (conductivity_units,DESCRIPTION) values ('mS/cm','millisiemens per centimeter');

