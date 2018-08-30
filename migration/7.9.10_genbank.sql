-- group authors and such into a "batch" - sequences that share authors and such
drop table genbank_people;
drop table genbank_sequence;
drop table genbank_batch;

create table genbank_batch (
	genbank_batch_id number not null,
	contact_agent_id number not null,
	batch_name varchar2(255) not null,
	first_name varchar2(255) not null,
	middle_initial varchar2(255) not null,
	last_name varchar2(255) not null,
	email varchar2(255) not null,
	organization varchar2(255) not null,
	department varchar2(255) not null,
	phone varchar2(255),
	fax varchar2(255),
	street varchar2(255) not null,
	city varchar2(255) not null,
	state_prov varchar2(255) not null,
	postal_code varchar2(255) not null,
	country varchar2(255) not null,
	ref_title varchar2(255) not null,
	biosample varchar2(255),
	bioproject varchar2(255)
);
	




alter table genbank_batch add constraint PK_genbank_batch_id PRIMARY KEY (genbank_batch_id) using index TABLESPACE UAM_IDX_1;

create unique index ix_u_gb_batchname on genbank_batch(batch_name) tablespace uam_idx_1;


create or replace public synonym genbank_batch for genbank_batch;
grant all on genbank_batch to coldfusion_user;

-- the people involved; pull from Agents as much as possible
-- maybe add a new agent address to accommodate these data
-- and a "save to your agent record for next time" button on the seq form


create table genbank_people (
	genbank_people_id number not null,
	genbank_batch_id number not null,
	agent_id number not null,
	agent_role varchar2(255) not null,
	first_name varchar2(255) not null,
	middle_initial varchar2(255) ,
	last_name varchar2(255) not null,
	agent_order number not null
);


alter table genbank_people add constraint PK_genbank_people_id PRIMARY KEY (genbank_people_id) using index TABLESPACE UAM_IDX_1;
ALTER TABLE genbank_people ADD CONSTRAINT fk_gb_ppl_batch FOREIGN KEY (genbank_batch_id) REFERENCES genbank_batch(genbank_batch_id);
ALTER TABLE genbank_people ADD CONSTRAINT fk_gb_people_agent FOREIGN KEY (agent_id) REFERENCES agent(agent_id);


create or replace public synonym genbank_people for genbank_people;
grant all on genbank_people to coldfusion_user;


-- sequence and metadata
-- need to hear back from MSB folks
-- I have no idea what goes here...

create table genbank_sequence (
	sequence_id number not null,
	genbank_batch_id number not null,
	sequence_identifier varchar2(50) not null,
	collection_object_id number not null,
	sequence_data clob
);

-- https://www.ncbi.nlm.nih.gov/biosample/docs/attributes/
-- source_material_id:
  -- unique identifier assigned to a material sample used for extracting nucleic acids, and subsequent sequencing. The identifier can refer either to the original material collected or to any derived sub-samples.
-- tissue
  -- Type of tissue the sample was taken from.
alter table genbank_sequence add source_material_id varchar2(255);
alter table genbank_sequence add tissue varchar2(255);



alter table genbank_sequence add constraint PK_genbank_sequence_id PRIMARY KEY (sequence_id) using index TABLESPACE UAM_IDX_1;
ALTER TABLE genbank_sequence ADD CONSTRAINT fk_gb_sq_batch FOREIGN KEY (genbank_batch_id) REFERENCES genbank_batch(genbank_batch_id);
ALTER TABLE genbank_sequence ADD CONSTRAINT fk_gb_sq_specimen FOREIGN KEY (collection_object_id) REFERENCES cataloged_item(collection_object_id);
 create unique index ix_u_gb_sq_id on genbank_sequence(genbank_batch_id,sequence_identifier) tablespace uam_idx_1;

create or replace public synonym genbank_sequence for genbank_sequence;
grant all on genbank_sequence to coldfusion_user;



-- new address type for this
-- try to not make people type this stuff too much!
insert into CTADDRESS_TYPE (ADDRESS_TYPE,DESCRIPTION) values ('formatted JSON','Address components as JSON data objects. Init: used to populate GenBank submission form.')


insert into cf_form_permissions (FORM_PATH,ROLE_NAME) values ('/tools/genbank_submit.cfm','coldfusion_user');
        
        
curl ftp://ftp.ncbi.nih.gov/toolbox/ncbi_tools/converters/by_program/tbl2asn/linux.tbl2asn.gz --output linux.tbl2asn.gz
sudo mv linux.tbl2asn /usr/local/bin/
chmod +x linux.tbl2asn                       
                        