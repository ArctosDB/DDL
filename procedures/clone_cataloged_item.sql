CREATE OR REPLACE PROCEDURE clone_cataloged_item (
	guid in VARCHAR2,
	newguid out VARCHAR2
)
IS
	oldCollectionObjectID number;
	newCollectionObjectID number;
	oldCollectionID number;
	newCatNum number;
	userAgentID number;
	r_container_id number;
	tempnum number;
	tempstr VARCHAR2(4000);
begin

	--dbms_output.put_line('making clone of ' || guid);

	SELECT  
    	/*+ RESULT_CACHE */ agent_id 
    INTO 
    	userAgentID 
    FROM 
    	agent_name 
    WHERE 
    	agent_name_type ='login' AND
    	upper(agent_name)=sys_context('USERENV', 'SESSION_USER')
    ;    

    -- we need next values for parts so have to grab a static copy
    select sq_collection_object_id.nextval into newCollectionObjectID from dual;

	select 
		cataloged_item.collection_object_id,
		cataloged_item.collection_id,
		collection.guid_prefix
	into 
		oldCollectionObjectId,
		oldCollectionID,
		tempstr
	from 
		cataloged_item,
		collection 
	where 
		cataloged_item.collection_id=collection.collection_id and
		guid_prefix || ':' || cat_num=guid;
	
	--dbms_output.put_line('got old IDs');


	select max(to_number(cat_num)) + 1 into newCatNum from cataloged_item where collection_id=oldCollectionID;
	

	--dbms_output.put_line('making ' || newCatNum);
	
	newguid:=tempstr || ':' || newCatNum;

	INSERT INTO coll_object (
		COLLECTION_OBJECT_ID,
		COLL_OBJECT_TYPE,
		ENTERED_PERSON_ID,
		COLL_OBJECT_ENTERED_DATE,
		COLL_OBJ_DISPOSITION,
		LOT_COUNT,
		CONDITION,
		FLAGS
	) VALUES (
		newCollectionObjectID,
		'CI',
		userAgentID,
		sysdate,
		'not applicable',
		1,
		'not applicable',
		(select flags from coll_object where collection_object_id=oldCollectionObjectId)
	);	
	
	INSERT INTO cataloged_item (
		COLLECTION_OBJECT_ID,
		CAT_NUM,
		ACCN_ID,
		COLLECTION_CDE,
		CATALOGED_ITEM_TYPE,
		COLLECTION_ID
		) (
		select
			newCollectionObjectID,
			newCatNum,
			accn_id,
			collection_cde,
			CATALOGED_ITEM_TYPE,
			COLLECTION_ID
		from
			cataloged_item
		where
			collection_object_id=oldCollectionObjectID
	);
	
	for r in (select * from specimen_event where collection_object_id=oldCollectionObjectId) loop
		insert into specimen_event (
			COLLECTION_OBJECT_ID,
            COLLECTING_EVENT_ID,
            ASSIGNED_BY_AGENT_ID,
            ASSIGNED_DATE,
            SPECIMEN_EVENT_REMARK,
            SPECIMEN_EVENT_TYPE,
            COLLECTING_METHOD,
            COLLECTING_SOURCE,
            VERIFICATIONSTATUS,
            HABITAT
        ) VALUES (
            newCollectionObjectID,
            r.COLLECTING_EVENT_ID,
            r.ASSIGNED_BY_AGENT_ID,
            r.ASSIGNED_DATE,
            r.SPECIMEN_EVENT_REMARK,
            r.SPECIMEN_EVENT_TYPE,
            r.COLLECTING_METHOD,
            r.COLLECTING_SOURCE,
            r.VERIFICATIONSTATUS,
            r.HABITAT
        );
 	end loop;
    
 	for r in (select * from identification where collection_object_id=oldCollectionObjectId) loop
 		insert into identification (
			IDENTIFICATION_ID,
			COLLECTION_OBJECT_ID,
			MADE_DATE,
			NATURE_OF_ID,
			ACCEPTED_ID_FG,
			IDENTIFICATION_REMARKS,
			TAXA_FORMULA,
			SCIENTIFIC_NAME
		) values (
			sq_identification_id.nextval,
			newCollectionObjectID,
			r.MADE_DATE,
			r.NATURE_OF_ID,
			r.ACCEPTED_ID_FG,
			r.IDENTIFICATION_REMARKS,
			r.TAXA_FORMULA,
			r.SCIENTIFIC_NAME
		);
		
		for x in (select * from identification_taxonomy where identification_id=r.IDENTIFICATION_ID) loop
			insert into identification_taxonomy (
				IDENTIFICATION_ID,
				TAXON_NAME_ID,
				VARIABLE
			) values (
				sq_identification_id.currval,
				x.TAXON_NAME_ID,
				x.VARIABLE
			);
		end loop;
		for x in (select * from identification_agent where identification_id=r.IDENTIFICATION_ID) loop
			insert into identification_agent (
				IDENTIFICATION_ID,
				AGENT_ID,
				IDENTIFIER_ORDER
			) values (
				sq_identification_id.currval,
				x.AGENT_ID,
				x.IDENTIFIER_ORDER
			);
		end loop;
		for z in (select * from citation where IDENTIFICATION_ID=r.IDENTIFICATION_ID) loop
			insert into citation (
				CITATION_ID,
				IDENTIFICATION_ID,
				PUBLICATION_ID,
				COLLECTION_OBJECT_ID,
				OCCURS_PAGE_NUMBER,
				TYPE_STATUS,
				CITATION_REMARKS
			) values (
				sq_CITATION_ID.nextval,
				sq_identification_id.currval,
				z.PUBLICATION_ID,
				newCollectionObjectID,
				z.OCCURS_PAGE_NUMBER,
				z.TYPE_STATUS,
				z.CITATION_REMARKS
			);
		end loop;
	end loop;
	insert into coll_object_remark (
		COLLECTION_OBJECT_ID,
		COLL_OBJECT_REMARKS,
		ASSOCIATED_SPECIES
	)  ( select
			newCollectionObjectID,
			COLL_OBJECT_REMARKS,
			ASSOCIATED_SPECIES
		from
			coll_object_remark
		where
			collection_object_id=oldCollectionObjectId				
	);
			
	for r in (
		select
			coll_object.COLLECTION_OBJECT_ID,
			COLL_OBJECT_TYPE,
			ENTERED_PERSON_ID,
			COLL_OBJECT_ENTERED_DATE,
			COLL_OBJ_DISPOSITION,
			LOT_COUNT,
			CONDITION,
			PART_NAME,
			DERIVED_FROM_CAT_ITEM,
			coll_object_remarks,
			container.parent_container_id
		FROM
			coll_object,
			specimen_part,
			coll_object_remark,
			coll_obj_cont_hist,
			container
		where
			coll_object.COLLECTION_OBJECT_ID=specimen_part.COLLECTION_OBJECT_ID and
			specimen_part.DERIVED_FROM_CAT_ITEM=oldCollectionObjectId and
			specimen_part.COLLECTION_OBJECT_ID=coll_object_remark.COLLECTION_OBJECT_ID (+) and
			specimen_part.COLLECTION_OBJECT_ID=coll_obj_cont_hist.COLLECTION_OBJECT_ID (+) and
			coll_obj_cont_hist.container_id=container.container_id (+)
	) loop
		INSERT INTO coll_object (
			COLLECTION_OBJECT_ID,
			COLL_OBJECT_TYPE,
			ENTERED_PERSON_ID,
			COLL_OBJECT_ENTERED_DATE,
			COLL_OBJ_DISPOSITION,
			LOT_COUNT,
			CONDITION 
		) VALUES (
			sq_collection_object_id.nextval,
			'SP',
			userAgentID,
			sysdate,
			r.COLL_OBJ_DISPOSITION,
			r.LOT_COUNT,
			r.CONDITION   
		);
		INSERT INTO specimen_part (	
			COLLECTION_OBJECT_ID,
			PART_NAME,
			DERIVED_FROM_CAT_ITEM
		) VALUES (
			sq_collection_object_id.currval,
			r.PART_NAME,
			newCollectionObjectID
		);
		if r.coll_object_remarks is not null then
			INSERT INTO coll_object_remark (
				collection_object_id, 
				coll_object_remarks
			) VALUES (
				sq_collection_object_id.currval, 
				r.coll_object_remarks
			);
		end if;
		if r.parent_container_id is not null then
			--dbms_output.put_line ('made coll_obj_cont_hist');
		    -- find the container_id of the part we just made
		    select sq_collection_object_id.currval into tempnum from dual;
		    SELECT container_id INTO r_container_id FROM coll_obj_cont_hist WHERE collection_object_id = tempnum;
		    --dbms_output.put_line ('CURRENT part IS : ' || r_container_id);
			UPDATE 
				container 
			SET 
				parent_container_id = r.parent_container_id
			WHERE 
				container_id = r_container_id;
		end if;
		for l in (select * from loan_item where COLLECTION_OBJECT_ID=r.COLLECTION_OBJECT_ID) loop
			insert into loan_item (
				TRANSACTION_ID ,
				COLLECTION_OBJECT_ID,
				RECONCILED_BY_PERSON_ID,
				RECONCILED_DATE,
				ITEM_DESCR,
				ITEM_INSTRUCTIONS,
				LOAN_ITEM_REMARKS
			) values (
				l.TRANSACTION_ID ,
				sq_collection_object_id.currval ,
				l.RECONCILED_BY_PERSON_ID,
				l.RECONCILED_DATE,
				l.ITEM_DESCR,
				l.ITEM_INSTRUCTIONS,
				l.LOAN_ITEM_REMARKS
			);
		end loop;
	end loop;
	for r in (select * FROM coll_obj_other_id_num where COLLECTION_OBJECT_ID=oldCollectionObjectId) loop
		insert into coll_obj_other_id_num (
			COLLECTION_OBJECT_ID,
			OTHER_ID_TYPE,
			OTHER_ID_PREFIX,
			OTHER_ID_NUMBER,
			OTHER_ID_SUFFIX,
			DISPLAY_VALUE,
			COLL_OBJ_OTHER_ID_NUM_ID,
			ID_REFERENCES
		) values (
			newCollectionObjectID,
			r.OTHER_ID_TYPE,
			r.OTHER_ID_PREFIX,
			r.OTHER_ID_NUMBER,
			r.OTHER_ID_SUFFIX,
			r.DISPLAY_VALUE,
			sq_COLL_OBJ_OTHER_ID_NUM_ID.nextval,
			r.ID_REFERENCES
		);
	end loop;
	for r in (select * FROM attributes where COLLECTION_OBJECT_ID=oldCollectionObjectId) loop
		insert into attributes (
			ATTRIBUTE_ID,
			COLLECTION_OBJECT_ID,
			DETERMINED_BY_AGENT_ID,
			ATTRIBUTE_TYPE,
			ATTRIBUTE_VALUE,
			ATTRIBUTE_UNITS,
			ATTRIBUTE_REMARK,
			DETERMINED_DATE,
			DETERMINATION_METHOD 
		) values (
			sq_ATTRIBUTE_ID.nextval,
			newCollectionObjectID,
			r.DETERMINED_BY_AGENT_ID,
			r.ATTRIBUTE_TYPE,
			r.ATTRIBUTE_VALUE,
			r.ATTRIBUTE_UNITS,
			r.ATTRIBUTE_REMARK,
			r.DETERMINED_DATE,
			r.DETERMINATION_METHOD 
		);
	end loop;
	for r in (select * FROM coll_object_encumbrance where COLLECTION_OBJECT_ID=oldCollectionObjectId) loop
		insert into coll_object_encumbrance (
			ENCUMBRANCE_ID,
			COLLECTION_OBJECT_ID
		) values (
			r.ENCUMBRANCE_ID,
			newCollectionObjectID
		);
	end loop;

	-- cataloged item "data loans"
	for l in (select * from loan_item where COLLECTION_OBJECT_ID=oldCollectionObjectId) loop
		insert into loan_item (
			TRANSACTION_ID ,
			COLLECTION_OBJECT_ID,
			RECONCILED_BY_PERSON_ID,
			RECONCILED_DATE,
			ITEM_DESCR,
			ITEM_INSTRUCTIONS,
			LOAN_ITEM_REMARKS
		) values (
			l.TRANSACTION_ID ,
			newCollectionObjectID,
			l.RECONCILED_BY_PERSON_ID,
			l.RECONCILED_DATE,
			l.ITEM_DESCR,
			l.ITEM_INSTRUCTIONS,
			l.LOAN_ITEM_REMARKS
		);
	end loop;
	for r in (select * from collector where COLLECTION_OBJECT_ID=oldCollectionObjectId) loop
		insert into collector (
			COLLECTION_OBJECT_ID,
			AGENT_ID,
			COLLECTOR_ROLE,
			COLL_ORDER
		) values (
			newCollectionObjectID,
			r.AGENT_ID,
			r.COLLECTOR_ROLE,
			r.COLL_ORDER
		);
	end loop;

end;
/

sho err;

create or replace public synonym clone_cataloged_item for clone_cataloged_item;
	grant execute on clone_cataloged_item to global_admin;


-- exec clone_cataloged_item('UAM:Mamm:12');

