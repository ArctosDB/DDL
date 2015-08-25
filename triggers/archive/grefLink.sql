/* GReF triggers and migration SQL code 
Author: Peter DeVore */

-- This portion is for testing on a branch separate from the main server.
-- DO NOT UNCOMMENT THIS.

/*
--For testing purposes, create tables to test stuff with

alter table gref_roi_ng drop constraint grefroingPubIdConstraint;

alter table gref_roi_ng drop constraint grefroingValueConstraint;

drop table gref_roi_ng;
drop table book_section;
drop table gref_roi_value_ng;

create table book_section (
	publication_id number not null,
	book_id number not null,
	book_section_order number not null,
	primary key (book_id)
	);
	
create table gref_roi_value_ng (
	id number not null,
	roi_value_type varchar2(40) not null,
	higher_geography_id number, 
	agent_id number, 
	collection_object_id number, 
	collecting_event_id number,
	primary key (id)
	);

create table gref_roi_ng (
	publication_id number not null,
	section_number number not null,
	ROI_VALUE_NG_ID number not null,
	page_id number not null
	);

alter table gref_roi_ng add constraint grefroingPubIdConstraint
    foreign key (publication_id) references book_section(book_id)
    initially deferred deferrable;

alter table gref_roi_ng add constraint grefroingValueConstraint
    foreign key (ROI_VALUE_NG_ID) references gref_roi_value_ng(id)
    initially deferred deferrable;

-- dummy values!
-- this set should give pubid=234, pageid=68, oid=57, oid_type='collection_object'
insert into gref_roi_value_ng values (1, 'catalog_number', null, null, 57, null);
insert into gref_roi_ng values (32, 4, 1, 68);
insert into book_section values (234, 32, 4);

-- end dummy info
*/

-- Create a table that maps from roi_value_type to oidtype
drop table gref_roi_value_to_oid_type;
create table gref_roi_value_to_oid_type (
	roi_value_type varchar2(255) not null,
	oid_table varchar2(255) not null,
	oid_column varchar2(255) not null,
	PRIMARY KEY (roi_value_type)
	);
insert into gref_roi_value_to_oid_type (
	roi_value_type,
	oid_table,
	oid_column) values (
	'collecting_event',
	'collecting_event',
	'collecting_event_id'
	);
insert into gref_roi_value_to_oid_type (
	roi_value_type,
	oid_table,
	oid_column) values (
	'catalog_number',
	'cataloged_item',
	'collection_object_id'
	);
insert into gref_roi_value_to_oid_type (
	roi_value_type,
	oid_table,
	oid_column) values (
	'agent',
	'agent',
	'agent_id'
	);
insert into gref_roi_value_to_oid_type (
	roi_value_type,
	oid_table,
	oid_column) values (
	'higher_geography',
	'higher_geography',
	'higher_geography_id'
	);

-- inserts a link from gref info. This is a media dependent part of the code
--drop procedure insertGrefLink;
create or replace procedure insertGrefLink (pubid in number, pageid in number, oid in number, 
                value_type in varchar2, roi_value_id in number)
as       
        gref_base_url varchar2(255) := 'http://bg.berkeley.edu/gref/Client.html';
        oidtype varchar2(40);
        related_table varchar2(40);
        url varchar2(255);
        media_id number;
begin
    -- pubid, pageid, oid, value_type, roi_value_id, gref_base_url
        select substr(oid_column,1,length(oid_column)-3), oid_table into oidtype, related_table 
                from gref_roi_value_to_oid_type where roi_value_type = value_type;
    -- pubid, pageid, oid, value_type, roi_value_id, gref_base_url, oidtype, related_table
        -- make the link
        url := gref_base_url || '?publicationid=' || pubid || chr(38) || 'pageid=' || pageid || 
                        chr(38) || 'oid=' || oid || chr(38) || 'oidtype=' || oidtype;
    -- pubid, pageid, oid, value_type, roi_value_id, gref_base_url, oidtype, related_table, url
        -- make the new media item and get the id from the new media item
        insert into media (
           media_uri,
           mime_type,
           media_type
           ) values (
           url,
           'text/html',
           'image'
           ) returning media_id into media_id;
        -- by now, everything is defined
        -- make the new media relationship to the otherid
        insert into media_relations (
                media_id,
                media_relationship,
                created_by_agent_id,
                related_primary_key
                ) values (
                media_id,
                -- makes sure that the string after the last space in media_relationship resolves to a valid table name
                'field notebook for :related_table', 
                0,
                ':oid');
        -- make a new media relationship to the gref_roi_value_ng
        insert into media_relations (
                media_id,
                media_relationship,
                created_by_agent_id,
                related_primary_key
                ) values (
                media_id,
                'from gref_roi_value_ng', 
                0,
                ':roi_value_id');
end insertGrefLink;
/
--sho err

-- updates a link from gref info. This is a media dependent part of the code
--drop procedure updateGrefLink;
create or replace procedure updateGrefLink (pubid in number, pageid in number, oid in number, 
		value_type in varchar2, roi_value_id in number)
as
	gref_base_url varchar2(255) := 'http://bg.berkeley.edu/gref/Client.html';
	url varchar2(255);
	oidtype varchar2(40);
	related_table varchar2(40);
	media_id number;
