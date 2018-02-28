

drop table ctculture;

create table cttemperature_units (
	temperature_units varchar2(40) not null,
	description varchar2(4000) not null
);


create public synonym cttemperature_units for cttemperature_units;

grant select on cttemperature_units to public;

grant all on cttemperature_units to manage_codetables;

create unique index ix_u_cttemperature_units_tu on cttemperature_units (temperature_units) tablespace uam_idx_1;

create table log_cttemperature_units ( 
	username varchar2(60),	
	when date default sysdate,
	n_temperature_units varchar2(60),
	n_DESCRIPTION varchar2(4000),
	o_temperature_units varchar2(60),
	o_DESCRIPTION varchar2(4000)
);


create or replace public synonym log_cttemperature_units for log_cttemperature_units;


grant select on log_cttemperature_units to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_cttemperature_units 
	AFTER INSERT or update or delete ON cttemperature_units
	FOR EACH ROW 
BEGIN 
	insert into log_cttemperature_units ( 
		username, 
		when,
		n_temperature_units,
		n_DESCRIPTION,
		o_temperature_units,
		o_DESCRIPTION
	) values (
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.temperature_units,
		:NEW.DESCRIPTION,
		:OLD.temperature_units,
		:OLD.DESCRIPTION
	);
END;
/
	

insert into cttemperature_units (temperature_units,DESCRIPTION) values ('celsius','https://en.wikipedia.org/wiki/Celsius');
insert into cttemperature_units (temperature_units,DESCRIPTION) values ('fahrenheit','https://en.wikipedia.org/wiki/Fahrenheit');
insert into cttemperature_units (temperature_units,DESCRIPTION) values ('kelvin','https://en.wikipedia.org/wiki/Kelvin');

