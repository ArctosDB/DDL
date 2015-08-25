create table ctaddress_type (
	address_type varchar2(25) not null,
	description varchar2(4000)
);

create or replace public synonym ctaddress_type for ctaddress_type;
grant all on ctaddress_type to manage_codetables;
grant select on ctaddress_type to public;

ALTER TABLE ctaddress_type ADD CONSTRAINT pk_ctaddress_type PRIMARY KEY (address_type) USING INDEX TABLESPACE UAM_IDX_1;

insert into ctaddress_type (address_type,description) (select ADDR_TYPE,DESCRIPTION from CTADDR_TYPE);
insert into ctaddress_type (address_type,description) (select ADDRESS_TYPE,DESCRIPTION from CTELECTRONIC_ADDR_TYPE);

 
create table address (
	address_id number not null,
	agent_id number not null,
	address_type varchar2(255) not null,
	address varchar2(4000) NOT NULL,
	VALID_ADDR_FG number not null,
	address_remark varchar2(4000) NULL,
 	CHECK (VALID_ADDR_FG in (0,1))
);
 	
 
create public synonym address for address;
grant all on address to manage_agents;

ALTER TABLE address ADD CONSTRAINT pk_address PRIMARY KEY (address_id) USING INDEX TABLESPACE UAM_IDX_1;

ALTER TABLE address add CONSTRAINT fk_address_type FOREIGN KEY (address_type) REFERENCES ctaddress_type (address_type);
ALTER TABLE address add CONSTRAINT fk_address_agent FOREIGN KEY (agent_id) REFERENCES agent (agent_id);

insert into address (
	address_id,
	agent_id,
	address_type,
	address,
	VALID_ADDR_FG,
	address_remark
)(
	select
		ADDR_ID,
		AGENT_ID,
		ADDR_TYPE,
		FORMATTED_ADDR,
		VALID_ADDR_FG,
		ADDR_REMARKS
	from
	addr)
	;

	commit;
	
	
	
	SELECT a.table_name, a.column_name, a.constraint_name, c.owner, 
       -- referenced pk
       c.r_owner, c_pk.table_name r_table_name, c_pk.constraint_name r_pk
  FROM all_cons_columns a
  JOIN all_constraints c ON a.owner = c.owner
                        AND a.constraint_name = c.constraint_name
  JOIN all_constraints c_pk ON c.r_owner = c_pk.owner
                           AND c.r_constraint_name = c_pk.constraint_name
 WHERE c.constraint_type = 'R'
   AND a.table_name = 'ADDR';


select *
from
    all_constraints
where
    r_constraint_name in
    (select       constraint_name
    from
       all_constraints
    where
       table_name='ADDR')
;   


lock table shipment in exclusive mode nowait;

alter table shipment drop constraint FK_SHIPMENT_ADDR_SHIPPEDFROM;

ALTER TABLE shipment add CONSTRAINT FK_SHIPMENT_ADDR_SHIPPEDFROM FOREIGN KEY (SHIPPED_FROM_ADDR_ID) REFERENCES address (address_id);


alter table shipment drop constraint FK_SHIPMENT_ADDR_SHIPPEDTO;
ALTER TABLE shipment add CONSTRAINT FK_SHIPMENT_ADDR_SHIPPEDTO FOREIGN KEY (SHIPPED_TO_ADDR_ID) REFERENCES address (address_id);

-- now have all old constraints pointing at new table

commit;







drop SEQUENCE sq_address_id;
drop PUBLIC SYNONYM sq_address_id;

select max(address_id) + 1 from address;

CREATE SEQUENCE sq_address_id start with 10002801 increment by 1;

CREATE PUBLIC SYNONYM sq_address_id FOR sq_address_id;
GRANT SELECT ON sq_address_id TO PUBLIC;





update address set address_type='Correspondence', VALID_ADDR_FG=0 where address_type='Previous';
 
delete from ctaddress_type where address_type='Previous';





 insert into address (
	agent_id,
	address_type,
	address,
	VALID_ADDR_FG
)(
	select
		AGENT_ID,
		ADDRESS_TYPE,
		ADDRESS,
		1
	from
	electronic_address)
	;
	
	

-- make things more consistent

	ALTER TABLE address drop CONSTRAINT fk_address_type;
	update address set address_type='email' where address_type='e-mail';
	update ctaddress_type set address_type='email' where address_type='e-mail';
	
	update address set address_type='shipping' where address_type='Shipping';
	update ctaddress_type set address_type='shipping' where address_type='Shipping';
	
	update address set address_type='url' where address_type='URL';
	update ctaddress_type set address_type='url' where address_type='URL';
	
	update address set address_type='correspondence' where address_type='Correspondence';
	update ctaddress_type set address_type='correspondence' where address_type='Correspondence';

	update address set address_type='home' where address_type='Home';
	update ctaddress_type set address_type='home' where address_type='Home';

	ALTER TABLE address add CONSTRAINT fk_address_type FOREIGN KEY (address_type) REFERENCES ctaddress_type (address_type);

	
	
