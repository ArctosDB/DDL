drop table doi;


create table doi (
	doi varchar2(60) not null,
	media_id number null,
	publication_id number null,
	collection_object_id number null,
	agent_id number null,
	project_id number null,
	taxon_name_id number null
);

create or replace public synonym doi for doi;
grant select on doi to public;
       
grant all on doi to global_admin;
       
ALTER TABLE doi add CONSTRAINT pk_doi PRIMARY KEY (doi);


ALTER TABLE doi add CONSTRAINT fk_media_doi FOREIGN KEY (media_id) REFERENCES media(media_id);   
ALTER TABLE doi add CONSTRAINT fk_publication_doi FOREIGN KEY (publication_id) REFERENCES publication(publication_id); 
ALTER TABLE doi add CONSTRAINT fk_catalogeditem_doi FOREIGN KEY (collection_object_id) REFERENCES cataloged_item(collection_object_id);  
ALTER TABLE doi add CONSTRAINT fk_agent_doi FOREIGN KEY (agent_id) REFERENCES agent(agent_id);    
ALTER TABLE doi add CONSTRAINT fk_project_doi FOREIGN KEY (project_id) REFERENCES project(project_id);   

alter table cf_global_settings add ezid_username varchar2(255);
alter table cf_global_settings add ezid_password varchar2(255);

update cf_global_settings set ezid_username='xxxxxxxx',ezid_password='xxxxxxx';


