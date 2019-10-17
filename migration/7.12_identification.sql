-- https://github.com/ArctosDB/arctos/issues/2170#issuecomment-514784485
------------------------------------- oracle -------------------------------------
create table ctidentification_confidence (
	identification_confidence varchar2(30) not null,
	description varchar2(4000) not null
);


create or replace public synonym ctidentification_confidence for ctidentification_confidence;
grant select on ctidentification_confidence to public;

alter table ctidentification_confidence add constraint pkidentification_confidence primary key (identification_confidence);

insert into ctidentification_confidence (identification_confidence,description) values ('high','Determiner(s), or collection personnel on behalf of determiners(s), have high confidence that the identification is correct.');
insert into ctidentification_confidence (identification_confidence,description) values ('medium','Determiner(s), or collection personnel on behalf of determiners(s), have moderate confidence that the identification is correct.');
insert into ctidentification_confidence (identification_confidence,description) values ('low','Determiner(s), or collection personnel on behalf of determiners(s), have low confidence that the identification is correct.');
insert into ctidentification_confidence (identification_confidence,description) values ('unknown','Determiner(s), or collection personnel on behalf of determiners(s), have expressed that they do not know how confident the identification is.');



drop table log_ctident_confidence;

create table log_ctident_confidence ( 
		username varchar2(60),	
		change_date date default sysdate,
		n_identification_confidence varchar2(30)  null,
		n_description varchar2(4000) null,
		o_identification_confidence varchar2(30) null,
		o_description varchar2(4000) null
);

create or replace public synonym log_ctident_confidence for log_ctident_confidence;

grant select on log_ctident_confidence to coldfusion_user;

CREATE OR REPLACE TRIGGER TR_log_ctident_confidence AFTER INSERT or update or delete ON ctidentification_confidence 
FOR EACH ROW 
BEGIN 
	insert into log_ctident_confidence ( 
		username,
		change_date,
		n_identification_confidence,
		n_description,
		o_identification_confidence,
		o_description
	) values ( 
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.identification_confidence,
		:NEW.description,
		:OLD.identification_confidence,
		:OLD.description
	);
END;
/

sho err;



alter table identification add identification_confidence varchar(30);
ALTER TABLE identification ADD CONSTRAINT fk_identification_confidence  FOREIGN KEY (identification_confidence)  REFERENCES ctidentification_confidence(identification_confidence);

alter table cf_temp_id add identification_confidence varchar2(30);

insert into ctnature_of_id (NATURE_OF_ID, DESCRIPTION) values ('fine features','Identification based on close examination of diagnostic traits that may include qualitative observations (e.g., fine-scale feather pattern or shape), quantitative measurements (e.g., scale counts, length measurements), microscopic analysis, CT scan, etc.');
insert into ctnature_of_id (NATURE_OF_ID, DESCRIPTION) values ('function','Identification based on functional attributes. This applies primarily to cultural items, e.g., ''arrow head'' versus ''spear head''.');
insert into ctnature_of_id (NATURE_OF_ID, DESCRIPTION) values ('molecular','Identification based on laboratory analysis comparing the specimen to related taxa by molecular criteria (e.g., DNA sequences, genomics).');
insert into ctnature_of_id (NATURE_OF_ID, DESCRIPTION) values ('geographic distribution','Identification based on known geographic range. Specimen is assumed to be the species or subspecies expected at the collecting locality. This should only be used to supplement another ID, generally to a broader taxon.');
insert into ctnature_of_id (NATURE_OF_ID, DESCRIPTION) values ('coarse features','Identification based on gross examination of diagnostic traits that may include qualitiative assessment of morphology, coloration, structure, etc. Examination of features may be direct (specimen) or indirect (e.g.,  photograph). "Looks like a moose."');
insert into ctnature_of_id (NATURE_OF_ID, DESCRIPTION) values ('karyotype','Identification based on analysis of chromosomes.');
insert into ctnature_of_id (NATURE_OF_ID, DESCRIPTION) values ('relationship','Identification based on the identification of a related individual (e.g., parent, sibling), a maker (e.g., for objects such as nests or cultural items), or of another object that has the same function and/or features (e.g., for cultural items).');
insert into ctnature_of_id (NATURE_OF_ID, DESCRIPTION) values ('audio-visual','Identification based on observations or recordings that include sound (call, song, etc.) and/or video. This could be qualitative or quantitative.');
insert into ctnature_of_id (NATURE_OF_ID, DESCRIPTION) values ('taxonomic revision','Identification based on published taxonomic revision.This designation is appropriate only in the presence of an earlier identification. It implies that a different taxonomic name is being applied without reexamination of the specimen. In most cases this results from taxonomic synonymization of names.');
insert into ctnature_of_id (NATURE_OF_ID, DESCRIPTION) values ('unknown','The nature of the identification is not known. May include legacy identifications.');