update ctaddress_type set description='Mailing address for letters. Format is {Name, Job Title} [new line] {Full Mailing Address, including country and zip or equivilant}.' where ADDRESS_TYPE='correspondence';
update ctaddress_type set description='Shipping address for packages. Format is {Name, Job Title} [new line] {Full Mailing Address, including country and zip or equivilant}.' where ADDRESS_TYPE='shipping';
update ctaddress_type set description='Personal mailing address. Format is {Name, Job Title} [new line] {Full Mailing Address, including country and zip or equivilant}.' where ADDRESS_TYPE='home';


 

CREATE OR REPLACE FUNCTION get_address(p_key_val IN NUMBER )...... this code is in the DDL folder

-- save job title, for some reason....

insert into  ctagent_name_type (AGENT_NAME_TYPE,DESCRIPTION) values ('job title','current job title (rescued from old addr table)');

-- blargh
update agent_name set agent_name=t


declare
	c number;
begin
	for r in (select job_title, agent_id from addr where trim(job_title) is not null) loop
	select count(*) into c from agent_name where agent_name_type='job title' and agent_id=r.agent_id;
	if c=0 then
		insert into agent_name (AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME) values (sq_agent_name_id.nextval,r.agent_id,'job title',trim(r.job_title));
	end if;
	end loop;
end ;
/


-- turn the old stuff off to better detect problems

drop public synonym addr;
drop public synonym electronic_address;
REVOKE ALL ON ADDR FROM PUBLIC;
REVOKE ALL ON ADDR FROM UAM_QUERY;
REVOKE ALL ON ADDR FROM MANAGE_TRANSACTIONS;


REVOKE ALL ON ELECTRONIC_ADDRESS FROM MANAGE_TRANSACTIONS;
REVOKE ALL ON ELECTRONIC_ADDRESS FROM PUBLIC;
REVOKE ALL ON ELECTRONIC_ADDRESS FROM UAM_QUERY;



















 --------------reports
 
UAM@ARCTOS> select report_name,sql_text from cf_report_sql;


update cf_report_sql set sql_text='
 SELECT
    trans.trans_date,
    --borrow.LENDERS_TRANS_NUM_CDE,
    --borrow.LENDERS_INVOICE_RETURNED_FG,
    borrow.RECEIVED_DATE,
    borrow.DUE_DATE,
    borrow.LENDERS_LOAN_DATE return_due_date,
    borrow.BORROW_STATUS loan_status,
    borrow.LENDERS_INSTRUCTIONS as loan_instructions,
    borrow.LENDER_LOAN_TYPE,
    borrow.borrow_number loan_number,
    trans.nature_of_material,
    trans.trans_remarks,
    shipment.shipped_date,
   	getPreferredAgentName(shipment.PACKED_BY_AGENT_ID) processed_by_name,
   	concattransagent(trans.transaction_id, ''authorized by'') recAgentName ,
    concattransagent(trans.transaction_id, ''received by'')  authAgentName ,
   -- concattransagent(trans.transaction_id, ''received from'') recFromAgentName,
    shiptoa.address outside_address,
    shipfra.address inside_address,
    shiptoa.address shipped_to_address,
    shipfra.address shipped_from_address,
    '''' project_sponsor_name,
    '''' acknowledgement,
    '''' outside_contact_name,
    '''' inside_contact_name,
    '''' outside_contact_title,
    '''' inside_contact_title,
    '''' inside_email_address,
    '''' outside_email_address,
    '''' loan_description,
    '''' loan_type,
    '''' shipped_date
  FROM
    borrow,
    trans,
    shipment,
    address shiptoa,
    address shipfra
  WHERE
    borrow.transaction_id = trans.transaction_id and
     borrow.transaction_id = shipment.transaction_id (+) and
     shipment.SHIPPED_TO_ADDR_ID=shiptoa.address_id (+) and
     shipment.SHIPPED_FROM_ADDR_ID=shipfra.address_id (+) and
     borrow.transaction_id=#transaction_id#
' where report_name='CUMV_BORROW_TEMP';


 ALTER TABLE ADDR DROP CONSTRAINT FK_ADDR_AGENT;
 ALTER TABLE ELECTRONIC_ADDRESS DROP CONSTRAINT FK_ELECTRONICADDR_AGENT;

drop trigger TR_ADDR_BU
drop procedure add_new_addr;

-- run triggers/address.sql
-- run procedures/add_new_address.sql
