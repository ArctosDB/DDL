

drop table container_environment;


 
 create table container_environment (
 	container_environment_id number not null,
 	container_id number not null,
 	check_date date not null,
	checked_by_agent_id number not null,
 	parameter_type varchar2(60) not null,
 	parameter_value number not null,
	remark varchar2(4000)
 );
 
 
 ALTER TABLE container_environment ADD CONSTRAINT pk_container_environment 
 	PRIMARY KEY (container_environment_id) USING INDEX TABLESPACE UAM_IDX_1;

-- drop table ctcontainer_env_parameter;
 
 
 create table ctcontainer_env_parameter (
 	parameter_type  varchar2(60) not null,
 	description varchar2(4000) not null
 );
 
 insert into ctcontainer_env_parameter (
 	parameter_type,
 	description
 ) values (
 	'ethanol concentration',
 	'Ethanol concentration. Number between 0 (none detected) and 1 (100%).'	
 );
 
 insert into ctcontainer_env_parameter (
 	parameter_type,
 	description
 ) values (
 	'isopropanol concentration',
 	'Isopropanol concentration. Number between 0 (none detected) and 1 (100%).'	
 );
 
 insert into ctcontainer_env_parameter (
 	parameter_type,
 	description
 ) values (
 	'checked',
 	'Indicates container was checked, but nothing was measured. Only valid value is "1."'	
 );

 insert into ctcontainer_env_parameter (
 	parameter_type,
 	description
 ) values (
 	'temperature (C)',
 	'Measured temparature in celcius. Number.'	
 );

 insert into ctcontainer_env_parameter (
 	parameter_type,
 	description
 ) values (
 	'relative humidity (%)',
 	'Measured relative humidity. Number between 0 and 100.'	
 );

 
 create table log_ctcontainer_env_parameter ( 
	username varchar2(60),	
	when date default sysdate,
	n_parameter_type varchar2(60),
	n_DESCRIPTION varchar2(4000),
	o_parameter_type varchar2(60),
	o_DESCRIPTION varchar2(4000)
);

create or replace public synonym log_ctcontainer_env_parameter for log_ctcontainer_env_parameter;

grant select on log_ctcontainer_env_parameter to coldfusion_user;



CREATE OR REPLACE TRIGGER TR_log_ctcontr_env_parameter
	AFTER INSERT or update or delete ON ctcontainer_env_parameter
	FOR EACH ROW 
BEGIN 
	insert into log_ctcontainer_env_parameter ( 
		username, 
		when,
		n_parameter_type,
		n_DESCRIPTION,
		o_parameter_type,
		o_DESCRIPTION
	) values (
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.parameter_type,
		:NEW.DESCRIPTION,
		:OLD.parameter_type,
		:OLD.DESCRIPTION
	);
END;
/
	



ALTER TABLE ctcontainer_env_parameter ADD CONSTRAINT pk_ctcontainer_env_parameter PRIMARY KEY (parameter_type) 
 	USING INDEX TABLESPACE UAM_IDX_1;

ALTER TABLE container_environment add CONSTRAINT fk_parameter_type FOREIGN KEY 
	(parameter_type) REFERENCES ctcontainer_env_parameter (parameter_type);

	
ALTER TABLE container_environment add CONSTRAINT fk_cenv_container_id FOREIGN KEY 
	(container_id) REFERENCES container (container_id);
	
	
create sequence sq_container_environment_id;

create public synonym sq_container_environment_id for sq_container_environment_id;
grant select on sq_container_environment_id to public;



create public synonym container_environment for container_environment;
grant all on container_environment to manage_container;
grant select on container_environment to coldfusion_user;

create public synonym ctcontainer_env_parameter for ctcontainer_env_parameter;
grant all on ctcontainer_env_parameter to manage_codetables;
grant select on ctcontainer_env_parameter to public;


CREATE OR REPLACE TRIGGER trg_cmpd_container_environment
FOR insert or update or DELETE ON container_environment
COMPOUND TRIGGER
    BEFORE EACH ROW IS BEGIN
	    if inserting then
	    	if :NEW.container_environment_id is null then
	    		select sq_container_environment_id.nextval into :NEW.container_environment_id from dual;
	    	end if;
	    	if :NEW.checked_by_agent_id is null then
	    		select 
					agent_id 
				into 
					:NEW.checked_by_agent_id 
				from
					agent_name 
				where 
					agent_name_type='login' and 
					upper(agent_name)=sys_context('USERENV', 'SESSION_USER')
				;
			end if;
			if :NEW.check_date is null then
				:NEW.check_date:=sysdate;
			end if;
		end if;
		if inserting or updating then
			if :NEW.parameter_type = 'ethanol concentration' then
				if :NEW.parameter_value not between 0 and 1 then
					RAISE_APPLICATION_ERROR(-20001,'ethanol concentration must be between 0 and 1');
				end if;
			elsif :NEW.parameter_type = 'isopropanol concentration' then
				if :NEW.parameter_value not between 0 and 1 then
					RAISE_APPLICATION_ERROR(-20001,'isopropanol concentration must be between 0 and 1');
				end if;
			elsif :NEW.parameter_type = 'checked' then
				if :NEW.parameter_value != 1 then
					RAISE_APPLICATION_ERROR(-20001,'checked may be only 1');
				end if;
			elsif :NEW.parameter_type = 'temperature (C)' then
				-- rock on
				null;
			elsif :NEW.parameter_type = 'relative humidity (%)' then
				if :NEW.parameter_value not between 0 and 100 then
					RAISE_APPLICATION_ERROR(-20001,'relative humidity (%) must be between 0 and 100.');
				end if;
			else
				RAISE_APPLICATION_ERROR(-20001,:NEW.parameter_type || ' is not handled; contact a DBA');
			end if;
		end if; 
	end BEFORE EACH ROW;
