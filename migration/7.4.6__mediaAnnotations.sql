alter table annotations add media_id number;


CREATE OR REPLACE FUNCTION getAnnotationObject (aid in NUMBER )
	return varchar2
	AS
		ano annotations%rowtype;
		
		sname varchar2(4000);
		result varchar2(4000);
		tresult varchar2(4000);
		publink varchar2(4000);
		sep varchar2(2) :='';
	BEGIN
		
		result:='boogity';
		
		select * into ano from annotations  where annotation_id=aid;
		if ano.collection_object_id is not null then
			select '<a href="/guid/' || guid || '">' || guid || ' (' || scientific_name || ')</a>' into result from flat where collection_object_id=ano.collection_object_id;
			--dbms_output.put_line('specimen');
			--result:='specimen';
		elsif ano.taxon_name_id is not null then
			select '<a href="/name/' || scientific_name || '">' || scientific_name || '</a>' into result from taxon_name where taxon_name_id=ano.taxon_name_id;
		elsif ano.project_id is not null then
			select '<a href="/project/' || niceURL(PROJECT_NAME) || '">' || PROJECT_NAME || '</a>' into result from project where project_id=ano.project_id;
		elsif ano.publication_id is not null then
			select '<a href="/publication/' || publication_id || '">' || SHORT_CITATION || '</a>' into result from publication where publication_id=ano.publication_id;
		elsif ano.media_id is not null then
			select '<a href="/media/' || media_id || '"> Media ' || media_id || '</a>' into result from media where media_id=ano.media_id;
	end if;
		
		
		
		return result;
	END;
/
sho err;


create or replace public synonym getAnnotationObject for getAnnotationObject;
grant execute on getAnnotationObject to public;





insert into CTMEDIA_RELATIONSHIP (MEDIA_RELATIONSHIP,DESCRIPTION) values 
	('documents borrow','Documentation in support of transaction type "borrow."');
	