update ctnature_of_id set description='LEGACY VALUE: not available for new IDs. ' || description where nature_of_id not in ('fine features','function','molecular','geographic distribution','coarse features','karyotype','relationship','audio-visual','taxonomic revision','unknown');

CREATE OR REPLACE TRIGGER temp_tr_id_biu
before INSERT ON identification
FOR EACH ROW
BEGIN
	-- limit new identifications to the new values
	IF :NEW.nature_of_id not in ('features','fine features','function','molecular','geographic distribution','coarse features','karyotype','relationship','audio-visual','revised taxonomy','unknown') then
		RAISE_APPLICATION_ERROR(-20001,'Legacy nature_of_id terms are disallowed; see https://github.com/ArctosDB/arctos/issues/2170');
	end if;
END;
/

update ctnature_of_id set description='This designation is appropriate only in the presence of an earlier identification. It implies that the specimen has not been reexamined, and only that a different taxonomic name is being applied. In most cases this results from taxonomic synonymization of names.' where nature_of_id='revised taxonomy';


create table temp_bak_identifi_20191002 as select * from identification;

--------------------------------
done
exec pause_maintenance('off');

update 
	identification 
set 
	IDENTIFICATION_REMARKS=decode(
		IDENTIFICATION_REMARKS,
		NULL,'Former nature_of_id: taxonomic revision.',
		IDENTIFICATION_REMARKS || '; Former nature_of_id: taxonomic revision.'
	),
	nature_of_id='revised taxonomy'
where
	nature_of_id='taxonomic revision'
;
	

delete from ctnature_of_id where nature_of_id='taxonomic revision';

exec pause_maintenance('on');
--------------------------------


create table temp_bak_temp as select * from identification;




--------------------------------
done
exec pause_maintenance('off');
lock table identification in exclusive mode nowait;

-- use IDENTIFICATION_REMARKS to break this up a bit

-- not null must be first
update 
	identification 
set 
	IDENTIFICATION_REMARKS=IDENTIFICATION_REMARKS || '; Former nature_of_id: legacy.',
	nature_of_id='unknown'
where
	IDENTIFICATION_REMARKS is not null and
	nature_of_id='legacy'
;


update 
	identification 
set 
	IDENTIFICATION_REMARKS='Former nature_of_id: legacy.',
	nature_of_id='unknown'
where
	IDENTIFICATION_REMARKS is null and 
	nature_of_id='legacy'
;



	
delete from ctnature_of_id where nature_of_id='legacy';
commit;

exec pause_maintenance('on');
--------------------------------


--------------------------------
done
exec pause_maintenance('off');
lock table identification in exclusive mode nowait;


update 
	identification 
set 
	IDENTIFICATION_REMARKS=decode(
		IDENTIFICATION_REMARKS,
		NULL,'Former nature_of_id: molecular data.',
		IDENTIFICATION_REMARKS || '; Former nature_of_id: molecular data.'
	),
	nature_of_id='molecular'
where
	nature_of_id='molecular data'
;

delete from ctnature_of_id where nature_of_id='molecular data';


exec pause_maintenance('on');

  --------------------------------

 
 


--------------------------------
todo