END;
/
sho err;

-- migrate container_check

select count(*) from container_check;
--120

lock table container_check in exclusive mode nowait;

insert into container_environment (
	container_environment_id,
	container_id,
	check_date,
	checked_by_agent_id,
	parameter_type,
	parameter_value,
	remark
) (
	select
		sq_container_environment_id.nextval,
		CONTAINER_ID,
		CHECK_DATE,
		CHECKED_AGENT_ID,
		'checked',
		1,
		CHECK_REMARK
	from
		container_check
);

-- 120 rows created.

drop public synonym container_check;


-- migrate fluid_container_history


select count(*) from fluid_container_history;
-- 826
lock table fluid_container_history in exclusive mode nowait;



insert into container_environment (
	container_environment_id,
	container_id,
	check_date,
	checked_by_agent_id,
	parameter_type,
	parameter_value,
	remark
) (
	select
		sq_container_environment_id.nextval,
		CONTAINER_ID,
		CHECKED_DATE,
		0,
		decode(FLUID_TYPE,
			'ethanol','ethanol concentration',
			'isopropanol','isopropanol concentration',
			'error_on_this'
		),
		CONCENTRATION,
		FLUID_REMARKS
	from
		fluid_container_history
);

select count(*) from container_environment;
--946
select 946-120 from dual
-- checks out

-- hide but keep for now the old tables

drop public synonym fluid_container_history;


-- big data?
-- create test agent: 21286538
-- test container: 2815064

declare
	t number;
 begin
	 for r in 1..10000 loop
	 	
	 	select dbms_random.value(-38,-42) into t from dual;
	 
	 	insert into container_environment (
			container_id,
			check_date,
			checked_by_agent_id,
			parameter_type,
			parameter_value
		) values (
			2815064,
			sysdate,
			21286538,
			'temperature (C)',
			t
		);
	 end loop;
 end;
/




new test:

http://arctos-test.tacc.utexas.edu/EditContainer.cfm?container_id=12571227
http://arctos-test.tacc.utexas.edu/guid/MVZ:Herp:178059




-- function to concatenate summary of all attributes for a specimen
-- Pass in 1 for forceEncumbrance to force the function to consider attributes, regardless of current user
-- eg, return encumbered records __AS UAM__ for eg, the purposes of maintaining filtered_flat

drop function getLastContainerEnvironmeny;

CREATE OR REPLACE FUNCTION getLastContainerEnvironment (cid in number)
return varchar2 as
	l_str    varchar2(4000);
begin
	select blurb into
		l_str
		from (
		select 
			parameter_type || '=' || parameter_value || '@' || to_char(check_date,'yyyy-mm-dd') blurb
		from 
			container_environment
		where
			container_id=cid
		order by 
			check_date desc
	)
	where
		rownum=1;
	return l_str;
  end;
/

create or replace public synonym getLastContainerEnvironment for getLastContainerEnvironment;
grant execute on getLastContainerEnvironment to public;

select getLastContainerEnvironment(12571227) from dual;
select getLastContainerEnvironment(12029914) from dual;



CREATE OR REPLACE FUNCTION getContainerStackEnvironment (cid in number)
return varchar2 as
	l_str    varchar2(4000);
begin
	select blurb into
		l_str
		from (
		select 
			parameter_type || '=' || parameter_value || '@' || to_char(check_date,'yyyy-mm-dd') blurb
		from 
			container_environment
		where
			container_id=cid
		order by 
			check_date desc
	)
	where
		rownum=1;
		
	return l_str;				
  end;
/




 
 ---- bulkloader
 
 
 drop table cf_container_environment;
 
 create table cf_container_environment (
 	barcode varchar2(60) not null,
 	check_date date not null,
	checked_by_agent varchar2(60) not null,
 	parameter_type varchar2(60) not null,
 	parameter_value number not null,
	remark varchar2(4000),
	container_id number,
	agent_id number,
	status varchar2(4000)
 );
 
create or replace public synonym cf_container_environment for cf_container_environment;
grant all on cf_container_environment to manage_container;

 