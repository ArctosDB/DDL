/*
	Arctos v2.5 Release Notes:
	******************************************************************
	We intend to migrate arctos.database.museum to v2.5 on Monday, June 22 after 5PM AKDT. We expect only brief interruptions of 
	service to the public site. Actions which change data should not be attempted during the migration.
	
	A test instance is available at http://arctos-test.arctos.database.museum for those who wish to preview/test this release.
	(Let me know if you have difficulty accessing this site - there are access restrictions.) The following test recommendations
	outline major changes.
	
	Make very sure that you are testing at arctos-test and not in one of the production environments.
	*********************************************************************
	There is now an email reminder that fires when an item has been in the pending relations table for > 30
	days. It, and many other features of Arctos, rely on each collection having at least one collection_contact 
	of type "data quality" and those contacts having an electronic_address of type "e-mail."
	
	Collection Contacts are available from Management/Misc./Manage Collections.
	
	Agent addresses are under Specimen/Agents
	
	Test: Confirm that your collection has these data available if you wish to receive various reminders.
	-------------------------------------------	
	Logins and session expiration are now managed natively by the application. Your login will expire after 90 minutes of inactivity.
	The idea is the same as the previous cookie-based session management, but should now be more predictable. Additionally, this 
	should significantly improve performance as user information is stored in server memory instead of on disk and in cookies.
	
	Test: Login and session management is functional.
	---------------------------------------------
	Object Tracking
		Menu cleaned up
		New unified Find Container form
		Improved Collection Object>>Container form
		Moved 'bulk parts to containers' to tools with other bulkloaders
		see http://code.google.com/p/arctos/issues/detail?id=109 for more
		
	Test: All object tracking applications (excluding the DGR widget).
	--------------------------------------------
	Taxonomy Search now has a 1000-record filter to prevent excess resource allocation to spiders.
	
	Test: Let me know if not being able to return >1000 records poses difficulties. I can bump the value up a bit, or 
		bypass the filter for "power users" if necessary.
	------------------------------------------------
	Added Reports/Write SQL: allows users to submit SELECT statement and return tabular data
	
	Test: Should return data for any valid SQL SELECT statement you can generate. Should error or return nothing
		if you attempt to access non-shared data, or run any DDL or UPDATE code. 
	-----------------------------------------------
	Binary Objects are out. Media is in. In short, Media can:
		1) Do what Binary Object did: link images to specimen records (using a similar interface)
		2) Create linkages between "Media" and most (potentially any) other "node" in Arctos. 
		
		Media is defined as anything you can create a URI to (a URL is one type of URI). Images on the network, 
		images you load to Arctos, web pages (such as MorphBank), and spreadsheets on an FTP site are all 
		potential examples of Media.
		
		Media relationships - the link to Arctos "nodes" - can include such things as
			shows cataloged_item (binary object's replacement)
			taken by agent
			taken at locality
			shows collecting_event
			
	Test: At least as functional as Binary Objects
	-------------------------------------------------
	SpecimenDetail will now accept a case-insensitive GUID as 
		1) prescribed by DWC (eg, UAM:Mamm:1), or 
		2) a concatenation of collection and cat number (eg, UAM Mammals 1)
	-------------------------------------------------
	Added Manage Collection/collection information:
		GenBank login information (populated for all collections using the generic account)
		Loan Policy URL: Link to display with Collections on /home.cfm page 
			This is where collections should provide guidance for requesting specimens. You may use this to initiate the 
			"shopping cart" features of Arctos - contact me for details.
	---------------------------------------------------
	Added requirements for users with coldfusion_user role:
		Oracle and ColdFusion logins must match.
		Must have agent_name of type login that matches Arctos username
		Warning if no email address in profile
*/
ALTER TABLE cf_temp_relations ADD insert_date DATE;
UPDATE cf_temp_relations SET insert_date=SYSDATE;
ALTER TABLE cf_temp_relations MODIFY insert_date NOT NULL;
ALTER TABLE cf_temp_relations MODIFY insert_date DEFAULT SYSDATE;

/*
    Developer todo:
    
    ADD /ScheduledTasks/attention_needed.cfm TO scheduled tasks
	add /tools/pendingRelations.cfm to scheduled tasks
	/DDL/migration/media.sql
	Form Permissions:
	
	ScheduledTasks/attention_needed.cfm
	findContainer.cfm
	part2container.cfm
	
	Clean up part containers
        	select collection_object_id from cataloged_item where collection_object_id not in (
        	select derived_from_cat_item from specimen_part);
        	
	
            select count(*) from coll_obj_cont_hist where collection_object_id not in (
            	select collection_object_id from specimen_part);
             create table coll_obj_cont_hist20080623 as select * from coll_obj_cont_hist;
             
            delete from coll_obj_cont_hist where collection_object_id not in (
            	select collection_object_id from specimen_part);	
            --orphans??
            select count(*) from container where 
            container_type='collection object' and
            container_id not in (select container_id from coll_obj_cont_hist);
            --yep...
            delete from container where container_type='collection object' and
            container_id not in (select container_id from coll_obj_cont_hist);
            
            
            update container set label=(
            select collection.collection || ' ' || cataloged_item.cat_num || ' ' || part_name
            from
            cataloged_item,
            collection,
            specimen_part,
            coll_obj_cont_hist
            where
            cataloged_item.collection_id=collection.collection_id and
            cataloged_item.collection_object_id=specimen_part.derived_from_cat_item (+) and
            specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
            coll_obj_cont_hist.container_id=container.container_id
            )
            where container_type='collection object'
            ;
      		
      		
      	Rebuild  trigger make_part_coll_obj_cont
      	
      	Get rid of the whole retarded medium JPG thing:
      	delete from binary_object where  DERIVED_FROM_COLL_OBJ is not null;
      	run DDL/migration/media.sql
		run /fix/migrateMedia.cfm to bring binary objects in
		
		Add stuff to collection table
			alter table collection add genbank_prid number;
			alter table collection add genbank_username varchar2(20);
			alter table collection add genbank_pwd varchar2(20);
			alter table collection add loan_policy_url varchar2(255);
			
			update collection set 
				genbank_prid=3849,
				genbank_username='uam',
				genbank_pwd='bU7$f%Nu';
			
		-- random housekeeping:
 		alter table identification drop column ID_MADE_BY_AGENT_ID;
		rebuild package bulk_pkg (revision 4228) which was revised to remove id_made_by_agent_id from insert into identification.:w
		
			
	---------------------- 7/8/08:
	
	rebuild trigger td_agent		
	rebuild trigger tu_agent
*/