exec pause_maintenance('off');
lock table identification in exclusive mode nowait;

update 
	identification 
set 
	IDENTIFICATION_REMARKS=decode(
		IDENTIFICATION_REMARKS,
		NULL,'Former nature_of_id: ID of kin.',
		IDENTIFICATION_REMARKS || '; Former nature_of_id: ID of kin.'
	),
	nature_of_id='relationship'
where
	nature_of_id='ID of kin'
;

delete from ctnature_of_id where nature_of_id='ID of kin';

exec pause_maintenance('on');


-----------------------------------------

select * from ctnature_of_id where nature_of_id not in ('fine features','function','molecular','geographic distribution','coarse features','karyotype','relationship','audio-visual','taxonomic revision','unknown');


CREATE OR REPLACE TRIGGER trg_accn_datecheck
before INSERT or update ON accn
FOR EACH ROW
	declare status varchar2(255);
BEGIN
	status:=is_iso8601(:NEW.RECEIVED_DATE);
    IF status != 'valid' THEN
        raise_application_error(-20001,'RECEIVED_DATE: ' || status);
    END IF;
END;
/
sho err



	
	
	
	
	
	
	
	
	
	
	
	
	
------------------------------------- pg -------------------------------------

create table ctidentification_confidence (
	identification_confidence varchar(30) not null,
	description varchar(4000) not null
);

grant select on ctidentification_confidence to public;

alter table ctidentification_confidence add constraint pkidentification_confidence primary key (identification_confidence);

insert into ctidentification_confidence (identification_confidence,description) values ('high','Determiner(s), or collection personnel on behalf of determiners(s), have high confidence that the identification is correct.');
insert into ctidentification_confidence (identification_confidence,description) values ('medium','Determiner(s), or collection personnel on behalf of determiners(s), have moderate confidence that the identification is correct.');
insert into ctidentification_confidence (identification_confidence,description) values ('low','Determiner(s), or collection personnel on behalf of determiners(s), have low confidence that the identification is correct.');
insert into ctidentification_confidence (identification_confidence,description) values ('unknown','Determiner(s), or collection personnel on behalf of determiners(s), have expressed that they do not know how confident the identification is.');


create table log_ctident_confidence ( 
		username varchar(60),	
		change_date timestamp default LOCALTIMESTAMP,
		n_identification_confidence varchar(30)  null,
		n_description varchar(4000) null,
		o_identification_confidence varchar(30) null,
		o_description varchar(4000) null
);

	
DROP TRIGGER IF EXISTS TR_log_ctident_confidence ON ctidentification_confidence CASCADE;
CREATE OR REPLACE FUNCTION trigger_fct_TR_log_ctident_confidence() RETURNS trigger AS $BODY$
BEGIN
insert into log_ctidentification_confidence (
	username,
	change_date,
	n_identification_confidence,
	n_DESCRIPTION,
	o_identification_confidence,
	o_DESCRIPTION
) values (
	session_user,
	LOCALTIMESTAMP,
	NEW.identification_confidence,
	NEW.DESCRIPTION,
	OLD.identification_confidence,
	OLD.DESCRIPTION
);
IF TG_OP = 'DELETE' THEN
	RETURN OLD;
ELSE
	RETURN NEW;
END IF;

END
$BODY$
 LANGUAGE 'plpgsql' SECURITY DEFINER;
-- REVOKE ALL ON FUNCTION trigger_fct_tr_log_ctkill_method() FROM PUBLIC;

CREATE TRIGGER TR_log_ctident_confidence
	AFTER INSERT OR UPDATE OR DELETE ON ctidentification_confidence FOR EACH ROW
	EXECUTE PROCEDURE trigger_fct_TR_log_ctident_confidence();

	
	
alter table identification add identification_confidence varchar(30);
ALTER TABLE identification ADD CONSTRAINT fk_identification_confidence  FOREIGN KEY (identification_confidence)  REFERENCES ctidentification_confidence(identification_confidence);

alter table cf_temp_id add identification_confidence varchar(30);


