insert into CTMEDIA_RELATIONSHIP (MEDIA_RELATIONSHIP,DESCRIPTION) values 
	('describes taxon_name','Media which documents or describes a taxon name or concept.');
	
	
update media_relations set MEDIA_RELATIONSHIP='describes taxon_name' where MEDIA_RELATIONSHIP='describes taxonomy';


delete from CTMEDIA_RELATIONSHIP where MEDIA_RELATIONSHIP='describes taxonomy';


drop view taxonomy;

drop public synonym taxonomy;

rebuild media_flat