begin
	select substr(oid_column,1,length(oid_column)-3), oid_table into oidtype, related_table 
		from gref_roi_value_to_oid_type where roi_value_type = value_type;
	execute immediate 'select ' || oidtype || ' into oid from gref_roi_value_ng';
	-- make the link
	url := gref_base_url || '?publicationid=' || pubid || chr(38) || 'pageid=' || pageid || 
	 		chr(38) || 'oid=' || oid || chr(38) || 'oidtype=' || oidtype;
	 -- gives the valid media_id
	 SELECT media_id INTO media_id FROM media_relations 
	 WHERE media_relationship LIKE '%GREF_ROI_VALUE_NG' 
	 AND related_primary_key = oid;
	-- make the new media item and get the id from the new media item
	--insert into media (
--		media_uri,
--		mime_type,
--	   media_type
--	   ) values (
--	   url,
--	   'text/html',
--	   'image'
--	   ) returning media_id into :media_id;
	-- update all media_relations where the media_id is the right one
	UPDATE media_relations 
	    SET
            media_relationship = 'field notebook for ' || related_table, 
	        related_primary_key = oid
	    WHERE 
	        media_id = media_id;
end;
/
--sho err

-- Run once to create gref links for all current data.
--drop procedure migrateGrefData;
create or replace procedure migrateGrefData 
	as
                type rc is ref cursor;
		pubid number;
		pageid number;
		roi_value_type varchar2(255);
		oid number;
		roi_value_id number;
		cur rc;
begin
	open cur for '
		select
		   book_section.publication_id, gref_roi_ng.page_id, gref_roi_value_ng.roi_value_type,
		   gref_roi_value_ng.id
		from
			gref_roi_ng, gref_roi_value_ng, book_section
		where
			gref_roi_ng.publication_id = book_section.book_id
			and gref_roi_ng.section_number = book_section.book_section_order
			and gref_roi_value_ng.id = gref_roi_ng.ROI_VALUE_NG_ID';
	loop
		fetch cur into pubid, pageid, roi_value_type, roi_value_id;
		exit when cur%notfound;
		insertGrefLink(pubid, pageid, oid, roi_value_type, roi_value_id);
	end loop;
	close cur;
end;
/
--sho err
--migrateGrefData();

	

-- When a new ROI is added, we want this to fire.
-- It will update the media table to have the correct link.
-- the information it needs is: gref_base_url, oid, oidtype-- we want it to create a link like:
-- :gref_base_url/Client.html?publicationid=:pubId&pageid=:pageid&oid=:oid&oidtype=:oidtype
CREATE OR REPLACE TRIGGER grefValueLinkInsert AFTER INSERT ON gref_roi_value_ng for each row
	declare
                type rc is ref cursor;
		pubid number;
		pageid number;
		roi_value_type varchar2(255);
		oid number;
		cur rc;
	begin
		-- create the link to GREF
		-- query gref tables
		open cur for '
			select
				book_section.publication_id, gref_roi_ng.page_id, gref_roi_value_ng.roi_value_type
			from
				gref_roi_ng, gref_roi_value_ng, book_section
			where
			  book_section.book_id = gref_roi_ng.publication_id
			  and gref_roi_ng.section_number = book_section.book_section_order
			  and gref_roi_value_ng.id = gref_roi_ng.ROI_VALUE_NG_ID
			  and gref_roi_value_ng.id = :new.id';
		-- loop on the results
		LOOP 
		  	fetch cur into pubid, pageid, roi_value_type;
		  	exit when cur%notfound;
			--make the link
		  	insertGrefLink(pubid, pageid, oid, roi_value_type, :new.id);
	    end loop;
            close cur;
END;

--drop trigger grefValueLinkUpdate;
--CREATE OR REPLACE TRIGGER grefValueLinkUpdate AFTER UPDATE ON gref_roi_value_ng for each row	
--	declare
--		type rc is ref cursor;
--		url varchar2(255);
--		pubid number;
--		pageid number;
--		roi_value_type varchar2(255);
--		oidtype varchar2(255);
--		media_id number;
--		related_table varchar2(40);
--		cur rc;
--	begin
--		-- create the link to GREF
--		  -- query gref tables
--		  open cur for '
--			select
--	  		  book_section.publication_id, gref_roi_ng.page_id, gref_roi_value_ng.roi_value_type
--			from
--			  gref_roi_ng, gref_roi_value_ng, book_section
--			where
--			  book_section.book_id = gref_roi_ng.publication_id
--			  and gref_roi_ng.section_number = book_section.book_section_order
--			  and gref_roi_value_ng.id = gref_roi_ng.ROI_VALUE_NG_ID
--			  and gref_roi_value_ng.id = :new.id';
--		  -- loop on the results
--		LOOP 
--		  	 fetch cur into pubid, pageid, roi_value_type;
--		  	 exit when cur%notfound;
--			--make the link
--		  	 updateGrefLink(pubid, pageid, oid, roi_value_type, :new.id);
--	    end loop;
--            close cur;
--END;
--/
--sho err


-- Testing trigger portion
-- this set should give pubid=2345, pageid=18, oid=67, oid_type='collecting_event'
insert into gref_roi_value_ng values (2, 'collecting_event', null, null, 67, null);
insert into gref_roi_ng values (33, 5, 2, 18);
insert into book_section values (2345, 33, 5);