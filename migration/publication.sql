/*
uam> create table dlm.publication20090803 as select * from publication;
uam> create table dlm.publicationauthorname20090803 as select * from publication_author_name;
create table dlm.ctpublication_type20090803 as select * from ctpublication_type;

*/

create table publication_attributes (
	publication_attribute_id NUMBER NOT NULL,
	publication_id number not null,
	publication_attribute varchar2(60) not null,
	pub_att_value varchar2(255) not null
);
CREATE SEQUENCE sq_publication_attribute_id;

CREATE OR REPLACE TRIGGER publication_attributes_key                                         
 before insert  ON publication_attributes
 for each row 
    begin     
    	if :NEW.publication_attribute_id is null then                                                                                      
    		select sq_publication_attribute_id.nextval into :new.publication_attribute_id from dual;
    	end if;                                
    end;                                                                                            
/
sho err

ALTER TABLE publication_attributes ADD constraint pk_publication_attribute_id PRIMARY KEY (publication_attribute_id);

create table ctpublication_attribute (publication_attribute varchar2(60) not null);

ALTER TABLE ctpublication_attribute ADD constraint pk_publication_attribute PRIMARY KEY (publication_attribute);

ALTER TABLE publication_attributes
add CONSTRAINT fk_ctpublication_attribute
FOREIGN KEY (publication_attribute)
REFERENCES ctpublication_attribute(publication_attribute);

insert into ctpublication_attribute values ('storage location');
insert into ctpublication_attribute values ('remark');
insert into ctpublication_attribute values ('volume');
insert into ctpublication_attribute values ('page total');
insert into ctpublication_attribute values ('publisher');
insert into ctpublication_attribute values ('section type');
insert into ctpublication_attribute values ('begin page');
insert into ctpublication_attribute values ('end page');
insert into ctpublication_attribute values ('section order');
insert into ctpublication_attribute values ('journal name');
insert into ctpublication_attribute values ('issue');

ALTER TABLE publication DROP CONSTRAINT pub_pub_type_cons;

UPDATE publication SET publication_type='journal article' WHERE publication_type='Journal Article';
UPDATE publication SET publication_type='book section' WHERE publication_type='Book Section';
UPDATE publication SET publication_type='book' WHERE publication_type='Book';

DELETE FROM ctpublication_type;

INSERT INTO ctpublication_type(publication_type) (SELECT DISTINCT(publication_type) FROM publication);

ALTER TABLE 
    publication
add CONSTRAINT 
    fk_ctpublication_type
FOREIGN KEY 
    (publication_type)
REFERENCES 
    ctpublication_type(publication_type)
;

-- FOR TEST: start over....
-- delete from publication_attributes;
-- remark
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    publication_id,
		    'remark',
		    PUBLICATION_REMARKS
		from 
		    publication
		where 
		    publication_type IN ('journal article', 'book') AND
		    PUBLICATION_REMARKS is not null
	);
	
ALTER TABLE publication_attributes MODIFY PUB_ATT_VALUE VARCHAR2(4000);
    
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( SELECT 
            book_section.publication_id,
            'remark',
            CASE 
                WHEN a.publication_remarks IS NOT NULL AND b.publication_remarks IS NOT NULL THEN
                    a.publication_remarks || '; ' || b.publication_remarks
                WHEN a.publication_remarks IS NOT NULL AND b.publication_remarks IS NULL THEN
                    a.publication_remarks
                WHEN a.publication_remarks IS NULL AND b.publication_remarks IS NOT NULL THEN
                    b.publication_remarks
            	ELSE
            	    'something else'
            END CASE
        FROM 
            publication a,
            publication b,
            book_section
        WHERE 
		    b.publication_type='book section' AND
            book_section.book_id=a.publication_id AND
            book_section.publication_id=b.publication_id AND
            (a.publication_remarks IS NOT NULL OR b.publication_remarks IS NOT NULL)
	);
	
-- storage location
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    publication_id,
		    'storage location',
		    PUBLICATION_LOC
		from 
		    publication
		where 
		    publication_type IN ('journal article', 'book') AND
		    PUBLICATION_LOC is not null
	);
	
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( SELECT 
            book_section.publication_id,
            'storage location',
            CASE 
                WHEN a.PUBLICATION_LOC IS NOT NULL AND b.PUBLICATION_LOC IS NOT NULL THEN
                    a.PUBLICATION_LOC || '; ' || b.PUBLICATION_LOC
                WHEN a.PUBLICATION_LOC IS NOT NULL AND b.PUBLICATION_LOC IS NULL THEN
                    a.PUBLICATION_LOC
                WHEN a.PUBLICATION_LOC IS NULL AND b.PUBLICATION_LOC IS NOT NULL THEN
                    b.PUBLICATION_LOC
            	ELSE
            	    'something else'
            END CASE
        FROM 
            publication a,
            publication b,
            book_section
        WHERE 
		    b.publication_type='book section' AND
            book_section.book_id=a.publication_id AND
            book_section.publication_id=b.publication_id AND
            (a.publication_remarks IS NOT NULL OR b.publication_remarks IS NOT NULL)
	);
	
-- hose anything?
select * from publication_attributes where pub_att_value='something else';	
-- just 3 storage location - kill it
DELETE FROM publication_attributes where pub_att_value='something else';
-- volume 
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    book_section.publication_id,
		    'volume',
		    VOLUME_NUMBER
		from 
		    book,
		    book_section 
		where
		    book.publication_id=book_section.book_id AND
		    VOLUME_NUMBER is not null
	);

insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    book.publication_id,
		    'volume',
		    VOLUME_NUMBER
		from 
		    book
		where
		    book.publication_id NOT IN (SELECT book_id FROM book_section) AND
		    VOLUME_NUMBER is not null
	);
--page total
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    book_section.publication_id,
		    'page total',
		    PAGE_TOTAL
		from 
		    book,
		    book_section 
		where
		    book.publication_id=book_section.book_id AND
		    PAGE_TOTAL is not null
	);
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    book.publication_id,
		    'page total',
		    PAGE_TOTAL
		from 
		    book
		where
		    book.publication_id NOT IN (SELECT book_id FROM book_section) AND
		    PAGE_TOTAL is not null
	);	

insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    book_section.publication_id,
		    'publisher',
		    PUBLISHER_NAME
		from 
		    book,
		    book_section 
		where
		    book.publication_id=book_section.book_id AND
		    PUBLISHER_NAME is not null
	);
	
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    book.publication_id,
		    'publisher',
		    PUBLISHER_NAME
		from 
		    book
		where
		    book.publication_id NOT IN (SELECT book_id FROM book_section) AND
		    PUBLISHER_NAME is not null
	);		
	
ALTER TABLE publication_author_name ADD author_role VARCHAR2(60);

CREATE TABLE ctauthor_role (author_role VARCHAR2(60));
INSERT INTO ctauthor_role VALUES ('author');
INSERT INTO ctauthor_role VALUES ('editor');

UPDATE publication_author_name SET author_role='author';

ALTER TABLE publication_author_name MODIFY author_role NOT NULL;
 

 BEGIN
  FOR r IN ( SELECT 
     book_section.publication_id,
     agent_name_id 
FROM 
    publication_author_name,
    book,
    book_section
WHERE
    publication_author_name.publication_id=book.publication_id AND
    book_section.book_id=book.publication_id AND
    EDITED_WORK_FG=1
) LOOP
    UPDATE publication_author_name SET author_role='editor' WHERE
         publication_id=r.publication_id AND agent_name_id=r.agent_name_id;
   END LOOP;
END;
/ 
         
ALTER TABLE ctauthor_role ADD constraint pk_ctauthor_role PRIMARY KEY (author_role); 

ALTER TABLE publication_author_name
add CONSTRAINT fk_author_role
  FOREIGN KEY (author_role)
  REFERENCES ctauthor_role(author_role);

insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    book_section.publication_id,
		    'section type',
		    BOOK_SECTION_TYPE
		from 
		    book_section 
		where
		    BOOK_SECTION_TYPE is not null
	);

insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    book_section.publication_id,
		    'begin page',
		    BEGINS_PAGE_NUMBER
		from 
		    book_section 
		where
		    BEGINS_PAGE_NUMBER is not null
	);	

insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    book_section.publication_id,
		    'end page',
		    ENDS_PAGE_NUMBER
		from 
		    book_section 
		where
		    ENDS_PAGE_NUMBER is not null
	);	
	
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    book_section.publication_id,
		    'section order',
		    BOOK_SECTION_ORDER
		from 
		    book_section 
		where
		    BOOK_SECTION_ORDER is not null
	);	
			
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    journal_article.publication_id,
		    'publisher',
		    PUBLISHER_NAME
		from 
		    journal,
		    journal_article 
		where
		    journal.journal_id=journal_article.journal_id AND
		    PUBLISHER_NAME is not null
	);		
	
CREATE TABLE ctjournal_name (journal_name varchar2(150) NOT NULL);

INSERT INTO ctjournal_name (SELECT DISTINCT(journal_name) FROM journal);

ALTER TABLE ctjournal_name ADD constraint pk_journal_name PRIMARY KEY (journal_name); 

CREATE OR REPLACE TRIGGER chchk_publication_attributes
before UPDATE or INSERT ON publication_attributes
for each row
declare
numrows number;
BEGIN
	IF :NEW.publication_attribute = 'journal name' THEN
	    SELECT COUNT(*) INTO numrows FROM ctjournal_name WHERE journal_name = :NEW.pub_att_value;
    	IF (numrows = 0) THEN
    		 raise_application_error(
    	        -20001,
    	        'Invalid journal_name ' || :NEW.pub_att_value
    	      );
    	END IF;
	END IF;
	 	
END;
/
sho err

insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    journal_article.publication_id,
		    'journal name',
		    JOURNAL_NAME
		from 
		    journal,
		    journal_article 
		where
		    journal.journal_id=journal_article.journal_id AND
		    JOURNAL_NAME is not null
	);	

insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    publication_id,
		    'begin page',
		    BEGINS_PAGE_NUMBER
		from 
		    journal_article 
		where
		    BEGINS_PAGE_NUMBER is not null
	);	
	
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    publication_id,
		    'end page',
		    ENDS_PAGE_NUMBER
		from 
		    journal_article 
		where
		    ENDS_PAGE_NUMBER is not null
	);	
	
insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    publication_id,
		    'volume',
		    VOLUME_NUMBER
		from 
		    journal_article 
		where
		    VOLUME_NUMBER is not null
	);

insert into publication_attributes (
	publication_id,
	publication_attribute,
	pub_att_value
	) ( select 
		    publication_id,
		    'issue',
		    ISSUE_NUMBER
		from 
		    journal_article 
		where
		    ISSUE_NUMBER is not null
	);

ALTER TABLE publication ADD is_peer_reviewed_fg NUMBER(1);
UPDATE publication SET is_peer_reviewed_fg=1;
ALTER TABLE publication MODIFY is_peer_reviewed_fg NOT NULL;
ALTER TABLE publication add CONSTRAINT ck_peer_flag CHECK (is_peer_reviewed_fg IN (0,1));


CREATE PUBLIC SYNONYM ctpublication_attribute FOR ctpublication_attribute;
GRANT ALL ON ctpublication_attribute TO manage_codetables;
GRANT SELECT ON ctpublication_attribute TO PUBLIC;

CREATE PUBLIC SYNONYM publication_attributes FOR publication_attributes;
GRANT ALL ON publication_attributes TO manage_publications;
GRANT SELECT ON publication_attributes TO PUBLIC;

CREATE PUBLIC SYNONYM ctauthor_role FOR ctauthor_role;
GRANT ALL ON ctauthor_role TO manage_codetables;
GRANT SELECT ON ctauthor_role TO PUBLIC;

CREATE PUBLIC SYNONYM ctjournal_name FOR ctjournal_name;
GRANT ALL ON ctjournal_name TO manage_codetables;
GRANT SELECT ON ctjournal_name TO PUBLIC;

-- Book section titles should have format "some chapter In: some book"

CREATE TABLE tpt AS SELECT book_section.publication_id pid,
    bs.publication_title || ' In: ' || bk.publication_title pt
FROM
    book_section,
    publication bs,
    publication bk
WHERE
    book_section.publication_id=bs.publication_id AND
    book_section.book_id=bk.publication_id
;

CREATE TABLE orig_publication AS SELECT * FROM publication;

ALTER TABLE publication MODIFY publication_title VARCHAR2(4000);

BEGIN
    FOR r IN (SELECT * FROM tpt) LOOP
        UPDATE publication SET publication_title=r.pt WHERE publication_id=r.pid;
    END LOOP;
END;
/

DROP TABLE tpt;



ALTER TABLE ctpublication_attribute ADD description VARCHAR2(4000);
ALTER TABLE ctpublication_attribute ADD control VARCHAR2(40);



ALTER TABLE publication_author_name ADD publication_author_name_id NUMBER;
CREATE SEQUENCE sq_publication_author_name_id;

BEGIN
    FOR r IN (SELECT ROWID FROM publication_author_name) LOOP
        UPDATE publication_author_name SET publication_author_name_id=sq_publication_author_name_id.nextval WHERE 
        ROWID=r.rowid;
    END LOOP;
END;
/

ALTER TABLE publication_author_name MODIFY publication_author_name_id NOT NULL;
ALTER TABLE 
    publication_author_name
add CONSTRAINT 
    pk_publication_author_name
PRIMARY KEY 
    (publication_author_name_id);

CREATE OR REPLACE TRIGGER seq_publication_author_name                                         
 before insert  ON publication_author_name
 for each row 
    begin     
    	if :NEW.publication_author_name_id is null then                                                                                      
    		select sq_publication_author_name_id.nextval into :new.publication_author_name_id from dual;
    	end if;                                
    end;                                                                                            
/
sho err

CREATE UNIQUE INDEX u_c_publication_attributes ON publication_attributes (PUBLICATION_ID,PUBLICATION_ATTRIBUTE) TABLESPACE uam_idx_1;

    
-- move books that have sections authors to the section
CREATE TABLE origpublication_author_name AS SELECT * FROM publication_author_name;

DECLARE npid NUMBER;
s VARCHAR2(4000);
BEGIN
    FOR r IN (SELECT book_id,publication_id FROM book_section) LOOP        
            dbms_output.put_line('bookid: ' || r.book_id || '; pubID: ' || r.publication_id);
            SELECT MAX(AUTHOR_POSITION+1) INTO npid FROM publication_author_name WHERE publication_id=r.book_id;
            dbms_output.put_line('npid: ' || npid);
            FOR l IN (SELECT publication_id,AGENT_NAME_ID FROM publication_author_name WHERE publication_id=r.book_id) LOOP
                BEGIN
                s:='UPDATE 
                    publication_author_name 
                SET 
                    publication_id=' || r.publication_id || ',
                    AUTHOR_POSITION=' || npid || '
                WHERE 
                    publication_id=' || r.book_id || ' AND
                    AGENT_NAME_ID=' || l.AGENT_NAME_ID;
                dbms_output.put_line(s);
                 EXECUTE IMMEDIATE (s);
               npid:=npid+1;
               EXCEPTION
            WHEN OTHERS THEN
               dbms_output.put_line('goddammit MVZ: bookid: ' || r.book_id || '; pubID: ' || r.publication_id);
        END;
            END LOOP;
        --
    END LOOP;
END;
/







/*
bookid: 1000170; pubID: 1000171
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=1000171,
		    AUTHOR_POSITION=4
		WHERE
		    publi
cation_id=1000170 AND
		    AGENT_NAME_ID=5237
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=1000171,
		    AUTHOR_POSITION=5
		WHERE
		    publi
cation_id=1000170 AND
		    AGENT_NAME_ID=1021704
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=1000171,
		    AUTHOR_POSITION=6
		WHERE
		    publi
cation_id=1000170 AND
		    AGENT_NAME_ID=1022831
bookid: 63; pubID: 64
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=64,
		    AUTHOR_POSITION=2
		WHERE
		    publicatio
n_id=63 AND
		    AGENT_NAME_ID=5473
bookid: 68; pubID: 69
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=69,
		    AUTHOR_POSITION=4
		WHERE
		    publicatio
n_id=68 AND
		    AGENT_NAME_ID=4690
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=69,
		    AUTHOR_POSITION=5
		WHERE
		    publicatio
n_id=68 AND
		    AGENT_NAME_ID=5832
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=69,
		    AUTHOR_POSITION=6
		WHERE
		    publicatio
n_id=68 AND
		    AGENT_NAME_ID=5992
bookid: 68; pubID: 70
npid:
bookid: 13; pubID: 107
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=107,
		    AUTHOR_POSITION=3
		WHERE
		    publicati
on_id=13 AND
		    AGENT_NAME_ID=978
goddammit MVZ: bookid: 13; pubID: 107
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=107,
		    AUTHOR_POSITION=3
		WHERE
		    publicati
on_id=13 AND
		    AGENT_NAME_ID=4531
goddammit MVZ: bookid: 13; pubID: 107
bookid: 187; pubID: 188
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=188,
		    AUTHOR_POSITION=5
		WHERE
		    publicati
on_id=187 AND
		    AGENT_NAME_ID=13288
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=188,
		    AUTHOR_POSITION=6
		WHERE
		    publicati
on_id=187 AND
		    AGENT_NAME_ID=13289
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=188,
		    AUTHOR_POSITION=7
		WHERE
		    publicati
on_id=187 AND
		    AGENT_NAME_ID=13290
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=188,
		    AUTHOR_POSITION=8
		WHERE
		    publicati
on_id=187 AND
		    AGENT_NAME_ID=13291
bookid: 168; pubID: 169
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=169,
		    AUTHOR_POSITION=2
		WHERE
		    publicati
on_id=168 AND
		    AGENT_NAME_ID=5992
bookid: 10001580; pubID: 10002096
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002096,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002096
bookid: 10001580; pubID: 10002097
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002097,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002097
bookid: 10001580; pubID: 10002098
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002098,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002098
bookid: 10001580; pubID: 10002108
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002108,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002108
bookid: 10001580; pubID: 10002109
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002109,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002109
bookid: 10001580; pubID: 10002110
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002110,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002110
bookid: 10001580; pubID: 10002111
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002111,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002111
bookid: 10001581; pubID: 10002112
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002112,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001581 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001581; pubID: 10002112
bookid: 10001581; pubID: 10002113
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002113,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001581 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001581; pubID: 10002113
bookid: 10001580; pubID: 10002114
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002114,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002114
bookid: 10001581; pubID: 10002115
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002115,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001581 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001581; pubID: 10002115
bookid: 10001580; pubID: 10002116
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002116,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002116
bookid: 10001581; pubID: 10002117
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002117,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001581 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001581; pubID: 10002117
bookid: 10001581; pubID: 10002118
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002118,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001581 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001581; pubID: 10002118
bookid: 10001581; pubID: 10002119
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002119,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001581 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001581; pubID: 10002119
bookid: 10001581; pubID: 10002120
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002120,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001581 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001581; pubID: 10002120
bookid: 10001580; pubID: 10002121
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002121,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002121
bookid: 10001581; pubID: 10002122
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002122,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001581 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001581; pubID: 10002122
bookid: 10001580; pubID: 10002123
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002123,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002123
bookid: 10001581; pubID: 10002124
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002124,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001581 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001581; pubID: 10002124
bookid: 10001581; pubID: 10002125
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002125,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001581 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001581; pubID: 10002125
bookid: 10001580; pubID: 10002126
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002126,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002126
bookid: 10001582; pubID: 10002127
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002127,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002127
bookid: 10001582; pubID: 10002128
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002128,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002128
bookid: 10001582; pubID: 10002129
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002129,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002129
bookid: 10001582; pubID: 10002130
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002130,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002130
bookid: 10001582; pubID: 10002131
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002131,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002131
bookid: 10001582; pubID: 10002132
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002132,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002132
bookid: 10001582; pubID: 10002133
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002133,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002133
bookid: 10001582; pubID: 10002134
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002134,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002134
bookid: 10001582; pubID: 10002135
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002135,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002135
bookid: 10001582; pubID: 10002136
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002136,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002136
bookid: 10001582; pubID: 10002137
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002137,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002137
bookid: 10001582; pubID: 10002138
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002138,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002138
bookid: 10001582; pubID: 10002139
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002139,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002139
bookid: 10001582; pubID: 10002140
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002140,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002140
bookid: 10001582; pubID: 10002141
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002141,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002141
bookid: 10001582; pubID: 10002142
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002142,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001582 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001582; pubID: 10002142
bookid: 10001664; pubID: 10002143
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002143,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001664 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001664; pubID: 10002143
bookid: 10001664; pubID: 10002144
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002144,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001664 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001664; pubID: 10002144
bookid: 10001665; pubID: 10002145
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002145,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001665 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001665; pubID: 10002145
bookid: 10001665; pubID: 10002146
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002146,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001665 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001665; pubID: 10002146
bookid: 10001666; pubID: 10002147
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002147,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001666 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001666; pubID: 10002147
bookid: 10001667; pubID: 10002148
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002148,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001667 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001667; pubID: 10002148
bookid: 10001667; pubID: 10002149
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002149,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001667 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001667; pubID: 10002149
bookid: 10001667; pubID: 10002150
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002150,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001667 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001667; pubID: 10002150
bookid: 10001667; pubID: 10002151
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002151,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001667 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001667; pubID: 10002151
bookid: 10001667; pubID: 10002152
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002152,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001667 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001667; pubID: 10002152
bookid: 10001668; pubID: 10002153
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002153,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001668 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001668; pubID: 10002153
bookid: 10001668; pubID: 10002154
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002154,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001668 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001668; pubID: 10002154
bookid: 10001678; pubID: 10002155
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002155,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001678 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001678; pubID: 10002155
bookid: 10001678; pubID: 10002156
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002156,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001678 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001678; pubID: 10002156
bookid: 10001678; pubID: 10002157
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002157,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001678 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001678; pubID: 10002157
bookid: 10001678; pubID: 10002158
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002158,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001678 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001678; pubID: 10002158
bookid: 10001689; pubID: 10002159
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002159,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001689 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001689; pubID: 10002159
bookid: 10001689; pubID: 10002160
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002160,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001689 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001689; pubID: 10002160
bookid: 10001689; pubID: 10002161
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002161,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001689 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001689; pubID: 10002161
bookid: 10001688; pubID: 10002162
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002162,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001688 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001688; pubID: 10002162
bookid: 10001690; pubID: 10002163
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002163,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001690 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001690; pubID: 10002163
bookid: 10001691; pubID: 10002164
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002164,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001691 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001691; pubID: 10002164
bookid: 10001692; pubID: 10002165
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002165,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001692 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001692; pubID: 10002165
bookid: 10001692; pubID: 10002166
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002166,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001692 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001692; pubID: 10002166
bookid: 10001693; pubID: 10002167
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002167,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001693 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001693; pubID: 10002167
bookid: 10001693; pubID: 10002168
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002168,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001693 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001693; pubID: 10002168
bookid: 10001694; pubID: 10002169
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002169,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001694 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001694; pubID: 10002169
bookid: 10001694; pubID: 10002170
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002170,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001694 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001694; pubID: 10002170
bookid: 10001695; pubID: 10002171
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002171,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001695 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001695; pubID: 10002171
bookid: 10001695; pubID: 10002172
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002172,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001695 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001695; pubID: 10002172
bookid: 10001697; pubID: 10002173
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002173,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001697 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001697; pubID: 10002173
bookid: 10001696; pubID: 10002174
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002174,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001696 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001696; pubID: 10002174
bookid: 10001696; pubID: 10002175
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002175,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001696 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001696; pubID: 10002175
bookid: 10001697; pubID: 10002176
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002176,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001697 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001697; pubID: 10002176
bookid: 10001697; pubID: 10002177
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002177,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001697 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001697; pubID: 10002177
bookid: 10001697; pubID: 10002178
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002178,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001697 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001697; pubID: 10002178
bookid: 10001698; pubID: 10002179
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002179,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001698 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001698; pubID: 10002179
bookid: 10001679; pubID: 10002180
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002180,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001679 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001679; pubID: 10002180
bookid: 10001680; pubID: 10002181
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002181,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001680 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001680; pubID: 10002181
bookid: 10001680; pubID: 10002182
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002182,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001680 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001680; pubID: 10002182
bookid: 10001681; pubID: 10002183
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002183,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001681 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001681; pubID: 10002183
bookid: 10001681; pubID: 10002184
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002184,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001681 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001681; pubID: 10002184
bookid: 10001681; pubID: 10002185
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002185,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001681 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001681; pubID: 10002185
bookid: 10001681; pubID: 10002186
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002186,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001681 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001681; pubID: 10002186
bookid: 10001681; pubID: 10002187
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002187,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001681 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001681; pubID: 10002187
bookid: 10001682; pubID: 10002188
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002188,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001682 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001682; pubID: 10002188
bookid: 10001682; pubID: 10002189
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002189,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001682 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001682; pubID: 10002189
bookid: 10001682; pubID: 10002190
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002190,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001682 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001682; pubID: 10002190
bookid: 10001682; pubID: 10002191
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002191,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001682 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001682; pubID: 10002191
bookid: 10001682; pubID: 10002192
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002192,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001682 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001682; pubID: 10002192
bookid: 10001682; pubID: 10002193
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002193,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001682 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001682; pubID: 10002193
bookid: 10001683; pubID: 10002194
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002194,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001683 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001683; pubID: 10002194
bookid: 10001683; pubID: 10002195
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002195,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001683 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001683; pubID: 10002195
bookid: 10001684; pubID: 10002196
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002196,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001684 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001684; pubID: 10002196
bookid: 10001684; pubID: 10002197
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002197,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001684 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001684; pubID: 10002197
bookid: 10001684; pubID: 10002198
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002198,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001684 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001684; pubID: 10002198
bookid: 10001685; pubID: 10002199
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002199,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001685 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001685; pubID: 10002199
bookid: 10001685; pubID: 10002200
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002200,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001685 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001685; pubID: 10002200
bookid: 10001685; pubID: 10002201
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002201,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001685 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001685; pubID: 10002201
bookid: 10001685; pubID: 10002203
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002203,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001685 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001685; pubID: 10002203
bookid: 10001685; pubID: 10002204
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002204,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001685 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001685; pubID: 10002204
bookid: 10001324; pubID: 10002205
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002205,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001324 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001324; pubID: 10002205
bookid: 10001324; pubID: 10002206
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002206,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001324 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001324; pubID: 10002206
bookid: 10001324; pubID: 10002207
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002207,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001324 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001324; pubID: 10002207
bookid: 10001325; pubID: 10002208
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002208,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001325 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001325; pubID: 10002208
bookid: 10001325; pubID: 10002209
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002209,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001325 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001325; pubID: 10002209
bookid: 10001325; pubID: 10002210
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002210,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001325 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001325; pubID: 10002210
bookid: 10001325; pubID: 10002211
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002211,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001325 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001325; pubID: 10002211
bookid: 10001325; pubID: 10002212
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002212,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001325 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001325; pubID: 10002212
bookid: 10001325; pubID: 10002213
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002213,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001325 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001325; pubID: 10002213
bookid: 10001325; pubID: 10002214
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002214,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001325 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001325; pubID: 10002214
bookid: 10001326; pubID: 10002215
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002215,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001326 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001326; pubID: 10002215
bookid: 10001326; pubID: 10002216
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002216,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001326 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001326; pubID: 10002216
bookid: 10001326; pubID: 10002217
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002217,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001326 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001326; pubID: 10002217
bookid: 10001326; pubID: 10002218
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002218,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001326 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001326; pubID: 10002218
bookid: 10001327; pubID: 10002219
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002219,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001327 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001327; pubID: 10002219
bookid: 10001327; pubID: 10002220
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002220,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001327 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001327; pubID: 10002220
bookid: 10001327; pubID: 10002221
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002221,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001327 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001327; pubID: 10002221
bookid: 10001328; pubID: 10002222
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002222,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001328 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001328; pubID: 10002222
bookid: 10001328; pubID: 10002223
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002223,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001328 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001328; pubID: 10002223
bookid: 10001328; pubID: 10002224
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002224,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001328 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001328; pubID: 10002224
bookid: 10001328; pubID: 10002225
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002225,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001328 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001328; pubID: 10002225
bookid: 10001329; pubID: 10002226
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002226,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001329 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001329; pubID: 10002226
bookid: 10001329; pubID: 10002227
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002227,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001329 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001329; pubID: 10002227
bookid: 10001329; pubID: 10002228
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002228,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001329 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001329; pubID: 10002228
bookid: 10001329; pubID: 10002229
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002229,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001329 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001329; pubID: 10002229
bookid: 10001331; pubID: 10002231
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002231,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001331 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001331; pubID: 10002231
bookid: 10001331; pubID: 10002232
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002232,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001331 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001331; pubID: 10002232
bookid: 10001331; pubID: 10002233
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002233,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001331 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001331; pubID: 10002233
bookid: 10001331; pubID: 10002234
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002234,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001331 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001331; pubID: 10002234
bookid: 10001331; pubID: 10002235
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002235,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001331 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001331; pubID: 10002235
bookid: 10001331; pubID: 10002236
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002236,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001331 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001331; pubID: 10002236
bookid: 10001330; pubID: 10002237
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002237,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002237
bookid: 10001330; pubID: 10002238
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002238,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002238
bookid: 10001330; pubID: 10002239
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002239,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002239
bookid: 10001330; pubID: 10002240
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002240,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002240
bookid: 10001330; pubID: 10002241
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002241,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002241
bookid: 10001330; pubID: 10002242
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002242,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002242
bookid: 10001330; pubID: 10002243
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002243,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002243
bookid: 10001330; pubID: 10002244
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002244,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002244
bookid: 10001330; pubID: 10002245
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002245,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002245
bookid: 10001330; pubID: 10002246
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002246,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002246
bookid: 10001332; pubID: 10002247
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002247,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002247
bookid: 10001332; pubID: 10002248
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002248,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002248
bookid: 10001332; pubID: 10002249
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002249,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002249
bookid: 10001332; pubID: 10002250
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002250,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002250
bookid: 10001332; pubID: 10002251
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002251,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002251
bookid: 10001332; pubID: 10002252
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002252,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002252
bookid: 10001332; pubID: 10002253
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002253,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002253
bookid: 10001332; pubID: 10002254
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002254,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002254
bookid: 10001332; pubID: 10002255
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002255,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002255
bookid: 10001332; pubID: 10002256
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002256,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002256
bookid: 10001332; pubID: 10002257
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002257,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002257
bookid: 10001332; pubID: 10002258
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002258,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002258
bookid: 10001333; pubID: 10002259
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002259,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002259
bookid: 10001333; pubID: 10002260
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002260,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002260
bookid: 10001333; pubID: 10002261
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002261,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002261
bookid: 10001333; pubID: 10002262
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002262,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002262
bookid: 10001333; pubID: 10002263
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002263,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002263
bookid: 10001333; pubID: 10002264
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002264,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002264
bookid: 10001333; pubID: 10002265
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002265,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002265
bookid: 10001333; pubID: 10002266
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002266,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002266
bookid: 10001333; pubID: 10002267
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002267,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002267
bookid: 10001333; pubID: 10002268
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002268,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002268
bookid: 10001333; pubID: 10002269
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002269,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002269
bookid: 10001333; pubID: 10002270
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002270,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002270
bookid: 10001333; pubID: 10002271
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002271,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002271
bookid: 10001333; pubID: 10002272
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002272,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002272
bookid: 10001333; pubID: 10002273
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002273,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002273
bookid: 10001333; pubID: 10002274
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002274,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002274
bookid: 10001333; pubID: 10002275
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002275,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002275
bookid: 10001333; pubID: 10002276
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002276,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002276
bookid: 10001333; pubID: 10002277
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002277,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002277
bookid: 10001333; pubID: 10002278
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002278,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002278
bookid: 10001333; pubID: 10002279
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002279,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002279
bookid: 10001337; pubID: 10002280
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002280,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001337 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001337; pubID: 10002280
bookid: 10001337; pubID: 10002281
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002281,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001337 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001337; pubID: 10002281
bookid: 10001337; pubID: 10002282
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002282,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001337 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001337; pubID: 10002282
bookid: 10001337; pubID: 10002283
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002283,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001337 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001337; pubID: 10002283
bookid: 10000483; pubID: 10000682
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000682,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000483 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000483; pubID: 10000682
bookid: 10000483; pubID: 10000683
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000683,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000483 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000483; pubID: 10000683
bookid: 10000483; pubID: 10000684
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000684,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000483 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000483; pubID: 10000684
bookid: 10000483; pubID: 10000685
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000685,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000483 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000483; pubID: 10000685
bookid: 10000484; pubID: 10000686
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000686,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000484 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000484; pubID: 10000686
bookid: 10000484; pubID: 10000687
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000687,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000484 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000484; pubID: 10000687
bookid: 10000484; pubID: 10000688
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000688,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000484 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000484; pubID: 10000688
bookid: 10000482; pubID: 10000689
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000689,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000482 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000482; pubID: 10000689
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000689,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000482 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10000482; pubID: 10000689
bookid: 10000486; pubID: 10000690
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000690,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000486 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000486; pubID: 10000690
bookid: 10000486; pubID: 10000691
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000691,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000486 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000486; pubID: 10000691
bookid: 10000486; pubID: 10000692
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000692,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000486 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000486; pubID: 10000692
bookid: 10000486; pubID: 10000693
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000693,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000486 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000486; pubID: 10000693
bookid: 10000486; pubID: 10000694
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000694,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000486 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000486; pubID: 10000694
bookid: 10000482; pubID: 10000695
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000695,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000482 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10000482; pubID: 10000695
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000695,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000482 AND
		    AGENT_NAME_ID=10001776
bookid: 10000487; pubID: 10000696
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000696,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000487 AND
		    AGENT_NAME_ID=10000186
goddammit MVZ: bookid: 10000487; pubID: 10000696
bookid: 10000487; pubID: 10000697
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000697,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000487 AND
		    AGENT_NAME_ID=10000186
goddammit MVZ: bookid: 10000487; pubID: 10000697
bookid: 10000487; pubID: 10000698
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000698,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000487 AND
		    AGENT_NAME_ID=10000186
goddammit MVZ: bookid: 10000487; pubID: 10000698
bookid: 10000488; pubID: 10000699
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000699,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000488 AND
		    AGENT_NAME_ID=10000186
goddammit MVZ: bookid: 10000488; pubID: 10000699
bookid: 10000489; pubID: 10000700
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000700,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000489 AND
		    AGENT_NAME_ID=10000186
goddammit MVZ: bookid: 10000489; pubID: 10000700
bookid: 10000489; pubID: 10000701
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000701,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000489 AND
		    AGENT_NAME_ID=10000186
goddammit MVZ: bookid: 10000489; pubID: 10000701
bookid: 10000489; pubID: 10000702
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000702,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000489 AND
		    AGENT_NAME_ID=10000186
goddammit MVZ: bookid: 10000489; pubID: 10000702
bookid: 10000489; pubID: 10000703
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000703,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000489 AND
		    AGENT_NAME_ID=10000186
goddammit MVZ: bookid: 10000489; pubID: 10000703
bookid: 10000490; pubID: 10000704
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000704,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000490 AND
		    AGENT_NAME_ID=10000135
goddammit MVZ: bookid: 10000490; pubID: 10000704
bookid: 10000490; pubID: 10000705
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000705,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000490 AND
		    AGENT_NAME_ID=10000135
goddammit MVZ: bookid: 10000490; pubID: 10000705
bookid: 10000490; pubID: 10000706
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000706,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000490 AND
		    AGENT_NAME_ID=10000135
goddammit MVZ: bookid: 10000490; pubID: 10000706
bookid: 10000491; pubID: 10000707
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000707,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000491 AND
		    AGENT_NAME_ID=10000216
goddammit MVZ: bookid: 10000491; pubID: 10000707
bookid: 10000491; pubID: 10000708
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000708,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000491 AND
		    AGENT_NAME_ID=10000216
goddammit MVZ: bookid: 10000491; pubID: 10000708
bookid: 10000491; pubID: 10000709
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000709,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000491 AND
		    AGENT_NAME_ID=10000216
goddammit MVZ: bookid: 10000491; pubID: 10000709
bookid: 10000492; pubID: 10000710
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000710,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000492 AND
		    AGENT_NAME_ID=10000216
goddammit MVZ: bookid: 10000492; pubID: 10000710
bookid: 10000492; pubID: 10000711
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000711,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000492 AND
		    AGENT_NAME_ID=10000216
goddammit MVZ: bookid: 10000492; pubID: 10000711
bookid: 10000492; pubID: 10000712
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000712,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000492 AND
		    AGENT_NAME_ID=10000216
goddammit MVZ: bookid: 10000492; pubID: 10000712
bookid: 10000493; pubID: 10000713
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000713,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000493 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000493; pubID: 10000713
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000713,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000493 AND
		    AGENT_NAME_ID=10006821
bookid: 10000493; pubID: 10000714
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000714,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000493 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000493; pubID: 10000714
bookid: 10000493; pubID: 10000715
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000715,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000493 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000493; pubID: 10000715
bookid: 10000493; pubID: 10000716
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000716,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000493 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000493; pubID: 10000716
bookid: 10000493; pubID: 10000717
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000717,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000493 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000493; pubID: 10000717
bookid: 10000493; pubID: 10000718
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000718,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000493 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000493; pubID: 10000718
bookid: 10000493; pubID: 10000719
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000719,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000493 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000493; pubID: 10000719
bookid: 10000493; pubID: 10000720
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000720,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000493 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000493; pubID: 10000720
bookid: 10000494; pubID: 10000721
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000721,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000494 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000494; pubID: 10000721
bookid: 10000495; pubID: 10000722
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000722,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10000722
bookid: 10000495; pubID: 10000723
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000723,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10000723
bookid: 10000495; pubID: 10000724
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000724,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10000724
bookid: 10000495; pubID: 10000725
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000725,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10000725
bookid: 10000495; pubID: 10000726
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000726,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10000726
bookid: 10000495; pubID: 10000727
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000727,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10000727
bookid: 10000495; pubID: 10000728
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000728,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10000728
bookid: 10000495; pubID: 10000729
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000729,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10000729
bookid: 10000495; pubID: 10000730
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000730,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10000730
bookid: 10000496; pubID: 10000731
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000731,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000496 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000496; pubID: 10000731
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000731,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000496 AND
		    AGENT_NAME_ID=10000225
bookid: 10000496; pubID: 10000732
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000732,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000496 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000496; pubID: 10000732
bookid: 10000496; pubID: 10000733
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000733,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000496 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000496; pubID: 10000733
bookid: 10000496; pubID: 10000734
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000734,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000496 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000496; pubID: 10000734
bookid: 10000497; pubID: 10000735
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000735,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000497 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000497; pubID: 10000735
bookid: 10000497; pubID: 10000736
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000736,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000497 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000497; pubID: 10000736
bookid: 10000497; pubID: 10000737
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000737,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000497 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000497; pubID: 10000737
bookid: 10000498; pubID: 10000738
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000738,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10000498 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000498; pubID: 10000738
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000738,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10000498 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10000498; pubID: 10000738
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000738,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10000498 AND
		    AGENT_NAME_ID=10005497
bookid: 10000498; pubID: 10000739
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000739,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000498 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000498; pubID: 10000739
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000739,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000498 AND
		    AGENT_NAME_ID=10000225
bookid: 10000499; pubID: 10000740
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000740,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000499 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000499; pubID: 10000740
bookid: 10000499; pubID: 10000741
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000741,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000499 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000499; pubID: 10000741
bookid: 10000499; pubID: 10000742
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000742,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000499 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000499; pubID: 10000742
bookid: 10000499; pubID: 10000743
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000743,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000499 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000499; pubID: 10000743
bookid: 10000499; pubID: 10000744
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000744,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000499 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000499; pubID: 10000744
bookid: 10000499; pubID: 10000745
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000745,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000499 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000499; pubID: 10000745
bookid: 10000499; pubID: 10000746
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000746,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000499 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000499; pubID: 10000746
bookid: 10000500; pubID: 10000747
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000747,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000500 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000500; pubID: 10000747
bookid: 10000500; pubID: 10000748
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000748,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000500 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000500; pubID: 10000748
bookid: 10000500; pubID: 10000749
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000749,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000500 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000500; pubID: 10000749
bookid: 10000500; pubID: 10000750
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000750,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000500 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000500; pubID: 10000750
bookid: 10000500; pubID: 10000751
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000751,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000500 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000500; pubID: 10000751
bookid: 10000500; pubID: 10000752
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000752,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000500 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000500; pubID: 10000752
bookid: 10000500; pubID: 10000753
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000753,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000500 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000500; pubID: 10000753
bookid: 10000500; pubID: 10000754
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000754,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000500 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000500; pubID: 10000754
bookid: 10000501; pubID: 10000755
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000755,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000501 AND
		    AGENT_NAME_ID=10000339
goddammit MVZ: bookid: 10000501; pubID: 10000755
bookid: 10000502; pubID: 10000756
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000756,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000502 AND
		    AGENT_NAME_ID=10000448
goddammit MVZ: bookid: 10000502; pubID: 10000756
bookid: 10000503; pubID: 10000757
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000757,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000503 AND
		    AGENT_NAME_ID=10000450
goddammit MVZ: bookid: 10000503; pubID: 10000757
bookid: 10000503; pubID: 10000758
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000758,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000503 AND
		    AGENT_NAME_ID=10000450
goddammit MVZ: bookid: 10000503; pubID: 10000758
bookid: 10000503; pubID: 10000759
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000759,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000503 AND
		    AGENT_NAME_ID=10000450
goddammit MVZ: bookid: 10000503; pubID: 10000759
bookid: 10000504; pubID: 10000760
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000760,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000504 AND
		    AGENT_NAME_ID=10000454
goddammit MVZ: bookid: 10000504; pubID: 10000760
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000760,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000504 AND
		    AGENT_NAME_ID=10000482
bookid: 10000504; pubID: 10000761
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000761,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000504 AND
		    AGENT_NAME_ID=10000454
goddammit MVZ: bookid: 10000504; pubID: 10000761
bookid: 10000504; pubID: 10000762
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000762,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000504 AND
		    AGENT_NAME_ID=10000454
goddammit MVZ: bookid: 10000504; pubID: 10000762
bookid: 10000504; pubID: 10000763
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000763,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000504 AND
		    AGENT_NAME_ID=10000454
bookid: 10000504; pubID: 10000764
npid:
bookid: 10000505; pubID: 10000765
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000765,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000505 AND
		    AGENT_NAME_ID=10000463
goddammit MVZ: bookid: 10000505; pubID: 10000765
bookid: 10000505; pubID: 10000766
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000766,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000505 AND
		    AGENT_NAME_ID=10000463
goddammit MVZ: bookid: 10000505; pubID: 10000766
bookid: 10000505; pubID: 10000767
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000767,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000505 AND
		    AGENT_NAME_ID=10000463
goddammit MVZ: bookid: 10000505; pubID: 10000767
bookid: 10000505; pubID: 10000768
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000768,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000505 AND
		    AGENT_NAME_ID=10000463
goddammit MVZ: bookid: 10000505; pubID: 10000768
bookid: 10000505; pubID: 10000769
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000769,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000505 AND
		    AGENT_NAME_ID=10000463
goddammit MVZ: bookid: 10000505; pubID: 10000769
bookid: 10000505; pubID: 10000770
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000770,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000505 AND
		    AGENT_NAME_ID=10000463
goddammit MVZ: bookid: 10000505; pubID: 10000770
bookid: 10000506; pubID: 10000771
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000771,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000506 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000506; pubID: 10000771
bookid: 10000506; pubID: 10000772
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000772,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000506 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000506; pubID: 10000772
bookid: 10000506; pubID: 10000773
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000773,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000506 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000506; pubID: 10000773
bookid: 10000506; pubID: 10000774
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000774,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000506 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000506; pubID: 10000774
bookid: 10000506; pubID: 10000775
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000775,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000506 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000506; pubID: 10000775
bookid: 10000506; pubID: 10000776
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000776,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000506 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000506; pubID: 10000776
bookid: 10000506; pubID: 10000777
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000777,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000506 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000506; pubID: 10000777
bookid: 10000507; pubID: 10000778
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000778,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000778
bookid: 10000507; pubID: 10000779
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000779,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000779
bookid: 10000507; pubID: 10000780
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000780,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000780
bookid: 10000507; pubID: 10000781
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000781,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000781
bookid: 10000507; pubID: 10000782
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000782,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000782
bookid: 10000507; pubID: 10000783
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000783,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000783
bookid: 10000507; pubID: 10000784
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000784,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000784
bookid: 10000507; pubID: 10000785
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000785,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000785
bookid: 10000507; pubID: 10000786
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000786,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000786
bookid: 10000507; pubID: 10000787
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000787,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000787
bookid: 10000507; pubID: 10000788
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000788,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000788
bookid: 10000507; pubID: 10000789
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000789,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000789
bookid: 10000507; pubID: 10000790
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000790,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000790
bookid: 10000507; pubID: 10000791
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000791,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000791
bookid: 10000507; pubID: 10000792
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000792,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000792
bookid: 10000507; pubID: 10000793
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000793,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000507 AND
		    AGENT_NAME_ID=10000695
goddammit MVZ: bookid: 10000507; pubID: 10000793
bookid: 10000508; pubID: 10000794
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000794,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000508 AND
		    AGENT_NAME_ID=10000777
goddammit MVZ: bookid: 10000508; pubID: 10000794
bookid: 10000509; pubID: 10000795
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000795,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000509 AND
		    AGENT_NAME_ID=10000868
goddammit MVZ: bookid: 10000509; pubID: 10000795
bookid: 10000509; pubID: 10000796
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000796,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000509 AND
		    AGENT_NAME_ID=10000868
goddammit MVZ: bookid: 10000509; pubID: 10000796
bookid: 10000509; pubID: 10000797
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000797,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000509 AND
		    AGENT_NAME_ID=10000868
goddammit MVZ: bookid: 10000509; pubID: 10000797
bookid: 10000510; pubID: 10000798
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000798,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000798
bookid: 10000510; pubID: 10000799
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000799,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000799
bookid: 10000510; pubID: 10000800
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000800,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000800
bookid: 10000510; pubID: 10000801
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000801,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000801
bookid: 10000510; pubID: 10000802
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000802,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000802
bookid: 10000510; pubID: 10000803
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000803,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000803
bookid: 10000510; pubID: 10000804
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000804,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000804
bookid: 10000510; pubID: 10000805
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000805,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000805
bookid: 10000510; pubID: 10000806
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000806,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000806
bookid: 10000510; pubID: 10000807
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000807,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000807
bookid: 10000510; pubID: 10000808
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000808,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000808
bookid: 10000510; pubID: 10000809
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000809,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000510 AND
		    AGENT_NAME_ID=10000905
goddammit MVZ: bookid: 10000510; pubID: 10000809
bookid: 10000514; pubID: 10000821
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000821,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000514 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000514; pubID: 10000821
bookid: 10000516; pubID: 10000825
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000825,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000516 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000516; pubID: 10000825
bookid: 10000516; pubID: 10000826
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000826,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000516 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000516; pubID: 10000826
bookid: 10000516; pubID: 10000827
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000827,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000516 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000516; pubID: 10000827
bookid: 10000516; pubID: 10000828
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000828,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000516 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000516; pubID: 10000828
bookid: 10000516; pubID: 10000829
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000829,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000516 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000516; pubID: 10000829
bookid: 10000517; pubID: 10000830
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000830,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000517 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000517; pubID: 10000830
bookid: 10000517; pubID: 10000831
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000831,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000517 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000517; pubID: 10000831
bookid: 10000517; pubID: 10000832
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000832,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000517 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000517; pubID: 10000832
bookid: 10000517; pubID: 10000833
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000833,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000517 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000517; pubID: 10000833
bookid: 10000518; pubID: 10000834
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000834,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10000518 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000518; pubID: 10000834
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000834,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10000518 AND
		    AGENT_NAME_ID=10000995
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000834,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10000518 AND
		    AGENT_NAME_ID=10011693
bookid: 10000518; pubID: 10000835
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000835,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000518 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000518; pubID: 10000835
bookid: 10000518; pubID: 10000836
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000836,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000518 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000518; pubID: 10000836
bookid: 10000519; pubID: 10000837
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000837,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000519 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000519; pubID: 10000837
bookid: 10000519; pubID: 10000838
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000838,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000519 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000519; pubID: 10000838
bookid: 10000519; pubID: 10000839
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000839,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000519 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000519; pubID: 10000839
bookid: 10000519; pubID: 10000840
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000840,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000519 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000519; pubID: 10000840
bookid: 10000520; pubID: 10000841
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000841,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000520 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000520; pubID: 10000841
bookid: 10000521; pubID: 10000842
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000842,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000521 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000521; pubID: 10000842
bookid: 10000522; pubID: 10000843
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000843,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000522 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000522; pubID: 10000843
bookid: 10000522; pubID: 10000844
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000844,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000522 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000522; pubID: 10000844
bookid: 10000522; pubID: 10000845
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000845,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000522 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000522; pubID: 10000845
bookid: 10000522; pubID: 10000846
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000846,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000522 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000522; pubID: 10000846
bookid: 10000522; pubID: 10000847
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000847,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000522 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000522; pubID: 10000847
bookid: 10000522; pubID: 10000848
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000848,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000522 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000522; pubID: 10000848
bookid: 10000523; pubID: 10000849
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000849,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000523 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000523; pubID: 10000849
bookid: 10000523; pubID: 10000850
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000850,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000523 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000523; pubID: 10000850
bookid: 10000523; pubID: 10000851
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000851,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000523 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000523; pubID: 10000851
bookid: 10000523; pubID: 10000852
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000852,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000523 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000523; pubID: 10000852
bookid: 10000523; pubID: 10000853
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000853,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000523 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000523; pubID: 10000853
bookid: 10000523; pubID: 10000854
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000854,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000523 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000523; pubID: 10000854
bookid: 10000523; pubID: 10000855
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000855,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000523 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000523; pubID: 10000855
bookid: 10000523; pubID: 10000856
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000856,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000523 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000523; pubID: 10000856
bookid: 10000524; pubID: 10000857
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000857,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000524 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000524; pubID: 10000857
bookid: 10000524; pubID: 10000858
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000858,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000524 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000524; pubID: 10000858
bookid: 10000524; pubID: 10000859
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000859,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000524 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000524; pubID: 10000859
bookid: 10000524; pubID: 10000860
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000860,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000524 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000524; pubID: 10000860
bookid: 10000524; pubID: 10000861
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000861,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000524 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000524; pubID: 10000861
bookid: 10000524; pubID: 10000862
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000862,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000524 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000524; pubID: 10000862
bookid: 10000525; pubID: 10000863
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000863,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000525 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000525; pubID: 10000863
bookid: 10000526; pubID: 10000864
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000864,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000526 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000526; pubID: 10000864
bookid: 10000526; pubID: 10000865
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000865,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000526 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000526; pubID: 10000865
bookid: 10000526; pubID: 10000866
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000866,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000526 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000526; pubID: 10000866
bookid: 10000526; pubID: 10000867
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000867,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000526 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000526; pubID: 10000867
bookid: 10000526; pubID: 10000868
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000868,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000526 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000526; pubID: 10000868
bookid: 10000527; pubID: 10000869
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000869,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000527 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000527; pubID: 10000869
bookid: 10000527; pubID: 10000870
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000870,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000527 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000527; pubID: 10000870
bookid: 10000527; pubID: 10000871
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000871,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000527 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000527; pubID: 10000871
bookid: 10000527; pubID: 10000872
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000872,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000527 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000527; pubID: 10000872
bookid: 10000528; pubID: 10000873
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000873,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000528 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000528; pubID: 10000873
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000873,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000528 AND
		    AGENT_NAME_ID=10008200
bookid: 10000528; pubID: 10000874
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000874,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000528 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000528; pubID: 10000874
bookid: 10000528; pubID: 10000875
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000875,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000528 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000528; pubID: 10000875
bookid: 10000528; pubID: 10000876
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000876,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000528 AND
		    AGENT_NAME_ID=10000251
bookid: 10000528; pubID: 10000877
npid:
bookid: 10000528; pubID: 10000878
npid:
bookid: 10000529; pubID: 10000879
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000879,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000529 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000529; pubID: 10000879
bookid: 10000530; pubID: 10000880
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000880,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000530 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000530; pubID: 10000880
bookid: 10000530; pubID: 10000882
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000882,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000530 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000530; pubID: 10000882
bookid: 10000530; pubID: 10000883
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000883,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000530 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000530; pubID: 10000883
bookid: 10000531; pubID: 10000884
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000884,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000531 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000531; pubID: 10000884
bookid: 10000531; pubID: 10000886
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000886,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000531 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000531; pubID: 10000886
bookid: 10000531; pubID: 10000887
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000887,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000531 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000531; pubID: 10000887
bookid: 10000532; pubID: 10000888
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000888,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000532 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000532; pubID: 10000888
bookid: 10000532; pubID: 10000889
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000889,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000532 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000532; pubID: 10000889
bookid: 10000532; pubID: 10000890
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000890,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000532 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000532; pubID: 10000890
bookid: 10000533; pubID: 10000891
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000891,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000533 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000533; pubID: 10000891
bookid: 10000533; pubID: 10000892
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000892,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000533 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000533; pubID: 10000892
bookid: 10000533; pubID: 10000893
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000893,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000533 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000533; pubID: 10000893
bookid: 10000534; pubID: 10000894
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000894,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000534 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000534; pubID: 10000894
bookid: 10000535; pubID: 10000895
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000895,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000535 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000535; pubID: 10000895
bookid: 10000535; pubID: 10000896
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000896,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000535 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000535; pubID: 10000896
bookid: 10000536; pubID: 10000897
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000897,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000897
bookid: 10000536; pubID: 10000898
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000898,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000898
bookid: 10000535; pubID: 10000899
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000899,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000535 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000535; pubID: 10000899
bookid: 10000536; pubID: 10000900
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000900,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000900
bookid: 10000536; pubID: 10000901
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000901,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000901
bookid: 10000536; pubID: 10000902
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000902,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000902
bookid: 10000536; pubID: 10000903
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000903,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000903
bookid: 10000536; pubID: 10000904
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000904,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000904
bookid: 10000537; pubID: 10000905
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000905,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000537 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000537; pubID: 10000905
bookid: 10000536; pubID: 10000906
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000906,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000906
bookid: 10000536; pubID: 10000907
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000907,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000907
bookid: 10000537; pubID: 10000908
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000908,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000537 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000537; pubID: 10000908
bookid: 10000536; pubID: 10000909
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000909,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000909
bookid: 10000536; pubID: 10000910
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000910,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000910
bookid: 10000537; pubID: 10000911
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000911,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000537 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000537; pubID: 10000911
bookid: 10000536; pubID: 10000912
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000912,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000536 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000536; pubID: 10000912
bookid: 10000537; pubID: 10000913
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000913,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000537 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000537; pubID: 10000913
bookid: 10000538; pubID: 10000914
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000914,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000538 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000538; pubID: 10000914
bookid: 10000538; pubID: 10000915
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000915,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000538 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000538; pubID: 10000915
bookid: 10000537; pubID: 10000916
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000916,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000537 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000537; pubID: 10000916
bookid: 10000538; pubID: 10000917
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000917,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000538 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000538; pubID: 10000917
bookid: 10000538; pubID: 10000918
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000918,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000538 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000538; pubID: 10000918
bookid: 10000538; pubID: 10000919
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000919,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000538 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000538; pubID: 10000919
bookid: 10000537; pubID: 10000920
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000920,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000537 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000537; pubID: 10000920
bookid: 10000538; pubID: 10000921
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000921,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000538 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000538; pubID: 10000921
bookid: 10000537; pubID: 10000922
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000922,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000537 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000537; pubID: 10000922
bookid: 10000539; pubID: 10000923
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000923,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000539 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000539; pubID: 10000923
bookid: 10000537; pubID: 10000924
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000924,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000537 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000537; pubID: 10000924
bookid: 10000539; pubID: 10000925
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000925,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000539 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000539; pubID: 10000925
bookid: 10000537; pubID: 10000926
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000926,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000537 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10000537; pubID: 10000926
bookid: 10000539; pubID: 10000927
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000927,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000539 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000539; pubID: 10000927
bookid: 10000539; pubID: 10000928
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000928,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000539 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000539; pubID: 10000928
bookid: 10000539; pubID: 10000929
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000929,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000539 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000539; pubID: 10000929
bookid: 10000540; pubID: 10000930
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000930,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000540 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000540; pubID: 10000930
bookid: 10000540; pubID: 10000931
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000931,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000540 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000540; pubID: 10000931
bookid: 10000540; pubID: 10000932
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000932,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000540 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000540; pubID: 10000932
bookid: 10000540; pubID: 10000933
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000933,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000540 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000540; pubID: 10000933
bookid: 10000540; pubID: 10000934
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000934,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000540 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000540; pubID: 10000934
bookid: 10000540; pubID: 10000935
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000935,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000540 AND
		    AGENT_NAME_ID=10000097
goddammit MVZ: bookid: 10000540; pubID: 10000935
bookid: 10000541; pubID: 10000936
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000936,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000541 AND
		    AGENT_NAME_ID=10014127
goddammit MVZ: bookid: 10000541; pubID: 10000936
bookid: 10000541; pubID: 10000937
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000937,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000541 AND
		    AGENT_NAME_ID=10014127
goddammit MVZ: bookid: 10000541; pubID: 10000937
bookid: 10000541; pubID: 10000938
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000938,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000541 AND
		    AGENT_NAME_ID=10014127
goddammit MVZ: bookid: 10000541; pubID: 10000938
bookid: 10000541; pubID: 10000939
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000939,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000541 AND
		    AGENT_NAME_ID=10014127
goddammit MVZ: bookid: 10000541; pubID: 10000939
bookid: 10000541; pubID: 10000940
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000940,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000541 AND
		    AGENT_NAME_ID=10014127
goddammit MVZ: bookid: 10000541; pubID: 10000940
bookid: 10000542; pubID: 10000941
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000941,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000542 AND
		    AGENT_NAME_ID=10001393
goddammit MVZ: bookid: 10000542; pubID: 10000941
bookid: 10000543; pubID: 10000942
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000942,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000543 AND
		    AGENT_NAME_ID=10001434
goddammit MVZ: bookid: 10000543; pubID: 10000942
bookid: 10000542; pubID: 10000943
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000943,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000542 AND
		    AGENT_NAME_ID=10001393
goddammit MVZ: bookid: 10000542; pubID: 10000943
bookid: 10000544; pubID: 10000944
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000944,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000544 AND
		    AGENT_NAME_ID=10001602
goddammit MVZ: bookid: 10000544; pubID: 10000944
bookid: 10000545; pubID: 10000945
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000945,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000545 AND
		    AGENT_NAME_ID=10000642
goddammit MVZ: bookid: 10000545; pubID: 10000945
bookid: 10000546; pubID: 10000946
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000946,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000546 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000546; pubID: 10000946
bookid: 10000546; pubID: 10000947
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000947,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000546 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000546; pubID: 10000947
bookid: 10000547; pubID: 10000948
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000948,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000547 AND
		    AGENT_NAME_ID=10001606
goddammit MVZ: bookid: 10000547; pubID: 10000948
bookid: 10000546; pubID: 10000949
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000949,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000546 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000546; pubID: 10000949
bookid: 10000547; pubID: 10000950
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000950,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000547 AND
		    AGENT_NAME_ID=10001606
goddammit MVZ: bookid: 10000547; pubID: 10000950
bookid: 10000546; pubID: 10000951
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000951,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000546 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000546; pubID: 10000951
bookid: 10000548; pubID: 10000952
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000952,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000548 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000548; pubID: 10000952
bookid: 10000546; pubID: 10000953
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000953,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000546 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000546; pubID: 10000953
bookid: 10000549; pubID: 10000954
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000954,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000549 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000549; pubID: 10000954
bookid: 10000548; pubID: 10000955
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000955,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000548 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000548; pubID: 10000955
bookid: 10000548; pubID: 10000956
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000956,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000548 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000548; pubID: 10000956
bookid: 10000549; pubID: 10000957
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000957,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000549 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000549; pubID: 10000957
bookid: 10000549; pubID: 10000958
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000958,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000549 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000549; pubID: 10000958
bookid: 10000549; pubID: 10000959
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000959,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000549 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000549; pubID: 10000959
bookid: 10000549; pubID: 10000960
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000960,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000549 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000549; pubID: 10000960
bookid: 10000548; pubID: 10000961
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000961,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000548 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000548; pubID: 10000961
bookid: 10000549; pubID: 10000962
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000962,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000549 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000549; pubID: 10000962
bookid: 10000550; pubID: 10000963
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000963,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000550 AND
		    AGENT_NAME_ID=10001785
goddammit MVZ: bookid: 10000550; pubID: 10000963
bookid: 10000550; pubID: 10000964
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000964,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000550 AND
		    AGENT_NAME_ID=10001785
goddammit MVZ: bookid: 10000550; pubID: 10000964
bookid: 10000550; pubID: 10000965
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000965,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000550 AND
		    AGENT_NAME_ID=10001785
goddammit MVZ: bookid: 10000550; pubID: 10000965
bookid: 10000552; pubID: 10000966
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000966,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000552 AND
		    AGENT_NAME_ID=10001796
goddammit MVZ: bookid: 10000552; pubID: 10000966
bookid: 10000551; pubID: 10000967
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000967,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000551 AND
		    AGENT_NAME_ID=10001904
goddammit MVZ: bookid: 10000551; pubID: 10000967
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000967,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000551 AND
		    AGENT_NAME_ID=10012400
bookid: 10000552; pubID: 10000968
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000968,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000552 AND
		    AGENT_NAME_ID=10001796
goddammit MVZ: bookid: 10000552; pubID: 10000968
bookid: 10000551; pubID: 10000969
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000969,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000551 AND
		    AGENT_NAME_ID=10001904
goddammit MVZ: bookid: 10000551; pubID: 10000969
bookid: 10000551; pubID: 10000970
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000970,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000551 AND
		    AGENT_NAME_ID=10001904
goddammit MVZ: bookid: 10000551; pubID: 10000970
bookid: 10000553; pubID: 10000971
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000971,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000553 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000553; pubID: 10000971
bookid: 10000554; pubID: 10000972
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000972,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000554 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000554; pubID: 10000972
bookid: 10000555; pubID: 10000973
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000973,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000555 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000555; pubID: 10000973
bookid: 10000556; pubID: 10000974
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000974,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000556 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000556; pubID: 10000974
bookid: 10000556; pubID: 10000975
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000975,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000556 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000556; pubID: 10000975
bookid: 10000556; pubID: 10000976
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000976,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000556 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000556; pubID: 10000976
bookid: 10000556; pubID: 10000977
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000977,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000556 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000556; pubID: 10000977
bookid: 10000556; pubID: 10000978
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000978,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000556 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000556; pubID: 10000978
bookid: 10000556; pubID: 10000979
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000979,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000556 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000556; pubID: 10000979
bookid: 10000557; pubID: 10000980
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000980,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000557 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000557; pubID: 10000980
bookid: 10000557; pubID: 10000981
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000981,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000557 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000557; pubID: 10000981
bookid: 10000557; pubID: 10000982
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000982,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000557 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000557; pubID: 10000982
bookid: 10000557; pubID: 10000983
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000983,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000557 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000557; pubID: 10000983
bookid: 10000557; pubID: 10000984
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000984,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000557 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000557; pubID: 10000984
bookid: 10000557; pubID: 10000985
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000985,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000557 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000557; pubID: 10000985
bookid: 10000558; pubID: 10000986
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000986,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000558 AND
		    AGENT_NAME_ID=10002184
goddammit MVZ: bookid: 10000558; pubID: 10000986
bookid: 10000558; pubID: 10000987
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000987,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000558 AND
		    AGENT_NAME_ID=10002184
goddammit MVZ: bookid: 10000558; pubID: 10000987
bookid: 10000558; pubID: 10000988
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000988,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000558 AND
		    AGENT_NAME_ID=10002184
goddammit MVZ: bookid: 10000558; pubID: 10000988
bookid: 10000559; pubID: 10000989
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000989,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000559 AND
		    AGENT_NAME_ID=10002205
bookid: 10000559; pubID: 10000990
npid:
bookid: 10000560; pubID: 10000991
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000991,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000560 AND
		    AGENT_NAME_ID=10002283
goddammit MVZ: bookid: 10000560; pubID: 10000991
bookid: 10000560; pubID: 10000992
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000992,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000560 AND
		    AGENT_NAME_ID=10002283
goddammit MVZ: bookid: 10000560; pubID: 10000992
bookid: 10000560; pubID: 10000993
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000993,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000560 AND
		    AGENT_NAME_ID=10002283
goddammit MVZ: bookid: 10000560; pubID: 10000993
bookid: 10000560; pubID: 10000994
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000994,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000560 AND
		    AGENT_NAME_ID=10002283
goddammit MVZ: bookid: 10000560; pubID: 10000994
bookid: 10000560; pubID: 10000995
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000995,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000560 AND
		    AGENT_NAME_ID=10002283
goddammit MVZ: bookid: 10000560; pubID: 10000995
bookid: 10000561; pubID: 10000996
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000996,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000561 AND
		    AGENT_NAME_ID=10002283
goddammit MVZ: bookid: 10000561; pubID: 10000996
bookid: 10000562; pubID: 10000997
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000997,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000562 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000562; pubID: 10000997
bookid: 10000562; pubID: 10000998
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000998,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000562 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000562; pubID: 10000998
bookid: 10000562; pubID: 10000999
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10000999,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000562 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000562; pubID: 10000999
bookid: 10000562; pubID: 10001000
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001000,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000562 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000562; pubID: 10001000
bookid: 10000562; pubID: 10001001
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001001,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000562 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000562; pubID: 10001001
bookid: 10000562; pubID: 10001002
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001002,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000562 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000562; pubID: 10001002
bookid: 10000562; pubID: 10001003
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001003,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000562 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000562; pubID: 10001003
bookid: 10000563; pubID: 10001004
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001004,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000563 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000563; pubID: 10001004
bookid: 10000563; pubID: 10001005
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001005,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000563 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000563; pubID: 10001005
bookid: 10000563; pubID: 10001006
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001006,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000563 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000563; pubID: 10001006
bookid: 10000563; pubID: 10001007
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001007,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000563 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10000563; pubID: 10001007
bookid: 10000564; pubID: 10001008
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001008,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000564 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000564; pubID: 10001008
bookid: 10000565; pubID: 10001009
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001009,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000565 AND
		    AGENT_NAME_ID=10001318
goddammit MVZ: bookid: 10000565; pubID: 10001009
bookid: 10000565; pubID: 10001010
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001010,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000565 AND
		    AGENT_NAME_ID=10001318
goddammit MVZ: bookid: 10000565; pubID: 10001010
bookid: 10000564; pubID: 10001011
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001011,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000564 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000564; pubID: 10001011
bookid: 10000565; pubID: 10001012
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001012,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000565 AND
		    AGENT_NAME_ID=10001318
goddammit MVZ: bookid: 10000565; pubID: 10001012
bookid: 10000565; pubID: 10001013
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001013,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000565 AND
		    AGENT_NAME_ID=10001318
goddammit MVZ: bookid: 10000565; pubID: 10001013
bookid: 10000564; pubID: 10001014
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001014,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000564 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000564; pubID: 10001014
bookid: 10000565; pubID: 10001015
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001015,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000565 AND
		    AGENT_NAME_ID=10001318
goddammit MVZ: bookid: 10000565; pubID: 10001015
bookid: 10000566; pubID: 10001016
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001016,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000566 AND
		    AGENT_NAME_ID=10001318
goddammit MVZ: bookid: 10000566; pubID: 10001016
bookid: 10000566; pubID: 10001017
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001017,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000566 AND
		    AGENT_NAME_ID=10001318
goddammit MVZ: bookid: 10000566; pubID: 10001017
bookid: 10000566; pubID: 10001018
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001018,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000566 AND
		    AGENT_NAME_ID=10001318
goddammit MVZ: bookid: 10000566; pubID: 10001018
bookid: 10000564; pubID: 10001019
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001019,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000564 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000564; pubID: 10001019
bookid: 10000566; pubID: 10001020
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001020,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000566 AND
		    AGENT_NAME_ID=10001318
goddammit MVZ: bookid: 10000566; pubID: 10001020
bookid: 10000566; pubID: 10001021
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001021,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000566 AND
		    AGENT_NAME_ID=10001318
goddammit MVZ: bookid: 10000566; pubID: 10001021
bookid: 10000567; pubID: 10001022
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001022,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000567 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000567; pubID: 10001022
bookid: 10000567; pubID: 10001023
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001023,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000567 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000567; pubID: 10001023
bookid: 10000564; pubID: 10001024
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001024,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000564 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000564; pubID: 10001024
bookid: 10000567; pubID: 10001025
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001025,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000567 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000567; pubID: 10001025
bookid: 10000567; pubID: 10001026
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001026,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000567 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000567; pubID: 10001026
bookid: 10000569; pubID: 10001027
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001027,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000569 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000569; pubID: 10001027
bookid: 10000569; pubID: 10001028
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001028,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000569 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000569; pubID: 10001028
bookid: 10000569; pubID: 10001029
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001029,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000569 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000569; pubID: 10001029
bookid: 10000568; pubID: 10001030
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001030,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000568 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000568; pubID: 10001030
bookid: 10000568; pubID: 10001031
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001031,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000568 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000568; pubID: 10001031
bookid: 10000568; pubID: 10001032
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001032,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000568 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000568; pubID: 10001032
bookid: 10000569; pubID: 10001033
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001033,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000569 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000569; pubID: 10001033
bookid: 10000570; pubID: 10001034
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001034,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000570 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000570; pubID: 10001034
bookid: 10000568; pubID: 10001035
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001035,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000568 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000568; pubID: 10001035
bookid: 10000570; pubID: 10001036
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001036,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000570 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000570; pubID: 10001036
bookid: 10000570; pubID: 10001037
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001037,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000570 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000570; pubID: 10001037
bookid: 10000568; pubID: 10001038
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001038,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000568 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000568; pubID: 10001038
bookid: 10000568; pubID: 10001039
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001039,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000568 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000568; pubID: 10001039
bookid: 10000570; pubID: 10001040
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001040,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000570 AND
		    AGENT_NAME_ID=10002460
goddammit MVZ: bookid: 10000570; pubID: 10001040
bookid: 10000571; pubID: 10001041
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001041,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000571 AND
		    AGENT_NAME_ID=10002528
goddammit MVZ: bookid: 10000571; pubID: 10001041
bookid: 10000571; pubID: 10001042
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001042,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000571 AND
		    AGENT_NAME_ID=10002528
goddammit MVZ: bookid: 10000571; pubID: 10001042
bookid: 10000571; pubID: 10001043
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001043,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000571 AND
		    AGENT_NAME_ID=10002528
goddammit MVZ: bookid: 10000571; pubID: 10001043
bookid: 10000571; pubID: 10001044
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001044,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000571 AND
		    AGENT_NAME_ID=10002528
goddammit MVZ: bookid: 10000571; pubID: 10001044
bookid: 10000571; pubID: 10001045
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001045,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000571 AND
		    AGENT_NAME_ID=10002528
goddammit MVZ: bookid: 10000571; pubID: 10001045
bookid: 10000573; pubID: 10001046
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001046,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000573 AND
		    AGENT_NAME_ID=10002528
bookid: 10000572; pubID: 10001047
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001047,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000572 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000572; pubID: 10001047
bookid: 10000574; pubID: 10001048
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001048,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000574 AND
		    AGENT_NAME_ID=10002738
bookid: 10000575; pubID: 10001049
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001049,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000575 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000575; pubID: 10001049
bookid: 10000574; pubID: 10001050
npid:
bookid: 10000576; pubID: 10001051
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001051,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000576 AND
		    AGENT_NAME_ID=10002749
goddammit MVZ: bookid: 10000576; pubID: 10001051
bookid: 10000576; pubID: 10001052
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001052,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000576 AND
		    AGENT_NAME_ID=10002749
goddammit MVZ: bookid: 10000576; pubID: 10001052
bookid: 10000575; pubID: 10001053
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001053,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000575 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000575; pubID: 10001053
bookid: 10000576; pubID: 10001054
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001054,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000576 AND
		    AGENT_NAME_ID=10002749
goddammit MVZ: bookid: 10000576; pubID: 10001054
bookid: 10000575; pubID: 10001055
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001055,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000575 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000575; pubID: 10001055
bookid: 10000577; pubID: 10001056
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001056,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000577 AND
		    AGENT_NAME_ID=10002758
goddammit MVZ: bookid: 10000577; pubID: 10001056
bookid: 10000575; pubID: 10001058
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001058,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000575 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000575; pubID: 10001058
bookid: 10000575; pubID: 10001059
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001059,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000575 AND
		    AGENT_NAME_ID=10002838
goddammit MVZ: bookid: 10000575; pubID: 10001059
bookid: 10000579; pubID: 10001060
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001060,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000579 AND
		    AGENT_NAME_ID=10002963
goddammit MVZ: bookid: 10000579; pubID: 10001060
bookid: 10000579; pubID: 10001061
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001061,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000579 AND
		    AGENT_NAME_ID=10002963
goddammit MVZ: bookid: 10000579; pubID: 10001061
bookid: 10000578; pubID: 10001062
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001062,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000578 AND
		    AGENT_NAME_ID=10002868
goddammit MVZ: bookid: 10000578; pubID: 10001062
bookid: 10000579; pubID: 10001063
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001063,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000579 AND
		    AGENT_NAME_ID=10002963
goddammit MVZ: bookid: 10000579; pubID: 10001063
bookid: 10000578; pubID: 10001064
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001064,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000578 AND
		    AGENT_NAME_ID=10002868
goddammit MVZ: bookid: 10000578; pubID: 10001064
bookid: 10000580; pubID: 10001065
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001065,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000580 AND
		    AGENT_NAME_ID=10002963
goddammit MVZ: bookid: 10000580; pubID: 10001065
bookid: 10000580; pubID: 10001066
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001066,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000580 AND
		    AGENT_NAME_ID=10002963
goddammit MVZ: bookid: 10000580; pubID: 10001066
bookid: 10000580; pubID: 10001067
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001067,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000580 AND
		    AGENT_NAME_ID=10002963
goddammit MVZ: bookid: 10000580; pubID: 10001067
bookid: 10000582; pubID: 10001070
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001070,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000582 AND
		    AGENT_NAME_ID=10003040
goddammit MVZ: bookid: 10000582; pubID: 10001070
bookid: 10000583; pubID: 10001072
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001072,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000583 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000583; pubID: 10001072
bookid: 10000583; pubID: 10001073
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001073,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000583 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000583; pubID: 10001073
bookid: 10000583; pubID: 10001075
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001075,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000583 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000583; pubID: 10001075
bookid: 10000583; pubID: 10001076
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001076,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000583 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000583; pubID: 10001076
bookid: 10000583; pubID: 10001077
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001077,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000583 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000583; pubID: 10001077
bookid: 10000583; pubID: 10001079
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001079,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000583 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000583; pubID: 10001079
bookid: 10000583; pubID: 10001080
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001080,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000583 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000583; pubID: 10001080
bookid: 10000584; pubID: 10001082
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001082,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000584 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000584; pubID: 10001082
bookid: 10000584; pubID: 10001084
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001084,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000584 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000584; pubID: 10001084
bookid: 10000584; pubID: 10001085
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001085,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000584 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000584; pubID: 10001085
bookid: 10000585; pubID: 10001086
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001086,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000585 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000585; pubID: 10001086
bookid: 10000585; pubID: 10001087
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001087,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000585 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000585; pubID: 10001087
bookid: 10000586; pubID: 10001088
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001088,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000586 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000586; pubID: 10001088
bookid: 10000587; pubID: 10001090
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001090,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000587 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000587; pubID: 10001090
bookid: 10000587; pubID: 10001091
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001091,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000587 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000587; pubID: 10001091
bookid: 10000587; pubID: 10001092
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001092,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000587 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000587; pubID: 10001092
bookid: 10000587; pubID: 10001093
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001093,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000587 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000587; pubID: 10001093
bookid: 10000587; pubID: 10001095
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001095,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000587 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000587; pubID: 10001095
bookid: 10000589; pubID: 10001097
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001097,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000589 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000589; pubID: 10001097
bookid: 10000589; pubID: 10001099
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001099,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000589 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000589; pubID: 10001099
bookid: 10000589; pubID: 10001101
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001101,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000589 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000589; pubID: 10001101
bookid: 10000591; pubID: 10001107
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001107,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000591 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000591; pubID: 10001107
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001107,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000591 AND
		    AGENT_NAME_ID=10002395
bookid: 10000591; pubID: 10001110
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001110,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000591 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000591; pubID: 10001110
bookid: 10000591; pubID: 10001111
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001111,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000591 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000591; pubID: 10001111
bookid: 10000592; pubID: 10001112
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001112,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000592 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000592; pubID: 10001112
bookid: 10000592; pubID: 10001113
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001113,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000592 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000592; pubID: 10001113
bookid: 10000592; pubID: 10001114
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001114,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000592 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000592; pubID: 10001114
bookid: 10000592; pubID: 10001115
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001115,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000592 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000592; pubID: 10001115
bookid: 10000592; pubID: 10001116
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001116,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000592 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000592; pubID: 10001116
bookid: 10000593; pubID: 10001117
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001117,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000593 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000593; pubID: 10001117
bookid: 10000593; pubID: 10001118
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001118,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000593 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000593; pubID: 10001118
bookid: 10000593; pubID: 10001119
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001119,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000593 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000593; pubID: 10001119
bookid: 10000593; pubID: 10001120
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001120,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000593 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000593; pubID: 10001120
bookid: 10000593; pubID: 10001121
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001121,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000593 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000593; pubID: 10001121
bookid: 10000593; pubID: 10001122
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001122,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000593 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000593; pubID: 10001122
bookid: 10000594; pubID: 10001123
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001123,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000594 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000594; pubID: 10001123
bookid: 10000594; pubID: 10001124
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001124,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000594 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000594; pubID: 10001124
bookid: 10000594; pubID: 10001125
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001125,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000594 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000594; pubID: 10001125
bookid: 10000594; pubID: 10001126
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001126,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000594 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000594; pubID: 10001126
bookid: 10000594; pubID: 10001127
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001127,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000594 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000594; pubID: 10001127
bookid: 10000594; pubID: 10001128
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001128,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000594 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000594; pubID: 10001128
bookid: 10000594; pubID: 10001129
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001129,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000594 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000594; pubID: 10001129
bookid: 10000595; pubID: 10001130
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001130,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001130
bookid: 10000595; pubID: 10001131
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001131,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001131
bookid: 10000595; pubID: 10001132
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001132,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001132
bookid: 10000595; pubID: 10001133
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001133,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001133
bookid: 10000595; pubID: 10001134
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001134,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001134
bookid: 10000595; pubID: 10001135
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001135,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001135
bookid: 10000595; pubID: 10001136
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001136,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001136
bookid: 10000595; pubID: 10001137
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001137,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001137
bookid: 10000595; pubID: 10001138
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001138,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001138
bookid: 10000595; pubID: 10001139
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001139,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001139
bookid: 10000595; pubID: 10001140
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001140,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001140
bookid: 10000595; pubID: 10001141
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001141,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000595 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000595; pubID: 10001141
bookid: 10000596; pubID: 10001142
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001142,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001142
bookid: 10000596; pubID: 10001143
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001143,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001143
bookid: 10000596; pubID: 10001144
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001144,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001144
bookid: 10000596; pubID: 10001145
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001145,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001145
bookid: 10000596; pubID: 10001146
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001146,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001146
bookid: 10000596; pubID: 10001147
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001147,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001147
bookid: 10000596; pubID: 10001148
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001148,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001148
bookid: 10000596; pubID: 10001149
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001149,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001149
bookid: 10000596; pubID: 10001150
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001150,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001150
bookid: 10000596; pubID: 10001151
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001151,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001151
bookid: 10000596; pubID: 10001152
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001152,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000596 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000596; pubID: 10001152
bookid: 10000597; pubID: 10001153
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001153,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000597 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000597; pubID: 10001153
bookid: 10000597; pubID: 10001154
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001154,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000597 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000597; pubID: 10001154
bookid: 10000597; pubID: 10001155
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001155,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000597 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000597; pubID: 10001155
bookid: 10000597; pubID: 10001156
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001156,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000597 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000597; pubID: 10001156
bookid: 10000597; pubID: 10001157
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001157,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000597 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000597; pubID: 10001157
bookid: 10000597; pubID: 10001159
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001159,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000597 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000597; pubID: 10001159
bookid: 10000598; pubID: 10001160
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001160,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000598 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000598; pubID: 10001160
bookid: 10000598; pubID: 10001161
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001161,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000598 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000598; pubID: 10001161
bookid: 10000598; pubID: 10001162
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001162,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000598 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000598; pubID: 10001162
bookid: 10000598; pubID: 10001163
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001163,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000598 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000598; pubID: 10001163
bookid: 10000598; pubID: 10001164
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001164,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000598 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000598; pubID: 10001164
bookid: 10000598; pubID: 10001165
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001165,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000598 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000598; pubID: 10001165
bookid: 10000598; pubID: 10001166
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001166,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000598 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000598; pubID: 10001166
bookid: 10000598; pubID: 10001167
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001167,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000598 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000598; pubID: 10001167
bookid: 10000599; pubID: 10001168
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001168,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000599 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000599; pubID: 10001168
bookid: 10000599; pubID: 10001169
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001169,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000599 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000599; pubID: 10001169
bookid: 10000599; pubID: 10001170
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001170,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000599 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000599; pubID: 10001170
bookid: 10000599; pubID: 10001171
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001171,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000599 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000599; pubID: 10001171
bookid: 10000599; pubID: 10001172
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001172,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000599 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000599; pubID: 10001172
bookid: 10000599; pubID: 10001173
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001173,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000599 AND
		    AGENT_NAME_ID=10001279
goddammit MVZ: bookid: 10000599; pubID: 10001173
bookid: 10000600; pubID: 10001174
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001174,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000600 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000600; pubID: 10001174
bookid: 10000600; pubID: 10001175
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001175,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000600 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000600; pubID: 10001175
bookid: 10000600; pubID: 10001176
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001176,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000600 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000600; pubID: 10001176
bookid: 10000600; pubID: 10001177
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001177,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000600 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000600; pubID: 10001177
bookid: 10000600; pubID: 10001178
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001178,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000600 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000600; pubID: 10001178
bookid: 10000600; pubID: 10001179
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001179,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000600 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000600; pubID: 10001179
bookid: 10000601; pubID: 10001180
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001180,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000601 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000601; pubID: 10001180
bookid: 10000601; pubID: 10001181
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001181,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000601 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000601; pubID: 10001181
bookid: 10000601; pubID: 10001182
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001182,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000601 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000601; pubID: 10001182
bookid: 10000601; pubID: 10001183
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001183,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000601 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000601; pubID: 10001183
bookid: 10000601; pubID: 10001184
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001184,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000601 AND
		    AGENT_NAME_ID=10003251
goddammit MVZ: bookid: 10000601; pubID: 10001184
bookid: 10000635; pubID: 10001185
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001185,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000635 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000635; pubID: 10001185
bookid: 10000635; pubID: 10001186
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001186,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000635 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000635; pubID: 10001186
bookid: 10000635; pubID: 10001187
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001187,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000635 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000635; pubID: 10001187
bookid: 10000635; pubID: 10001188
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001188,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000635 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000635; pubID: 10001188
bookid: 10000635; pubID: 10001189
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001189,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000635 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000635; pubID: 10001189
bookid: 10000636; pubID: 10001190
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001190,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000636 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000636; pubID: 10001190
bookid: 10000636; pubID: 10001191
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001191,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000636 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000636; pubID: 10001191
bookid: 10000636; pubID: 10001192
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001192,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000636 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000636; pubID: 10001192
bookid: 10000637; pubID: 10001193
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001193,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000637 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000637; pubID: 10001193
bookid: 10000637; pubID: 10001194
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001194,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000637 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000637; pubID: 10001194
bookid: 10000637; pubID: 10001195
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001195,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000637 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000637; pubID: 10001195
bookid: 10000638; pubID: 10001196
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001196,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000638 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000638; pubID: 10001196
bookid: 10000639; pubID: 10001197
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001197,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000639 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000639; pubID: 10001197
bookid: 10000639; pubID: 10001198
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001198,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000639 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000639; pubID: 10001198
bookid: 10000639; pubID: 10001199
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001199,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000639 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000639; pubID: 10001199
bookid: 10000639; pubID: 10001200
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001200,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000639 AND
		    AGENT_NAME_ID=10000956
goddammit MVZ: bookid: 10000639; pubID: 10001200
bookid: 10000641; pubID: 10001201
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001201,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000641 AND
		    AGENT_NAME_ID=10002868
goddammit MVZ: bookid: 10000641; pubID: 10001201
bookid: 10000641; pubID: 10001202
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001202,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000641 AND
		    AGENT_NAME_ID=10002868
goddammit MVZ: bookid: 10000641; pubID: 10001202
bookid: 10000642; pubID: 10001203
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001203,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000642 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000642; pubID: 10001203
bookid: 10000642; pubID: 10001204
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001204,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000642 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000642; pubID: 10001204
bookid: 10000642; pubID: 10001205
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001205,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000642 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000642; pubID: 10001205
bookid: 10000642; pubID: 10001206
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001206,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000642 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000642; pubID: 10001206
bookid: 10000642; pubID: 10001207
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001207,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000642 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000642; pubID: 10001207
bookid: 10000642; pubID: 10001208
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001208,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000642 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000642; pubID: 10001208
bookid: 10000642; pubID: 10001209
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001209,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000642 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000642; pubID: 10001209
bookid: 10000644; pubID: 10001212
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001212,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000644 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000644; pubID: 10001212
bookid: 10000644; pubID: 10001213
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001213,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000644 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000644; pubID: 10001213
bookid: 10000644; pubID: 10001214
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001214,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000644 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000644; pubID: 10001214
bookid: 10000644; pubID: 10001215
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001215,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000644 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000644; pubID: 10001215
bookid: 10000644; pubID: 10001216
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001216,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000644 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000644; pubID: 10001216
bookid: 10000645; pubID: 10001217
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001217,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000645 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000645; pubID: 10001217
bookid: 10000645; pubID: 10001218
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001218,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000645 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000645; pubID: 10001218
bookid: 10000645; pubID: 10001219
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001219,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000645 AND
		    AGENT_NAME_ID=10002911
goddammit MVZ: bookid: 10000645; pubID: 10001219
bookid: 10000646; pubID: 10001220
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001220,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000646 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000646; pubID: 10001220
bookid: 10000646; pubID: 10001221
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001221,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000646 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000646; pubID: 10001221
bookid: 10000646; pubID: 10001222
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001222,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000646 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000646; pubID: 10001222
bookid: 10000646; pubID: 10001223
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001223,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000646 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000646; pubID: 10001223
bookid: 10000646; pubID: 10001224
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001224,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000646 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000646; pubID: 10001224
bookid: 10000647; pubID: 10001225
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001225,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000647 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000647; pubID: 10001225
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001225,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000647 AND
		    AGENT_NAME_ID=10002395
bookid: 10000647; pubID: 10001226
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001226,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000647 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000647; pubID: 10001226
bookid: 10000647; pubID: 10001227
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001227,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000647 AND
		    AGENT_NAME_ID=10000936
goddammit MVZ: bookid: 10000647; pubID: 10001227
bookid: 10000648; pubID: 10001228
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001228,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000648 AND
		    AGENT_NAME_ID=10003407
goddammit MVZ: bookid: 10000648; pubID: 10001228
bookid: 10000649; pubID: 10001229
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001229,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000649 AND
		    AGENT_NAME_ID=10001427
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001229,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10000649 AND
		    AGENT_NAME_ID=10003430
goddammit MVZ: bookid: 10000649; pubID: 10001229
bookid: 10000649; pubID: 10001230
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001230,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000649 AND
		    AGENT_NAME_ID=10003430
goddammit MVZ: bookid: 10000649; pubID: 10001230
bookid: 10000650; pubID: 10001232
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001232,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000650 AND
		    AGENT_NAME_ID=10003428
goddammit MVZ: bookid: 10000650; pubID: 10001232
bookid: 10000651; pubID: 10001233
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001233,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000651 AND
		    AGENT_NAME_ID=10003460
goddammit MVZ: bookid: 10000651; pubID: 10001233
bookid: 10000651; pubID: 10001234
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001234,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000651 AND
		    AGENT_NAME_ID=10003460
goddammit MVZ: bookid: 10000651; pubID: 10001234
bookid: 10000652; pubID: 10001235
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001235,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000652 AND
		    AGENT_NAME_ID=10003498
goddammit MVZ: bookid: 10000652; pubID: 10001235
bookid: 10000653; pubID: 10001236
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001236,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000653 AND
		    AGENT_NAME_ID=10003546
goddammit MVZ: bookid: 10000653; pubID: 10001236
bookid: 10000653; pubID: 10001237
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001237,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000653 AND
		    AGENT_NAME_ID=10003546
goddammit MVZ: bookid: 10000653; pubID: 10001237
bookid: 10000653; pubID: 10001238
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001238,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000653 AND
		    AGENT_NAME_ID=10003546
goddammit MVZ: bookid: 10000653; pubID: 10001238
bookid: 10000653; pubID: 10001239
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001239,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000653 AND
		    AGENT_NAME_ID=10003546
goddammit MVZ: bookid: 10000653; pubID: 10001239
bookid: 10000654; pubID: 10001240
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001240,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000654 AND
		    AGENT_NAME_ID=10003634
goddammit MVZ: bookid: 10000654; pubID: 10001240
bookid: 10000655; pubID: 10001241
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001241,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000655 AND
		    AGENT_NAME_ID=10003624
goddammit MVZ: bookid: 10000655; pubID: 10001241
bookid: 10000655; pubID: 10001242
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001242,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000655 AND
		    AGENT_NAME_ID=10003624
goddammit MVZ: bookid: 10000655; pubID: 10001242
bookid: 10000655; pubID: 10001243
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001243,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000655 AND
		    AGENT_NAME_ID=10003624
goddammit MVZ: bookid: 10000655; pubID: 10001243
bookid: 10000656; pubID: 10001244
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001244,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000656 AND
		    AGENT_NAME_ID=10000679
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001244,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10000656 AND
		    AGENT_NAME_ID=10003648
goddammit MVZ: bookid: 10000656; pubID: 10001244
bookid: 10000656; pubID: 10001245
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001245,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000656 AND
		    AGENT_NAME_ID=10003648
goddammit MVZ: bookid: 10000656; pubID: 10001245
bookid: 10000658; pubID: 10001246
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001246,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000658 AND
		    AGENT_NAME_ID=10003456
goddammit MVZ: bookid: 10000658; pubID: 10001246
bookid: 10000659; pubID: 10001247
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001247,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000659 AND
		    AGENT_NAME_ID=10003456
goddammit MVZ: bookid: 10000659; pubID: 10001247
bookid: 10000660; pubID: 10001248
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001248,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000660 AND
		    AGENT_NAME_ID=10003456
goddammit MVZ: bookid: 10000660; pubID: 10001248
bookid: 10000661; pubID: 10001249
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001249,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000661 AND
		    AGENT_NAME_ID=10003456
goddammit MVZ: bookid: 10000661; pubID: 10001249
bookid: 10000662; pubID: 10001250
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001250,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000662 AND
		    AGENT_NAME_ID=10003456
goddammit MVZ: bookid: 10000662; pubID: 10001250
bookid: 10000663; pubID: 10001251
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001251,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000663 AND
		    AGENT_NAME_ID=10003456
goddammit MVZ: bookid: 10000663; pubID: 10001251
bookid: 10000664; pubID: 10001252
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001252,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000664 AND
		    AGENT_NAME_ID=10003456
goddammit MVZ: bookid: 10000664; pubID: 10001252
bookid: 10000665; pubID: 10001253
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001253,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000665 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000665; pubID: 10001253
bookid: 10000665; pubID: 10001254
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001254,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000665 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000665; pubID: 10001254
bookid: 10000666; pubID: 10001255
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001255,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000666 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000666; pubID: 10001255
bookid: 10000666; pubID: 10001256
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001256,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000666 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000666; pubID: 10001256
bookid: 10000667; pubID: 10001257
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001257,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000667 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000667; pubID: 10001257
bookid: 10000667; pubID: 10001258
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001258,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000667 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000667; pubID: 10001258
bookid: 10000668; pubID: 10001259
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001259,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000668 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000668; pubID: 10001259
bookid: 10000668; pubID: 10001260
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001260,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000668 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000668; pubID: 10001260
bookid: 10000669; pubID: 10001261
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001261,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000669 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000669; pubID: 10001261
bookid: 10000669; pubID: 10001262
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001262,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000669 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000669; pubID: 10001262
bookid: 10000670; pubID: 10001263
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001263,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000670 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000670; pubID: 10001263
bookid: 10000671; pubID: 10001264
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001264,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000671 AND
		    AGENT_NAME_ID=10014130
goddammit MVZ: bookid: 10000671; pubID: 10001264
bookid: 10000672; pubID: 10001265
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001265,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000672 AND
		    AGENT_NAME_ID=10001012
goddammit MVZ: bookid: 10000672; pubID: 10001265
bookid: 10000672; pubID: 10001266
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001266,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000672 AND
		    AGENT_NAME_ID=10001012
goddammit MVZ: bookid: 10000672; pubID: 10001266
bookid: 10000672; pubID: 10001267
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001267,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000672 AND
		    AGENT_NAME_ID=10001012
goddammit MVZ: bookid: 10000672; pubID: 10001267
bookid: 10000672; pubID: 10001268
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001268,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000672 AND
		    AGENT_NAME_ID=10001012
goddammit MVZ: bookid: 10000672; pubID: 10001268
bookid: 10000672; pubID: 10001269
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001269,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000672 AND
		    AGENT_NAME_ID=10001012
goddammit MVZ: bookid: 10000672; pubID: 10001269
bookid: 10000672; pubID: 10001270
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001270,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000672 AND
		    AGENT_NAME_ID=10001012
goddammit MVZ: bookid: 10000672; pubID: 10001270
bookid: 10000673; pubID: 10001271
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001271,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000673 AND
		    AGENT_NAME_ID=10003042
goddammit MVZ: bookid: 10000673; pubID: 10001271
bookid: 10000673; pubID: 10001272
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001272,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000673 AND
		    AGENT_NAME_ID=10003042
goddammit MVZ: bookid: 10000673; pubID: 10001272
bookid: 10000673; pubID: 10001273
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001273,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000673 AND
		    AGENT_NAME_ID=10003042
goddammit MVZ: bookid: 10000673; pubID: 10001273
bookid: 10000673; pubID: 10001274
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001274,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000673 AND
		    AGENT_NAME_ID=10003042
goddammit MVZ: bookid: 10000673; pubID: 10001274
bookid: 10000673; pubID: 10001275
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001275,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000673 AND
		    AGENT_NAME_ID=10003042
goddammit MVZ: bookid: 10000673; pubID: 10001275
bookid: 10000674; pubID: 10001276
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001276,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000674 AND
		    AGENT_NAME_ID=10003999
goddammit MVZ: bookid: 10000674; pubID: 10001276
bookid: 10000674; pubID: 10001277
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001277,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000674 AND
		    AGENT_NAME_ID=10003999
goddammit MVZ: bookid: 10000674; pubID: 10001277
bookid: 10000674; pubID: 10001278
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001278,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000674 AND
		    AGENT_NAME_ID=10003999
goddammit MVZ: bookid: 10000674; pubID: 10001278
bookid: 10000675; pubID: 10001279
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001279,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000675 AND
		    AGENT_NAME_ID=10003999
goddammit MVZ: bookid: 10000675; pubID: 10001279
bookid: 10000675; pubID: 10001280
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001280,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000675 AND
		    AGENT_NAME_ID=10003999
goddammit MVZ: bookid: 10000675; pubID: 10001280
bookid: 10000676; pubID: 10001281
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001281,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000676 AND
		    AGENT_NAME_ID=10001399
bookid: 10000676; pubID: 10001282
npid:
bookid: 10000676; pubID: 10001283
npid:
bookid: 10000676; pubID: 10001284
npid:
bookid: 10000677; pubID: 10001285
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001285,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000677 AND
		    AGENT_NAME_ID=10003999
goddammit MVZ: bookid: 10000677; pubID: 10001285
bookid: 10000677; pubID: 10001286
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001286,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000677 AND
		    AGENT_NAME_ID=10003999
goddammit MVZ: bookid: 10000677; pubID: 10001286
bookid: 10000677; pubID: 10001287
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001287,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000677 AND
		    AGENT_NAME_ID=10003999
goddammit MVZ: bookid: 10000677; pubID: 10001287
bookid: 10000677; pubID: 10001288
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001288,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000677 AND
		    AGENT_NAME_ID=10003999
goddammit MVZ: bookid: 10000677; pubID: 10001288
bookid: 10000678; pubID: 10001289
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001289,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000678 AND
		    AGENT_NAME_ID=10004124
goddammit MVZ: bookid: 10000678; pubID: 10001289
bookid: 10000678; pubID: 10001290
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001290,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000678 AND
		    AGENT_NAME_ID=10004124
goddammit MVZ: bookid: 10000678; pubID: 10001290
bookid: 10000678; pubID: 10001291
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001291,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000678 AND
		    AGENT_NAME_ID=10004124
goddammit MVZ: bookid: 10000678; pubID: 10001291
bookid: 10000678; pubID: 10001292
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001292,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000678 AND
		    AGENT_NAME_ID=10004124
goddammit MVZ: bookid: 10000678; pubID: 10001292
bookid: 10000679; pubID: 10001293
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001293,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000679 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000679; pubID: 10001293
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001293,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000679 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10000679; pubID: 10001293
bookid: 10001768; pubID: 10001771
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001771,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001768 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10001768; pubID: 10001771
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001771,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001768 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001768; pubID: 10001771
bookid: 10000495; pubID: 10001874
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001874,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10001874
bookid: 10000498; pubID: 10001880
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001880,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000498 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000498; pubID: 10001880
bookid: 10001316; pubID: 10001911
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001911,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001316 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001316; pubID: 10001911
bookid: 10001316; pubID: 10001913
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001913,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001316 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001316; pubID: 10001913
bookid: 10001316; pubID: 10001915
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001915,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001316 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001316; pubID: 10001915
bookid: 10001317; pubID: 10001917
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001917,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001317 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001317; pubID: 10001917
bookid: 10001317; pubID: 10001919
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001919,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001317 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001317; pubID: 10001919
bookid: 10001318; pubID: 10001921
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001921,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001318 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001318; pubID: 10001921
bookid: 10001318; pubID: 10001923
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001923,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001318 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001318; pubID: 10001923
bookid: 10001318; pubID: 10001926
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001926,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001318 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001318; pubID: 10001926
bookid: 10001319; pubID: 10001929
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001929,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001319 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001319; pubID: 10001929
bookid: 10001319; pubID: 10001931
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001931,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001319 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001319; pubID: 10001931
bookid: 10001320; pubID: 10001933
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001933,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001320 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001320; pubID: 10001933
bookid: 10001320; pubID: 10001935
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001935,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001320 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001320; pubID: 10001935
bookid: 10001320; pubID: 10001936
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001936,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001320 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001320; pubID: 10001936
bookid: 10001320; pubID: 10001938
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001938,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001320 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001320; pubID: 10001938
bookid: 10001320; pubID: 10001940
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001940,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001320 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001320; pubID: 10001940
bookid: 10001320; pubID: 10001942
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001942,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001320 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001320; pubID: 10001942
bookid: 10001320; pubID: 10001943
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001943,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001320 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001320; pubID: 10001943
bookid: 10001320; pubID: 10001946
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001946,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001320 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001320; pubID: 10001946
bookid: 10001321; pubID: 10001948
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001948,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001321 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001321; pubID: 10001948
bookid: 10001321; pubID: 10001950
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001950,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001321 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001321; pubID: 10001950
bookid: 10001321; pubID: 10001952
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001952,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001321 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001321; pubID: 10001952
bookid: 10001321; pubID: 10001954
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001954,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001321 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001321; pubID: 10001954
bookid: 10001321; pubID: 10001956
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001956,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001321 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001321; pubID: 10001956
bookid: 10001321; pubID: 10001958
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001958,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001321 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001321; pubID: 10001958
bookid: 10001322; pubID: 10001961
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001961,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001322 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001322; pubID: 10001961
bookid: 10001322; pubID: 10001964
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001964,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001322 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001322; pubID: 10001964
bookid: 10001446; pubID: 10001971
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001971,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001446 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001446; pubID: 10001971
bookid: 10001446; pubID: 10001972
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001972,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001446 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001446; pubID: 10001972
bookid: 10001322; pubID: 10001973
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001973,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001322 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001322; pubID: 10001973
bookid: 10001322; pubID: 10001976
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001976,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001322 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001322; pubID: 10001976
bookid: 10001322; pubID: 10001978
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001978,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001322 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001322; pubID: 10001978
bookid: 10001322; pubID: 10001980
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001980,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001322 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001322; pubID: 10001980
bookid: 10001322; pubID: 10001982
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001982,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001322 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001322; pubID: 10001982
bookid: 10001322; pubID: 10001984
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001984,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001322 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001322; pubID: 10001984
bookid: 10001322; pubID: 10001985
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001985,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001322 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001322; pubID: 10001985
bookid: 10001322; pubID: 10001986
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001986,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001322 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001322; pubID: 10001986
bookid: 10001323; pubID: 10001990
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001990,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001323 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001323; pubID: 10001990
bookid: 10001323; pubID: 10001991
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001991,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001323 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001323; pubID: 10001991
bookid: 10001323; pubID: 10001992
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001992,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001323 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001323; pubID: 10001992
bookid: 10001323; pubID: 10001993
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001993,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001323 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001323; pubID: 10001993
bookid: 10001323; pubID: 10001995
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001995,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001323 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001323; pubID: 10001995
bookid: 10001323; pubID: 10001996
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001996,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001323 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001323; pubID: 10001996
bookid: 10001447; pubID: 10001997
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001997,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001447 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001447; pubID: 10001997
bookid: 10001447; pubID: 10001999
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10001999,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001447 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001447; pubID: 10001999
bookid: 10001447; pubID: 10002001
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002001,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001447 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001447; pubID: 10002001
bookid: 10001448; pubID: 10002002
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002002,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001448 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001448; pubID: 10002002
bookid: 10001448; pubID: 10002004
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002004,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001448 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001448; pubID: 10002004
bookid: 10001448; pubID: 10002006
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002006,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001448 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001448; pubID: 10002006
bookid: 10001448; pubID: 10002007
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002007,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001448 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001448; pubID: 10002007
bookid: 10001444; pubID: 10003708
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003708,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003708
bookid: 10001444; pubID: 10003709
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003709,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003709
bookid: 10001444; pubID: 10003710
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003710,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003710
bookid: 10001444; pubID: 10003711
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003711,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003711
bookid: 10001444; pubID: 10003712
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003712,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003712
bookid: 10001444; pubID: 10003713
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003713,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003713
bookid: 10001444; pubID: 10003714
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003714,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003714
bookid: 10001444; pubID: 10003715
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003715,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003715
bookid: 10001444; pubID: 10003716
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003716,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003716
bookid: 10001444; pubID: 10003717
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003717,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003717
bookid: 10001444; pubID: 10003718
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003718,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003718
bookid: 10001444; pubID: 10003719
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003719,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003719
bookid: 10001444; pubID: 10003720
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003720,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001444 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001444; pubID: 10003720
bookid: 10001443; pubID: 10003721
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003721,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001443 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001443; pubID: 10003721
bookid: 10001443; pubID: 10003722
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003722,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001443 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001443; pubID: 10003722
bookid: 10001443; pubID: 10003723
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003723,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001443 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001443; pubID: 10003723
bookid: 10001443; pubID: 10003724
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003724,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001443 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001443; pubID: 10003724
bookid: 10001442; pubID: 10003725
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003725,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001442 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001442; pubID: 10003725
bookid: 10001442; pubID: 10003726
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003726,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001442 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001442; pubID: 10003726
bookid: 10001337; pubID: 10002284
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002284,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001337 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001337; pubID: 10002284
bookid: 10001337; pubID: 10002285
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002285,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001337 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001337; pubID: 10002285
bookid: 10001337; pubID: 10002286
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002286,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001337 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001337; pubID: 10002286
bookid: 10001337; pubID: 10002287
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002287,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001337 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001337; pubID: 10002287
bookid: 10001337; pubID: 10002288
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002288,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001337 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001337; pubID: 10002288
bookid: 10001710; pubID: 10002289
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002289,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001710 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001710; pubID: 10002289
bookid: 10001710; pubID: 10002290
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002290,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001710 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001710; pubID: 10002290
bookid: 10001710; pubID: 10002291
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002291,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001710 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001710; pubID: 10002291
bookid: 10001710; pubID: 10002292
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002292,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001710 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001710; pubID: 10002292
bookid: 10001711; pubID: 10002293
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002293,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001711 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001711; pubID: 10002293
bookid: 10001711; pubID: 10002294
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002294,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001711 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001711; pubID: 10002294
bookid: 10001711; pubID: 10002295
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002295,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001711 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001711; pubID: 10002295
bookid: 10001712; pubID: 10002296
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002296,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001712 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001712; pubID: 10002296
bookid: 10001712; pubID: 10002297
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002297,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001712 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001712; pubID: 10002297
bookid: 10001712; pubID: 10002298
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002298,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001712 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001712; pubID: 10002298
bookid: 10001712; pubID: 10002299
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002299,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001712 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001712; pubID: 10002299
bookid: 10001712; pubID: 10002300
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002300,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001712 AND
		    AGENT_NAME_ID=10003172
goddammit MVZ: bookid: 10001712; pubID: 10002300
bookid: 10001342; pubID: 10002301
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002301,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002301
bookid: 10001342; pubID: 10002302
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002302,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002302
bookid: 10001342; pubID: 10002303
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002303,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002303
bookid: 10001342; pubID: 10002304
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002304,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002304
bookid: 10001342; pubID: 10002305
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002305,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002305
bookid: 10001342; pubID: 10002306
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002306,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002306
bookid: 10001342; pubID: 10002307
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002307,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002307
bookid: 10001342; pubID: 10002308
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002308,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002308
bookid: 10001342; pubID: 10002309
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002309,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002309
bookid: 10001342; pubID: 10002310
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002310,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002310
bookid: 10001342; pubID: 10002311
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002311,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002311
bookid: 10001342; pubID: 10002312
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002312,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002312
bookid: 10001342; pubID: 10002313
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002313,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001342 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001342; pubID: 10002313
bookid: 10001359; pubID: 10002314
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002314,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001359 AND
		    AGENT_NAME_ID=10005638
goddammit MVZ: bookid: 10001359; pubID: 10002314
bookid: 10001359; pubID: 10002315
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002315,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001359 AND
		    AGENT_NAME_ID=10005638
goddammit MVZ: bookid: 10001359; pubID: 10002315
bookid: 10001359; pubID: 10002316
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002316,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001359 AND
		    AGENT_NAME_ID=10005638
goddammit MVZ: bookid: 10001359; pubID: 10002316
bookid: 10001359; pubID: 10002317
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002317,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001359 AND
		    AGENT_NAME_ID=10005638
goddammit MVZ: bookid: 10001359; pubID: 10002317
bookid: 10001359; pubID: 10002318
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002318,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001359 AND
		    AGENT_NAME_ID=10005638
goddammit MVZ: bookid: 10001359; pubID: 10002318
bookid: 10001384; pubID: 10002319
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002319,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002319
bookid: 10001384; pubID: 10002320
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002320,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002320
bookid: 10001384; pubID: 10002321
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002321,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002321
bookid: 10001384; pubID: 10002322
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002322,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002322
bookid: 10001384; pubID: 10002323
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002323,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002323
bookid: 10001384; pubID: 10002324
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002324,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002324
bookid: 10001384; pubID: 10002325
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002325,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002325
bookid: 10001384; pubID: 10002327
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002327,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002327
bookid: 10001384; pubID: 10002328
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002328,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002328
bookid: 10001384; pubID: 10002329
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002329,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002329
bookid: 10001385; pubID: 10002330
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002330,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001385 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001385; pubID: 10002330
bookid: 10001385; pubID: 10002331
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002331,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001385 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001385; pubID: 10002331
bookid: 10001385; pubID: 10002332
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002332,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001385 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001385; pubID: 10002332
bookid: 10001385; pubID: 10002333
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002333,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001385 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001385; pubID: 10002333
bookid: 10001385; pubID: 10002334
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002334,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001385 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001385; pubID: 10002334
bookid: 10001386; pubID: 10002335
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002335,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001386 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001386; pubID: 10002335
bookid: 10001386; pubID: 10002336
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002336,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001386 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001386; pubID: 10002336
bookid: 10001386; pubID: 10002337
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002337,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001386 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001386; pubID: 10002337
bookid: 10001387; pubID: 10002338
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002338,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001387 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001387; pubID: 10002338
bookid: 10001387; pubID: 10002339
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002339,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001387 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001387; pubID: 10002339
bookid: 10001387; pubID: 10002340
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002340,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001387 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001387; pubID: 10002340
bookid: 10001387; pubID: 10002341
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002341,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001387 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001387; pubID: 10002341
bookid: 10001387; pubID: 10002342
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002342,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001387 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001387; pubID: 10002342
bookid: 10001387; pubID: 10002343
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002343,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001387 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001387; pubID: 10002343
bookid: 10001388; pubID: 10002345
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002345,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001388 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001388; pubID: 10002345
bookid: 10001388; pubID: 10002346
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002346,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001388 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001388; pubID: 10002346
bookid: 10001388; pubID: 10002347
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002347,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001388 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001388; pubID: 10002347
bookid: 10001388; pubID: 10002348
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002348,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001388 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001388; pubID: 10002348
bookid: 10001388; pubID: 10002350
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002350,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001388 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001388; pubID: 10002350
bookid: 10001388; pubID: 10002351
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002351,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001388 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001388; pubID: 10002351
bookid: 10001388; pubID: 10002352
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002352,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001388 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001388; pubID: 10002352
bookid: 10001388; pubID: 10002353
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002353,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001388 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001388; pubID: 10002353
bookid: 10001388; pubID: 10002354
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002354,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001388 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001388; pubID: 10002354
bookid: 10001485; pubID: 10002355
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002355,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001485 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001485; pubID: 10002355
bookid: 10001485; pubID: 10002356
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002356,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001485 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001485; pubID: 10002356
bookid: 10001485; pubID: 10002357
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002357,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001485 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001485; pubID: 10002357
bookid: 10001485; pubID: 10002358
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002358,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001485 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001485; pubID: 10002358
bookid: 10001485; pubID: 10002359
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002359,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001485 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001485; pubID: 10002359
bookid: 10001622; pubID: 10002360
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002360,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001622 AND
		    AGENT_NAME_ID=10011279
goddammit MVZ: bookid: 10001622; pubID: 10002360
bookid: 10001663; pubID: 10002361
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002361,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001663 AND
		    AGENT_NAME_ID=10008331
goddammit MVZ: bookid: 10001663; pubID: 10002361
bookid: 10001663; pubID: 10002362
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002362,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001663 AND
		    AGENT_NAME_ID=10008331
goddammit MVZ: bookid: 10001663; pubID: 10002362
bookid: 10001663; pubID: 10002363
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002363,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001663 AND
		    AGENT_NAME_ID=10008331
goddammit MVZ: bookid: 10001663; pubID: 10002363
bookid: 10001657; pubID: 10002364
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002364,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001657 AND
		    AGENT_NAME_ID=10011370
goddammit MVZ: bookid: 10001657; pubID: 10002364
bookid: 10001657; pubID: 10002365
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002365,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001657 AND
		    AGENT_NAME_ID=10011370
goddammit MVZ: bookid: 10001657; pubID: 10002365
bookid: 10001658; pubID: 10002366
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002366,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001658 AND
		    AGENT_NAME_ID=10011370
goddammit MVZ: bookid: 10001658; pubID: 10002366
bookid: 10001658; pubID: 10002367
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002367,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001658 AND
		    AGENT_NAME_ID=10011370
goddammit MVZ: bookid: 10001658; pubID: 10002367
bookid: 10001659; pubID: 10002368
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002368,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001659 AND
		    AGENT_NAME_ID=10011370
goddammit MVZ: bookid: 10001659; pubID: 10002368
bookid: 10001659; pubID: 10002369
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002369,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001659 AND
		    AGENT_NAME_ID=10011370
goddammit MVZ: bookid: 10001659; pubID: 10002369
bookid: 10001659; pubID: 10002370
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002370,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001659 AND
		    AGENT_NAME_ID=10011370
goddammit MVZ: bookid: 10001659; pubID: 10002370
bookid: 10001659; pubID: 10002371
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002371,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001659 AND
		    AGENT_NAME_ID=10011370
goddammit MVZ: bookid: 10001659; pubID: 10002371
bookid: 10001361; pubID: 10002372
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002372,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001361 AND
		    AGENT_NAME_ID=10002014
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002372,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001361 AND
		    AGENT_NAME_ID=10004772
goddammit MVZ: bookid: 10001361; pubID: 10002372
bookid: 10001361; pubID: 10002373
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002373,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001361 AND
		    AGENT_NAME_ID=10004772
goddammit MVZ: bookid: 10001361; pubID: 10002373
bookid: 10001361; pubID: 10002374
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002374,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001361 AND
		    AGENT_NAME_ID=10004772
goddammit MVZ: bookid: 10001361; pubID: 10002374
bookid: 10001361; pubID: 10002375
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002375,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001361 AND
		    AGENT_NAME_ID=10004772
goddammit MVZ: bookid: 10001361; pubID: 10002375
bookid: 10001361; pubID: 10002376
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002376,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001361 AND
		    AGENT_NAME_ID=10004772
bookid: 10001361; pubID: 10002377
npid:
bookid: 10001361; pubID: 10002378
npid:
bookid: 10001660; pubID: 10002379
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002379,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001660 AND
		    AGENT_NAME_ID=10003910
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002379,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001660 AND
		    AGENT_NAME_ID=10011379
goddammit MVZ: bookid: 10001660; pubID: 10002379
bookid: 10001660; pubID: 10002380
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002380,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001660 AND
		    AGENT_NAME_ID=10011379
goddammit MVZ: bookid: 10001660; pubID: 10002380
bookid: 10001660; pubID: 10002381
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002381,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001660 AND
		    AGENT_NAME_ID=10011379
goddammit MVZ: bookid: 10001660; pubID: 10002381
bookid: 10001660; pubID: 10002382
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002382,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001660 AND
		    AGENT_NAME_ID=10011379
bookid: 10001558; pubID: 10002383
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002383,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001558 AND
		    AGENT_NAME_ID=10002262
goddammit MVZ: bookid: 10001558; pubID: 10002383
bookid: 10001559; pubID: 10002384
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002384,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001559 AND
		    AGENT_NAME_ID=10002262
goddammit MVZ: bookid: 10001559; pubID: 10002384
bookid: 10001559; pubID: 10002385
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002385,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001559 AND
		    AGENT_NAME_ID=10002262
goddammit MVZ: bookid: 10001559; pubID: 10002385
bookid: 10001479; pubID: 10002386
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002386,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001479 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001479; pubID: 10002386
bookid: 10001479; pubID: 10002387
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002387,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001479 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001479; pubID: 10002387
bookid: 10001479; pubID: 10002388
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002388,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001479 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001479; pubID: 10002388
bookid: 10001479; pubID: 10002389
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002389,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001479 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001479; pubID: 10002389
bookid: 10001480; pubID: 10002390
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002390,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001480 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001480; pubID: 10002390
bookid: 10001481; pubID: 10002391
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002391,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001481 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001481; pubID: 10002391
bookid: 10001481; pubID: 10002392
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002392,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001481 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001481; pubID: 10002392
bookid: 10001371; pubID: 10002393
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002393,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001371 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001371; pubID: 10002393
bookid: 10001371; pubID: 10002394
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002394,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001371 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001371; pubID: 10002394
bookid: 10001371; pubID: 10002395
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002395,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001371 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001371; pubID: 10002395
bookid: 10001482; pubID: 10002396
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002396,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001482 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001482; pubID: 10002396
bookid: 10001482; pubID: 10002397
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002397,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001482 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001482; pubID: 10002397
bookid: 10001371; pubID: 10002398
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002398,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001371 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001371; pubID: 10002398
bookid: 10001482; pubID: 10002399
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002399,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001482 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001482; pubID: 10002399
bookid: 10001482; pubID: 10002400
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002400,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001482 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001482; pubID: 10002400
bookid: 10001482; pubID: 10002401
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002401,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001482 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001482; pubID: 10002401
bookid: 10001482; pubID: 10002402
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002402,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001482 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001482; pubID: 10002402
bookid: 10001372; pubID: 10002403
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002403,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001372 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001372; pubID: 10002403
bookid: 10001372; pubID: 10002404
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002404,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001372 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001372; pubID: 10002404
bookid: 10001372; pubID: 10002405
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002405,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001372 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001372; pubID: 10002405
bookid: 10001373; pubID: 10002406
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002406,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001373 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001373; pubID: 10002406
bookid: 10001373; pubID: 10002407
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002407,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001373 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001373; pubID: 10002407
bookid: 10001483; pubID: 10002408
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002408,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001483 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001483; pubID: 10002408
bookid: 10001483; pubID: 10002409
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002409,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001483 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001483; pubID: 10002409
bookid: 10001483; pubID: 10002410
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002410,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001483 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001483; pubID: 10002410
bookid: 10001483; pubID: 10002411
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002411,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001483 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001483; pubID: 10002411
bookid: 10001483; pubID: 10002412
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002412,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001483 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001483; pubID: 10002412
bookid: 10001483; pubID: 10002413
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002413,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001483 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001483; pubID: 10002413
bookid: 10001483; pubID: 10002414
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002414,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001483 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001483; pubID: 10002414
bookid: 10001484; pubID: 10002415
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002415,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001484 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001484; pubID: 10002415
bookid: 10001484; pubID: 10002416
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002416,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001484 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001484; pubID: 10002416
bookid: 10001484; pubID: 10002417
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002417,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001484 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001484; pubID: 10002417
bookid: 10001374; pubID: 10002418
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002418,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001374 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001374; pubID: 10002418
bookid: 10001374; pubID: 10002419
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002419,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001374 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001374; pubID: 10002419
bookid: 10001374; pubID: 10002420
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002420,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001374 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001374; pubID: 10002420
bookid: 10001374; pubID: 10002421
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002421,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001374 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001374; pubID: 10002421
bookid: 10001375; pubID: 10002422
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002422,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001375 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001375; pubID: 10002422
bookid: 10001375; pubID: 10002423
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002423,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001375 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001375; pubID: 10002423
bookid: 10001375; pubID: 10002424
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002424,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001375 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001375; pubID: 10002424
bookid: 10001375; pubID: 10002425
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002425,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001375 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001375; pubID: 10002425
bookid: 10001375; pubID: 10002426
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002426,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001375 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001375; pubID: 10002426
bookid: 10001375; pubID: 10002427
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002427,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001375 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001375; pubID: 10002427
bookid: 10001376; pubID: 10002428
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002428,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001376 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001376; pubID: 10002428
bookid: 10001449; pubID: 10002008
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002008,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001449 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001449; pubID: 10002008
bookid: 10001449; pubID: 10002009
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002009,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001449 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001449; pubID: 10002009
bookid: 10001452; pubID: 10002010
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002010,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001452 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001452; pubID: 10002010
bookid: 10001453; pubID: 10002011
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002011,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001453 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001453; pubID: 10002011
bookid: 10001454; pubID: 10002012
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002012,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001454 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001454; pubID: 10002012
bookid: 10001455; pubID: 10002013
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002013,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001455 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001455; pubID: 10002013
bookid: 10001451; pubID: 10002014
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002014,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001451 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001451; pubID: 10002014
bookid: 10001451; pubID: 10002018
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002018,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001451 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001451; pubID: 10002018
bookid: 10001450; pubID: 10002019
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002019,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001450 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001450; pubID: 10002019
bookid: 10001450; pubID: 10002020
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002020,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001450 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001450; pubID: 10002020
bookid: 10001450; pubID: 10002021
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002021,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001450 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001450; pubID: 10002021
bookid: 10001456; pubID: 10002022
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002022,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001456 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001456; pubID: 10002022
bookid: 10001456; pubID: 10002023
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002023,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001456 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001456; pubID: 10002023
bookid: 10001456; pubID: 10002024
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002024,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001456 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001456; pubID: 10002024
bookid: 10001456; pubID: 10002025
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002025,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001456 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001456; pubID: 10002025
bookid: 10002026; pubID: 10002027
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002027,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10002026 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10002026; pubID: 10002027
bookid: 10001457; pubID: 10002028
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002028,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001457 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001457; pubID: 10002028
bookid: 10001457; pubID: 10002029
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002029,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001457 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001457; pubID: 10002029
bookid: 10001457; pubID: 10002030
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002030,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001457 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001457; pubID: 10002030
bookid: 10001457; pubID: 10002031
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002031,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001457 AND
		    AGENT_NAME_ID=10000922
goddammit MVZ: bookid: 10001457; pubID: 10002031
bookid: 10001570; pubID: 10002032
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002032,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001570 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001570; pubID: 10002032
bookid: 10001570; pubID: 10002033
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002033,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001570 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001570; pubID: 10002033
bookid: 10001570; pubID: 10002034
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002034,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001570 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001570; pubID: 10002034
bookid: 10001570; pubID: 10002035
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002035,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001570 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001570; pubID: 10002035
bookid: 10001570; pubID: 10002036
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002036,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001570 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001570; pubID: 10002036
bookid: 10001570; pubID: 10002037
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002037,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001570 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001570; pubID: 10002037
bookid: 10001570; pubID: 10002038
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002038,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001570 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001570; pubID: 10002038
bookid: 10001571; pubID: 10002039
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002039,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001571 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001571; pubID: 10002039
bookid: 10001571; pubID: 10002040
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002040,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001571 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001571; pubID: 10002040
bookid: 10001572; pubID: 10002041
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002041,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001572 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001572; pubID: 10002041
bookid: 10001572; pubID: 10002042
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002042,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001572 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001572; pubID: 10002042
bookid: 10001572; pubID: 10002043
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002043,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001572 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001572; pubID: 10002043
bookid: 10001572; pubID: 10002044
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002044,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001572 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001572; pubID: 10002044
bookid: 10001572; pubID: 10002045
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002045,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001572 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001572; pubID: 10002045
bookid: 10001573; pubID: 10002046
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002046,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001573 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001573; pubID: 10002046
bookid: 10001573; pubID: 10002047
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002047,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001573 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001573; pubID: 10002047
bookid: 10001573; pubID: 10002048
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002048,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001573 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001573; pubID: 10002048
bookid: 10001573; pubID: 10002049
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002049,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001573 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001573; pubID: 10002049
bookid: 10001573; pubID: 10002050
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002050,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001573 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001573; pubID: 10002050
bookid: 10001573; pubID: 10002051
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002051,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001573 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001573; pubID: 10002051
bookid: 10001573; pubID: 10002052
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002052,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001573 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001573; pubID: 10002052
bookid: 10001574; pubID: 10002053
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002053,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001574 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001574; pubID: 10002053
bookid: 10001574; pubID: 10002054
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002054,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001574 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001574; pubID: 10002054
bookid: 10001574; pubID: 10002055
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002055,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001574 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001574; pubID: 10002055
bookid: 10001574; pubID: 10002056
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002056,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001574 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001574; pubID: 10002056
bookid: 10001574; pubID: 10002057
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002057,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001574 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001574; pubID: 10002057
bookid: 10001574; pubID: 10002058
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002058,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001574 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001574; pubID: 10002058
bookid: 10001574; pubID: 10002059
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002059,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001574 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001574; pubID: 10002059
bookid: 10001574; pubID: 10002060
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002060,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001574 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001574; pubID: 10002060
bookid: 10001575; pubID: 10002061
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002061,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001575 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001575; pubID: 10002061
bookid: 10001575; pubID: 10002062
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002062,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001575 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001575; pubID: 10002062
bookid: 10001575; pubID: 10002063
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002063,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001575 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001575; pubID: 10002063
bookid: 10001575; pubID: 10002064
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002064,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001575 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001575; pubID: 10002064
bookid: 10001575; pubID: 10002065
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002065,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001575 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001575; pubID: 10002065
bookid: 10001575; pubID: 10002066
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002066,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001575 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001575; pubID: 10002066
bookid: 10001575; pubID: 10002067
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002067,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001575 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001575; pubID: 10002067
bookid: 10001576; pubID: 10002068
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002068,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001576 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001576; pubID: 10002068
bookid: 10001576; pubID: 10002069
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002069,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001576 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001576; pubID: 10002069
bookid: 10001576; pubID: 10002070
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002070,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001576 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001576; pubID: 10002070
bookid: 10001576; pubID: 10002071
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002071,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001576 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001576; pubID: 10002071
bookid: 10001576; pubID: 10002072
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002072,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001576 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001576; pubID: 10002072
bookid: 10001576; pubID: 10002073
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002073,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001576 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001576; pubID: 10002073
bookid: 10001577; pubID: 10002074
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002074,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001577 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001577; pubID: 10002074
bookid: 10001577; pubID: 10002075
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002075,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001577 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001577; pubID: 10002075
bookid: 10001577; pubID: 10002076
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002076,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001577 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001577; pubID: 10002076
bookid: 10001577; pubID: 10002077
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002077,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001577 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001577; pubID: 10002077
bookid: 10001577; pubID: 10002078
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002078,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001577 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001577; pubID: 10002078
bookid: 10001577; pubID: 10002079
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002079,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001577 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001577; pubID: 10002079
bookid: 10001578; pubID: 10002080
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002080,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001578 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001578; pubID: 10002080
bookid: 10001576; pubID: 10002081
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002081,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001576 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001576; pubID: 10002081
bookid: 10001578; pubID: 10002082
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002082,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001578 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001578; pubID: 10002082
bookid: 10001578; pubID: 10002083
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002083,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001578 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001578; pubID: 10002083
bookid: 10001578; pubID: 10002084
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002084,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001578 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001578; pubID: 10002084
bookid: 10001579; pubID: 10002085
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002085,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001579 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001579; pubID: 10002085
bookid: 10001579; pubID: 10002086
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002086,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001579 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001579; pubID: 10002086
bookid: 10001579; pubID: 10002087
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002087,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001579 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001579; pubID: 10002087
bookid: 10001579; pubID: 10002088
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002088,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001579 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001579; pubID: 10002088
bookid: 10001579; pubID: 10002089
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002089,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001579 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001579; pubID: 10002089
bookid: 10001579; pubID: 10002090
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002090,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001579 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001579; pubID: 10002090
bookid: 10001579; pubID: 10002091
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002091,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001579 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001579; pubID: 10002091
bookid: 10001580; pubID: 10002092
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002092,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002092
bookid: 10001579; pubID: 10002093
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002093,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001579 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001579; pubID: 10002093
bookid: 10001579; pubID: 10002094
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002094,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001579 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001579; pubID: 10002094
bookid: 10001580; pubID: 10002095
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002095,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001580 AND
		    AGENT_NAME_ID=10001045
goddammit MVZ: bookid: 10001580; pubID: 10002095
bookid: 10001606; pubID: 10002647
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002647,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001606 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001606; pubID: 10002647
bookid: 10001606; pubID: 10002648
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002648,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001606 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001606; pubID: 10002648
bookid: 10001607; pubID: 10002649
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002649,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001607 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001607; pubID: 10002649
bookid: 10001607; pubID: 10002650
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002650,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001607 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001607; pubID: 10002650
bookid: 10001607; pubID: 10002651
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002651,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001607 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001607; pubID: 10002651
bookid: 10001753; pubID: 10002652
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002652,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001753 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001753; pubID: 10002652
bookid: 10001753; pubID: 10002653
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002653,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001753 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001753; pubID: 10002653
bookid: 10001753; pubID: 10002654
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002654,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001753 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001753; pubID: 10002654
bookid: 10001753; pubID: 10002655
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002655,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001753 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001753; pubID: 10002655
bookid: 10001641; pubID: 10002656
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002656,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001641 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001641; pubID: 10002656
bookid: 10001642; pubID: 10002657
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002657,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001642 AND
		    AGENT_NAME_ID=10002708
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002657,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001642 AND
		    AGENT_NAME_ID=10006992
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002657,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001642 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001642; pubID: 10002657
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002657,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001642 AND
		    AGENT_NAME_ID=10714456
bookid: 10001642; pubID: 10002658
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002658,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001642 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001642; pubID: 10002658
bookid: 10001338; pubID: 10002659
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002659,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001338 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001338; pubID: 10002659
bookid: 10001339; pubID: 10002660
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002660,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001339 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001339; pubID: 10002660
bookid: 10001340; pubID: 10002661
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002661,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001340 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001340; pubID: 10002661
bookid: 10001340; pubID: 10002662
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002662,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001340 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001340; pubID: 10002662
bookid: 10001341; pubID: 10002663
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002663,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001341 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001341; pubID: 10002663
bookid: 10001343; pubID: 10002664
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002664,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001343 AND
		    AGENT_NAME_ID=10000183
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002664,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001343 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001343; pubID: 10002664
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002664,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001343 AND
		    AGENT_NAME_ID=10005107
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002664,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001343 AND
		    AGENT_NAME_ID=10005148
bookid: 10001343; pubID: 10002665
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002665,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001343 AND
		    AGENT_NAME_ID=10000201
goddammit MVZ: bookid: 10001343; pubID: 10002665
bookid: 10001343; pubID: 10002666
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002666,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001343 AND
		    AGENT_NAME_ID=10000201
bookid: 10001343; pubID: 10002667
npid:
bookid: 10001343; pubID: 10002668
npid:
bookid: 10001343; pubID: 10002669
npid:
bookid: 10001343; pubID: 10002670
npid:
bookid: 10001671; pubID: 10002672
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002672,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001671 AND
		    AGENT_NAME_ID=10005738
goddammit MVZ: bookid: 10001671; pubID: 10002672
bookid: 10001672; pubID: 10002673
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002673,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001672 AND
		    AGENT_NAME_ID=10005738
goddammit MVZ: bookid: 10001672; pubID: 10002673
bookid: 10001674; pubID: 10002674
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002674,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001674 AND
		    AGENT_NAME_ID=10005738
goddammit MVZ: bookid: 10001674; pubID: 10002674
bookid: 10001675; pubID: 10002675
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002675,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001675 AND
		    AGENT_NAME_ID=10005738
goddammit MVZ: bookid: 10001675; pubID: 10002675
bookid: 10001673; pubID: 10002676
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002676,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001673 AND
		    AGENT_NAME_ID=10005738
goddammit MVZ: bookid: 10001673; pubID: 10002676
bookid: 10001676; pubID: 10002677
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002677,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001676 AND
		    AGENT_NAME_ID=10005738
goddammit MVZ: bookid: 10001676; pubID: 10002677
bookid: 10001644; pubID: 10002678
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002678,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001644 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001644; pubID: 10002678
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002678,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001644 AND
		    AGENT_NAME_ID=10714459
bookid: 10001644; pubID: 10002679
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002679,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001644 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001644; pubID: 10002679
bookid: 10001644; pubID: 10002680
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002680,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001644 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001644; pubID: 10002680
bookid: 10001643; pubID: 10002681
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002681,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001643 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001643; pubID: 10002681
bookid: 10001643; pubID: 10002682
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002682,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001643 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001643; pubID: 10002682
bookid: 10001643; pubID: 10002683
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002683,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001643 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001643; pubID: 10002683
bookid: 10001645; pubID: 10002684
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002684,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001645 AND
		    AGENT_NAME_ID=10003616
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002684,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001645 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001645; pubID: 10002684
bookid: 10001645; pubID: 10002685
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002685,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001645 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001645; pubID: 10002685
bookid: 10001645; pubID: 10002686
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002686,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001645 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001645; pubID: 10002686
bookid: 10001646; pubID: 10002687
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002687,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001646 AND
		    AGENT_NAME_ID=10003792
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002687,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001646 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001646; pubID: 10002687
bookid: 10001646; pubID: 10002688
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002688,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001646 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001646; pubID: 10002688
bookid: 10001646; pubID: 10002689
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002689,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001646 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001646; pubID: 10002689
bookid: 10001647; pubID: 10002692
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002692,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001647 AND
		    AGENT_NAME_ID=10010420
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002692,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001647 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001647; pubID: 10002692
bookid: 10001647; pubID: 10002693
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002693,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001647 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001647; pubID: 10002693
bookid: 10001647; pubID: 10002694
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002694,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001647 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001647; pubID: 10002694
bookid: 10001647; pubID: 10002695
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002695,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001647 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001647; pubID: 10002695
bookid: 10001647; pubID: 10002696
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002696,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001647 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001647; pubID: 10002696
bookid: 10001647; pubID: 10002697
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002697,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001647 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001647; pubID: 10002697
bookid: 10000557; pubID: 10002698
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002698,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000557 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000557; pubID: 10002698
bookid: 10001747; pubID: 10002699
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002699,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001747 AND
		    AGENT_NAME_ID=10001332
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002699,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001747 AND
		    AGENT_NAME_ID=10002011
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002699,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001747 AND
		    AGENT_NAME_ID=10014129
goddammit MVZ: bookid: 10001747; pubID: 10002699
bookid: 10001747; pubID: 10002700
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002700,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001747 AND
		    AGENT_NAME_ID=10014129
bookid: 10001747; pubID: 10002701
npid:
bookid: 10001648; pubID: 10002702
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002702,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001648 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001648; pubID: 10002702
bookid: 10001648; pubID: 10002703
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002703,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001648 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001648; pubID: 10002703
bookid: 10001648; pubID: 10002704
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002704,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001648 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001648; pubID: 10002704
bookid: 10001649; pubID: 10002705
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002705,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001649 AND
		    AGENT_NAME_ID=10008621
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002705,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001649 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001649; pubID: 10002705
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002705,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001649 AND
		    AGENT_NAME_ID=10714462
bookid: 10001649; pubID: 10002706
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002706,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001649 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001649; pubID: 10002706
bookid: 10001649; pubID: 10002707
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002707,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001649 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001649; pubID: 10002707
bookid: 10001650; pubID: 10002708
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002708,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001650 AND
		    AGENT_NAME_ID=10010420
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002708,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001650 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001650; pubID: 10002708
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002708,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001650 AND
		    AGENT_NAME_ID=10014008
bookid: 10001650; pubID: 10002709
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002709,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001650 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001650; pubID: 10002709
bookid: 10001650; pubID: 10002710
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002710,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001650 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001650; pubID: 10002710
bookid: 10001650; pubID: 10002711
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002711,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001650 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001650; pubID: 10002711
bookid: 10001651; pubID: 10002712
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002712,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001651 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001651; pubID: 10002712
bookid: 10001651; pubID: 10002713
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002713,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001651 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001651; pubID: 10002713
bookid: 10001652; pubID: 10002714
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002714,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001652 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001652; pubID: 10002714
bookid: 10001652; pubID: 10002715
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002715,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001652 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001652; pubID: 10002715
bookid: 10001652; pubID: 10002716
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002716,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001652 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001652; pubID: 10002716
bookid: 10001652; pubID: 10002717
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002717,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001652 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001652; pubID: 10002717
bookid: 10001653; pubID: 10002718
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002718,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001653 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001653; pubID: 10002718
bookid: 10001653; pubID: 10002719
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002719,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001653 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001653; pubID: 10002719
bookid: 10001653; pubID: 10002720
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002720,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001653 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001653; pubID: 10002720
bookid: 10001653; pubID: 10002721
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002721,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001653 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001653; pubID: 10002721
bookid: 10001654; pubID: 10002722
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002722,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001654 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001654; pubID: 10002722
bookid: 10001654; pubID: 10002723
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002723,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001654 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001654; pubID: 10002723
bookid: 10001654; pubID: 10002724
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002724,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001654 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001654; pubID: 10002724
bookid: 10001654; pubID: 10002725
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002725,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001654 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001654; pubID: 10002725
bookid: 10000546; pubID: 10002726
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002726,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000546 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000546; pubID: 10002726
bookid: 10001655; pubID: 10002727
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002727,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001655 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001655; pubID: 10002727
bookid: 10001655; pubID: 10002728
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002728,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001655 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001655; pubID: 10002728
bookid: 10001655; pubID: 10002729
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002729,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001655 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001655; pubID: 10002729
bookid: 10001655; pubID: 10002730
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002730,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001655 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001655; pubID: 10002730
bookid: 10001655; pubID: 10002731
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002731,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001655 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001655; pubID: 10002731
bookid: 10001655; pubID: 10002732
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002732,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001655 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001655; pubID: 10002732
bookid: 10001656; pubID: 10002733
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002733,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001656 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001656; pubID: 10002733
bookid: 10001656; pubID: 10002734
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002734,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001656 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001656; pubID: 10002734
bookid: 10001656; pubID: 10002735
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002735,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001656 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001656; pubID: 10002735
bookid: 10001656; pubID: 10002736
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002736,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001656 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001656; pubID: 10002736
bookid: 10001415; pubID: 10002737
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002737,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001415 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001415; pubID: 10002737
bookid: 10001415; pubID: 10002738
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002738,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001415 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001415; pubID: 10002738
bookid: 10001415; pubID: 10002739
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002739,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001415 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001415; pubID: 10002739
bookid: 10001415; pubID: 10002740
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002740,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001415 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001415; pubID: 10002740
bookid: 10001416; pubID: 10002741
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002741,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001416 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001416; pubID: 10002741
bookid: 10001417; pubID: 10002742
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002742,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001417 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001417; pubID: 10002742
bookid: 10001417; pubID: 10002743
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002743,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001417 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001417; pubID: 10002743
bookid: 10001418; pubID: 10002744
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002744,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001418 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001418; pubID: 10002744
bookid: 10001418; pubID: 10002745
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002745,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001418 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001418; pubID: 10002745
bookid: 10001419; pubID: 10002746
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002746,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001419 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001419; pubID: 10002746
bookid: 10001419; pubID: 10002747
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002747,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001419 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001419; pubID: 10002747
bookid: 10001419; pubID: 10002748
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002748,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001419 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001419; pubID: 10002748
bookid: 10001420; pubID: 10002749
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002749,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001420 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001420; pubID: 10002749
bookid: 10001420; pubID: 10002750
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002750,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001420 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001420; pubID: 10002750
bookid: 10001420; pubID: 10002751
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002751,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001420 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001420; pubID: 10002751
bookid: 10001421; pubID: 10002752
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002752,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001421 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001421; pubID: 10002752
bookid: 10001421; pubID: 10002753
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002753,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001421 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001421; pubID: 10002753
bookid: 10001421; pubID: 10002754
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002754,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001421 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001421; pubID: 10002754
bookid: 10001422; pubID: 10002755
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002755,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001422 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001422; pubID: 10002755
bookid: 10001422; pubID: 10002756
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002756,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001422 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001422; pubID: 10002756
bookid: 10001422; pubID: 10002757
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002757,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001422 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001422; pubID: 10002757
bookid: 10001423; pubID: 10002758
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002758,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001423 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001423; pubID: 10002758
bookid: 10001424; pubID: 10002759
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002759,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001424 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001424; pubID: 10002759
bookid: 10001425; pubID: 10002760
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002760,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001425 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001425; pubID: 10002760
bookid: 10001425; pubID: 10002761
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002761,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001425 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001425; pubID: 10002761
bookid: 10001425; pubID: 10002762
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002762,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001425 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001425; pubID: 10002762
bookid: 10001426; pubID: 10002763
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002763,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001426 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001426; pubID: 10002763
bookid: 10001426; pubID: 10002764
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002764,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001426 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001426; pubID: 10002764
bookid: 10001427; pubID: 10002765
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002765,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001427 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001427; pubID: 10002765
bookid: 10001428; pubID: 10002766
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002766,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001428 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001428; pubID: 10002766
bookid: 10001428; pubID: 10002767
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002767,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001428 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001428; pubID: 10002767
bookid: 10001428; pubID: 10002768
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002768,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001428 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001428; pubID: 10002768
bookid: 10001428; pubID: 10002769
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002769,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001428 AND
		    AGENT_NAME_ID=10001363
goddammit MVZ: bookid: 10001428; pubID: 10002769
bookid: 10001348; pubID: 10002770
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002770,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001348 AND
		    AGENT_NAME_ID=10003166
goddammit MVZ: bookid: 10001348; pubID: 10002770
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002770,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001348 AND
		    AGENT_NAME_ID=10005105
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002770,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001348 AND
		    AGENT_NAME_ID=10005472
bookid: 10001348; pubID: 10002771
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002771,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001348 AND
		    AGENT_NAME_ID=10003166
goddammit MVZ: bookid: 10001348; pubID: 10002771
bookid: 10001348; pubID: 10002772
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002772,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001348 AND
		    AGENT_NAME_ID=10003166
bookid: 10001348; pubID: 10002773
npid:
bookid: 10001431; pubID: 10002774
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002774,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001431 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001431; pubID: 10002774
bookid: 10001432; pubID: 10002775
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002775,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001432 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001432; pubID: 10002775
bookid: 10001433; pubID: 10002776
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002776,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001433 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001433; pubID: 10002776
bookid: 10001434; pubID: 10002777
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002777,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001434 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001434; pubID: 10002777
bookid: 10001435; pubID: 10002778
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002778,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001435 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001435; pubID: 10002778
bookid: 10001436; pubID: 10002779
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002779,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001436 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001436; pubID: 10002779
bookid: 10001438; pubID: 10002780
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002780,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001438 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001438; pubID: 10002780
bookid: 10001438; pubID: 10002781
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002781,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001438 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001438; pubID: 10002781
bookid: 10001439; pubID: 10002782
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002782,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001439 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001439; pubID: 10002782
bookid: 10001439; pubID: 10002783
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002783,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001439 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001439; pubID: 10002783
bookid: 10001439; pubID: 10002784
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002784,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001439 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001439; pubID: 10002784
bookid: 10001439; pubID: 10002785
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002785,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001439 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001439; pubID: 10002785
bookid: 10001439; pubID: 10002786
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002786,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001439 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001439; pubID: 10002786
bookid: 10001437; pubID: 10002787
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002787,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001437 AND
		    AGENT_NAME_ID=10007275
goddammit MVZ: bookid: 10001437; pubID: 10002787
bookid: 10001391; pubID: 10002788
npid: 2
UPDATE
			    publication_author_name
		SET
		    publicati
on_id=10002788,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001391 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001391; pubID: 10002788
bookid: 10001393; pubID: 10002789
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002789,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001393 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001393; pubID: 10002789
bookid: 10001394; pubID: 10002790
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002790,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001394 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001394; pubID: 10002790
bookid: 10001395; pubID: 10002791
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002791,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001395 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001395; pubID: 10002791
bookid: 10001396; pubID: 10002792
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002792,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001396 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001396; pubID: 10002792
bookid: 10001392; pubID: 10002793
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002793,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001392 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001392; pubID: 10002793
bookid: 10001392; pubID: 10002794
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002794,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001392 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001392; pubID: 10002794
bookid: 10001392; pubID: 10002795
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002795,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001392 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001392; pubID: 10002795
bookid: 10001392; pubID: 10002796
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002796,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001392 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001392; pubID: 10002796
bookid: 10001392; pubID: 10002797
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002797,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001392 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001392; pubID: 10002797
bookid: 10001392; pubID: 10002798
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002798,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001392 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001392; pubID: 10002798
bookid: 10001397; pubID: 10002799
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002799,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001397 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001397; pubID: 10002799
bookid: 10001398; pubID: 10002800
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002800,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001398 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001398; pubID: 10002800
bookid: 10001399; pubID: 10002801
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002801,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001399 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001399; pubID: 10002801
bookid: 10001400; pubID: 10002802
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002802,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001400 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001400; pubID: 10002802
bookid: 10001402; pubID: 10002803
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002803,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001402 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001402; pubID: 10002803
bookid: 10001401; pubID: 10002804
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002804,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001401 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001401; pubID: 10002804
bookid: 10001401; pubID: 10002805
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002805,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001401 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001401; pubID: 10002805
bookid: 10001401; pubID: 10002806
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002806,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001401 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001401; pubID: 10002806
bookid: 10001401; pubID: 10002807
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002807,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001401 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001401; pubID: 10002807
bookid: 10001405; pubID: 10002808
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002808,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001405 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001405; pubID: 10002808
bookid: 10001406; pubID: 10002809
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002809,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001406 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001406; pubID: 10002809
bookid: 10001403; pubID: 10002810
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002810,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001403 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001403; pubID: 10002810
bookid: 10001403; pubID: 10002811
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002811,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001403 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001403; pubID: 10002811
bookid: 10001403; pubID: 10002812
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002812,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001403 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001403; pubID: 10002812
bookid: 10001403; pubID: 10002813
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002813,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001403 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001403; pubID: 10002813
bookid: 10001407; pubID: 10002814
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002814,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001407 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001407; pubID: 10002814
bookid: 10001408; pubID: 10002815
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002815,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001408 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001408; pubID: 10002815
bookid: 10001408; pubID: 10002816
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002816,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001408 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001408; pubID: 10002816
bookid: 10001408; pubID: 10002817
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002817,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001408 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001408; pubID: 10002817
bookid: 10001408; pubID: 10002818
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002818,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001408 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001408; pubID: 10002818
bookid: 10001408; pubID: 10002819
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002819,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001408 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001408; pubID: 10002819
bookid: 10001408; pubID: 10002820
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002820,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001408 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001408; pubID: 10002820
bookid: 10001408; pubID: 10002821
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002821,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001408 AND
		    AGENT_NAME_ID=10001158
bookid: 10001409; pubID: 10002822
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002822,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002822
bookid: 10001409; pubID: 10002823
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002823,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002823
bookid: 10001409; pubID: 10002824
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002824,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002824
bookid: 10001409; pubID: 10002825
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002825,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002825
bookid: 10001409; pubID: 10002826
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002826,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002826
bookid: 10001409; pubID: 10002827
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002827,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002827
bookid: 10001409; pubID: 10002828
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002828,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002828
bookid: 10001409; pubID: 10002829
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002829,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002829
bookid: 10001409; pubID: 10002830
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002830,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002830
bookid: 10001409; pubID: 10002831
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002831,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002831
bookid: 10001409; pubID: 10002832
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002832,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002832
bookid: 10001409; pubID: 10002833
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002833,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002833
bookid: 10001409; pubID: 10002834
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002834,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001409 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001409; pubID: 10002834
bookid: 10001411; pubID: 10002835
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002835,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001411 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001411; pubID: 10002835
bookid: 10001411; pubID: 10002836
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002836,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001411 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001411; pubID: 10002836
bookid: 10001411; pubID: 10002837
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002837,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001411 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001411; pubID: 10002837
bookid: 10001411; pubID: 10002838
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002838,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001411 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001411; pubID: 10002838
bookid: 10001411; pubID: 10002839
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002839,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001411 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001411; pubID: 10002839
bookid: 10001411; pubID: 10002840
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002840,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001411 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001411; pubID: 10002840
bookid: 10001411; pubID: 10002841
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002841,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001411 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001411; pubID: 10002841
bookid: 10001410; pubID: 10002842
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002842,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001410 AND
		    AGENT_NAME_ID=10001158
goddammit MVZ: bookid: 10001410; pubID: 10002842
bookid: 10001404; pubID: 10002843
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002843,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001404 AND
		    AGENT_NAME_ID=10001158
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002843,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001404 AND
		    AGENT_NAME_ID=10006865
goddammit MVZ: bookid: 10001404; pubID: 10002843
bookid: 10001404; pubID: 10002844
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002844,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001404 AND
		    AGENT_NAME_ID=10006865
bookid: 10001413; pubID: 10002845
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002845,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001413 AND
		    AGENT_NAME_ID=10006865
goddammit MVZ: bookid: 10001413; pubID: 10002845
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002845,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001413 AND
		    AGENT_NAME_ID=10406865
bookid: 10001412; pubID: 10002846
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002846,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001412 AND
		    AGENT_NAME_ID=10006865
goddammit MVZ: bookid: 10001412; pubID: 10002846
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002846,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001412 AND
		    AGENT_NAME_ID=10406865
bookid: 10001412; pubID: 10002847
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002847,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001412 AND
		    AGENT_NAME_ID=10006865
goddammit MVZ: bookid: 10001412; pubID: 10002847
bookid: 10001412; pubID: 10002848
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002848,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001412 AND
		    AGENT_NAME_ID=10006865
goddammit MVZ: bookid: 10001412; pubID: 10002848
bookid: 10001316; pubID: 10002851
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002851,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001316 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001316; pubID: 10002851
bookid: 10001332; pubID: 10002852
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002852,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001332 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001332; pubID: 10002852
bookid: 10001333; pubID: 10002853
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002853,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001333 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001333; pubID: 10002853
bookid: 10001318; pubID: 10002854
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002854,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001318 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001318; pubID: 10002854
bookid: 10001680; pubID: 10002855
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002855,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001680 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001680; pubID: 10002855
bookid: 10001681; pubID: 10002856
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002856,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001681 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001681; pubID: 10002856
bookid: 10001682; pubID: 10002857
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002857,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001682 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001682; pubID: 10002857
bookid: 10001683; pubID: 10002858
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002858,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001683 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001683; pubID: 10002858
bookid: 10001685; pubID: 10002859
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002859,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001685 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001685; pubID: 10002859
bookid: 10001679; pubID: 10002860
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002860,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001679 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001679; pubID: 10002860
bookid: 10001678; pubID: 10002861
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002861,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001678 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001678; pubID: 10002861
bookid: 10001684; pubID: 10002862
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002862,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001684 AND
		    AGENT_NAME_ID=10000729
goddammit MVZ: bookid: 10001684; pubID: 10002862
bookid: 10001697; pubID: 10002863
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002863,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001697 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001697; pubID: 10002863
bookid: 10000557; pubID: 10002864
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002864,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000557 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000557; pubID: 10002864
bookid: 10000549; pubID: 10002865
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002865,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000549 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000549; pubID: 10002865
bookid: 10001667; pubID: 10002866
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002866,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001667 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001667; pubID: 10002866
bookid: 10001623; pubID: 10002867
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002867,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001623 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001623; pubID: 10002867
bookid: 10001361; pubID: 10002868
npid:
bookid: 10001749; pubID: 10002869
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002869,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001749 AND
		    AGENT_NAME_ID=10001736
goddammit MVZ: bookid: 10001749; pubID: 10002869
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002869,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001749 AND
		    AGENT_NAME_ID=10001764
goddammit MVZ: bookid: 10001749; pubID: 10002869
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002869,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001749 AND
		    AGENT_NAME_ID=10003232
goddammit MVZ: bookid: 10001749; pubID: 10002869
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002869,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001749 AND
		    AGENT_NAME_ID=10008526
goddammit MVZ: bookid: 10001749; pubID: 10002869
bookid: 10001749; pubID: 10002870
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002870,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001749 AND
		    AGENT_NAME_ID=10001736
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002870,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001749 AND
		    AGENT_NAME_ID=10001764
goddammit MVZ: bookid: 10001749; pubID: 10002870
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002870,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001749 AND
		    AGENT_NAME_ID=10003232
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002870,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001749 AND
		    AGENT_NAME_ID=10008526
bookid: 10001749; pubID: 10002871
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002871,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001749 AND
		    AGENT_NAME_ID=10001764
bookid: 10001749; pubID: 10002872
npid:
bookid: 10001749; pubID: 10002873
npid:
bookid: 10001747; pubID: 10002874
npid:
bookid: 10000546; pubID: 10002875
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002875,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000546 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000546; pubID: 10002875
bookid: 10000548; pubID: 10002876
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002876,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000548 AND
		    AGENT_NAME_ID=10000807
goddammit MVZ: bookid: 10000548; pubID: 10002876
bookid: 10001668; pubID: 10002877
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002877,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001668 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001668; pubID: 10002877
bookid: 10001668; pubID: 10002878
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002878,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001668 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001668; pubID: 10002878
bookid: 10001664; pubID: 10002879
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002879,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001664 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001664; pubID: 10002879
bookid: 10001665; pubID: 10002880
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002880,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001665 AND
		    AGENT_NAME_ID=10001776
goddammit MVZ: bookid: 10001665; pubID: 10002880
bookid: 10001559; pubID: 10002881
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002881,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001559 AND
		    AGENT_NAME_ID=10002262
goddammit MVZ: bookid: 10001559; pubID: 10002881
bookid: 10001319; pubID: 10002882
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002882,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001319 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001319; pubID: 10002882
bookid: 10001320; pubID: 10002883
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002883,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001320 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001320; pubID: 10002883
bookid: 10001321; pubID: 10002884
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002884,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001321 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001321; pubID: 10002884
bookid: 10001323; pubID: 10002885
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002885,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001323 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001323; pubID: 10002885
bookid: 10001324; pubID: 10002886
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002886,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001324 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001324; pubID: 10002886
bookid: 10001325; pubID: 10002887
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002887,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001325 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001325; pubID: 10002887
bookid: 10001326; pubID: 10002888
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002888,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001326 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001326; pubID: 10002888
bookid: 10001327; pubID: 10002889
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002889,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001327 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001327; pubID: 10002889
bookid: 10001329; pubID: 10002890
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002890,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001329 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001329; pubID: 10002890
bookid: 10001331; pubID: 10002891
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002891,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001331 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001331; pubID: 10002891
bookid: 10001330; pubID: 10002892
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002892,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001330 AND
		    AGENT_NAME_ID=10000220
goddammit MVZ: bookid: 10001330; pubID: 10002892
bookid: 10001743; pubID: 10002893
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002893,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001743 AND
		    AGENT_NAME_ID=10001892
goddammit MVZ: bookid: 10001743; pubID: 10002893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002893,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001743 AND
		    AGENT_NAME_ID=10002120
goddammit MVZ: bookid: 10001743; pubID: 10002893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002893,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001743 AND
		    AGENT_NAME_ID=10002261
goddammit MVZ: bookid: 10001743; pubID: 10002893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002893,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001743 AND
		    AGENT_NAME_ID=10002813
goddammit MVZ: bookid: 10001743; pubID: 10002893
bookid: 10001743; pubID: 10002894
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002894,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001743 AND
		    AGENT_NAME_ID=10001892
goddammit MVZ: bookid: 10001743; pubID: 10002894
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002894,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001743 AND
		    AGENT_NAME_ID=10002120
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002894,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001743 AND
		    AGENT_NAME_ID=10002261
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002894,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001743 AND
		    AGENT_NAME_ID=10002813
bookid: 10001743; pubID: 10002895
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002895,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001743 AND
		    AGENT_NAME_ID=10001892
bookid: 10001743; pubID: 10002896
npid:
bookid: 10001743; pubID: 10002897
npid:
bookid: 10000493; pubID: 10002898
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002898,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000493 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000493; pubID: 10002898
bookid: 10000556; pubID: 10002899
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002899,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000556 AND
		    AGENT_NAME_ID=10002010
goddammit MVZ: bookid: 10000556; pubID: 10002899
bookid: 10000495; pubID: 10002900
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002900,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000495 AND
		    AGENT_NAME_ID=10000224
goddammit MVZ: bookid: 10000495; pubID: 10002900
bookid: 10001689; pubID: 10002901
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002901,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001689 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001689; pubID: 10002901
bookid: 10001616; pubID: 10002902
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002902,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001616 AND
		    AGENT_NAME_ID=10000912
goddammit MVZ: bookid: 10001616; pubID: 10002902
bookid: 10001614; pubID: 10002903
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002903,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001614 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001614; pubID: 10002903
bookid: 10001614; pubID: 10002904
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002904,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001614 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001614; pubID: 10002904
bookid: 10001614; pubID: 10002905
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002905,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001614 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001614; pubID: 10002905
bookid: 10001614; pubID: 10002906
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002906,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001614 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001614; pubID: 10002906
bookid: 10001613; pubID: 10002907
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002907,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001613 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001613; pubID: 10002907
bookid: 10001613; pubID: 10002908
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002908,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001613 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001613; pubID: 10002908
bookid: 10001613; pubID: 10002909
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002909,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001613 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001613; pubID: 10002909
bookid: 10001612; pubID: 10002910
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002910,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001612 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001612; pubID: 10002910
bookid: 10001612; pubID: 10002911
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002911,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001612 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001612; pubID: 10002911
bookid: 10001612; pubID: 10002912
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002912,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001612 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001612; pubID: 10002912
bookid: 10001612; pubID: 10002913
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002913,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001612 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001612; pubID: 10002913
bookid: 10001612; pubID: 10002914
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002914,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001612 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001612; pubID: 10002914
bookid: 10001612; pubID: 10002915
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002915,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001612 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001612; pubID: 10002915
bookid: 10001612; pubID: 10002916
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002916,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001612 AND
		    AGENT_NAME_ID=10007799
goddammit MVZ: bookid: 10001612; pubID: 10002916
bookid: 10001615; pubID: 10002917
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002917,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001615 AND
		    AGENT_NAME_ID=10001024
goddammit MVZ: bookid: 10001615; pubID: 10002917
bookid: 10001562; pubID: 10002918
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002918,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001562 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10001562; pubID: 10002918
bookid: 10001562; pubID: 10002919
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002919,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001562 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10001562; pubID: 10002919
bookid: 10001562; pubID: 10002920
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002920,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001562 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10001562; pubID: 10002920
bookid: 10001562; pubID: 10002921
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002921,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001562 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10001562; pubID: 10002921
bookid: 10001561; pubID: 10002922
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002922,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001561 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10001561; pubID: 10002922
bookid: 10001561; pubID: 10002923
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002923,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001561 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10001561; pubID: 10002923
bookid: 10001561; pubID: 10002924
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002924,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001561 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10001561; pubID: 10002924
bookid: 10001561; pubID: 10002925
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002925,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001561 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10001561; pubID: 10002925
bookid: 10001561; pubID: 10002926
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002926,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001561 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10001561; pubID: 10002926
bookid: 10001560; pubID: 10002927
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002927,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001560 AND
		    AGENT_NAME_ID=10008307
goddammit MVZ: bookid: 10001560; pubID: 10002927
bookid: 10001563; pubID: 10002928
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002928,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001563 AND
		    AGENT_NAME_ID=10006867
goddammit MVZ: bookid: 10001563; pubID: 10002928
bookid: 10001563; pubID: 10002929
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002929,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001563 AND
		    AGENT_NAME_ID=10006867
goddammit MVZ: bookid: 10001563; pubID: 10002929
bookid: 10001563; pubID: 10002930
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002930,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001563 AND
		    AGENT_NAME_ID=10006867
goddammit MVZ: bookid: 10001563; pubID: 10002930
bookid: 10001564; pubID: 10002931
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002931,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001564 AND
		    AGENT_NAME_ID=10006867
goddammit MVZ: bookid: 10001564; pubID: 10002931
bookid: 10001564; pubID: 10002932
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002932,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001564 AND
		    AGENT_NAME_ID=10006867
goddammit MVZ: bookid: 10001564; pubID: 10002932
bookid: 10001564; pubID: 10002933
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002933,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001564 AND
		    AGENT_NAME_ID=10006867
goddammit MVZ: bookid: 10001564; pubID: 10002933
bookid: 10001564; pubID: 10002934
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002934,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001564 AND
		    AGENT_NAME_ID=10006867
goddammit MVZ: bookid: 10001564; pubID: 10002934
bookid: 10001569; pubID: 10002935
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002935,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001569 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001569; pubID: 10002935
bookid: 10001692; pubID: 10002936
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002936,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001692 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001692; pubID: 10002936
bookid: 10001694; pubID: 10002937
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002937,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001694 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001694; pubID: 10002937
bookid: 10001695; pubID: 10002938
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002938,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001695 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001695; pubID: 10002938
bookid: 10001566; pubID: 10002939
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002939,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001566 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001566; pubID: 10002939
bookid: 10001566; pubID: 10002940
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002940,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001566 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001566; pubID: 10002940
bookid: 10001566; pubID: 10002941
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002941,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001566 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001566; pubID: 10002941
bookid: 10001567; pubID: 10002942
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002942,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001567 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001567; pubID: 10002942
bookid: 10001567; pubID: 10002943
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002943,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001567 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001567; pubID: 10002943
bookid: 10001567; pubID: 10002944
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002944,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001567 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001567; pubID: 10002944
bookid: 10001567; pubID: 10002945
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002945,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001567 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001567; pubID: 10002945
bookid: 10001567; pubID: 10002946
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002946,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001567 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001567; pubID: 10002946
bookid: 10001568; pubID: 10002947
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002947,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001568 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001568; pubID: 10002947
bookid: 10001568; pubID: 10002948
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002948,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001568 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001568; pubID: 10002948
bookid: 10001568; pubID: 10002949
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002949,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001568 AND
		    AGENT_NAME_ID=10000480
goddammit MVZ: bookid: 10001568; pubID: 10002949
bookid: 10001512; pubID: 10002950
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002950,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001512 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001512; pubID: 10002950
bookid: 10001512; pubID: 10002951
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002951,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001512 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001512; pubID: 10002951
bookid: 10001512; pubID: 10002952
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002952,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001512 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001512; pubID: 10002952
bookid: 10001512; pubID: 10002953
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002953,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001512 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001512; pubID: 10002953
bookid: 10001513; pubID: 10002954
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002954,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001513 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001513; pubID: 10002954
bookid: 10001513; pubID: 10002955
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002955,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001513 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001513; pubID: 10002955
bookid: 10001513; pubID: 10002956
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002956,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001513 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001513; pubID: 10002956
bookid: 10001513; pubID: 10002957
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002957,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001513 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001513; pubID: 10002957
bookid: 10001686; pubID: 10002958
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002958,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001686 AND
		    AGENT_NAME_ID=10011776
goddammit MVZ: bookid: 10001686; pubID: 10002958
bookid: 10001686; pubID: 10002959
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002959,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001686 AND
		    AGENT_NAME_ID=10011776
goddammit MVZ: bookid: 10001686; pubID: 10002959
bookid: 10001686; pubID: 10002960
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002960,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001686 AND
		    AGENT_NAME_ID=10011776
goddammit MVZ: bookid: 10001686; pubID: 10002960
bookid: 10001687; pubID: 10002961
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002961,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001687 AND
		    AGENT_NAME_ID=10011813
goddammit MVZ: bookid: 10001687; pubID: 10002961
bookid: 10001687; pubID: 10002962
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002962,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001687 AND
		    AGENT_NAME_ID=10011813
goddammit MVZ: bookid: 10001687; pubID: 10002962
bookid: 10001687; pubID: 10002963
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002963,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001687 AND
		    AGENT_NAME_ID=10011813
goddammit MVZ: bookid: 10001687; pubID: 10002963
bookid: 10001514; pubID: 10002964
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002964,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001514 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001514; pubID: 10002964
bookid: 10001514; pubID: 10002965
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002965,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001514 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001514; pubID: 10002965
bookid: 10001514; pubID: 10002966
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002966,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001514 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001514; pubID: 10002966
bookid: 10001514; pubID: 10002967
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002967,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001514 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001514; pubID: 10002967
bookid: 10001518; pubID: 10002968
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002968,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001518 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001518; pubID: 10002968
bookid: 10001518; pubID: 10002969
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002969,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001518 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001518; pubID: 10002969
bookid: 10001518; pubID: 10002970
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002970,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001518 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001518; pubID: 10002970
bookid: 10001518; pubID: 10002971
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002971,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001518 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001518; pubID: 10002971
bookid: 10001518; pubID: 10002972
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002972,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001518 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001518; pubID: 10002972
bookid: 10001693; pubID: 10002973
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002973,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001693 AND
		    AGENT_NAME_ID=10000257
goddammit MVZ: bookid: 10001693; pubID: 10002973
bookid: 10001658; pubID: 10002974
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002974,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001658 AND
		    AGENT_NAME_ID=10011370
goddammit MVZ: bookid: 10001658; pubID: 10002974
bookid: 10001659; pubID: 10002975
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002975,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001659 AND
		    AGENT_NAME_ID=10011370
goddammit MVZ: bookid: 10001659; pubID: 10002975
bookid: 10001384; pubID: 10002976
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002976,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001384 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001384; pubID: 10002976
bookid: 10001385; pubID: 10002977
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002977,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001385 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001385; pubID: 10002977
bookid: 10001386; pubID: 10002978
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002978,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001386 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001386; pubID: 10002978
bookid: 10001388; pubID: 10002979
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002979,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001388 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001388; pubID: 10002979
bookid: 10001387; pubID: 10002980
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002980,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001387 AND
		    AGENT_NAME_ID=10000225
goddammit MVZ: bookid: 10001387; pubID: 10002980
bookid: 10001296; pubID: 10002981
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002981,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001296 AND
		    AGENT_NAME_ID=10004259
goddammit MVZ: bookid: 10001296; pubID: 10002981
bookid: 10001298; pubID: 10002982
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002982,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001298 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001298; pubID: 10002982
bookid: 10001298; pubID: 10002983
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002983,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001298 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001298; pubID: 10002983
bookid: 10001298; pubID: 10002984
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002984,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001298 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001298; pubID: 10002984
bookid: 10001299; pubID: 10002985
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002985,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001299 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001299; pubID: 10002985
bookid: 10001299; pubID: 10002986
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002986,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001299 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001299; pubID: 10002986
bookid: 10001299; pubID: 10002987
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002987,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001299 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001299; pubID: 10002987
bookid: 10001300; pubID: 10002988
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002988,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001300 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001300; pubID: 10002988
bookid: 10001300; pubID: 10002989
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002989,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001300 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001300; pubID: 10002989
bookid: 10001300; pubID: 10002990
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002990,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001300 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001300; pubID: 10002990
bookid: 10001300; pubID: 10002991
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002991,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001300 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001300; pubID: 10002991
bookid: 10001300; pubID: 10002992
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002992,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001300 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001300; pubID: 10002992
bookid: 10001300; pubID: 10002993
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002993,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001300 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001300; pubID: 10002993
bookid: 10001300; pubID: 10002994
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002994,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001300 AND
		    AGENT_NAME_ID=10000572
goddammit MVZ: bookid: 10001300; pubID: 10002994
bookid: 10001303; pubID: 10002995
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002995,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001303 AND
		    AGENT_NAME_ID=10004578
goddammit MVZ: bookid: 10001303; pubID: 10002995
bookid: 10001303; pubID: 10002996
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002996,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001303 AND
		    AGENT_NAME_ID=10004578
goddammit MVZ: bookid: 10001303; pubID: 10002996
bookid: 10001313; pubID: 10002997
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002997,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001313 AND
		    AGENT_NAME_ID=10004991
goddammit MVZ: bookid: 10001313; pubID: 10002997
bookid: 10001313; pubID: 10002998
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002998,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001313 AND
		    AGENT_NAME_ID=10004991
goddammit MVZ: bookid: 10001313; pubID: 10002998
bookid: 10001313; pubID: 10002999
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002999,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001313 AND
		    AGENT_NAME_ID=10004991
goddammit MVZ: bookid: 10001313; pubID: 10002999
bookid: 10001313; pubID: 10003000
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003000,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001313 AND
		    AGENT_NAME_ID=10004991
goddammit MVZ: bookid: 10001313; pubID: 10003000
bookid: 10001351; pubID: 10003001
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003001,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001351 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001351; pubID: 10003001
bookid: 10001351; pubID: 10003002
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003002,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001351 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001351; pubID: 10003002
bookid: 10001351; pubID: 10003003
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003003,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001351 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001351; pubID: 10003003
bookid: 10001352; pubID: 10003004
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003004,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001352 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001352; pubID: 10003004
bookid: 10001352; pubID: 10003005
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003005,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001352 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001352; pubID: 10003005
bookid: 10001352; pubID: 10003006
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003006,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001352 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001352; pubID: 10003006
bookid: 10001352; pubID: 10003007
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003007,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001352 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001352; pubID: 10003007
bookid: 10001352; pubID: 10003008
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003008,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001352 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001352; pubID: 10003008
bookid: 10001352; pubID: 10003009
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003009,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001352 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001352; pubID: 10003009
bookid: 10001353; pubID: 10003010
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003010,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001353 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001353; pubID: 10003010
bookid: 10001353; pubID: 10003011
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003011,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001353 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001353; pubID: 10003011
bookid: 10001353; pubID: 10003012
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003012,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001353 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001353; pubID: 10003012
bookid: 10001353; pubID: 10003013
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003013,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001353 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001353; pubID: 10003013
bookid: 10001353; pubID: 10003014
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003014,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001353 AND
		    AGENT_NAME_ID=10005502
goddammit MVZ: bookid: 10001353; pubID: 10003014
bookid: 10001355; pubID: 10003015
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003015,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001355 AND
		    AGENT_NAME_ID=10005619
goddammit MVZ: bookid: 10001355; pubID: 10003015
bookid: 10001356; pubID: 10003016
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003016,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001356 AND
		    AGENT_NAME_ID=10005619
goddammit MVZ: bookid: 10001356; pubID: 10003016
bookid: 10001356; pubID: 10003017
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003017,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001356 AND
		    AGENT_NAME_ID=10005619
goddammit MVZ: bookid: 10001356; pubID: 10003017
bookid: 10001356; pubID: 10003018
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003018,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001356 AND
		    AGENT_NAME_ID=10005619
goddammit MVZ: bookid: 10001356; pubID: 10003018
bookid: 10001357; pubID: 10003019
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003019,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001357 AND
		    AGENT_NAME_ID=10005619
goddammit MVZ: bookid: 10001357; pubID: 10003019
bookid: 10001357; pubID: 10003020
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003020,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001357 AND
		    AGENT_NAME_ID=10005619
goddammit MVZ: bookid: 10001357; pubID: 10003020
bookid: 10001358; pubID: 10003021
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003021,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001358 AND
		    AGENT_NAME_ID=10005619
goddammit MVZ: bookid: 10001358; pubID: 10003021
bookid: 10001358; pubID: 10003022
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003022,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001358 AND
		    AGENT_NAME_ID=10005619
goddammit MVZ: bookid: 10001358; pubID: 10003022
bookid: 10001358; pubID: 10003023
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003023,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001358 AND
		    AGENT_NAME_ID=10005619
goddammit MVZ: bookid: 10001358; pubID: 10003023
bookid: 10001366; pubID: 10003024
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003024,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001366 AND
		    AGENT_NAME_ID=10004632
bookid: 10001366; pubID: 10003025
npid:
bookid: 10001366; pubID: 10003026
npid:
bookid: 10001366; pubID: 10003027
npid:
bookid: 10001366; pubID: 10003028
npid:
bookid: 10001367; pubID: 10003029
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003029,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001367 AND
		    AGENT_NAME_ID=10004632
bookid: 10001367; pubID: 10003030
npid:
bookid: 10001367; pubID: 10003031
npid:
bookid: 10001367; pubID: 10003032
npid:
bookid: 10001367; pubID: 10003033
npid:
bookid: 10001367; pubID: 10003034
npid:
bookid: 10001367; pubID: 10003035
npid:
bookid: 10001368; pubID: 10003036
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003036,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001368 AND
		    AGENT_NAME_ID=10004632
bookid: 10001368; pubID: 10003037
npid:
bookid: 10001368; pubID: 10003038
npid:
bookid: 10001368; pubID: 10003039
npid:
bookid: 10001368; pubID: 10003040
npid:
bookid: 10001368; pubID: 10003041
npid:
bookid: 10001429; pubID: 10003042
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003042,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001429 AND
		    AGENT_NAME_ID=10007091
goddammit MVZ: bookid: 10001429; pubID: 10003042
bookid: 10001429; pubID: 10003043
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003043,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001429 AND
		    AGENT_NAME_ID=10007091
goddammit MVZ: bookid: 10001429; pubID: 10003043
bookid: 10001429; pubID: 10003044
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003044,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001429 AND
		    AGENT_NAME_ID=10007091
goddammit MVZ: bookid: 10001429; pubID: 10003044
bookid: 10001429; pubID: 10003045
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003045,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001429 AND
		    AGENT_NAME_ID=10007091
goddammit MVZ: bookid: 10001429; pubID: 10003045
bookid: 10001429; pubID: 10003046
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003046,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001429 AND
		    AGENT_NAME_ID=10007091
goddammit MVZ: bookid: 10001429; pubID: 10003046
bookid: 10001430; pubID: 10003047
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003047,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001430 AND
		    AGENT_NAME_ID=10007140
goddammit MVZ: bookid: 10001430; pubID: 10003047
bookid: 10001349; pubID: 10003048
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003048,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001349 AND
		    AGENT_NAME_ID=10005105
goddammit MVZ: bookid: 10001349; pubID: 10003048
bookid: 10001349; pubID: 10003049
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003049,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001349 AND
		    AGENT_NAME_ID=10005105
goddammit MVZ: bookid: 10001349; pubID: 10003049
bookid: 10001349; pubID: 10003050
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003050,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001349 AND
		    AGENT_NAME_ID=10005105
goddammit MVZ: bookid: 10001349; pubID: 10003050
bookid: 10001364; pubID: 10003051
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003051,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001364 AND
		    AGENT_NAME_ID=10005915
goddammit MVZ: bookid: 10001364; pubID: 10003051
bookid: 10001364; pubID: 10003052
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003052,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001364 AND
		    AGENT_NAME_ID=10005915
goddammit MVZ: bookid: 10001364; pubID: 10003052
bookid: 10001364; pubID: 10003053
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003053,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001364 AND
		    AGENT_NAME_ID=10005915
goddammit MVZ: bookid: 10001364; pubID: 10003053
bookid: 10001364; pubID: 10003054
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003054,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001364 AND
		    AGENT_NAME_ID=10005915
goddammit MVZ: bookid: 10001364; pubID: 10003054
bookid: 10001362; pubID: 10003055
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003055,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001362 AND
		    AGENT_NAME_ID=10005813
goddammit MVZ: bookid: 10001362; pubID: 10003055
bookid: 10001362; pubID: 10003056
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003056,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001362 AND
		    AGENT_NAME_ID=10005813
goddammit MVZ: bookid: 10001362; pubID: 10003056
bookid: 10001362; pubID: 10003057
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003057,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001362 AND
		    AGENT_NAME_ID=10005813
goddammit MVZ: bookid: 10001362; pubID: 10003057
bookid: 10001362; pubID: 10003058
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003058,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001362 AND
		    AGENT_NAME_ID=10005813
goddammit MVZ: bookid: 10001362; pubID: 10003058
bookid: 10001363; pubID: 10003059
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003059,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001363 AND
		    AGENT_NAME_ID=10005819
goddammit MVZ: bookid: 10001363; pubID: 10003059
bookid: 10001363; pubID: 10003060
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003060,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001363 AND
		    AGENT_NAME_ID=10005819
goddammit MVZ: bookid: 10001363; pubID: 10003060
bookid: 10001363; pubID: 10003061
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003061,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001363 AND
		    AGENT_NAME_ID=10005819
goddammit MVZ: bookid: 10001363; pubID: 10003061
bookid: 10001363; pubID: 10003062
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003062,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001363 AND
		    AGENT_NAME_ID=10005819
goddammit MVZ: bookid: 10001363; pubID: 10003062
bookid: 10001365; pubID: 10003063
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003063,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001365 AND
		    AGENT_NAME_ID=10014134
goddammit MVZ: bookid: 10001365; pubID: 10003063
bookid: 10001381; pubID: 10003064
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003064,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001381 AND
		    AGENT_NAME_ID=10006415
goddammit MVZ: bookid: 10001381; pubID: 10003064
bookid: 10001445; pubID: 10003065
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003065,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001445 AND
		    AGENT_NAME_ID=10007340
goddammit MVZ: bookid: 10001445; pubID: 10003065
bookid: 10001458; pubID: 10003066
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003066,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001458 AND
		    AGENT_NAME_ID=10007461
goddammit MVZ: bookid: 10001458; pubID: 10003066
bookid: 10001458; pubID: 10003067
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003067,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001458 AND
		    AGENT_NAME_ID=10007461
goddammit MVZ: bookid: 10001458; pubID: 10003067
bookid: 10001458; pubID: 10003068
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003068,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001458 AND
		    AGENT_NAME_ID=10007461
bookid: 10001458; pubID: 10003069
npid:
bookid: 10001470; pubID: 10003070
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003070,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001470 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001470; pubID: 10003070
bookid: 10001470; pubID: 10003071
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003071,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001470 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001470; pubID: 10003071
bookid: 10001470; pubID: 10003072
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003072,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001470 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001470; pubID: 10003072
bookid: 10001470; pubID: 10003073
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003073,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001470 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001470; pubID: 10003073
bookid: 10001470; pubID: 10003074
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003074,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001470 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001470; pubID: 10003074
bookid: 10001470; pubID: 10003075
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003075,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001470 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001470; pubID: 10003075
bookid: 10001470; pubID: 10003076
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003076,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001470 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001470; pubID: 10003076
bookid: 10001470; pubID: 10003077
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003077,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001470 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001470; pubID: 10003077
bookid: 10001470; pubID: 10003078
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003078,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001470 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001470; pubID: 10003078
bookid: 10001471; pubID: 10003079
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003079,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001471 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001471; pubID: 10003079
bookid: 10001472; pubID: 10003080
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003080,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001472 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001472; pubID: 10003080
bookid: 10001472; pubID: 10003081
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003081,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001472 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001472; pubID: 10003081
bookid: 10001472; pubID: 10003082
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003082,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001472 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001472; pubID: 10003082
bookid: 10001472; pubID: 10003083
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003083,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001472 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001472; pubID: 10003083
bookid: 10001473; pubID: 10003084
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003084,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001473 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001473; pubID: 10003084
bookid: 10001473; pubID: 10003085
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003085,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001473 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001473; pubID: 10003085
bookid: 10001473; pubID: 10003086
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003086,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001473 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001473; pubID: 10003086
bookid: 10001473; pubID: 10003087
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003087,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001473 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001473; pubID: 10003087
bookid: 10001473; pubID: 10003088
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003088,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001473 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001473; pubID: 10003088
bookid: 10001469; pubID: 10003089
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003089,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001469 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001469; pubID: 10003089
bookid: 10001469; pubID: 10003090
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003090,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001469 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001469; pubID: 10003090
bookid: 10001469; pubID: 10003091
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003091,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001469 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001469; pubID: 10003091
bookid: 10001469; pubID: 10003092
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003092,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001469 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001469; pubID: 10003092
bookid: 10001469; pubID: 10003093
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003093,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001469 AND
		    AGENT_NAME_ID=10000476
goddammit MVZ: bookid: 10001469; pubID: 10003093
bookid: 10001478; pubID: 10003094
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003094,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001478 AND
		    AGENT_NAME_ID=10008200
goddammit MVZ: bookid: 10001478; pubID: 10003094
bookid: 10001478; pubID: 10003095
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003095,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001478 AND
		    AGENT_NAME_ID=10008200
goddammit MVZ: bookid: 10001478; pubID: 10003095
bookid: 10001478; pubID: 10003096
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003096,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001478 AND
		    AGENT_NAME_ID=10008200
goddammit MVZ: bookid: 10001478; pubID: 10003096
bookid: 10001478; pubID: 10003097
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003097,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001478 AND
		    AGENT_NAME_ID=10008200
goddammit MVZ: bookid: 10001478; pubID: 10003097
bookid: 10001474; pubID: 10003098
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003098,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001474 AND
		    AGENT_NAME_ID=10007852
goddammit MVZ: bookid: 10001474; pubID: 10003098
bookid: 10001474; pubID: 10003099
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003099,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001474 AND
		    AGENT_NAME_ID=10007852
goddammit MVZ: bookid: 10001474; pubID: 10003099
bookid: 10001474; pubID: 10003100
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003100,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001474 AND
		    AGENT_NAME_ID=10007852
goddammit MVZ: bookid: 10001474; pubID: 10003100
bookid: 10001474; pubID: 10003101
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003101,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001474 AND
		    AGENT_NAME_ID=10007852
goddammit MVZ: bookid: 10001474; pubID: 10003101
bookid: 10001474; pubID: 10003102
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003102,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001474 AND
		    AGENT_NAME_ID=10007852
goddammit MVZ: bookid: 10001474; pubID: 10003102
bookid: 10001502; pubID: 10003103
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003103,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001502 AND
		    AGENT_NAME_ID=10001027
goddammit MVZ: bookid: 10001502; pubID: 10003103
bookid: 10001502; pubID: 10003104
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003104,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001502 AND
		    AGENT_NAME_ID=10001027
goddammit MVZ: bookid: 10001502; pubID: 10003104
bookid: 10001502; pubID: 10003105
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003105,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001502 AND
		    AGENT_NAME_ID=10001027
goddammit MVZ: bookid: 10001502; pubID: 10003105
bookid: 10001500; pubID: 10003106
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003106,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001500 AND
		    AGENT_NAME_ID=10008358
goddammit MVZ: bookid: 10001500; pubID: 10003106
bookid: 10001500; pubID: 10003107
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003107,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001500 AND
		    AGENT_NAME_ID=10008358
goddammit MVZ: bookid: 10001500; pubID: 10003107
bookid: 10001500; pubID: 10003108
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003108,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001500 AND
		    AGENT_NAME_ID=10008358
goddammit MVZ: bookid: 10001500; pubID: 10003108
bookid: 10001500; pubID: 10003109
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003109,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001500 AND
		    AGENT_NAME_ID=10008358
goddammit MVZ: bookid: 10001500; pubID: 10003109
bookid: 10001500; pubID: 10003110
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003110,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001500 AND
		    AGENT_NAME_ID=10008358
goddammit MVZ: bookid: 10001500; pubID: 10003110
bookid: 10001466; pubID: 10003111
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003111,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001466 AND
		    AGENT_NAME_ID=10001474
goddammit MVZ: bookid: 10001466; pubID: 10003111
bookid: 10001467; pubID: 10003112
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003112,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001467 AND
		    AGENT_NAME_ID=10004452
goddammit MVZ: bookid: 10001467; pubID: 10003112
bookid: 10001467; pubID: 10003113
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003113,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001467 AND
		    AGENT_NAME_ID=10004452
goddammit MVZ: bookid: 10001467; pubID: 10003113
bookid: 10001467; pubID: 10003114
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003114,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001467 AND
		    AGENT_NAME_ID=10004452
goddammit MVZ: bookid: 10001467; pubID: 10003114
bookid: 10001511; pubID: 10003115
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003115,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001511 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001511; pubID: 10003115
bookid: 10001511; pubID: 10003116
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003116,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001511 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001511; pubID: 10003116
bookid: 10001511; pubID: 10003117
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003117,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001511 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001511; pubID: 10003117
bookid: 10001511; pubID: 10003118
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003118,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001511 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001511; pubID: 10003118
bookid: 10001511; pubID: 10003119
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003119,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001511 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001511; pubID: 10003119
bookid: 10001511; pubID: 10003120
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003120,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001511 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001511; pubID: 10003120
bookid: 10001511; pubID: 10003121
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003121,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001511 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001511; pubID: 10003121
bookid: 10001510; pubID: 10003122
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003122,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001510 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001510; pubID: 10003122
bookid: 10001510; pubID: 10003123
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003123,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001510 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001510; pubID: 10003123
bookid: 10001510; pubID: 10003124
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003124,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001510 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001510; pubID: 10003124
bookid: 10001510; pubID: 10003125
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003125,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001510 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001510; pubID: 10003125
bookid: 10001510; pubID: 10003126
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003126,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001510 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001510; pubID: 10003126
bookid: 10001510; pubID: 10003127
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003127,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001510 AND
		    AGENT_NAME_ID=10001041
goddammit MVZ: bookid: 10001510; pubID: 10003127
bookid: 10001509; pubID: 10003128
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003128,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001509 AND
		    AGENT_NAME_ID=10008942
goddammit MVZ: bookid: 10001509; pubID: 10003128
bookid: 10001508; pubID: 10003129
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003129,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001508 AND
		    AGENT_NAME_ID=10008880
goddammit MVZ: bookid: 10001508; pubID: 10003129
bookid: 10001507; pubID: 10003130
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003130,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001507 AND
		    AGENT_NAME_ID=10008876
goddammit MVZ: bookid: 10001507; pubID: 10003130
bookid: 10001507; pubID: 10003131
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003131,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001507 AND
		    AGENT_NAME_ID=10008876
goddammit MVZ: bookid: 10001507; pubID: 10003131
bookid: 10001507; pubID: 10003132
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003132,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001507 AND
		    AGENT_NAME_ID=10008876
goddammit MVZ: bookid: 10001507; pubID: 10003132
bookid: 10001507; pubID: 10003133
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003133,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001507 AND
		    AGENT_NAME_ID=10008876
goddammit MVZ: bookid: 10001507; pubID: 10003133
bookid: 10001534; pubID: 10003134
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003134,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001534 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001534; pubID: 10003134
bookid: 10001533; pubID: 10003135
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003135,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001533 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001533; pubID: 10003135
bookid: 10001533; pubID: 10003136
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003136,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001533 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001533; pubID: 10003136
bookid: 10001532; pubID: 10003137
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003137,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001532 AND
		    AGENT_NAME_ID=10009399
goddammit MVZ: bookid: 10001532; pubID: 10003137
bookid: 10001516; pubID: 10003138
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003138,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009211
goddammit MVZ: bookid: 10001516; pubID: 10003138
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003138,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009212
goddammit MVZ: bookid: 10001516; pubID: 10003138
bookid: 10001516; pubID: 10003139
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003139,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009211
goddammit MVZ: bookid: 10001516; pubID: 10003139
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003139,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009212
goddammit MVZ: bookid: 10001516; pubID: 10003139
bookid: 10001516; pubID: 10003140
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003140,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009211
goddammit MVZ: bookid: 10001516; pubID: 10003140
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003140,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009212
goddammit MVZ: bookid: 10001516; pubID: 10003140
bookid: 10001516; pubID: 10003141
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003141,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009211
goddammit MVZ: bookid: 10001516; pubID: 10003141
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003141,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009212
goddammit MVZ: bookid: 10001516; pubID: 10003141
bookid: 10001516; pubID: 10003142
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003142,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009211
goddammit MVZ: bookid: 10001516; pubID: 10003142
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003142,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009212
goddammit MVZ: bookid: 10001516; pubID: 10003142
bookid: 10001516; pubID: 10003143
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003143,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009211
goddammit MVZ: bookid: 10001516; pubID: 10003143
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003143,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001516 AND
		    AGENT_NAME_ID=10009212
goddammit MVZ: bookid: 10001516; pubID: 10003143
bookid: 10001517; pubID: 10003144
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003144,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001517 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001517; pubID: 10003144
bookid: 10001517; pubID: 10003145
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003145,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001517 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001517; pubID: 10003145
bookid: 10001517; pubID: 10003146
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003146,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001517 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001517; pubID: 10003146
bookid: 10001517; pubID: 10003147
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003147,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001517 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001517; pubID: 10003147
bookid: 10001517; pubID: 10003148
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003148,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001517 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001517; pubID: 10003148
bookid: 10001517; pubID: 10003149
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003149,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001517 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001517; pubID: 10003149
bookid: 10001517; pubID: 10003150
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003150,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001517 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001517; pubID: 10003150
bookid: 10001517; pubID: 10003151
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003151,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001517 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001517; pubID: 10003151
bookid: 10001517; pubID: 10003152
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003152,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001517 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001517; pubID: 10003152
bookid: 10001538; pubID: 10003153
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003153,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001538 AND
		    AGENT_NAME_ID=10009734
goddammit MVZ: bookid: 10001538; pubID: 10003153
bookid: 10001537; pubID: 10003154
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003154,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001537 AND
		    AGENT_NAME_ID=10009611
goddammit MVZ: bookid: 10001537; pubID: 10003154
bookid: 10001536; pubID: 10003155
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003155,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001536 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001536; pubID: 10003155
bookid: 10001536; pubID: 10003156
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003156,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001536 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001536; pubID: 10003156
bookid: 10001536; pubID: 10003157
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003157,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001536 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001536; pubID: 10003157
bookid: 10001536; pubID: 10003158
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003158,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001536 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001536; pubID: 10003158
bookid: 10001536; pubID: 10003159
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003159,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001536 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001536; pubID: 10003159
bookid: 10001536; pubID: 10003160
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003160,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001536 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001536; pubID: 10003160
bookid: 10001536; pubID: 10003161
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003161,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001536 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001536; pubID: 10003161
bookid: 10001536; pubID: 10003162
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003162,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001536 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001536; pubID: 10003162
bookid: 10001536; pubID: 10003163
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003163,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001536 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001536; pubID: 10003163
bookid: 10001535; pubID: 10003164
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003164,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001535 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001535; pubID: 10003164
bookid: 10001535; pubID: 10003165
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003165,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001535 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10001535; pubID: 10003165
bookid: 10001661; pubID: 10003166
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003166,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001661 AND
		    AGENT_NAME_ID=10011489
goddammit MVZ: bookid: 10001661; pubID: 10003166
bookid: 10001662; pubID: 10003167
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003167,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001662 AND
		    AGENT_NAME_ID=10000504
goddammit MVZ: bookid: 10001662; pubID: 10003167
bookid: 10001662; pubID: 10003168
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003168,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001662 AND
		    AGENT_NAME_ID=10000504
goddammit MVZ: bookid: 10001662; pubID: 10003168
bookid: 10001662; pubID: 10003169
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003169,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001662 AND
		    AGENT_NAME_ID=10000504
goddammit MVZ: bookid: 10001662; pubID: 10003169
bookid: 10001662; pubID: 10003170
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003170,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001662 AND
		    AGENT_NAME_ID=10000504
goddammit MVZ: bookid: 10001662; pubID: 10003170
bookid: 10001662; pubID: 10003171
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003171,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001662 AND
		    AGENT_NAME_ID=10000504
goddammit MVZ: bookid: 10001662; pubID: 10003171
bookid: 10001621; pubID: 10003172
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003172,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001621 AND
		    AGENT_NAME_ID=10011135
goddammit MVZ: bookid: 10001621; pubID: 10003172
bookid: 10001621; pubID: 10003173
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003173,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001621 AND
		    AGENT_NAME_ID=10011135
goddammit MVZ: bookid: 10001621; pubID: 10003173
bookid: 10001621; pubID: 10003174
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003174,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001621 AND
		    AGENT_NAME_ID=10011135
goddammit MVZ: bookid: 10001621; pubID: 10003174
bookid: 10001596; pubID: 10003175
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003175,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001596 AND
		    AGENT_NAME_ID=10010480
goddammit MVZ: bookid: 10001596; pubID: 10003175
bookid: 10001596; pubID: 10003176
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003176,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001596 AND
		    AGENT_NAME_ID=10010480
goddammit MVZ: bookid: 10001596; pubID: 10003176
bookid: 10001596; pubID: 10003177
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003177,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001596 AND
		    AGENT_NAME_ID=10010480
goddammit MVZ: bookid: 10001596; pubID: 10003177
bookid: 10001596; pubID: 10003178
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003178,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001596 AND
		    AGENT_NAME_ID=10010480
goddammit MVZ: bookid: 10001596; pubID: 10003178
bookid: 10001540; pubID: 10003179
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003179,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001540 AND
		    AGENT_NAME_ID=10009942
goddammit MVZ: bookid: 10001540; pubID: 10003179
bookid: 10001750; pubID: 10003180
npid: 6
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003180,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10001217
goddammit MVZ: bookid: 10001750; pubID: 10003180
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003180,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001750; pubID: 10003180
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003180,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10010354
goddammit MVZ: bookid: 10001750; pubID: 10003180
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003180,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10010415
goddammit MVZ: bookid: 10001750; pubID: 10003180
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003180,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10012107
goddammit MVZ: bookid: 10001750; pubID: 10003180
bookid: 10001750; pubID: 10003181
npid: 6
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003181,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10001217
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003181,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10006339
goddammit MVZ: bookid: 10001750; pubID: 10003181
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003181,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10010354
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003181,
		    AUTHOR_POSITION=8
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10010415
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003181,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10012107
bookid: 10001750; pubID: 10003182
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003182,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001750 AND
		    AGENT_NAME_ID=10006339
bookid: 10001750; pubID: 10003183
npid:
bookid: 10001750; pubID: 10003184
npid:
bookid: 10001750; pubID: 10003185
npid:
bookid: 10001670; pubID: 10003186
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003186,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001670 AND
		    AGENT_NAME_ID=10008113
goddammit MVZ: bookid: 10001670; pubID: 10003186
bookid: 10001670; pubID: 10003187
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003187,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001670 AND
		    AGENT_NAME_ID=10008113
goddammit MVZ: bookid: 10001670; pubID: 10003187
bookid: 10001670; pubID: 10003188
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003188,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001670 AND
		    AGENT_NAME_ID=10008113
goddammit MVZ: bookid: 10001670; pubID: 10003188
bookid: 10001719; pubID: 10003189
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003189,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001719 AND
		    AGENT_NAME_ID=10003162
goddammit MVZ: bookid: 10001719; pubID: 10003189
bookid: 10001720; pubID: 10003190
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003190,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001720 AND
		    AGENT_NAME_ID=10003162
goddammit MVZ: bookid: 10001720; pubID: 10003190
bookid: 10001720; pubID: 10003191
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003191,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001720 AND
		    AGENT_NAME_ID=10003162
goddammit MVZ: bookid: 10001720; pubID: 10003191
bookid: 10001721; pubID: 10003192
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003192,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001721 AND
		    AGENT_NAME_ID=10013949
bookid: 10001721; pubID: 10003193
npid:
bookid: 10001718; pubID: 10003194
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003194,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001718 AND
		    AGENT_NAME_ID=10013130
goddammit MVZ: bookid: 10001718; pubID: 10003194
bookid: 10001715; pubID: 10003195
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003195,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001715 AND
		    AGENT_NAME_ID=10013055
goddammit MVZ: bookid: 10001715; pubID: 10003195
bookid: 10001713; pubID: 10003196
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003196,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001713 AND
		    AGENT_NAME_ID=10012879
goddammit MVZ: bookid: 10001713; pubID: 10003196
bookid: 10001713; pubID: 10003197
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003197,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001713 AND
		    AGENT_NAME_ID=10012879
goddammit MVZ: bookid: 10001713; pubID: 10003197
bookid: 10001713; pubID: 10003198
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003198,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001713 AND
		    AGENT_NAME_ID=10012879
goddammit MVZ: bookid: 10001713; pubID: 10003198
bookid: 10001713; pubID: 10003199
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003199,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001713 AND
		    AGENT_NAME_ID=10012879
goddammit MVZ: bookid: 10001713; pubID: 10003199
bookid: 10001297; pubID: 10003200
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003200,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001297 AND
		    AGENT_NAME_ID=10000572
bookid: 10001315; pubID: 10003201
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003201,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001315 AND
		    AGENT_NAME_ID=10004991
goddammit MVZ: bookid: 10001315; pubID: 10003201
bookid: 10001314; pubID: 10003202
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003202,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001314 AND
		    AGENT_NAME_ID=10004991
goddammit MVZ: bookid: 10001314; pubID: 10003202
bookid: 10001701; pubID: 10003203
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003203,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001701 AND
		    AGENT_NAME_ID=10001043
goddammit MVZ: bookid: 10001701; pubID: 10003203
bookid: 10001700; pubID: 10003204
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003204,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001700 AND
		    AGENT_NAME_ID=10001043
goddammit MVZ: bookid: 10001700; pubID: 10003204
bookid: 10001699; pubID: 10003205
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003205,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001699 AND
		    AGENT_NAME_ID=10000197
goddammit MVZ: bookid: 10001699; pubID: 10003205
bookid: 10001699; pubID: 10003206
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003206,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001699 AND
		    AGENT_NAME_ID=10000197
goddammit MVZ: bookid: 10001699; pubID: 10003206
bookid: 10001699; pubID: 10003207
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003207,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001699 AND
		    AGENT_NAME_ID=10000197
goddammit MVZ: bookid: 10001699; pubID: 10003207
bookid: 10001699; pubID: 10003208
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003208,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001699 AND
		    AGENT_NAME_ID=10000197
goddammit MVZ: bookid: 10001699; pubID: 10003208
bookid: 10001725; pubID: 10003209
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003209,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001725 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001725; pubID: 10003209
bookid: 10001725; pubID: 10003210
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003210,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001725 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001725; pubID: 10003210
bookid: 10001725; pubID: 10003211
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003211,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001725 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001725; pubID: 10003211
bookid: 10001725; pubID: 10003212
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003212,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001725 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001725; pubID: 10003212
bookid: 10001725; pubID: 10003213
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003213,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001725 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001725; pubID: 10003213
bookid: 10001725; pubID: 10003214
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003214,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001725 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001725; pubID: 10003214
bookid: 10001725; pubID: 10003215
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003215,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001725 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001725; pubID: 10003215
bookid: 10001731; pubID: 10003216
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003216,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001731 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001731; pubID: 10003216
bookid: 10001731; pubID: 10003217
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003217,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001731 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001731; pubID: 10003217
bookid: 10001731; pubID: 10003218
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003218,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001731 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001731; pubID: 10003218
bookid: 10001731; pubID: 10003219
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003219,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001731 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001731; pubID: 10003219
bookid: 10001731; pubID: 10003220
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003220,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001731 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001731; pubID: 10003220
bookid: 10001724; pubID: 10003221
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003221,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003221
bookid: 10001724; pubID: 10003222
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003222,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003222
bookid: 10001724; pubID: 10003223
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003223,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003223
bookid: 10001724; pubID: 10003224
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003224,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003224
bookid: 10001724; pubID: 10003225
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003225,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003225
bookid: 10001724; pubID: 10003226
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003226,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003226
bookid: 10001724; pubID: 10003227
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003227,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003227
bookid: 10001724; pubID: 10003228
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003228,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003228
bookid: 10001724; pubID: 10003229
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003229,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003229
bookid: 10001724; pubID: 10003230
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003230,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003230
bookid: 10001724; pubID: 10003231
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003231,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003231
bookid: 10001724; pubID: 10003232
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003232,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003232
bookid: 10001724; pubID: 10003233
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003233,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003233
bookid: 10001724; pubID: 10003234
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003234,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003234
bookid: 10001724; pubID: 10003235
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003235,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003235
bookid: 10001724; pubID: 10003236
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003236,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001724 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001724; pubID: 10003236
bookid: 10001308; pubID: 10003237
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003237,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001308 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001308; pubID: 10003237
bookid: 10001308; pubID: 10003238
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003238,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001308 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001308; pubID: 10003238
bookid: 10001308; pubID: 10003239
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003239,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001308 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001308; pubID: 10003239
bookid: 10001308; pubID: 10003240
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003240,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001308 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001308; pubID: 10003240
bookid: 10001308; pubID: 10003241
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003241,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001308 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001308; pubID: 10003241
bookid: 10001308; pubID: 10003242
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003242,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001308 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001308; pubID: 10003242
bookid: 10001308; pubID: 10003243
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003243,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001308 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001308; pubID: 10003243
bookid: 10001306; pubID: 10003244
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003244,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001306 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001306; pubID: 10003244
bookid: 10001306; pubID: 10003245
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003245,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001306 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001306; pubID: 10003245
bookid: 10001306; pubID: 10003246
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003246,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001306 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001306; pubID: 10003246
bookid: 10001306; pubID: 10003247
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003247,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001306 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001306; pubID: 10003247
bookid: 10001306; pubID: 10003248
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003248,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001306 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001306; pubID: 10003248
bookid: 10001306; pubID: 10003249
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003249,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001306 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001306; pubID: 10003249
bookid: 10001307; pubID: 10003250
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003250,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001307 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001307; pubID: 10003250
bookid: 10001307; pubID: 10003251
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003251,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001307 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001307; pubID: 10003251
bookid: 10001304; pubID: 10003252
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003252,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001304 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001304; pubID: 10003252
bookid: 10001304; pubID: 10003253
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003253,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001304 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001304; pubID: 10003253
bookid: 10001304; pubID: 10003254
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003254,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001304 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001304; pubID: 10003254
bookid: 10001304; pubID: 10003255
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003255,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001304 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001304; pubID: 10003255
bookid: 10001305; pubID: 10003256
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003256,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001305 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001305; pubID: 10003256
bookid: 10001305; pubID: 10003257
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003257,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001305 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001305; pubID: 10003257
bookid: 10001305; pubID: 10003258
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003258,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001305 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001305; pubID: 10003258
bookid: 10001305; pubID: 10003259
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003259,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001305 AND
		    AGENT_NAME_ID=10004703
goddammit MVZ: bookid: 10001305; pubID: 10003259
bookid: 10001310; pubID: 10003260
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003260,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001310 AND
		    AGENT_NAME_ID=10004715
goddammit MVZ: bookid: 10001310; pubID: 10003260
bookid: 10001310; pubID: 10003261
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003261,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001310 AND
		    AGENT_NAME_ID=10004715
goddammit MVZ: bookid: 10001310; pubID: 10003261
bookid: 10001302; pubID: 10003262
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003262,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001302 AND
		    AGENT_NAME_ID=10004550
goddammit MVZ: bookid: 10001302; pubID: 10003262
bookid: 10001295; pubID: 10003263
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003263,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001295 AND
		    AGENT_NAME_ID=10004135
goddammit MVZ: bookid: 10001295; pubID: 10003263
bookid: 10001294; pubID: 10003264
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003264,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001294 AND
		    AGENT_NAME_ID=10004135
goddammit MVZ: bookid: 10001294; pubID: 10003264
bookid: 10001370; pubID: 10003265
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003265,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001370 AND
		    AGENT_NAME_ID=10006315
goddammit MVZ: bookid: 10001370; pubID: 10003265
bookid: 10001369; pubID: 10003266
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003266,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001369 AND
		    AGENT_NAME_ID=10006315
goddammit MVZ: bookid: 10001369; pubID: 10003266
bookid: 10001369; pubID: 10003267
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003267,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001369 AND
		    AGENT_NAME_ID=10006315
goddammit MVZ: bookid: 10001369; pubID: 10003267
bookid: 10001369; pubID: 10003268
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003268,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001369 AND
		    AGENT_NAME_ID=10006315
goddammit MVZ: bookid: 10001369; pubID: 10003268
bookid: 10001369; pubID: 10003269
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003269,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001369 AND
		    AGENT_NAME_ID=10006315
goddammit MVZ: bookid: 10001369; pubID: 10003269
bookid: 10001350; pubID: 10003270
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003270,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001350 AND
		    AGENT_NAME_ID=10005392
bookid: 10001350; pubID: 10003271
npid:
bookid: 10001347; pubID: 10003272
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003272,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001347 AND
		    AGENT_NAME_ID=10005070
goddammit MVZ: bookid: 10001347; pubID: 10003272
bookid: 10001347; pubID: 10003273
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003273,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001347 AND
		    AGENT_NAME_ID=10005070
goddammit MVZ: bookid: 10001347; pubID: 10003273
bookid: 10001347; pubID: 10003274
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003274,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001347 AND
		    AGENT_NAME_ID=10005070
goddammit MVZ: bookid: 10001347; pubID: 10003274
bookid: 10001347; pubID: 10003275
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003275,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001347 AND
		    AGENT_NAME_ID=10005070
goddammit MVZ: bookid: 10001347; pubID: 10003275
bookid: 10001347; pubID: 10003276
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003276,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001347 AND
		    AGENT_NAME_ID=10005070
goddammit MVZ: bookid: 10001347; pubID: 10003276
bookid: 10001347; pubID: 10003277
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003277,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001347 AND
		    AGENT_NAME_ID=10005070
goddammit MVZ: bookid: 10001347; pubID: 10003277
bookid: 10001347; pubID: 10003278
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003278,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001347 AND
		    AGENT_NAME_ID=10005070
goddammit MVZ: bookid: 10001347; pubID: 10003278
bookid: 10001345; pubID: 10003279
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003279,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001345 AND
		    AGENT_NAME_ID=10005168
goddammit MVZ: bookid: 10001345; pubID: 10003279
bookid: 10001345; pubID: 10003280
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003280,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001345 AND
		    AGENT_NAME_ID=10005168
goddammit MVZ: bookid: 10001345; pubID: 10003280
bookid: 10001377; pubID: 10003281
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003281,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001377 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001377; pubID: 10003281
bookid: 10001377; pubID: 10003282
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003282,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001377 AND
		    AGENT_NAME_ID=10006388
bookid: 10001377; pubID: 10003283
npid:
bookid: 10001377; pubID: 10003284
npid:
bookid: 10001377; pubID: 10003285
npid:
bookid: 10001377; pubID: 10003286
npid:
bookid: 10001379; pubID: 10003287
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003287,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001379 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001379; pubID: 10003287
bookid: 10001379; pubID: 10003288
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003288,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001379 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001379; pubID: 10003288
bookid: 10001378; pubID: 10003289
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003289,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001378 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001378; pubID: 10003289
bookid: 10001378; pubID: 10003290
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003290,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001378 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001378; pubID: 10003290
bookid: 10001378; pubID: 10003291
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003291,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001378 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001378; pubID: 10003291
bookid: 10001378; pubID: 10003292
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003292,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001378 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001378; pubID: 10003292
bookid: 10001378; pubID: 10003293
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003293,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001378 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001378; pubID: 10003293
bookid: 10001378; pubID: 10003294
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003294,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001378 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001378; pubID: 10003294
bookid: 10001378; pubID: 10003295
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003295,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001378 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001378; pubID: 10003295
bookid: 10001380; pubID: 10003296
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003296,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001380 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001380; pubID: 10003296
bookid: 10001380; pubID: 10003297
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003297,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001380 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001380; pubID: 10003297
bookid: 10001380; pubID: 10003298
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003298,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001380 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001380; pubID: 10003298
bookid: 10001380; pubID: 10003299
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003299,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001380 AND
		    AGENT_NAME_ID=10006388
goddammit MVZ: bookid: 10001380; pubID: 10003299
bookid: 10003300; pubID: 10003301
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003301,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003301
bookid: 10003300; pubID: 10003302
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003302,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003302
bookid: 10003300; pubID: 10003303
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003303,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003303
bookid: 10003300; pubID: 10003304
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003304,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003304
bookid: 10003300; pubID: 10003305
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003305,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003305
bookid: 10003300; pubID: 10003306
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003306,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003306
bookid: 10003300; pubID: 10003307
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003307,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003307
bookid: 10003300; pubID: 10003308
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003308,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003308
bookid: 10003300; pubID: 10003309
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003309,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003309
bookid: 10003300; pubID: 10003310
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003310,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003310
bookid: 10003300; pubID: 10003311
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003311,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003311
bookid: 10003300; pubID: 10003312
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003312,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003312
bookid: 10003300; pubID: 10003313
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003313,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003300 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003300; pubID: 10003313
bookid: 10003314; pubID: 10003315
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003315,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003315
bookid: 10003314; pubID: 10003316
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003316,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003316
bookid: 10003314; pubID: 10003317
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003317,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003317
bookid: 10003314; pubID: 10003318
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003318,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003318
bookid: 10003314; pubID: 10003319
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003319,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003319
bookid: 10003314; pubID: 10003320
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003320,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003320
bookid: 10003314; pubID: 10003321
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003321,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003321
bookid: 10003314; pubID: 10003322
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003322,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003322
bookid: 10003314; pubID: 10003323
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003323,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003323
bookid: 10003314; pubID: 10003324
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003324,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003324
bookid: 10003314; pubID: 10003325
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003325,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003325
bookid: 10003314; pubID: 10003326
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003326,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003314 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003314; pubID: 10003326
bookid: 10003327; pubID: 10003328
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003328,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003327 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003327; pubID: 10003328
bookid: 10003327; pubID: 10003329
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003329,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003327 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003327; pubID: 10003329
bookid: 10003327; pubID: 10003330
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003330,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003327 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003327; pubID: 10003330
bookid: 10003327; pubID: 10003331
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003331,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003327 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003327; pubID: 10003331
bookid: 10003327; pubID: 10003332
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003332,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003327 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003327; pubID: 10003332
bookid: 10003327; pubID: 10003333
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003333,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003327 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003327; pubID: 10003333
bookid: 10003327; pubID: 10003334
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003334,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003327 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003327; pubID: 10003334
bookid: 10003327; pubID: 10003335
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003335,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003327 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003327; pubID: 10003335
bookid: 10003327; pubID: 10003336
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003336,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003327 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003327; pubID: 10003336
bookid: 10003327; pubID: 10003337
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003337,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003327 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003327; pubID: 10003337
bookid: 10001336; pubID: 10003338
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003338,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001336 AND
		    AGENT_NAME_ID=10005047
goddammit MVZ: bookid: 10001336; pubID: 10003338
bookid: 10001336; pubID: 10003339
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003339,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001336 AND
		    AGENT_NAME_ID=10005047
goddammit MVZ: bookid: 10001336; pubID: 10003339
bookid: 10001336; pubID: 10003340
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003340,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001336 AND
		    AGENT_NAME_ID=10005047
goddammit MVZ: bookid: 10001336; pubID: 10003340
bookid: 10001336; pubID: 10003341
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003341,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001336 AND
		    AGENT_NAME_ID=10005047
goddammit MVZ: bookid: 10001336; pubID: 10003341
bookid: 10001336; pubID: 10003342
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003342,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001336 AND
		    AGENT_NAME_ID=10005047
goddammit MVZ: bookid: 10001336; pubID: 10003342
bookid: 10001335; pubID: 10003343
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003343,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001335 AND
		    AGENT_NAME_ID=10005047
goddammit MVZ: bookid: 10001335; pubID: 10003343
bookid: 10001335; pubID: 10003344
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003344,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001335 AND
			    AGENT_NAME_ID=10005047
goddammit MVZ: bookid: 10001335; pubID: 10003344
bookid: 10001335; pubID: 10003345
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003345,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001335 AND
		    AGENT_NAME_ID=10005047
goddammit MVZ: bookid: 10001335; pubID: 10003345
bookid: 10001335; pubID: 10003346
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003346,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001335 AND
		    AGENT_NAME_ID=10005047
goddammit MVZ: bookid: 10001335; pubID: 10003346
bookid: 10001752; pubID: 10003347
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003347,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001752 AND
		    AGENT_NAME_ID=10004964
goddammit MVZ: bookid: 10001752; pubID: 10003347
bookid: 10001752; pubID: 10003348
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003348,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001752 AND
		    AGENT_NAME_ID=10004964
goddammit MVZ: bookid: 10001752; pubID: 10003348
bookid: 10001752; pubID: 10003349
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003349,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001752 AND
		    AGENT_NAME_ID=10004964
goddammit MVZ: bookid: 10001752; pubID: 10003349
bookid: 10003350; pubID: 10003351
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003351,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003350 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003350; pubID: 10003351
bookid: 10003350; pubID: 10003352
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003352,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003350 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003350; pubID: 10003352
bookid: 10003350; pubID: 10003353
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003353,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003350 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003350; pubID: 10003353
bookid: 10003350; pubID: 10003354
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003354,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003350 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003350; pubID: 10003354
bookid: 10003350; pubID: 10003355
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003355,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003350 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003350; pubID: 10003355
bookid: 10003350; pubID: 10003356
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003356,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003350 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003350; pubID: 10003356
bookid: 10003357; pubID: 10003358
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003358,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003357 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003357; pubID: 10003358
bookid: 10003357; pubID: 10003359
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003359,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003357 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003357; pubID: 10003359
bookid: 10003357; pubID: 10003360
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003360,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003357 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003357; pubID: 10003360
bookid: 10003357; pubID: 10003361
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003361,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003357 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003357; pubID: 10003361
bookid: 10003357; pubID: 10003362
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003362,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003357 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003357; pubID: 10003362
bookid: 10003357; pubID: 10003363
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003363,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003357 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003357; pubID: 10003363
bookid: 10003357; pubID: 10003364
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003364,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003357 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003357; pubID: 10003364
bookid: 10003365; pubID: 10003366
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003366,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003365 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003365; pubID: 10003366
bookid: 10003365; pubID: 10003367
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003367,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003365 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003365; pubID: 10003367
bookid: 10003365; pubID: 10003368
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003368,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003365 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003365; pubID: 10003368
bookid: 10003365; pubID: 10003369
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003369,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003365 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003365; pubID: 10003369
bookid: 10003365; pubID: 10003370
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003370,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003365 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003365; pubID: 10003370
bookid: 10003365; pubID: 10003371
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003371,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003365 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003365; pubID: 10003371
bookid: 10003365; pubID: 10003372
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003372,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003365 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003365; pubID: 10003372
bookid: 10003373; pubID: 10003374
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003374,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003373 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003373; pubID: 10003374
bookid: 10003373; pubID: 10003375
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003375,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003373 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003373; pubID: 10003375
bookid: 10003373; pubID: 10003376
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003376,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003373 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003373; pubID: 10003376
bookid: 10003373; pubID: 10003377
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003377,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003373 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003373; pubID: 10003377
bookid: 10003373; pubID: 10003378
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003378,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003373 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003373; pubID: 10003378
bookid: 10003373; pubID: 10003379
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003379,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003373 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003373; pubID: 10003379
bookid: 10001312; pubID: 10003380
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003380,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001312 AND
		    AGENT_NAME_ID=10004964
goddammit MVZ: bookid: 10001312; pubID: 10003380
bookid: 10003381; pubID: 10003382
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003382,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003382
bookid: 10003381; pubID: 10003383
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003383,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003383
bookid: 10003381; pubID: 10003384
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003384,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003384
bookid: 10003381; pubID: 10003385
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003385,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003385
bookid: 10003381; pubID: 10003386
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003386,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003386
bookid: 10003381; pubID: 10003387
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003387,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003387
bookid: 10003381; pubID: 10003388
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003388,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003388
bookid: 10003381; pubID: 10003389
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003389,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003389
bookid: 10003381; pubID: 10003390
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003390,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003390
bookid: 10003381; pubID: 10003391
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003391,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003391
bookid: 10003381; pubID: 10003392
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003392,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003392
bookid: 10003381; pubID: 10003393
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003393,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003393
bookid: 10003381; pubID: 10003394
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003394,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003381 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003381; pubID: 10003394
bookid: 10003395; pubID: 10003396
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003396,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003395 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003395; pubID: 10003396
bookid: 10003395; pubID: 10003397
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003397,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003395 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003395; pubID: 10003397
bookid: 10003395; pubID: 10003398
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003398,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003395 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003395; pubID: 10003398
bookid: 10003395; pubID: 10003399
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003399,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003395 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003395; pubID: 10003399
bookid: 10003395; pubID: 10003400
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003400,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003395 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003395; pubID: 10003400
bookid: 10003395; pubID: 10003401
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003401,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003395 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003395; pubID: 10003401
bookid: 10003395; pubID: 10003402
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003402,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003395 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003395; pubID: 10003402
bookid: 10003395; pubID: 10003403
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003403,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003395 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003395; pubID: 10003403
bookid: 10003395; pubID: 10003404
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003404,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003395 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003395; pubID: 10003404
bookid: 10003395; pubID: 10003405
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003405,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003395 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003395; pubID: 10003405
bookid: 10001355; pubID: 10003406
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003406,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001355 AND
		    AGENT_NAME_ID=10005619
goddammit MVZ: bookid: 10001355; pubID: 10003406
bookid: 10001354; pubID: 10003407
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003407,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001354 AND
		    AGENT_NAME_ID=10005571
goddammit MVZ: bookid: 10001354; pubID: 10003407
bookid: 10001354; pubID: 10003408
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003408,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001354 AND
		    AGENT_NAME_ID=10005571
goddammit MVZ: bookid: 10001354; pubID: 10003408
bookid: 10001354; pubID: 10003409
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003409,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001354 AND
		    AGENT_NAME_ID=10005571
goddammit MVZ: bookid: 10001354; pubID: 10003409
bookid: 10001354; pubID: 10003410
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003410,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001354 AND
		    AGENT_NAME_ID=10005571
goddammit MVZ: bookid: 10001354; pubID: 10003410
bookid: 10001354; pubID: 10003411
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003411,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001354 AND
		    AGENT_NAME_ID=10005571
goddammit MVZ: bookid: 10001354; pubID: 10003411
bookid: 10001344; pubID: 10003412
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003412,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001344 AND
		    AGENT_NAME_ID=10005139
goddammit MVZ: bookid: 10001344; pubID: 10003412
bookid: 10001344; pubID: 10003413
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003413,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001344 AND
		    AGENT_NAME_ID=10005139
goddammit MVZ: bookid: 10001344; pubID: 10003413
bookid: 10001344; pubID: 10003414
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003414,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001344 AND
		    AGENT_NAME_ID=10005139
goddammit MVZ: bookid: 10001344; pubID: 10003414
bookid: 10001344; pubID: 10003415
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003415,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001344 AND
		    AGENT_NAME_ID=10005139
goddammit MVZ: bookid: 10001344; pubID: 10003415
bookid: 10001344; pubID: 10003416
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003416,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001344 AND
		    AGENT_NAME_ID=10005139
goddammit MVZ: bookid: 10001344; pubID: 10003416
bookid: 10001344; pubID: 10003417
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003417,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001344 AND
		    AGENT_NAME_ID=10005139
goddammit MVZ: bookid: 10001344; pubID: 10003417
bookid: 10001344; pubID: 10003418
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003418,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001344 AND
		    AGENT_NAME_ID=10005139
goddammit MVZ: bookid: 10001344; pubID: 10003418
bookid: 10001344; pubID: 10003419
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003419,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001344 AND
		    AGENT_NAME_ID=10005139
goddammit MVZ: bookid: 10001344; pubID: 10003419
bookid: 10001344; pubID: 10003420
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003420,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001344 AND
		    AGENT_NAME_ID=10005139
goddammit MVZ: bookid: 10001344; pubID: 10003420
bookid: 10001334; pubID: 10003421
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003421,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001334 AND
		    AGENT_NAME_ID=1014117
goddammit MVZ: bookid: 10001334; pubID: 10003421
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003421,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001334 AND
		    AGENT_NAME_ID=10005045
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003421,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001334 AND
		    AGENT_NAME_ID=10014133
bookid: 10001334; pubID: 10003422
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003422,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001334 AND
		    AGENT_NAME_ID=1014117
goddammit MVZ: bookid: 10001334; pubID: 10003422
bookid: 10001334; pubID: 10003423
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003423,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001334 AND
		    AGENT_NAME_ID=1014117
goddammit MVZ: bookid: 10001334; pubID: 10003423
bookid: 10001334; pubID: 10003424
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003424,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001334 AND
		    AGENT_NAME_ID=1014117
goddammit MVZ: bookid: 10001334; pubID: 10003424
bookid: 10001334; pubID: 10003425
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003425,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001334 AND
		    AGENT_NAME_ID=1014117
bookid: 10001334; pubID: 10003426
npid:
bookid: 10001591; pubID: 10003427
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003427,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001591 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001591; pubID: 10003427
bookid: 10001591; pubID: 10003428
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003428,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001591 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001591; pubID: 10003428
bookid: 10001591; pubID: 10003429
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003429,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001591 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001591; pubID: 10003429
bookid: 10001591; pubID: 10003430
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003430,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001591 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001591; pubID: 10003430
bookid: 10001588; pubID: 10003431
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003431,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001588 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001588; pubID: 10003431
bookid: 10001586; pubID: 10003432
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003432,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001586 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001586; pubID: 10003432
bookid: 10001586; pubID: 10003433
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003433,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001586 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001586; pubID: 10003433
bookid: 10001586; pubID: 10003434
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003434,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001586 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001586; pubID: 10003434
bookid: 10001586; pubID: 10003435
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003435,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001586 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001586; pubID: 10003435
bookid: 10001586; pubID: 10003436
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003436,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001586 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001586; pubID: 10003436
bookid: 10001586; pubID: 10003437
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003437,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001586 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001586; pubID: 10003437
bookid: 10001586; pubID: 10003438
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003438,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001586 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001586; pubID: 10003438
bookid: 10001586; pubID: 10003439
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003439,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001586 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001586; pubID: 10003439
bookid: 10001586; pubID: 10003440
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003440,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001586 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001586; pubID: 10003440
bookid: 10001586; pubID: 10003441
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003441,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001586 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001586; pubID: 10003441
bookid: 10001587; pubID: 10003442
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003442,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001587 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001587; pubID: 10003442
bookid: 10001585; pubID: 10003443
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003443,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001585 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001585; pubID: 10003443
bookid: 10001585; pubID: 10003444
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003444,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001585 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001585; pubID: 10003444
bookid: 10001585; pubID: 10003445
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003445,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001585 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001585; pubID: 10003445
bookid: 10001585; pubID: 10003446
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003446,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001585 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001585; pubID: 10003446
bookid: 10001584; pubID: 10003447
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003447,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001584 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001584; pubID: 10003447
bookid: 10001584; pubID: 10003448
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003448,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001584 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001584; pubID: 10003448
bookid: 10001584; pubID: 10003449
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003449,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001584 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001584; pubID: 10003449
bookid: 10001584; pubID: 10003450
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003450,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001584 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001584; pubID: 10003450
bookid: 10001584; pubID: 10003451
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003451,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001584 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001584; pubID: 10003451
bookid: 10001584; pubID: 10003452
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003452,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001584 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001584; pubID: 10003452
bookid: 10001594; pubID: 10003453
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003453,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001594 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001594; pubID: 10003453
bookid: 10001594; pubID: 10003454
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003454,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001594 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001594; pubID: 10003454
bookid: 10001594; pubID: 10003455
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003455,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001594 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001594; pubID: 10003455
bookid: 10001592; pubID: 10003456
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003456,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001592 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001592; pubID: 10003456
bookid: 10001592; pubID: 10003457
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003457,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001592 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001592; pubID: 10003457
bookid: 10001592; pubID: 10003458
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003458,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001592 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001592; pubID: 10003458
bookid: 10001592; pubID: 10003459
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003459,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001592 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001592; pubID: 10003459
bookid: 10001592; pubID: 10003460
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003460,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001592 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001592; pubID: 10003460
bookid: 10001593; pubID: 10003461
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003461,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001593 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001593; pubID: 10003461
bookid: 10001593; pubID: 10003462
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003462,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001593 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001593; pubID: 10003462
bookid: 10001593; pubID: 10003463
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003463,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001593 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001593; pubID: 10003463
bookid: 10001593; pubID: 10003464
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003464,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001593 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001593; pubID: 10003464
bookid: 10001593; pubID: 10003465
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003465,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001593 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001593; pubID: 10003465
bookid: 10001593; pubID: 10003466
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003466,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001593 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001593; pubID: 10003466
bookid: 10001593; pubID: 10003467
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003467,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001593 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001593; pubID: 10003467
bookid: 10001590; pubID: 10003468
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003468,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001590 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001590; pubID: 10003468
bookid: 10001590; pubID: 10003469
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003469,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001590 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10001590; pubID: 10003469
bookid: 10001462; pubID: 10003470
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003470,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001462 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001462; pubID: 10003470
bookid: 10001462; pubID: 10003471
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003471,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001462 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001462; pubID: 10003471
bookid: 10001462; pubID: 10003472
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003472,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001462 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001462; pubID: 10003472
bookid: 10001462; pubID: 10003473
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003473,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001462 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001462; pubID: 10003473
bookid: 10001462; pubID: 10003474
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003474,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001462 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001462; pubID: 10003474
bookid: 10001462; pubID: 10003475
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003475,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001462 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001462; pubID: 10003475
bookid: 10001462; pubID: 10003476
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003476,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001462 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001462; pubID: 10003476
bookid: 10001462; pubID: 10003477
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003477,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001462 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001462; pubID: 10003477
bookid: 10001461; pubID: 10003478
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003478,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001461 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001461; pubID: 10003478
bookid: 10001461; pubID: 10003479
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003479,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001461 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001461; pubID: 10003479
bookid: 10001461; pubID: 10003480
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003480,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001461 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001461; pubID: 10003480
bookid: 10001461; pubID: 10003481
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003481,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001461 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001461; pubID: 10003481
bookid: 10001461; pubID: 10003482
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003482,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001461 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001461; pubID: 10003482
bookid: 10001461; pubID: 10003483
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003483,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001461 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001461; pubID: 10003483
bookid: 10001460; pubID: 10003484
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003484,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001460 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001460; pubID: 10003484
bookid: 10001460; pubID: 10003485
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003485,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001460 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001460; pubID: 10003485
bookid: 10001460; pubID: 10003486
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003486,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001460 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001460; pubID: 10003486
bookid: 10001460; pubID: 10003487
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003487,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001460 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001460; pubID: 10003487
bookid: 10001460; pubID: 10003488
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003488,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001460 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001460; pubID: 10003488
bookid: 10001459; pubID: 10003489
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003489,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001459 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001459; pubID: 10003489
bookid: 10001459; pubID: 10003490
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003490,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001459 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001459; pubID: 10003490
bookid: 10001459; pubID: 10003491
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003491,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001459 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001459; pubID: 10003491
bookid: 10001465; pubID: 10003492
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003492,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001465 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001465; pubID: 10003492
bookid: 10001464; pubID: 10003493
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003493,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001464 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001464; pubID: 10003493
bookid: 10001464; pubID: 10003494
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003494,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001464 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001464; pubID: 10003494
bookid: 10001464; pubID: 10003495
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003495,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001464 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001464; pubID: 10003495
bookid: 10001464; pubID: 10003496
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003496,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001464 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001464; pubID: 10003496
bookid: 10001464; pubID: 10003497
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003497,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001464 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001464; pubID: 10003497
bookid: 10001463; pubID: 10003498
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003498,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001463 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001463; pubID: 10003498
bookid: 10001463; pubID: 10003499
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003499,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001463 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001463; pubID: 10003499
bookid: 10001463; pubID: 10003500
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003500,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001463 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10001463; pubID: 10003500
bookid: 10001475; pubID: 10003501
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003501,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001475 AND
		    AGENT_NAME_ID=10007836
goddammit MVZ: bookid: 10001475; pubID: 10003501
bookid: 10001475; pubID: 10003502
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003502,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001475 AND
		    AGENT_NAME_ID=10007836
goddammit MVZ: bookid: 10001475; pubID: 10003502
bookid: 10001475; pubID: 10003503
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003503,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001475 AND
		    AGENT_NAME_ID=10007836
goddammit MVZ: bookid: 10001475; pubID: 10003503
bookid: 10001468; pubID: 10003504
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003504,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001468 AND
		    AGENT_NAME_ID=10007660
goddammit MVZ: bookid: 10001468; pubID: 10003504
bookid: 10001468; pubID: 10003505
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003505,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001468 AND
		    AGENT_NAME_ID=10007660
goddammit MVZ: bookid: 10001468; pubID: 10003505
bookid: 10001468; pubID: 10003506
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003506,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001468 AND
		    AGENT_NAME_ID=10007660
goddammit MVZ: bookid: 10001468; pubID: 10003506
bookid: 10001521; pubID: 10003507
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003507,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001521 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001521; pubID: 10003507
bookid: 10001521; pubID: 10003508
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003508,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001521 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001521; pubID: 10003508
bookid: 10001521; pubID: 10003509
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003509,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001521 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001521; pubID: 10003509
bookid: 10001521; pubID: 10003510
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003510,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001521 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001521; pubID: 10003510
bookid: 10001521; pubID: 10003511
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003511,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001521 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001521; pubID: 10003511
bookid: 10001520; pubID: 10003512
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003512,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001520 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001520; pubID: 10003512
bookid: 10001520; pubID: 10003513
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003513,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001520 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001520; pubID: 10003513
bookid: 10001520; pubID: 10003514
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003514,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001520 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001520; pubID: 10003514
bookid: 10001520; pubID: 10003515
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003515,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001520 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001520; pubID: 10003515
bookid: 10001519; pubID: 10003516
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003516,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001519 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001519; pubID: 10003516
bookid: 10001519; pubID: 10003517
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003517,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001519 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001519; pubID: 10003517
bookid: 10001523; pubID: 10003518
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003518,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003518
bookid: 10001523; pubID: 10003519
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003519,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003519
bookid: 10001523; pubID: 10003520
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003520,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003520
bookid: 10001523; pubID: 10003521
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003521,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003521
bookid: 10001523; pubID: 10003522
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003522,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003522
bookid: 10001523; pubID: 10003523
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003523,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003523
bookid: 10001523; pubID: 10003524
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003524,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003524
bookid: 10001523; pubID: 10003525
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003525,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003525
bookid: 10001523; pubID: 10003526
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003526,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003526
bookid: 10001523; pubID: 10003527
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003527,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003527
bookid: 10001523; pubID: 10003528
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003528,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001523 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001523; pubID: 10003528
bookid: 10001522; pubID: 10003529
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003529,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001522 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001522; pubID: 10003529
bookid: 10001522; pubID: 10003530
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003530,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001522 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001522; pubID: 10003530
bookid: 10001522; pubID: 10003531
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003531,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001522 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001522; pubID: 10003531
bookid: 10001522; pubID: 10003532
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003532,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001522 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001522; pubID: 10003532
bookid: 10001522; pubID: 10003533
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003533,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001522 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001522; pubID: 10003533
bookid: 10001522; pubID: 10003534
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003534,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001522 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001522; pubID: 10003534
bookid: 10001522; pubID: 10003535
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003535,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001522 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001522; pubID: 10003535
bookid: 10001522; pubID: 10003536
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003536,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001522 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001522; pubID: 10003536
bookid: 10001522; pubID: 10003537
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003537,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001522 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001522; pubID: 10003537
bookid: 10001522; pubID: 10003538
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003538,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001522 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001522; pubID: 10003538
bookid: 10001524; pubID: 10003539
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003539,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001524 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001524; pubID: 10003539
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003539,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001524 AND
		    AGENT_NAME_ID=10009211
bookid: 10001524; pubID: 10003540
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003540,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001524 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001524; pubID: 10003540
bookid: 10001524; pubID: 10003541
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003541,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001524 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001524; pubID: 10003541
bookid: 10001524; pubID: 10003542
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003542,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001524 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001524; pubID: 10003542
bookid: 10001524; pubID: 10003543
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003543,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001524 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001524; pubID: 10003543
bookid: 10001524; pubID: 10003544
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003544,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001524 AND
		    AGENT_NAME_ID=10008325
bookid: 10001526; pubID: 10003545
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003545,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001526 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001526; pubID: 10003545
bookid: 10001526; pubID: 10003546
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003546,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001526 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001526; pubID: 10003546
bookid: 10001526; pubID: 10003547
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003547,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001526 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001526; pubID: 10003547
bookid: 10001526; pubID: 10003549
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003549,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001526 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001526; pubID: 10003549
bookid: 10001526; pubID: 10003550
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003550,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001526 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001526; pubID: 10003550
bookid: 10001526; pubID: 10003551
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003551,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001526 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001526; pubID: 10003551
bookid: 10001527; pubID: 10003552
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003552,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001527 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001527; pubID: 10003552
bookid: 10001527; pubID: 10003553
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003553,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001527 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001527; pubID: 10003553
bookid: 10001527; pubID: 10003554
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003554,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001527 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001527; pubID: 10003554
bookid: 10001527; pubID: 10003555
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003555,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001527 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001527; pubID: 10003555
bookid: 10001527; pubID: 10003556
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003556,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001527 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001527; pubID: 10003556
bookid: 10001527; pubID: 10003557
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003557,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001527 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001527; pubID: 10003557
bookid: 10001527; pubID: 10003558
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003558,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001527 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001527; pubID: 10003558
bookid: 10001525; pubID: 10003559
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003559,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001525 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001525; pubID: 10003559
bookid: 10001525; pubID: 10003560
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003560,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001525 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001525; pubID: 10003560
bookid: 10001525; pubID: 10003561
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003561,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001525 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001525; pubID: 10003561
bookid: 10001525; pubID: 10003562
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003562,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001525 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001525; pubID: 10003562
bookid: 10001525; pubID: 10003563
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003563,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001525 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001525; pubID: 10003563
bookid: 10001525; pubID: 10003564
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003564,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001525 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001525; pubID: 10003564
bookid: 10001528; pubID: 10003565
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003565,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003565
bookid: 10001528; pubID: 10003566
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003566,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003566
bookid: 10001528; pubID: 10003567
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003567,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003567
bookid: 10001528; pubID: 10003568
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003568,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003568
bookid: 10001528; pubID: 10003569
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003569,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003569
bookid: 10001528; pubID: 10003570
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003570,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003570
bookid: 10001528; pubID: 10003571
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003571,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003571
bookid: 10001528; pubID: 10003572
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003572,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003572
bookid: 10001528; pubID: 10003573
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003573,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003573
bookid: 10001528; pubID: 10003574
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003574,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003574
bookid: 10001528; pubID: 10003575
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003575,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001528 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001528; pubID: 10003575
bookid: 10001554; pubID: 10003576
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003576,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001554 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001554; pubID: 10003576
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003576,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001554 AND
		    AGENT_NAME_ID=10011352
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003576,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001554 AND
		    AGENT_NAME_ID=10714447
bookid: 10001554; pubID: 10003577
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003577,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001554 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001554; pubID: 10003577
bookid: 10001553; pubID: 10003578
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003578,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001553 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001553; pubID: 10003578
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003578,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001553 AND
		    AGENT_NAME_ID=10011352
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003578,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001553 AND
		    AGENT_NAME_ID=10714447
bookid: 10001553; pubID: 10003579
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003579,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001553 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001553; pubID: 10003579
bookid: 10001552; pubID: 10003580
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003580,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001552 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001552; pubID: 10003580
bookid: 10001552; pubID: 10003581
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003581,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001552 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001552; pubID: 10003581
bookid: 10001552; pubID: 10003582
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003582,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001552 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001552; pubID: 10003582
bookid: 10001557; pubID: 10003583
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003583,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001557 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001557; pubID: 10003583
bookid: 10001557; pubID: 10003584
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003584,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001557 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001557; pubID: 10003584
bookid: 10001557; pubID: 10003585
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003585,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001557 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001557; pubID: 10003585
bookid: 10001557; pubID: 10003586
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003586,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001557 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001557; pubID: 10003586
bookid: 10001551; pubID: 10003587
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003587,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001551 AND
		    AGENT_NAME_ID=10003254
goddammit MVZ: bookid: 10001551; pubID: 10003587
bookid: 10001551; pubID: 10003588
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003588,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001551 AND
		    AGENT_NAME_ID=10003254
goddammit MVZ: bookid: 10001551; pubID: 10003588
bookid: 10001551; pubID: 10003589
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003589,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001551 AND
		    AGENT_NAME_ID=10003254
goddammit MVZ: bookid: 10001551; pubID: 10003589
bookid: 10001531; pubID: 10003590
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003590,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001531 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001531; pubID: 10003590
bookid: 10001531; pubID: 10003591
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003591,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001531 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001531; pubID: 10003591
bookid: 10001531; pubID: 10003592
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003592,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001531 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001531; pubID: 10003592
bookid: 10001531; pubID: 10003593
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003593,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001531 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001531; pubID: 10003593
bookid: 10001531; pubID: 10003594
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003594,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001531 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001531; pubID: 10003594
bookid: 10001531; pubID: 10003595
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003595,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001531 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001531; pubID: 10003595
bookid: 10001531; pubID: 10003596
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003596,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001531 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001531; pubID: 10003596
bookid: 10001531; pubID: 10003597
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003597,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001531 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001531; pubID: 10003597
bookid: 10001531; pubID: 10003598
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003598,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001531 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001531; pubID: 10003598
bookid: 10001529; pubID: 10003599
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003599,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001529 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001529; pubID: 10003599
bookid: 10001529; pubID: 10003600
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003600,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001529 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001529; pubID: 10003600
bookid: 10001529; pubID: 10003601
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003601,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001529 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001529; pubID: 10003601
bookid: 10001529; pubID: 10003602
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003602,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001529 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001529; pubID: 10003602
bookid: 10001529; pubID: 10003603
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003603,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001529 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001529; pubID: 10003603
bookid: 10001529; pubID: 10003604
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003604,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001529 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001529; pubID: 10003604
bookid: 10001529; pubID: 10003605
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003605,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001529 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001529; pubID: 10003605
bookid: 10001529; pubID: 10003606
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003606,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001529 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001529; pubID: 10003606
bookid: 10001529; pubID: 10003607
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003607,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001529 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001529; pubID: 10003607
bookid: 10001529; pubID: 10003608
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003608,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001529 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001529; pubID: 10003608
bookid: 10001530; pubID: 10003609
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003609,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003609
bookid: 10001530; pubID: 10003610
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003610,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003610
bookid: 10001530; pubID: 10003611
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003611,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003611
bookid: 10001530; pubID: 10003612
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003612,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003612
bookid: 10001530; pubID: 10003613
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003613,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003613
bookid: 10001530; pubID: 10003614
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003614,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003614
bookid: 10001530; pubID: 10003615
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003615,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003615
bookid: 10001530; pubID: 10003616
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003616,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003616
bookid: 10001530; pubID: 10003617
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003617,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003617
bookid: 10001530; pubID: 10003618
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003618,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003618
bookid: 10001530; pubID: 10003619
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003619,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003619
bookid: 10001530; pubID: 10003620
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003620,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001530 AND
		    AGENT_NAME_ID=10008325
goddammit MVZ: bookid: 10001530; pubID: 10003620
bookid: 10001583; pubID: 10003621
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003621,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001583 AND
		    AGENT_NAME_ID=10010420
goddammit MVZ: bookid: 10001583; pubID: 10003621
bookid: 10001583; pubID: 10003622
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003622,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001583 AND
		    AGENT_NAME_ID=10010420
goddammit MVZ: bookid: 10001583; pubID: 10003622
bookid: 10001583; pubID: 10003623
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003623,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001583 AND
		    AGENT_NAME_ID=10010420
goddammit MVZ: bookid: 10001583; pubID: 10003623
bookid: 10001583; pubID: 10003624
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003624,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001583 AND
		    AGENT_NAME_ID=10010420
goddammit MVZ: bookid: 10001583; pubID: 10003624
bookid: 10001583; pubID: 10003625
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003625,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001583 AND
		    AGENT_NAME_ID=10010420
goddammit MVZ: bookid: 10001583; pubID: 10003625
bookid: 10001556; pubID: 10003626
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003626,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001556 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001556; pubID: 10003626
bookid: 10001556; pubID: 10003627
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003627,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001556 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001556; pubID: 10003627
bookid: 10001556; pubID: 10003628
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003628,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001556 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001556; pubID: 10003628
bookid: 10001556; pubID: 10003629
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003629,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001556 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001556; pubID: 10003629
bookid: 10001556; pubID: 10003630
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003630,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001556 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001556; pubID: 10003630
bookid: 10001556; pubID: 10003631
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003631,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001556 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001556; pubID: 10003631
bookid: 10001555; pubID: 10003632
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003632,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001555 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001555; pubID: 10003632
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003632,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001555 AND
		    AGENT_NAME_ID=10714450
bookid: 10001555; pubID: 10003633
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003633,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001555 AND
		    AGENT_NAME_ID=10010034
goddammit MVZ: bookid: 10001555; pubID: 10003633
bookid: 10001539; pubID: 10003634
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003634,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001539 AND
		    AGENT_NAME_ID=10008333
goddammit MVZ: bookid: 10001539; pubID: 10003634
bookid: 10001539; pubID: 10003635
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003635,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001539 AND
		    AGENT_NAME_ID=10008333
goddammit MVZ: bookid: 10001539; pubID: 10003635
bookid: 10001539; pubID: 10003636
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003636,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001539 AND
		    AGENT_NAME_ID=10008333
goddammit MVZ: bookid: 10001539; pubID: 10003636
bookid: 10001539; pubID: 10003637
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003637,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001539 AND
		    AGENT_NAME_ID=10008333
goddammit MVZ: bookid: 10001539; pubID: 10003637
bookid: 10001600; pubID: 10003638
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003638,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001600 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001600; pubID: 10003638
bookid: 10001600; pubID: 10003639
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003639,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001600 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001600; pubID: 10003639
bookid: 10001600; pubID: 10003640
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003640,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001600 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001600; pubID: 10003640
bookid: 10001600; pubID: 10003641
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003641,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001600 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001600; pubID: 10003641
bookid: 10001600; pubID: 10003642
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003642,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001600 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001600; pubID: 10003642
bookid: 10001600; pubID: 10003643
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003643,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001600 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001600; pubID: 10003643
bookid: 10001600; pubID: 10003644
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003644,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001600 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001600; pubID: 10003644
bookid: 10001599; pubID: 10003645
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003645,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001599 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001599; pubID: 10003645
bookid: 10001599; pubID: 10003646
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003646,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001599 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001599; pubID: 10003646
bookid: 10001599; pubID: 10003647
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003647,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001599 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001599; pubID: 10003647
bookid: 10001599; pubID: 10003648
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003648,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001599 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001599; pubID: 10003648
bookid: 10001599; pubID: 10003649
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003649,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001599 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001599; pubID: 10003649
bookid: 10001599; pubID: 10003650
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003650,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001599 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001599; pubID: 10003650
bookid: 10001598; pubID: 10003651
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003651,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001598 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001598; pubID: 10003651
bookid: 10001598; pubID: 10003652
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003652,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001598 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001598; pubID: 10003652
bookid: 10001598; pubID: 10003653
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003653,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001598 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001598; pubID: 10003653
bookid: 10001598; pubID: 10003654
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003654,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001598 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001598; pubID: 10003654
bookid: 10001598; pubID: 10003655
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003655,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001598 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001598; pubID: 10003655
bookid: 10001597; pubID: 10003656
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003656,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001597 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001597; pubID: 10003656
bookid: 10001597; pubID: 10003657
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003657,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001597 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001597; pubID: 10003657
bookid: 10001597; pubID: 10003658
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003658,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001597 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001597; pubID: 10003658
bookid: 10001597; pubID: 10003659
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003659,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001597 AND
		    AGENT_NAME_ID=10010741
goddammit MVZ: bookid: 10001597; pubID: 10003659
bookid: 10001728; pubID: 10003660
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003660,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001728 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001728; pubID: 10003660
bookid: 10001729; pubID: 10003661
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003661,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001729 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001729; pubID: 10003661
bookid: 10001729; pubID: 10003662
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003662,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001729 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001729; pubID: 10003662
bookid: 10001729; pubID: 10003663
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003663,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001729 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001729; pubID: 10003663
bookid: 10001729; pubID: 10003664
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003664,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001729 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001729; pubID: 10003664
bookid: 10001729; pubID: 10003665
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003665,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001729 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001729; pubID: 10003665
bookid: 10001729; pubID: 10003666
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003666,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001729 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001729; pubID: 10003666
bookid: 10001723; pubID: 10003667
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003667,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001723 AND
		    AGENT_NAME_ID=10013323
goddammit MVZ: bookid: 10001723; pubID: 10003667
bookid: 10001723; pubID: 10003668
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003668,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001723 AND
		    AGENT_NAME_ID=10013323
goddammit MVZ: bookid: 10001723; pubID: 10003668
bookid: 10001723; pubID: 10003669
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003669,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001723 AND
		    AGENT_NAME_ID=10013323
goddammit MVZ: bookid: 10001723; pubID: 10003669
bookid: 10001723; pubID: 10003670
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003670,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001723 AND
		    AGENT_NAME_ID=10013323
goddammit MVZ: bookid: 10001723; pubID: 10003670
bookid: 10001723; pubID: 10003671
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003671,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001723 AND
		    AGENT_NAME_ID=10013323
goddammit MVZ: bookid: 10001723; pubID: 10003671
bookid: 10001733; pubID: 10003672
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003672,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001733 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001733; pubID: 10003672
bookid: 10001733; pubID: 10003673
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003673,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001733 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001733; pubID: 10003673
bookid: 10001733; pubID: 10003674
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003674,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001733 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001733; pubID: 10003674
bookid: 10001733; pubID: 10003675
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003675,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001733 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001733; pubID: 10003675
bookid: 10001733; pubID: 10003676
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003676,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001733 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001733; pubID: 10003676
bookid: 10001733; pubID: 10003677
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003677,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001733 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001733; pubID: 10003677
bookid: 10001733; pubID: 10003678
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003678,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001733 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001733; pubID: 10003678
bookid: 10001733; pubID: 10003679
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003679,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001733 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001733; pubID: 10003679
bookid: 10001733; pubID: 10003680
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003680,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001733 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001733; pubID: 10003680
bookid: 10001732; pubID: 10003681
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003681,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001732 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001732; pubID: 10003681
bookid: 10001732; pubID: 10003682
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003682,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001732 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001732; pubID: 10003682
bookid: 10001732; pubID: 10003683
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003683,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001732 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001732; pubID: 10003683
bookid: 10001546; pubID: 10003684
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003684,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001546 AND
		    AGENT_NAME_ID=10009995
goddammit MVZ: bookid: 10001546; pubID: 10003684
bookid: 10001548; pubID: 10003685
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003685,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001548 AND
		    AGENT_NAME_ID=10009995
goddammit MVZ: bookid: 10001548; pubID: 10003685
bookid: 10001547; pubID: 10003686
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003686,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001547 AND
		    AGENT_NAME_ID=10009995
goddammit MVZ: bookid: 10001547; pubID: 10003686
bookid: 10001550; pubID: 10003687
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003687,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001550 AND
		    AGENT_NAME_ID=10009995
goddammit MVZ: bookid: 10001550; pubID: 10003687
bookid: 10001543; pubID: 10003688
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003688,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001543 AND
		    AGENT_NAME_ID=10009995
goddammit MVZ: bookid: 10001543; pubID: 10003688
bookid: 10001542; pubID: 10003689
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003689,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001542 AND
		    AGENT_NAME_ID=10009995
goddammit MVZ: bookid: 10001542; pubID: 10003689
bookid: 10001544; pubID: 10003690
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003690,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001544 AND
		    AGENT_NAME_ID=10009995
goddammit MVZ: bookid: 10001544; pubID: 10003690
bookid: 10001549; pubID: 10003691
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003691,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001549 AND
		    AGENT_NAME_ID=10009995
goddammit MVZ: bookid: 10001549; pubID: 10003691
bookid: 10001545; pubID: 10003692
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003692,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001545 AND
		    AGENT_NAME_ID=10009995
goddammit MVZ: bookid: 10001545; pubID: 10003692
bookid: 10001728; pubID: 10003693
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003693,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001728 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001728; pubID: 10003693
bookid: 10001728; pubID: 10003694
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003694,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001728 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001728; pubID: 10003694
bookid: 10001728; pubID: 10003695
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003695,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001728 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001728; pubID: 10003695
bookid: 10001728; pubID: 10003696
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003696,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001728 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001728; pubID: 10003696
bookid: 10001441; pubID: 10003697
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003697,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003697
bookid: 10001441; pubID: 10003698
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003698,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003698
bookid: 10001441; pubID: 10003699
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003699,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003699
bookid: 10001441; pubID: 10003700
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003700,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003700
bookid: 10001441; pubID: 10003701
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003701,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003701
bookid: 10001441; pubID: 10003702
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003702,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003702
bookid: 10001441; pubID: 10003703
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003703,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003703
bookid: 10001441; pubID: 10003704
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003704,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003704
bookid: 10001441; pubID: 10003705
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003705,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003705
bookid: 10001441; pubID: 10003706
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003706,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003706
bookid: 10001441; pubID: 10003707
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003707,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001441 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001441; pubID: 10003707
bookid: 10001709; pubID: 10003999
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003999,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001709 AND
		    AGENT_NAME_ID=10012743
goddammit MVZ: bookid: 10001709; pubID: 10003999
bookid: 10001709; pubID: 10004000
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004000,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001709 AND
		    AGENT_NAME_ID=10012743
goddammit MVZ: bookid: 10001709; pubID: 10004000
bookid: 10001709; pubID: 10004001
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004001,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001709 AND
		    AGENT_NAME_ID=10012743
goddammit MVZ: bookid: 10001709; pubID: 10004001
bookid: 10001390; pubID: 10004002
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004002,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001390 AND
		    AGENT_NAME_ID=10006754
goddammit MVZ: bookid: 10001390; pubID: 10004002
bookid: 10001390; pubID: 10004003
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004003,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001390 AND
		    AGENT_NAME_ID=10006754
goddammit MVZ: bookid: 10001390; pubID: 10004003
bookid: 10001390; pubID: 10004004
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004004,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001390 AND
		    AGENT_NAME_ID=10006754
goddammit MVZ: bookid: 10001390; pubID: 10004004
bookid: 10001742; pubID: 10004005
npid: 7
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004005,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001742 AND
		    AGENT_NAME_ID=10001043
goddammit MVZ: bookid: 10001742; pubID: 10004005
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004005,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001742 AND
		    AGENT_NAME_ID=10001551
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004005,
		    AUTHOR_POSITION=8
		WHERE
		    publ
ication_id=10001742 AND
		    AGENT_NAME_ID=10003728
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004005,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10001742 AND
		    AGENT_NAME_ID=10007461
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004005,
		    AUTHOR_POSITION=10
		WHERE
		    pub
lication_id=10001742 AND
		    AGENT_NAME_ID=10007495
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004005,
		    AUTHOR_POSITION=11
		WHERE
		    pub
lication_id=10001742 AND
		    AGENT_NAME_ID=10013167
bookid: 10001742; pubID: 10004006
npid: 6
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004006,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001742 AND
		    AGENT_NAME_ID=10001043
bookid: 10001738; pubID: 10004007
npid: 10
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004007,
		    AUTHOR_POSITION=10
		WHERE
		    pub
lication_id=10001738 AND
		    AGENT_NAME_ID=10000648
goddammit MVZ: bookid: 10001738; pubID: 10004007
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004007,
		    AUTHOR_POSITION=10
		WHERE
		    pub
lication_id=10001738 AND
		    AGENT_NAME_ID=10001217
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004007,
		    AUTHOR_POSITION=11
		WHERE
		    pub
lication_id=10001738 AND
		    AGENT_NAME_ID=10002833
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004007,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001738 AND
		    AGENT_NAME_ID=10003298
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004007,
		    AUTHOR_POSITION=13
		WHERE
		    pub
lication_id=10001738 AND
		    AGENT_NAME_ID=10006853
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004007,
		    AUTHOR_POSITION=14
		WHERE
		    pub
lication_id=10001738 AND
		    AGENT_NAME_ID=10009276
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004007,
		    AUTHOR_POSITION=15
		WHERE
		    pub
lication_id=10001738 AND
		    AGENT_NAME_ID=10009618
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004007,
		    AUTHOR_POSITION=16
		WHERE
		    pub
lication_id=10001738 AND
		    AGENT_NAME_ID=10012267
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004007,
		    AUTHOR_POSITION=17
		WHERE
		    pub
lication_id=10001738 AND
		    AGENT_NAME_ID=10012375
bookid: 10001738; pubID: 10004008
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004008,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001738 AND
		    AGENT_NAME_ID=10000648
bookid: 10001738; pubID: 10004009
npid:
bookid: 10001738; pubID: 10004010
npid:
bookid: 10001738; pubID: 10004011
npid:
bookid: 10001738; pubID: 10004012
npid:
bookid: 10001738; pubID: 10004013
npid:
bookid: 10001738; pubID: 10004014
npid:
bookid: 10001738; pubID: 10004015
npid:
bookid: 10001738; pubID: 10004016
npid:
bookid: 10004017; pubID: 10004018
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004018,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004017 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10004017; pubID: 10004018
bookid: 10004019; pubID: 10004020
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004020,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004019 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004019; pubID: 10004020
bookid: 10004019; pubID: 10004021
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004021,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004019 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004019; pubID: 10004021
bookid: 10004019; pubID: 10004022
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004022,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004019 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004019; pubID: 10004022
bookid: 10004024; pubID: 10004025
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004025,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004024 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004024; pubID: 10004025
bookid: 10004024; pubID: 10004026
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004026,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004024 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004024; pubID: 10004026
bookid: 10004024; pubID: 10004027
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004027,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004024 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004024; pubID: 10004027
bookid: 10004024; pubID: 10004028
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004028,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004024 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004024; pubID: 10004028
bookid: 10004024; pubID: 10004029
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004029,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004024 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004024; pubID: 10004029
bookid: 10004024; pubID: 10004030
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004030,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004024 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004024; pubID: 10004030
bookid: 10004024; pubID: 10004031
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004031,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004024 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004024; pubID: 10004031
bookid: 10004024; pubID: 10004032
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004032,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004024 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004024; pubID: 10004032
bookid: 10004024; pubID: 10004033
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004033,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004024 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004024; pubID: 10004033
bookid: 10004034; pubID: 10004035
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004035,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004034 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004034; pubID: 10004035
bookid: 10004034; pubID: 10004036
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004036,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004034 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004034; pubID: 10004036
bookid: 10004034; pubID: 10004037
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004037,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004034 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004034; pubID: 10004037
bookid: 10004034; pubID: 10004038
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004038,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004034 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004034; pubID: 10004038
bookid: 10004034; pubID: 10004039
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004039,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004034 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004034; pubID: 10004039
bookid: 10004034; pubID: 10004040
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004040,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004034 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004034; pubID: 10004040
bookid: 10004041; pubID: 10004042
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004042,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004041 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004041; pubID: 10004042
bookid: 10004041; pubID: 10004043
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004043,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004041 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004041; pubID: 10004043
bookid: 10004044; pubID: 10004045
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004045,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004044 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004044; pubID: 10004045
bookid: 10004044; pubID: 10004046
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004046,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004044 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004044; pubID: 10004046
bookid: 10004044; pubID: 10004047
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004047,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004044 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004044; pubID: 10004047
bookid: 10004044; pubID: 10004048
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004048,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004044 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004044; pubID: 10004048
bookid: 10004044; pubID: 10004049
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004049,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004044 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004044; pubID: 10004049
bookid: 10004050; pubID: 10004051
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004051,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004050 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004050; pubID: 10004051
bookid: 10004050; pubID: 10004052
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004052,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004050 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004050; pubID: 10004052
bookid: 10004050; pubID: 10004053
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004053,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004050 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004050; pubID: 10004053
bookid: 10004050; pubID: 10004054
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004054,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004050 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004050; pubID: 10004054
bookid: 10004050; pubID: 10004055
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004055,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004050 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004050; pubID: 10004055
bookid: 10004050; pubID: 10004056
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004056,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004050 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004050; pubID: 10004056
bookid: 10004057; pubID: 10004058
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004058,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004057 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004057; pubID: 10004058
bookid: 10004057; pubID: 10004059
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004059,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004057 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004057; pubID: 10004059
bookid: 10004057; pubID: 10004060
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004060,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004057 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004057; pubID: 10004060
bookid: 10004057; pubID: 10004061
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004061,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004057 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004057; pubID: 10004061
bookid: 10004057; pubID: 10004062
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004062,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004057 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004057; pubID: 10004062
bookid: 10004057; pubID: 10004063
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004063,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004057 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004057; pubID: 10004063
bookid: 10004065; pubID: 10004066
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004066,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004065 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004065; pubID: 10004066
bookid: 10004065; pubID: 10004067
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004067,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004065 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004065; pubID: 10004067
bookid: 10004068; pubID: 10004069
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004069,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004068 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004068; pubID: 10004069
bookid: 10004070; pubID: 10004071
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004071,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004070 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004070; pubID: 10004071
bookid: 10004070; pubID: 10004072
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004072,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004070 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004070; pubID: 10004072
bookid: 10004073; pubID: 10004074
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004074,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004073 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004073; pubID: 10004074
bookid: 10004073; pubID: 10004075
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004075,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004073 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004073; pubID: 10004075
bookid: 10004073; pubID: 10004076
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004076,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004073 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004073; pubID: 10004076
bookid: 10004073; pubID: 10004077
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004077,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004073 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004073; pubID: 10004077
bookid: 10004073; pubID: 10004078
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004078,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004073 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004073; pubID: 10004078
bookid: 10004073; pubID: 10004079
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004079,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004073 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004073; pubID: 10004079
bookid: 10004073; pubID: 10004080
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004080,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004073 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004073; pubID: 10004080
bookid: 10004073; pubID: 10004081
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004081,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004073 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004073; pubID: 10004081
bookid: 10004082; pubID: 10004083
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004083,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004082 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004082; pubID: 10004083
bookid: 10004082; pubID: 10004084
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004084,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004082 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004082; pubID: 10004084
bookid: 10004082; pubID: 10004085
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004085,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004082 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004082; pubID: 10004085
bookid: 10004082; pubID: 10004086
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004086,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004082 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004082; pubID: 10004086
bookid: 10004082; pubID: 10004087
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004087,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004082 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004082; pubID: 10004087
bookid: 10004082; pubID: 10004088
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004088,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004082 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004082; pubID: 10004088
bookid: 10004089; pubID: 10004090
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004090,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004089 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004089; pubID: 10004090
bookid: 10004089; pubID: 10004091
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004091,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004089 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004089; pubID: 10004091
bookid: 10004089; pubID: 10004092
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004092,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004089 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004089; pubID: 10004092
bookid: 10004089; pubID: 10004093
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004093,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004089 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004089; pubID: 10004093
bookid: 10004089; pubID: 10004094
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004094,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004089 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004089; pubID: 10004094
bookid: 10004089; pubID: 10004095
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004095,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004089 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004089; pubID: 10004095
bookid: 10004089; pubID: 10004096
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004096,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004089 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004089; pubID: 10004096
bookid: 10004097; pubID: 10004098
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004098,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004097 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004097; pubID: 10004098
bookid: 10004099; pubID: 10004100
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004100,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004099 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004099; pubID: 10004100
bookid: 10004099; pubID: 10004101
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004101,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004099 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004099; pubID: 10004101
bookid: 10004102; pubID: 10004103
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004103,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004102 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004102; pubID: 10004103
bookid: 10004102; pubID: 10004104
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004104,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004102 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004102; pubID: 10004104
bookid: 10004105; pubID: 10004106
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004106,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004105 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004105; pubID: 10004106
bookid: 10004107; pubID: 10004108
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004108,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004107 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004107; pubID: 10004108
bookid: 10004107; pubID: 10004109
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004109,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004107 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004107; pubID: 10004109
bookid: 10004110; pubID: 10004111
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004111,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004110 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004110; pubID: 10004111
bookid: 10004110; pubID: 10004112
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004112,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004110 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004110; pubID: 10004112
bookid: 10004110; pubID: 10004113
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004113,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004110 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004110; pubID: 10004113
bookid: 10004110; pubID: 10004114
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004114,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004110 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004110; pubID: 10004114
bookid: 10004110; pubID: 10004115
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004115,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004110 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004110; pubID: 10004115
bookid: 10004116; pubID: 10004117
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004117,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004116 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004116; pubID: 10004117
bookid: 10004116; pubID: 10004118
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004118,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004116 AND
		    AGENT_NAME_ID=10009180
goddammit MVZ: bookid: 10004116; pubID: 10004118
bookid: 10001748; pubID: 10004119
npid: 7
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004119,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001748 AND
		    AGENT_NAME_ID=10005661
goddammit MVZ: bookid: 10001748; pubID: 10004119
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004119,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001748 AND
		    AGENT_NAME_ID=10006346
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004119,
		    AUTHOR_POSITION=8
		WHERE
		    publ
ication_id=10001748 AND
		    AGENT_NAME_ID=10008012
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004119,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10001748 AND
		    AGENT_NAME_ID=10009407
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004119,
		    AUTHOR_POSITION=10
		WHERE
		    pub
lication_id=10001748 AND
		    AGENT_NAME_ID=10012025
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004119,
		    AUTHOR_POSITION=11
		WHERE
		    pub
lication_id=10001748 AND
		    AGENT_NAME_ID=10013027
bookid: 10001748; pubID: 10004120
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004120,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001748 AND
		    AGENT_NAME_ID=10005661
bookid: 10001748; pubID: 10004121
npid:
bookid: 10001748; pubID: 10004122
npid:
bookid: 10001748; pubID: 10004123
npid:
bookid: 10001748; pubID: 10004124
npid:
bookid: 10000678; pubID: 10004125
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004125,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000678 AND
		    AGENT_NAME_ID=10004124
goddammit MVZ: bookid: 10000678; pubID: 10004125
bookid: 10000678; pubID: 10004126
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004126,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000678 AND
		    AGENT_NAME_ID=10004124
goddammit MVZ: bookid: 10000678; pubID: 10004126
bookid: 10000678; pubID: 10004127
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004127,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10000678 AND
		    AGENT_NAME_ID=10004124
goddammit MVZ: bookid: 10000678; pubID: 10004127
bookid: 10003373; pubID: 10004128
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004128,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003373 AND
		    AGENT_NAME_ID=10006376
goddammit MVZ: bookid: 10003373; pubID: 10004128
bookid: 10004142; pubID: 10004160
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004160,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004142 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10004142; pubID: 10004160
bookid: 10004142; pubID: 10004161
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004161,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004142 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10004142; pubID: 10004161
bookid: 10004142; pubID: 10004162
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004162,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004142 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10004142; pubID: 10004162
bookid: 10004142; pubID: 10004163
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004163,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004142 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10004142; pubID: 10004163
bookid: 10004142; pubID: 10004164
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004164,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004142 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10004142; pubID: 10004164
bookid: 10004141; pubID: 10004165
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004165,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004141 AND
		    AGENT_NAME_ID=10714332
goddammit MVZ: bookid: 10004141; pubID: 10004165
bookid: 10004157; pubID: 10004166
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004166,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004157 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10004157; pubID: 10004166
bookid: 10004157; pubID: 10004167
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004167,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004157 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10004157; pubID: 10004167
bookid: 10004157; pubID: 10004168
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004168,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004157 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10004157; pubID: 10004168
bookid: 10004157; pubID: 10004169
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004169,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004157 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10004157; pubID: 10004169
bookid: 10004157; pubID: 10004170
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004170,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004157 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10004157; pubID: 10004170
bookid: 10004157; pubID: 10004171
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004171,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004157 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10004157; pubID: 10004171
bookid: 10004157; pubID: 10004172
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004172,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004157 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10004157; pubID: 10004172
bookid: 10004158; pubID: 10004173
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004173,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004158 AND
		    AGENT_NAME_ID=10011348
goddammit MVZ: bookid: 10004158; pubID: 10004173
bookid: 10004158; pubID: 10004174
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004174,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004158 AND
		    AGENT_NAME_ID=10011348
bookid: 10004158; pubID: 10004175
npid:
bookid: 10004155; pubID: 10004176
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004176,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004155 AND
		    AGENT_NAME_ID=10011121
goddammit MVZ: bookid: 10004155; pubID: 10004176
bookid: 10004155; pubID: 10004177
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004177,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004155 AND
		    AGENT_NAME_ID=10011121
goddammit MVZ: bookid: 10004155; pubID: 10004177
bookid: 10004155; pubID: 10004178
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004178,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004155 AND
		    AGENT_NAME_ID=10011121
bookid: 10004155; pubID: 10004179
npid:
bookid: 10004155; pubID: 10004180
npid:
bookid: 10004155; pubID: 10004181
npid:
bookid: 10004155; pubID: 10004182
npid:
bookid: 10004154; pubID: 10004183
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004183,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004154 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10004154; pubID: 10004183
bookid: 10004154; pubID: 10004184
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004184,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004154 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10004154; pubID: 10004184
bookid: 10004154; pubID: 10004185
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004185,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004154 AND
		    AGENT_NAME_ID=10010450
goddammit MVZ: bookid: 10004154; pubID: 10004185
bookid: 10004153; pubID: 10004186
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004186,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004153 AND
		    AGENT_NAME_ID=10014094
goddammit MVZ: bookid: 10004153; pubID: 10004186
bookid: 10004151; pubID: 10004187
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004187,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004151 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10004151; pubID: 10004187
bookid: 10004151; pubID: 10004188
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004188,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004151 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10004151; pubID: 10004188
bookid: 10004151; pubID: 10004189
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004189,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004151 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10004151; pubID: 10004189
bookid: 10004151; pubID: 10004190
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004190,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004151 AND
		    AGENT_NAME_ID=10003242
bookid: 10004151; pubID: 10004191
npid:
bookid: 10004151; pubID: 10004192
npid:
bookid: 10004151; pubID: 10004193
npid:
bookid: 10004159; pubID: 10004196
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004196,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004159 AND
		    AGENT_NAME_ID=10012010
goddammit MVZ: bookid: 10004159; pubID: 10004196
bookid: 10004159; pubID: 10004197
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004197,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004159 AND
		    AGENT_NAME_ID=10012010
goddammit MVZ: bookid: 10004159; pubID: 10004197
bookid: 10004159; pubID: 10004198
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004198,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004159 AND
		    AGENT_NAME_ID=10012010
goddammit MVZ: bookid: 10004159; pubID: 10004198
bookid: 10004159; pubID: 10004199
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004199,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004159 AND
		    AGENT_NAME_ID=10012010
goddammit MVZ: bookid: 10004159; pubID: 10004199
bookid: 10004159; pubID: 10004200
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004200,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004159 AND
		    AGENT_NAME_ID=10012010
goddammit MVZ: bookid: 10004159; pubID: 10004200
bookid: 10004159; pubID: 10004201
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004201,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004159 AND
		    AGENT_NAME_ID=10012010
goddammit MVZ: bookid: 10004159; pubID: 10004201
bookid: 10004159; pubID: 10004202
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004202,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004159 AND
		    AGENT_NAME_ID=10012010
goddammit MVZ: bookid: 10004159; pubID: 10004202
bookid: 10004159; pubID: 10004203
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004203,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004159 AND
		    AGENT_NAME_ID=10012010
goddammit MVZ: bookid: 10004159; pubID: 10004203
bookid: 10004150; pubID: 10004204
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004204,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004150 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10004150; pubID: 10004204
bookid: 10004150; pubID: 10004205
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004205,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004150 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10004150; pubID: 10004205
bookid: 10004150; pubID: 10004206
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004206,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004150 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10004150; pubID: 10004206
bookid: 10004150; pubID: 10004207
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004207,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004150 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10004150; pubID: 10004207
bookid: 10004150; pubID: 10004208
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004208,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004150 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10004150; pubID: 10004208
bookid: 10004150; pubID: 10004209
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004209,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004150 AND
		    AGENT_NAME_ID=10003242
goddammit MVZ: bookid: 10004150; pubID: 10004209
bookid: 10004156; pubID: 10004210
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004210,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004156 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10004156; pubID: 10004210
bookid: 10004156; pubID: 10004211
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004211,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004156 AND
		    AGENT_NAME_ID=10011338
bookid: 10004156; pubID: 10004212
npid:
bookid: 10004156; pubID: 10004213
npid:
bookid: 10004156; pubID: 10004214
npid:
bookid: 10004215; pubID: 10004216
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004216,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004215 AND
		    AGENT_NAME_ID=10013799
goddammit MVZ: bookid: 10004215; pubID: 10004216
bookid: 10004215; pubID: 10004217
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004217,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004215 AND
		    AGENT_NAME_ID=10013799
goddammit MVZ: bookid: 10004215; pubID: 10004217
bookid: 10004215; pubID: 10004218
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004218,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004215 AND
		    AGENT_NAME_ID=10013799
goddammit MVZ: bookid: 10004215; pubID: 10004218
bookid: 10004145; pubID: 10004219
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004219,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004145 AND
		    AGENT_NAME_ID=10009155
goddammit MVZ: bookid: 10004145; pubID: 10004219
bookid: 10004145; pubID: 10004220
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004220,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004145 AND
		    AGENT_NAME_ID=10009155
goddammit MVZ: bookid: 10004145; pubID: 10004220
bookid: 10004145; pubID: 10004221
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004221,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004145 AND
		    AGENT_NAME_ID=10009155
goddammit MVZ: bookid: 10004145; pubID: 10004221
bookid: 10004145; pubID: 10004222
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004222,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004145 AND
		    AGENT_NAME_ID=10009155
goddammit MVZ: bookid: 10004145; pubID: 10004222
bookid: 10004145; pubID: 10004223
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004223,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004145 AND
		    AGENT_NAME_ID=10009155
goddammit MVZ: bookid: 10004145; pubID: 10004223
bookid: 10004145; pubID: 10004224
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004224,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004145 AND
		    AGENT_NAME_ID=10009155
goddammit MVZ: bookid: 10004145; pubID: 10004224
bookid: 10004143; pubID: 10004225
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004225,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004143 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10004143; pubID: 10004225
bookid: 10004143; pubID: 10004226
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004226,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004143 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10004143; pubID: 10004226
bookid: 10004143; pubID: 10004227
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004227,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004143 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10004143; pubID: 10004227
bookid: 10004143; pubID: 10004228
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004228,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004143 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10004143; pubID: 10004228
bookid: 10004143; pubID: 10004229
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004229,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004143 AND
		    AGENT_NAME_ID=10001905
goddammit MVZ: bookid: 10004143; pubID: 10004229
bookid: 10004141; pubID: 10004230
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004230,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004141 AND
		    AGENT_NAME_ID=10714332
goddammit MVZ: bookid: 10004141; pubID: 10004230
bookid: 10004141; pubID: 10004231
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004231,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004141 AND
		    AGENT_NAME_ID=10714332
goddammit MVZ: bookid: 10004141; pubID: 10004231
bookid: 10004141; pubID: 10004232
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004232,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004141 AND
		    AGENT_NAME_ID=10714332
goddammit MVZ: bookid: 10004141; pubID: 10004232
bookid: 10004140; pubID: 10004233
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004233,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004140 AND
		    AGENT_NAME_ID=10007558
goddammit MVZ: bookid: 10004140; pubID: 10004233
bookid: 10004140; pubID: 10004234
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004234,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004140 AND
		    AGENT_NAME_ID=10007558
goddammit MVZ: bookid: 10004140; pubID: 10004234
bookid: 10004140; pubID: 10004235
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004235,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004140 AND
		    AGENT_NAME_ID=10007558
goddammit MVZ: bookid: 10004140; pubID: 10004235
bookid: 10004140; pubID: 10004236
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004236,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004140 AND
		    AGENT_NAME_ID=10007558
goddammit MVZ: bookid: 10004140; pubID: 10004236
bookid: 10004139; pubID: 10004237
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004237,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004139 AND
		    AGENT_NAME_ID=10715730
goddammit MVZ: bookid: 10004139; pubID: 10004237
bookid: 10004137; pubID: 10004238
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004238,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004137 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10004137; pubID: 10004238
bookid: 10004136; pubID: 10004239
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004239,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004136 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10004136; pubID: 10004239
bookid: 10004138; pubID: 10004240
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004240,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004138 AND
		    AGENT_NAME_ID=10715399
goddammit MVZ: bookid: 10004138; pubID: 10004240
bookid: 10004138; pubID: 10004241
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004241,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004138 AND
		    AGENT_NAME_ID=10715399
goddammit MVZ: bookid: 10004138; pubID: 10004241
bookid: 10004138; pubID: 10004242
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004242,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004138 AND
		    AGENT_NAME_ID=10715399
goddammit MVZ: bookid: 10004138; pubID: 10004242
bookid: 10004138; pubID: 10004243
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004243,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004138 AND
		    AGENT_NAME_ID=10715399
goddammit MVZ: bookid: 10004138; pubID: 10004243
bookid: 10004134; pubID: 10004244
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004244,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004134 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10004134; pubID: 10004244
bookid: 10004135; pubID: 10004245
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004245,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004135 AND
		    AGENT_NAME_ID=10002360
goddammit MVZ: bookid: 10004135; pubID: 10004245
bookid: 10004130; pubID: 10004246
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004246,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004130 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10004130; pubID: 10004246
bookid: 10004130; pubID: 10004247
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004247,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004130 AND
		    AGENT_NAME_ID=10000251
bookid: 10004130; pubID: 10004248
npid:
bookid: 10004130; pubID: 10004249
npid:
bookid: 10004130; pubID: 10004250
npid:
bookid: 10004130; pubID: 10004251
npid:
bookid: 10004131; pubID: 10004252
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004252,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004131 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10004131; pubID: 10004252
bookid: 10004131; pubID: 10004253
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004253,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004131 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10004131; pubID: 10004253
bookid: 10004131; pubID: 10004254
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004254,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004131 AND
		    AGENT_NAME_ID=10000251
goddammit MVZ: bookid: 10004131; pubID: 10004254
bookid: 10004132; pubID: 10004255
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004255,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004132 AND
		    AGENT_NAME_ID=10002360
bookid: 10004132; pubID: 10004256
npid:
bookid: 10004132; pubID: 10004257
npid:
bookid: 10004132; pubID: 10004258
npid:
bookid: 10004133; pubID: 10004259
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004259,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004133 AND
		    AGENT_NAME_ID=10002360
bookid: 10004133; pubID: 10004260
npid:
bookid: 10004133; pubID: 10004261
npid:
bookid: 10004133; pubID: 10004262
npid:
bookid: 10004133; pubID: 10004263
npid:
bookid: 10004149; pubID: 10004264
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004264,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004149 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10004149; pubID: 10004264
bookid: 10004149; pubID: 10004265
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004265,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004149 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10004149; pubID: 10004265
bookid: 10004149; pubID: 10004266
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004266,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10004149 AND
		    AGENT_NAME_ID=10003750
goddammit MVZ: bookid: 10004149; pubID: 10004266
bookid: 10004156; pubID: 10004267
npid:
bookid: 10004156; pubID: 10004268
npid:
bookid: 10004156; pubID: 10004269
npid:
bookid: 10004156; pubID: 10004270
npid:
bookid: 10004156; pubID: 10004271
npid:
bookid: 10001446; pubID: 10004280
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004280,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001446 AND
		    AGENT_NAME_ID=10000922
bookid: 10001447; pubID: 10004281
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004281,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001447 AND
		    AGENT_NAME_ID=10000922
bookid: 10001448; pubID: 10004282
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004282,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001448 AND
		    AGENT_NAME_ID=10000922
bookid: 10001449; pubID: 10004283
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004283,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001449 AND
		    AGENT_NAME_ID=10000922
bookid: 10001450; pubID: 10004284
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004284,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001450 AND
		    AGENT_NAME_ID=10000922
bookid: 10004285; pubID: 10004286
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004286,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10004285 AND
		    AGENT_NAME_ID=10000224
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004286,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10004285 AND
		    AGENT_NAME_ID=10000225
bookid: 10004285; pubID: 10004287
npid:
bookid: 10004285; pubID: 10004288
npid:
bookid: 10004285; pubID: 10004289
npid:
bookid: 10000679; pubID: 10004290
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004290,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10000679 AND
		    AGENT_NAME_ID=10000224
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004290,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10000679 AND
		    AGENT_NAME_ID=10000225
bookid: 10004291; pubID: 10004292
npid:
bookid: 10001710; pubID: 10004293
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004293,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001710 AND
		    AGENT_NAME_ID=10003172
bookid: 10004294; pubID: 10004295
npid:
bookid: 10004294; pubID: 10004296
npid:
bookid: 10004294; pubID: 10004297
npid:
bookid: 10004294; pubID: 10004298
npid:
bookid: 10001457; pubID: 10004299
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004299,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001457 AND
		    AGENT_NAME_ID=10000922
bookid: 10001712; pubID: 10004300
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004300,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001712 AND
		    AGENT_NAME_ID=10003172
bookid: 10002026; pubID: 10004301
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004301,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10002026 AND
		    AGENT_NAME_ID=10000922
bookid: 10004506; pubID: 10004507
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004507,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10004506 AND
		    AGENT_NAME_ID=1100
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004507,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10004506 AND
		    AGENT_NAME_ID=1014128
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10004507,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10004506 AND
		    AGENT_NAME_ID=1015523
bookid: 10004506; pubID: 10004508
npid:
bookid: 10001376; pubID: 10002429
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002429,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001376 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001376; pubID: 10002429
bookid: 10001376; pubID: 10002430
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002430,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001376 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001376; pubID: 10002430
bookid: 10001376; pubID: 10002431
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002431,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001376 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001376; pubID: 10002431
bookid: 10001376; pubID: 10002432
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002432,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001376 AND
		    AGENT_NAME_ID=10000466
goddammit MVZ: bookid: 10001376; pubID: 10002432
bookid: 10001610; pubID: 10002433
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002433,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001610 AND
		    AGENT_NAME_ID=10010859
goddammit MVZ: bookid: 10001610; pubID: 10002433
bookid: 10001610; pubID: 10002434
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002434,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001610 AND
		    AGENT_NAME_ID=10010859
goddammit MVZ: bookid: 10001610; pubID: 10002434
bookid: 10001611; pubID: 10002435
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002435,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001611 AND
		    AGENT_NAME_ID=10010859
goddammit MVZ: bookid: 10001611; pubID: 10002435
bookid: 10001360; pubID: 10002436
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002436,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001360 AND
		    AGENT_NAME_ID=10005716
goddammit MVZ: bookid: 10001360; pubID: 10002436
bookid: 10001360; pubID: 10002437
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002437,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001360 AND
		    AGENT_NAME_ID=10005716
goddammit MVZ: bookid: 10001360; pubID: 10002437
bookid: 10001360; pubID: 10002438
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002438,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001360 AND
		    AGENT_NAME_ID=10005716
goddammit MVZ: bookid: 10001360; pubID: 10002438
bookid: 10001360; pubID: 10002439
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002439,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001360 AND
		    AGENT_NAME_ID=10005716
goddammit MVZ: bookid: 10001360; pubID: 10002439
bookid: 10001360; pubID: 10002440
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002440,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001360 AND
		    AGENT_NAME_ID=10005716
goddammit MVZ: bookid: 10001360; pubID: 10002440
bookid: 10001360; pubID: 10002441
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002441,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001360 AND
		    AGENT_NAME_ID=10005716
goddammit MVZ: bookid: 10001360; pubID: 10002441
bookid: 10001623; pubID: 10002442
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002442,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001623 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001623; pubID: 10002442
bookid: 10001623; pubID: 10002443
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002443,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001623 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001623; pubID: 10002443
bookid: 10001623; pubID: 10002444
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002444,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001623 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001623; pubID: 10002444
bookid: 10001623; pubID: 10002445
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002445,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001623 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001623; pubID: 10002445
bookid: 10001623; pubID: 10002446
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002446,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001623 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001623; pubID: 10002446
bookid: 10001623; pubID: 10002447
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002447,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001623 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001623; pubID: 10002447
bookid: 10001623; pubID: 10002448
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002448,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001623 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001623; pubID: 10002448
bookid: 10001624; pubID: 10002449
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002449,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002449
bookid: 10001624; pubID: 10002450
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002450,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002450
bookid: 10001624; pubID: 10002451
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002451,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002451
bookid: 10001624; pubID: 10002452
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002452,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002452
bookid: 10001624; pubID: 10002453
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002453,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002453
bookid: 10001624; pubID: 10002454
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002454,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002454
bookid: 10001624; pubID: 10002455
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002455,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002455
bookid: 10001624; pubID: 10002456
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002456,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002456
bookid: 10001624; pubID: 10002457
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002457,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002457
bookid: 10001624; pubID: 10002458
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002458,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002458
bookid: 10001624; pubID: 10002459
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002459,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002459
bookid: 10001624; pubID: 10002460
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002460,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001624 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001624; pubID: 10002460
bookid: 10001625; pubID: 10002465
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002465,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001625 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001625; pubID: 10002465
bookid: 10001625; pubID: 10002466
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002466,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001625 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001625; pubID: 10002466
bookid: 10001625; pubID: 10002467
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002467,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001625 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001625; pubID: 10002467
bookid: 10001625; pubID: 10002468
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002468,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001625 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001625; pubID: 10002468
bookid: 10001625; pubID: 10002469
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002469,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001625 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001625; pubID: 10002469
bookid: 10001625; pubID: 10002470
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002470,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001625 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001625; pubID: 10002470
bookid: 10001625; pubID: 10002471
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002471,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001625 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001625; pubID: 10002471
bookid: 10001625; pubID: 10002472
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002472,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001625 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001625; pubID: 10002472
bookid: 10001626; pubID: 10002473
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002473,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001626 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001626; pubID: 10002473
bookid: 10001486; pubID: 10002474
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002474,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002474
bookid: 10001486; pubID: 10002475
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002475,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002475
bookid: 10001486; pubID: 10002476
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002476,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002476
bookid: 10001486; pubID: 10002477
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002477,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002477
bookid: 10001486; pubID: 10002478
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002478,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002478
bookid: 10001486; pubID: 10002479
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002479,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002479
bookid: 10001486; pubID: 10002480
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002480,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002480
bookid: 10001486; pubID: 10002481
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002481,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002481
bookid: 10001486; pubID: 10002482
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002482,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002482
bookid: 10001486; pubID: 10002483
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002483,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002483
bookid: 10001486; pubID: 10002484
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002484,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002484
bookid: 10001486; pubID: 10002485
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002485,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002485
bookid: 10001486; pubID: 10002486
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002486,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002486
bookid: 10001486; pubID: 10002487
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002487,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002487
bookid: 10001486; pubID: 10002488
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002488,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002488
bookid: 10001486; pubID: 10002489
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002489,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001486 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001486; pubID: 10002489
bookid: 10001487; pubID: 10002490
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002490,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001487 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001487; pubID: 10002490
bookid: 10001487; pubID: 10002491
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002491,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001487 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001487; pubID: 10002491
bookid: 10001487; pubID: 10002492
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002492,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001487 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001487; pubID: 10002492
bookid: 10001487; pubID: 10002493
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002493,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001487 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001487; pubID: 10002493
bookid: 10001488; pubID: 10002494
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002494,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002494
bookid: 10001488; pubID: 10002495
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002495,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002495
bookid: 10001488; pubID: 10002496
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002496,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002496
bookid: 10001488; pubID: 10002497
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002497,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002497
bookid: 10001488; pubID: 10002498
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002498,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002498
bookid: 10001488; pubID: 10002499
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002499,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002499
bookid: 10001488; pubID: 10002500
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002500,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002500
bookid: 10001488; pubID: 10002501
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002501,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002501
bookid: 10001488; pubID: 10002502
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002502,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002502
bookid: 10001488; pubID: 10002503
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002503,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002503
bookid: 10001488; pubID: 10002504
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002504,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001488 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001488; pubID: 10002504
bookid: 10001493; pubID: 10002505
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002505,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001493 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001493; pubID: 10002505
bookid: 10001493; pubID: 10002506
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002506,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001493 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001493; pubID: 10002506
bookid: 10001493; pubID: 10002507
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002507,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001493 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001493; pubID: 10002507
bookid: 10001494; pubID: 10002508
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002508,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001494 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001494; pubID: 10002508
bookid: 10001494; pubID: 10002509
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002509,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001494 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001494; pubID: 10002509
bookid: 10001626; pubID: 10002510
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002510,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001626 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001626; pubID: 10002510
bookid: 10001626; pubID: 10002511
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002511,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001626 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001626; pubID: 10002511
bookid: 10001626; pubID: 10002512
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002512,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001626 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001626; pubID: 10002512
bookid: 10001626; pubID: 10002513
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002513,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001626 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001626; pubID: 10002513
bookid: 10001626; pubID: 10002514
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002514,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001626 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001626; pubID: 10002514
bookid: 10001626; pubID: 10002515
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002515,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001626 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001626; pubID: 10002515
bookid: 10001626; pubID: 10002516
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002516,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001626 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001626; pubID: 10002516
bookid: 10001626; pubID: 10002517
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002517,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001626 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001626; pubID: 10002517
bookid: 10001626; pubID: 10002518
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002518,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001626 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001626; pubID: 10002518
bookid: 10001627; pubID: 10002519
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002519,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001627 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001627; pubID: 10002519
bookid: 10001627; pubID: 10002520
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002520,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001627 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001627; pubID: 10002520
bookid: 10001627; pubID: 10002521
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002521,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001627 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001627; pubID: 10002521
bookid: 10001627; pubID: 10002522
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002522,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001627 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001627; pubID: 10002522
bookid: 10001627; pubID: 10002523
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002523,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001627 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001627; pubID: 10002523
bookid: 10001628; pubID: 10002524
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002524,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001628 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001628; pubID: 10002524
bookid: 10001628; pubID: 10002525
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002525,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001628 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001628; pubID: 10002525
bookid: 10001628; pubID: 10002526
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002526,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001628 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001628; pubID: 10002526
bookid: 10001628; pubID: 10002527
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002527,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001628 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001628; pubID: 10002527
bookid: 10001628; pubID: 10002528
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002528,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001628 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001628; pubID: 10002528
bookid: 10001628; pubID: 10002529
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002529,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001628 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001628; pubID: 10002529
bookid: 10001628; pubID: 10002530
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002530,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001628 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001628; pubID: 10002530
bookid: 10001628; pubID: 10002531
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002531,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001628 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001628; pubID: 10002531
bookid: 10001628; pubID: 10002532
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002532,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001628 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001628; pubID: 10002532
bookid: 10001628; pubID: 10002533
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002533,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001628 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001628; pubID: 10002533
bookid: 10001629; pubID: 10002534
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002534,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001629 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001629; pubID: 10002534
bookid: 10001630; pubID: 10002535
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002535,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001630 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001630; pubID: 10002535
bookid: 10001630; pubID: 10002536
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002536,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001630 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001630; pubID: 10002536
bookid: 10001632; pubID: 10002537
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002537,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001632 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001632; pubID: 10002537
bookid: 10001632; pubID: 10002538
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002538,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001632 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001632; pubID: 10002538
bookid: 10001631; pubID: 10002539
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002539,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001631 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001631; pubID: 10002539
bookid: 10001633; pubID: 10002540
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002540,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001633 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001633; pubID: 10002540
bookid: 10001634; pubID: 10002541
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002541,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001634 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001634; pubID: 10002541
bookid: 10001634; pubID: 10002542
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002542,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001634 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001634; pubID: 10002542
bookid: 10001634; pubID: 10002543
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002543,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001634 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001634; pubID: 10002543
bookid: 10001634; pubID: 10002544
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002544,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001634 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001634; pubID: 10002544
bookid: 10001634; pubID: 10002545
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002545,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001634 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001634; pubID: 10002545
bookid: 10001634; pubID: 10002546
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002546,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001634 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001634; pubID: 10002546
bookid: 10001635; pubID: 10002547
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002547,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001635 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001635; pubID: 10002547
bookid: 10001635; pubID: 10002548
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002548,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001635 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001635; pubID: 10002548
bookid: 10001635; pubID: 10002549
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002549,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001635 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001635; pubID: 10002549
bookid: 10001635; pubID: 10002550
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002550,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001635 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001635; pubID: 10002550
bookid: 10001635; pubID: 10002551
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002551,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001635 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001635; pubID: 10002551
bookid: 10001635; pubID: 10002552
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002552,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001635 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001635; pubID: 10002552
bookid: 10001636; pubID: 10002553
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002553,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001636 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001636; pubID: 10002553
bookid: 10001636; pubID: 10002554
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002554,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001636 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001636; pubID: 10002554
bookid: 10001636; pubID: 10002555
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002555,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001636 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001636; pubID: 10002555
bookid: 10001636; pubID: 10002556
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002556,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001636 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001636; pubID: 10002556
bookid: 10001636; pubID: 10002557
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002557,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001636 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001636; pubID: 10002557
bookid: 10001636; pubID: 10002558
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002558,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001636 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001636; pubID: 10002558
bookid: 10001637; pubID: 10002559
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002559,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001637 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001637; pubID: 10002559
bookid: 10001637; pubID: 10002560
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002560,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001637 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001637; pubID: 10002560
bookid: 10001637; pubID: 10002561
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002561,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001637 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001637; pubID: 10002561
bookid: 10001637; pubID: 10002562
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002562,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001637 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001637; pubID: 10002562
bookid: 10001637; pubID: 10002563
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002563,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001637 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001637; pubID: 10002563
bookid: 10001637; pubID: 10002564
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002564,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001637 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001637; pubID: 10002564
bookid: 10001638; pubID: 10002565
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002565,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001638 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001638; pubID: 10002565
bookid: 10001639; pubID: 10002566
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002566,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001639 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001639; pubID: 10002566
bookid: 10001489; pubID: 10002567
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002567,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002567
bookid: 10001489; pubID: 10002568
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002568,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002568
bookid: 10001489; pubID: 10002569
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002569,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002569
bookid: 10001489; pubID: 10002570
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002570,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002570
bookid: 10001489; pubID: 10002571
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002571,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002571
bookid: 10001489; pubID: 10002572
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002572,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002572
bookid: 10001489; pubID: 10002573
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002573,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002573
bookid: 10001489; pubID: 10002574
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002574,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002574
bookid: 10001489; pubID: 10002575
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002575,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002575
bookid: 10001489; pubID: 10002576
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002576,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002576
bookid: 10001489; pubID: 10002577
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002577,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001489 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001489; pubID: 10002577
bookid: 10001490; pubID: 10002578
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002578,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001490 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001490; pubID: 10002578
bookid: 10001490; pubID: 10002579
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002579,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001490 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001490; pubID: 10002579
bookid: 10001490; pubID: 10002580
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002580,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001490 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001490; pubID: 10002580
bookid: 10001490; pubID: 10002581
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002581,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001490 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001490; pubID: 10002581
bookid: 10001490; pubID: 10002582
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002582,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001490 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001490; pubID: 10002582
bookid: 10001490; pubID: 10002583
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002583,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001490 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001490; pubID: 10002583
bookid: 10001490; pubID: 10002584
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002584,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001490 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001490; pubID: 10002584
bookid: 10001491; pubID: 10002585
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002585,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001491 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001491; pubID: 10002585
bookid: 10001491; pubID: 10002586
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002586,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001491 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001491; pubID: 10002586
bookid: 10001491; pubID: 10002587
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002587,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001491 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001491; pubID: 10002587
bookid: 10001491; pubID: 10002588
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002588,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001491 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001491; pubID: 10002588
bookid: 10001491; pubID: 10002589
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002589,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001491 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001491; pubID: 10002589
bookid: 10001491; pubID: 10002590
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002590,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001491 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001491; pubID: 10002590
bookid: 10001491; pubID: 10002591
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002591,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001491 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001491; pubID: 10002591
bookid: 10001491; pubID: 10002592
npid: 2
UPDATE
		    publication_author_name
		SET
			    publicati
on_id=10002592,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001491 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001491; pubID: 10002592
bookid: 10001495; pubID: 10002593
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002593,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001495 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001495; pubID: 10002593
bookid: 10001495; pubID: 10002594
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002594,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001495 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001495; pubID: 10002594
bookid: 10001495; pubID: 10002595
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002595,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001495 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001495; pubID: 10002595
bookid: 10001495; pubID: 10002598
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002598,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001495 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001495; pubID: 10002598
bookid: 10001640; pubID: 10002599
npid: 8
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002599,
		    AUTHOR_POSITION=8
		WHERE
		    publ
ication_id=10001640 AND
		    AGENT_NAME_ID=10000480
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002599,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10001640 AND
		    AGENT_NAME_ID=10001686
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002599,
		    AUTHOR_POSITION=10
		WHERE
		    pub
lication_id=10001640 AND
		    AGENT_NAME_ID=10002756
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002599,
		    AUTHOR_POSITION=11
		WHERE
		    pub
lication_id=10001640 AND
		    AGENT_NAME_ID=10004324
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002599,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001640 AND
		    AGENT_NAME_ID=10006992
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002599,
		    AUTHOR_POSITION=13
		WHERE
		    pub
lication_id=10001640 AND
		    AGENT_NAME_ID=10008081
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002599,
		    AUTHOR_POSITION=14
		WHERE
		    pub
lication_id=10001640 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001640; pubID: 10002599
bookid: 10001640; pubID: 10002600
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002600,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001640 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001640; pubID: 10002600
bookid: 10001640; pubID: 10002601
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002601,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001640 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001640; pubID: 10002601
bookid: 10001640; pubID: 10002602
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002602,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001640 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001640; pubID: 10002602
bookid: 10001640; pubID: 10002603
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002603,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001640 AND
		    AGENT_NAME_ID=10011338
goddammit MVZ: bookid: 10001640; pubID: 10002603
bookid: 10001492; pubID: 10002604
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002604,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001492 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001492; pubID: 10002604
bookid: 10001492; pubID: 10002605
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002605,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001492 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001492; pubID: 10002605
bookid: 10001492; pubID: 10002606
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002606,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001492 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001492; pubID: 10002606
bookid: 10001492; pubID: 10002607
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002607,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001492 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001492; pubID: 10002607
bookid: 10001492; pubID: 10002608
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002608,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001492 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001492; pubID: 10002608
bookid: 10001492; pubID: 10002609
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002609,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001492 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001492; pubID: 10002609
bookid: 10001492; pubID: 10002610
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002610,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001492 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001492; pubID: 10002610
bookid: 10001492; pubID: 10002611
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002611,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001492 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001492; pubID: 10002611
bookid: 10001492; pubID: 10002612
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002612,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001492 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001492; pubID: 10002612
bookid: 10001496; pubID: 10002613
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002613,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001496 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001496; pubID: 10002613
bookid: 10001496; pubID: 10002614
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002614,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001496 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001496; pubID: 10002614
bookid: 10001496; pubID: 10002615
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002615,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001496 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001496; pubID: 10002615
bookid: 10001496; pubID: 10002616
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002616,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001496 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001496; pubID: 10002616
bookid: 10001496; pubID: 10002617
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002617,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001496 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001496; pubID: 10002617
bookid: 10001496; pubID: 10002618
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002618,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001496 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001496; pubID: 10002618
bookid: 10001498; pubID: 10002619
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002619,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001498 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001498; pubID: 10002619
bookid: 10001498; pubID: 10002620
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002620,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001498 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001498; pubID: 10002620
bookid: 10001498; pubID: 10002621
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002621,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001498 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001498; pubID: 10002621
bookid: 10001498; pubID: 10002622
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002622,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001498 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001498; pubID: 10002622
bookid: 10001498; pubID: 10002623
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002623,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001498 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001498; pubID: 10002623
bookid: 10001498; pubID: 10002624
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002624,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001498 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001498; pubID: 10002624
bookid: 10001497; pubID: 10002625
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002625,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001497 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001497; pubID: 10002625
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002625,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001497 AND
		    AGENT_NAME_ID=10009246
goddammit MVZ: bookid: 10001497; pubID: 10002625
bookid: 10001499; pubID: 10002626
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002626,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001499 AND
		    AGENT_NAME_ID=10000144
goddammit MVZ: bookid: 10001499; pubID: 10002626
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002626,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001499 AND
		    AGENT_NAME_ID=10000482
goddammit MVZ: bookid: 10001499; pubID: 10002626
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002626,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001499 AND
		    AGENT_NAME_ID=10007557
goddammit MVZ: bookid: 10001499; pubID: 10002626
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002626,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001499 AND
		    AGENT_NAME_ID=10008515
goddammit MVZ: bookid: 10001499; pubID: 10002626
bookid: 10001604; pubID: 10002627
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002627,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001604 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001604; pubID: 10002627
bookid: 10001604; pubID: 10002628
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002628,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001604 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001604; pubID: 10002628
bookid: 10001604; pubID: 10002629
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002629,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001604 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001604; pubID: 10002629
bookid: 10001605; pubID: 10002630
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002630,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001605 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001605; pubID: 10002630
bookid: 10001605; pubID: 10002631
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002631,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001605 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001605; pubID: 10002631
bookid: 10001605; pubID: 10002632
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002632,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001605 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001605; pubID: 10002632
bookid: 10001605; pubID: 10002633
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002633,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001605 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001605; pubID: 10002633
bookid: 10001608; pubID: 10002634
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002634,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001608 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001608; pubID: 10002634
bookid: 10001608; pubID: 10002635
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002635,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001608 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001608; pubID: 10002635
bookid: 10001608; pubID: 10002636
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002636,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001608 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001608; pubID: 10002636
bookid: 10001608; pubID: 10002637
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002637,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001608 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001608; pubID: 10002637
bookid: 10001608; pubID: 10002638
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002638,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001608 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001608; pubID: 10002638
bookid: 10001606; pubID: 10002639
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002639,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001606 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001606; pubID: 10002639
bookid: 10001606; pubID: 10002640
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002640,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001606 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001606; pubID: 10002640
bookid: 10001606; pubID: 10002641
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002641,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001606 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001606; pubID: 10002641
bookid: 10001606; pubID: 10002642
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002642,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001606 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001606; pubID: 10002642
bookid: 10001606; pubID: 10002643
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002643,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001606 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001606; pubID: 10002643
bookid: 10001606; pubID: 10002644
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002644,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001606 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001606; pubID: 10002644
bookid: 10001606; pubID: 10002645
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002645,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001606 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001606; pubID: 10002645
bookid: 10001606; pubID: 10002646
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10002646,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001606 AND
		    AGENT_NAME_ID=10006159
goddammit MVZ: bookid: 10001606; pubID: 10002646
bookid: 10001442; pubID: 10003727
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003727,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001442 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001442; pubID: 10003727
bookid: 10001442; pubID: 10003728
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003728,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001442 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001442; pubID: 10003728
bookid: 10001442; pubID: 10003729
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003729,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001442 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001442; pubID: 10003729
bookid: 10001442; pubID: 10003730
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003730,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001442 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001442; pubID: 10003730
bookid: 10001442; pubID: 10003731
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003731,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001442 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001442; pubID: 10003731
bookid: 10001442; pubID: 10003732
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003732,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001442 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001442; pubID: 10003732
bookid: 10001440; pubID: 10003733
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003733,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001440 AND
		    AGENT_NAME_ID=10007318
goddammit MVZ: bookid: 10001440; pubID: 10003733
bookid: 10001541; pubID: 10003734
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003734,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001541 AND
		    AGENT_NAME_ID=10009995
goddammit MVZ: bookid: 10001541; pubID: 10003734
bookid: 10001503; pubID: 10003735
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003735,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001503 AND
		    AGENT_NAME_ID=10008676
goddammit MVZ: bookid: 10001503; pubID: 10003735
bookid: 10001503; pubID: 10003736
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003736,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001503 AND
		    AGENT_NAME_ID=10008676
goddammit MVZ: bookid: 10001503; pubID: 10003736
bookid: 10001503; pubID: 10003737
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003737,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001503 AND
		    AGENT_NAME_ID=10008676
goddammit MVZ: bookid: 10001503; pubID: 10003737
bookid: 10001504; pubID: 10003738
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003738,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001504 AND
		    AGENT_NAME_ID=10008692
goddammit MVZ: bookid: 10001504; pubID: 10003738
bookid: 10001506; pubID: 10003739
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003739,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001506 AND
		    AGENT_NAME_ID=10008693
goddammit MVZ: bookid: 10001506; pubID: 10003739
bookid: 10001506; pubID: 10003740
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003740,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001506 AND
		    AGENT_NAME_ID=10008693
goddammit MVZ: bookid: 10001506; pubID: 10003740
bookid: 10001506; pubID: 10003741
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003741,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001506 AND
		    AGENT_NAME_ID=10008693
goddammit MVZ: bookid: 10001506; pubID: 10003741
bookid: 10001506; pubID: 10003742
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003742,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001506 AND
		    AGENT_NAME_ID=10008693
goddammit MVZ: bookid: 10001506; pubID: 10003742
bookid: 10001505; pubID: 10003743
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003743,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001505 AND
		    AGENT_NAME_ID=10008692
goddammit MVZ: bookid: 10001505; pubID: 10003743
bookid: 10001505; pubID: 10003744
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003744,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001505 AND
		    AGENT_NAME_ID=10008692
goddammit MVZ: bookid: 10001505; pubID: 10003744
bookid: 10001505; pubID: 10003745
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003745,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001505 AND
		    AGENT_NAME_ID=10008692
goddammit MVZ: bookid: 10001505; pubID: 10003745
bookid: 10001501; pubID: 10003746
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003746,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001501 AND
		    AGENT_NAME_ID=10008507
goddammit MVZ: bookid: 10001501; pubID: 10003746
bookid: 10001501; pubID: 10003747
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003747,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001501 AND
		    AGENT_NAME_ID=10008507
goddammit MVZ: bookid: 10001501; pubID: 10003747
bookid: 10001501; pubID: 10003748
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003748,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001501 AND
		    AGENT_NAME_ID=10008507
goddammit MVZ: bookid: 10001501; pubID: 10003748
bookid: 10001515; pubID: 10003749
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003749,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001515 AND
		    AGENT_NAME_ID=10009200
goddammit MVZ: bookid: 10001515; pubID: 10003749
bookid: 10001603; pubID: 10003750
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003750,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001603 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001603; pubID: 10003750
bookid: 10001603; pubID: 10003751
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003751,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001603 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001603; pubID: 10003751
bookid: 10001603; pubID: 10003752
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003752,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001603 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001603; pubID: 10003752
bookid: 10001601; pubID: 10003753
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003753,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001601 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001601; pubID: 10003753
bookid: 10001601; pubID: 10003754
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003754,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001601 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001601; pubID: 10003754
bookid: 10001601; pubID: 10003755
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003755,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001601 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001601; pubID: 10003755
bookid: 10001601; pubID: 10003756
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003756,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001601 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001601; pubID: 10003756
bookid: 10001602; pubID: 10003757
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003757,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001602 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001602; pubID: 10003757
bookid: 10001602; pubID: 10003758
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003758,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001602 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001602; pubID: 10003758
bookid: 10001602; pubID: 10003759
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003759,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001602 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001602; pubID: 10003759
bookid: 10001602; pubID: 10003760
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003760,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001602 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001602; pubID: 10003760
bookid: 10001602; pubID: 10003761
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003761,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001602 AND
		    AGENT_NAME_ID=10010753
goddammit MVZ: bookid: 10001602; pubID: 10003761
bookid: 10001704; pubID: 10003762
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003762,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001704 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001704; pubID: 10003762
bookid: 10001704; pubID: 10003763
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003763,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001704 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001704; pubID: 10003763
bookid: 10001704; pubID: 10003764
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003764,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001704 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001704; pubID: 10003764
bookid: 10001704; pubID: 10003765
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003765,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001704 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001704; pubID: 10003765
bookid: 10001704; pubID: 10003766
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003766,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001704 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001704; pubID: 10003766
bookid: 10001704; pubID: 10003767
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003767,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001704 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001704; pubID: 10003767
bookid: 10001704; pubID: 10003768
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003768,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001704 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001704; pubID: 10003768
bookid: 10001704; pubID: 10003769
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003769,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001704 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001704; pubID: 10003769
bookid: 10001704; pubID: 10003770
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003770,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001704 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001704; pubID: 10003770
bookid: 10001703; pubID: 10003771
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003771,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001703 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001703; pubID: 10003771
bookid: 10001703; pubID: 10003772
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003772,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001703 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001703; pubID: 10003772
bookid: 10001703; pubID: 10003773
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003773,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001703 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001703; pubID: 10003773
bookid: 10001703; pubID: 10003774
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003774,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001703 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001703; pubID: 10003774
bookid: 10001703; pubID: 10003775
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003775,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001703 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001703; pubID: 10003775
bookid: 10001703; pubID: 10003776
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003776,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001703 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001703; pubID: 10003776
bookid: 10001703; pubID: 10003777
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003777,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001703 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001703; pubID: 10003777
bookid: 10001703; pubID: 10003778
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003778,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001703 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001703; pubID: 10003778
bookid: 10001703; pubID: 10003779
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003779,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001703 AND
		    AGENT_NAME_ID=10011975
goddammit MVZ: bookid: 10001703; pubID: 10003779
bookid: 10001620; pubID: 10003780
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003780,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001620 AND
		    AGENT_NAME_ID=10011121
goddammit MVZ: bookid: 10001620; pubID: 10003780
bookid: 10001619; pubID: 10003781
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003781,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001619 AND
		    AGENT_NAME_ID=10011121
goddammit MVZ: bookid: 10001619; pubID: 10003781
bookid: 10001619; pubID: 10003782
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003782,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001619 AND
		    AGENT_NAME_ID=10011121
goddammit MVZ: bookid: 10001619; pubID: 10003782
bookid: 10001618; pubID: 10003783
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003783,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001618 AND
		    AGENT_NAME_ID=10011114
goddammit MVZ: bookid: 10001618; pubID: 10003783
bookid: 10001618; pubID: 10003784
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003784,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001618 AND
		    AGENT_NAME_ID=10011114
goddammit MVZ: bookid: 10001618; pubID: 10003784
bookid: 10001618; pubID: 10003785
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003785,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001618 AND
		    AGENT_NAME_ID=10011114
goddammit MVZ: bookid: 10001618; pubID: 10003785
bookid: 10001617; pubID: 10003786
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003786,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001617 AND
		    AGENT_NAME_ID=10011114
goddammit MVZ: bookid: 10001617; pubID: 10003786
bookid: 10001617; pubID: 10003787
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003787,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001617 AND
		    AGENT_NAME_ID=10011114
goddammit MVZ: bookid: 10001617; pubID: 10003787
bookid: 10001617; pubID: 10003788
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003788,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001617 AND
		    AGENT_NAME_ID=10011114
goddammit MVZ: bookid: 10001617; pubID: 10003788
bookid: 10001617; pubID: 10003789
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003789,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001617 AND
		    AGENT_NAME_ID=10011114
goddammit MVZ: bookid: 10001617; pubID: 10003789
bookid: 10001617; pubID: 10003790
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003790,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001617 AND
		    AGENT_NAME_ID=10011114
goddammit MVZ: bookid: 10001617; pubID: 10003790
bookid: 10001708; pubID: 10003791
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003791,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001708 AND
		    AGENT_NAME_ID=10012389
goddammit MVZ: bookid: 10001708; pubID: 10003791
bookid: 10001708; pubID: 10003792
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003792,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001708 AND
		    AGENT_NAME_ID=10012389
goddammit MVZ: bookid: 10001708; pubID: 10003792
bookid: 10001708; pubID: 10003793
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003793,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001708 AND
		    AGENT_NAME_ID=10012389
goddammit MVZ: bookid: 10001708; pubID: 10003793
bookid: 10001708; pubID: 10003794
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003794,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001708 AND
		    AGENT_NAME_ID=10012389
goddammit MVZ: bookid: 10001708; pubID: 10003794
bookid: 10001708; pubID: 10003795
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003795,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001708 AND
		    AGENT_NAME_ID=10012389
goddammit MVZ: bookid: 10001708; pubID: 10003795
bookid: 10001707; pubID: 10003796
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003796,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001707 AND
		    AGENT_NAME_ID=10005401
goddammit MVZ: bookid: 10001707; pubID: 10003796
bookid: 10001707; pubID: 10003797
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003797,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001707 AND
		    AGENT_NAME_ID=10005401
goddammit MVZ: bookid: 10001707; pubID: 10003797
bookid: 10001706; pubID: 10003798
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003798,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001706 AND
		    AGENT_NAME_ID=10013486
goddammit MVZ: bookid: 10001706; pubID: 10003798
bookid: 10001706; pubID: 10003799
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003799,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001706 AND
		    AGENT_NAME_ID=10013486
goddammit MVZ: bookid: 10001706; pubID: 10003799
bookid: 10001706; pubID: 10003800
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003800,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001706 AND
		    AGENT_NAME_ID=10013486
goddammit MVZ: bookid: 10001706; pubID: 10003800
bookid: 10001706; pubID: 10003801
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003801,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001706 AND
		    AGENT_NAME_ID=10013486
goddammit MVZ: bookid: 10001706; pubID: 10003801
bookid: 10001706; pubID: 10003802
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003802,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001706 AND
		    AGENT_NAME_ID=10013486
goddammit MVZ: bookid: 10001706; pubID: 10003802
bookid: 10001705; pubID: 10003803
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003803,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001705 AND
		    AGENT_NAME_ID=10013486
goddammit MVZ: bookid: 10001705; pubID: 10003803
bookid: 10001705; pubID: 10003804
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003804,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001705 AND
		    AGENT_NAME_ID=10013486
goddammit MVZ: bookid: 10001705; pubID: 10003804
bookid: 10001705; pubID: 10003805
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003805,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001705 AND
		    AGENT_NAME_ID=10013486
goddammit MVZ: bookid: 10001705; pubID: 10003805
bookid: 10001705; pubID: 10003806
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003806,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001705 AND
		    AGENT_NAME_ID=10013486
goddammit MVZ: bookid: 10001705; pubID: 10003806
bookid: 10001705; pubID: 10003807
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003807,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001705 AND
		    AGENT_NAME_ID=10013486
goddammit MVZ: bookid: 10001705; pubID: 10003807
bookid: 10001702; pubID: 10003808
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003808,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001702 AND
		    AGENT_NAME_ID=10001043
goddammit MVZ: bookid: 10001702; pubID: 10003808
bookid: 10001702; pubID: 10003809
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003809,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001702 AND
		    AGENT_NAME_ID=10001043
goddammit MVZ: bookid: 10001702; pubID: 10003809
bookid: 10001702; pubID: 10003810
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003810,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001702 AND
		    AGENT_NAME_ID=10001043
goddammit MVZ: bookid: 10001702; pubID: 10003810
bookid: 10001702; pubID: 10003811
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003811,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001702 AND
		    AGENT_NAME_ID=10001043
goddammit MVZ: bookid: 10001702; pubID: 10003811
bookid: 10001503; pubID: 10003812
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003812,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001503 AND
		    AGENT_NAME_ID=10008676
goddammit MVZ: bookid: 10001503; pubID: 10003812
bookid: 10001503; pubID: 10003813
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003813,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001503 AND
		    AGENT_NAME_ID=10008676
goddammit MVZ: bookid: 10001503; pubID: 10003813
bookid: 10001669; pubID: 10003814
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003814,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001669 AND
		    AGENT_NAME_ID=10011568
goddammit MVZ: bookid: 10001669; pubID: 10003814
bookid: 10001669; pubID: 10003815
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003815,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001669 AND
		    AGENT_NAME_ID=10011568
goddammit MVZ: bookid: 10001669; pubID: 10003815
bookid: 10001727; pubID: 10003816
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003816,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001727 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001727; pubID: 10003816
bookid: 10001727; pubID: 10003817
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003817,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001727 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001727; pubID: 10003817
bookid: 10001727; pubID: 10003818
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003818,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001727 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001727; pubID: 10003818
bookid: 10001727; pubID: 10003819
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003819,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001727 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001727; pubID: 10003819
bookid: 10001727; pubID: 10003820
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003820,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001727 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001727; pubID: 10003820
bookid: 10001727; pubID: 10003821
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003821,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001727 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001727; pubID: 10003821
bookid: 10001727; pubID: 10003822
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003822,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001727 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001727; pubID: 10003822
bookid: 10001730; pubID: 10003823
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003823,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001730 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001730; pubID: 10003823
bookid: 10001730; pubID: 10003824
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003824,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001730 AND
		    AGENT_NAME_ID=10013364
goddammit MVZ: bookid: 10001730; pubID: 10003824
bookid: 10001389; pubID: 10003825
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003825,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001389 AND
		    AGENT_NAME_ID=10006657
goddammit MVZ: bookid: 10001389; pubID: 10003825
bookid: 10001389; pubID: 10003826
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003826,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001389 AND
		    AGENT_NAME_ID=10006657
goddammit MVZ: bookid: 10001389; pubID: 10003826
bookid: 10001389; pubID: 10003827
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003827,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001389 AND
		    AGENT_NAME_ID=10006657
goddammit MVZ: bookid: 10001389; pubID: 10003827
bookid: 10001389; pubID: 10003828
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003828,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001389 AND
		    AGENT_NAME_ID=10006657
goddammit MVZ: bookid: 10001389; pubID: 10003828
bookid: 10001389; pubID: 10003829
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003829,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001389 AND
		    AGENT_NAME_ID=10006657
goddammit MVZ: bookid: 10001389; pubID: 10003829
bookid: 10001389; pubID: 10003830
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003830,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001389 AND
		    AGENT_NAME_ID=10006657
goddammit MVZ: bookid: 10001389; pubID: 10003830
bookid: 10001389; pubID: 10003831
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003831,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001389 AND
		    AGENT_NAME_ID=10006657
goddammit MVZ: bookid: 10001389; pubID: 10003831
bookid: 10001389; pubID: 10003832
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003832,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001389 AND
		    AGENT_NAME_ID=10006657
goddammit MVZ: bookid: 10001389; pubID: 10003832
bookid: 10001389; pubID: 10003833
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003833,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001389 AND
		    AGENT_NAME_ID=10006657
goddammit MVZ: bookid: 10001389; pubID: 10003833
bookid: 10001389; pubID: 10003834
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003834,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001389 AND
		    AGENT_NAME_ID=10006657
goddammit MVZ: bookid: 10001389; pubID: 10003834
bookid: 10001609; pubID: 10003835
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003835,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001609 AND
		    AGENT_NAME_ID=10003546
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003835,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001609 AND
		    AGENT_NAME_ID=10010806
goddammit MVZ: bookid: 10001609; pubID: 10003835
bookid: 10001609; pubID: 10003836
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003836,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001609 AND
		    AGENT_NAME_ID=10010806
goddammit MVZ: bookid: 10001609; pubID: 10003836
bookid: 10001609; pubID: 10003837
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003837,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001609 AND
		    AGENT_NAME_ID=10010806
goddammit MVZ: bookid: 10001609; pubID: 10003837
bookid: 10001609; pubID: 10003838
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003838,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001609 AND
		    AGENT_NAME_ID=10010806
goddammit MVZ: bookid: 10001609; pubID: 10003838
bookid: 10001609; pubID: 10003839
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003839,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001609 AND
		    AGENT_NAME_ID=10010806
goddammit MVZ: bookid: 10001609; pubID: 10003839
bookid: 10001609; pubID: 10003840
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003840,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001609 AND
		    AGENT_NAME_ID=10010806
goddammit MVZ: bookid: 10001609; pubID: 10003840
bookid: 10001565; pubID: 10003841
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003841,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001565 AND
		    AGENT_NAME_ID=10010197
goddammit MVZ: bookid: 10001565; pubID: 10003841
bookid: 10001716; pubID: 10003842
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003842,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003842
bookid: 10001716; pubID: 10003843
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003843,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003843
bookid: 10001716; pubID: 10003844
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003844,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003844
bookid: 10001716; pubID: 10003845
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003845,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003845
bookid: 10001716; pubID: 10003846
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003846,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003846
bookid: 10001716; pubID: 10003847
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003847,
		    AUTHOR_POSITION=2
		WHERE
			    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003847
bookid: 10001716; pubID: 10003848
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003848,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003848
bookid: 10001716; pubID: 10003849
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003849,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003849
bookid: 10001716; pubID: 10003850
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003850,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003850
bookid: 10001716; pubID: 10003851
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003851,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003851
bookid: 10001716; pubID: 10003852
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003852,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001716 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001716; pubID: 10003852
bookid: 10001717; pubID: 10003853
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003853,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001717 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001717; pubID: 10003853
bookid: 10001717; pubID: 10003854
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003854,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001717 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001717; pubID: 10003854
bookid: 10001717; pubID: 10003855
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003855,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001717 AND
		    AGENT_NAME_ID=10007081
goddammit MVZ: bookid: 10001717; pubID: 10003855
bookid: 10001309; pubID: 10003856
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003856,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001309 AND
		    AGENT_NAME_ID=10003223
goddammit MVZ: bookid: 10001309; pubID: 10003856
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003856,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001309 AND
		    AGENT_NAME_ID=10004682
goddammit MVZ: bookid: 10001309; pubID: 10003856
bookid: 10001309; pubID: 10003857
npid: 3
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003857,
		    AUTHOR_POSITION=3
		WHERE
		    publ
ication_id=10001309 AND
		    AGENT_NAME_ID=10003223
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003857,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001309 AND
		    AGENT_NAME_ID=10004682
goddammit MVZ: bookid: 10001309; pubID: 10003857
bookid: 10001309; pubID: 10003858
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003858,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001309 AND
		    AGENT_NAME_ID=10004682
goddammit MVZ: bookid: 10001309; pubID: 10003858
bookid: 10001309; pubID: 10003859
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003859,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001309 AND
		    AGENT_NAME_ID=10004682
bookid: 10001309; pubID: 10003860
npid:
bookid: 10001309; pubID: 10003861
npid:
bookid: 10001722; pubID: 10003862
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003862,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003862
bookid: 10001722; pubID: 10003863
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003863,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003863
bookid: 10001722; pubID: 10003864
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003864,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003864
bookid: 10001722; pubID: 10003865
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003865,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003865
bookid: 10001722; pubID: 10003866
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003866,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003866
bookid: 10001722; pubID: 10003867
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003867,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003867
bookid: 10001722; pubID: 10003868
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003868,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003868
bookid: 10001722; pubID: 10003869
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003869,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003869
bookid: 10001722; pubID: 10003870
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003870,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003870
bookid: 10001722; pubID: 10003871
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003871,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003871
bookid: 10001722; pubID: 10003872
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003872,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003872
bookid: 10001722; pubID: 10003873
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003873,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001722 AND
		    AGENT_NAME_ID=10005117
goddammit MVZ: bookid: 10001722; pubID: 10003873
bookid: 10001714; pubID: 10003874
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003874,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001714 AND
		    AGENT_NAME_ID=10009407
goddammit MVZ: bookid: 10001714; pubID: 10003874
bookid: 10001751; pubID: 10003875
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003875,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001751 AND
		    AGENT_NAME_ID=10003174
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003875,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001751 AND
		    AGENT_NAME_ID=10005018
goddammit MVZ: bookid: 10001751; pubID: 10003875
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003875,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001751 AND
		    AGENT_NAME_ID=10007032
goddammit MVZ: bookid: 10001751; pubID: 10003875
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003875,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001751 AND
		    AGENT_NAME_ID=10012545
goddammit MVZ: bookid: 10001751; pubID: 10003875
bookid: 10001751; pubID: 10003876
npid: 4
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003876,
		    AUTHOR_POSITION=4
		WHERE
		    publ
ication_id=10001751 AND
		    AGENT_NAME_ID=10005018
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003876,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001751 AND
		    AGENT_NAME_ID=10007032
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003876,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001751 AND
		    AGENT_NAME_ID=10012545
goddammit MVZ: bookid: 10001751; pubID: 10003876
bookid: 10001751; pubID: 10003877
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003877,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001751 AND
		    AGENT_NAME_ID=10012545
bookid: 10001751; pubID: 10003878
npid:
bookid: 10001751; pubID: 10003879
npid:
bookid: 10001476; pubID: 10003880
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003880,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001476 AND
		    AGENT_NAME_ID=10008134
goddammit MVZ: bookid: 10001476; pubID: 10003880
bookid: 10001476; pubID: 10003881
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003881,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001476 AND
		    AGENT_NAME_ID=10008134
goddammit MVZ: bookid: 10001476; pubID: 10003881
bookid: 10001477; pubID: 10003882
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003882,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001477 AND
		    AGENT_NAME_ID=10008134
goddammit MVZ: bookid: 10001477; pubID: 10003882
bookid: 10001477; pubID: 10003883
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003883,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001477 AND
		    AGENT_NAME_ID=10008134
goddammit MVZ: bookid: 10001477; pubID: 10003883
bookid: 10001476; pubID: 10003884
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003884,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001476 AND
		    AGENT_NAME_ID=10008134
goddammit MVZ: bookid: 10001476; pubID: 10003884
bookid: 10001476; pubID: 10003885
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003885,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001476 AND
		    AGENT_NAME_ID=10008134
goddammit MVZ: bookid: 10001476; pubID: 10003885
bookid: 10001740; pubID: 10003886
npid: 8
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003886,
		    AUTHOR_POSITION=8
		WHERE
		    publ
ication_id=10001740 AND
		    AGENT_NAME_ID=10000504
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003886,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10001740 AND
		    AGENT_NAME_ID=10001229
goddammit MVZ: bookid: 10001740; pubID: 10003886
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003886,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10001740 AND
		    AGENT_NAME_ID=10002424
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003886,
		    AUTHOR_POSITION=10
		WHERE
		    pub
lication_id=10001740 AND
		    AGENT_NAME_ID=10002643
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003886,
		    AUTHOR_POSITION=11
		WHERE
		    pub
lication_id=10001740 AND
		    AGENT_NAME_ID=10003254
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003886,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001740 AND
		    AGENT_NAME_ID=10006419
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003886,
		    AUTHOR_POSITION=13
		WHERE
		    pub
lication_id=10001740 AND
		    AGENT_NAME_ID=10007233
bookid: 10001740; pubID: 10003887
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003887,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001740 AND
		    AGENT_NAME_ID=10001229
bookid: 10001740; pubID: 10003888
npid:
bookid: 10001740; pubID: 10003889
npid:
bookid: 10001740; pubID: 10003890
npid:
bookid: 10001740; pubID: 10003891
npid:
bookid: 10001740; pubID: 10003892
npid:
bookid: 10001739; pubID: 10003893
npid: 12
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10000594
goddammit MVZ: bookid: 10001739; pubID: 10003893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10001031
goddammit MVZ: bookid: 10001739; pubID: 10003893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10001412
goddammit MVZ: bookid: 10001739; pubID: 10003893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10003019
goddammit MVZ: bookid: 10001739; pubID: 10003893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10003315
goddammit MVZ: bookid: 10001739; pubID: 10003893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10003468
goddammit MVZ: bookid: 10001739; pubID: 10003893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10004124
goddammit MVZ: bookid: 10001739; pubID: 10003893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10004367
goddammit MVZ: bookid: 10001739; pubID: 10003893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10005067
goddammit MVZ: bookid: 10001739; pubID: 10003893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10005712
goddammit MVZ: bookid: 10001739; pubID: 10003893
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003893,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10006213
goddammit MVZ: bookid: 10001739; pubID: 10003893
bookid: 10001739; pubID: 10003894
npid: 12
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10000594
goddammit MVZ: bookid: 10001739; pubID: 10003894
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=12
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10001031
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=13
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10001412
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=14
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10003019
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=15
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10003315
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=16
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10003468
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=17
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10004124
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=18
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10004367
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=19
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10005067
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=20
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10005712
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003894,
		    AUTHOR_POSITION=21
		WHERE
		    pub
lication_id=10001739 AND
		    AGENT_NAME_ID=10006213
bookid: 10001739; pubID: 10003895
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003895,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001739 AND
		    AGENT_NAME_ID=10000594
bookid: 10001739; pubID: 10003896
npid:
bookid: 10001739; pubID: 10003897
npid:
bookid: 10001739; pubID: 10003898
npid:
bookid: 10001739; pubID: 10003899
npid:
bookid: 10001739; pubID: 10003900
npid:
bookid: 10001739; pubID: 10003901
npid:
bookid: 10001739; pubID: 10003902
npid:
bookid: 10001739; pubID: 10003903
npid:
bookid: 10001739; pubID: 10003904
npid:
bookid: 10001739; pubID: 10003905
npid:
bookid: 10001737; pubID: 10003906
npid: 6
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003906,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001737 AND
		    AGENT_NAME_ID=1014117
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003906,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001737 AND
		    AGENT_NAME_ID=10000541
goddammit MVZ: bookid: 10001737; pubID: 10003906
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003906,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001737 AND
		    AGENT_NAME_ID=10003724
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003906,
		    AUTHOR_POSITION=8
		WHERE
		    publ
ication_id=10001737 AND
		    AGENT_NAME_ID=10008031
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003906,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10001737 AND
		    AGENT_NAME_ID=10011758
bookid: 10001737; pubID: 10003907
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003907,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001737 AND
		    AGENT_NAME_ID=10000541
bookid: 10001737; pubID: 10003908
npid:
bookid: 10001737; pubID: 10003909
npid:
bookid: 10001737; pubID: 10003910
npid:
bookid: 10001737; pubID: 10003911
npid:
bookid: 10001737; pubID: 10003912
npid:
bookid: 10001737; pubID: 10003913
npid:
bookid: 10001736; pubID: 10003914
npid: 7
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003914,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10000334
goddammit MVZ: bookid: 10001736; pubID: 10003914
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003914,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10000640
goddammit MVZ: bookid: 10001736; pubID: 10003914
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003914,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10000642
goddammit MVZ: bookid: 10001736; pubID: 10003914
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003914,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10001470
goddammit MVZ: bookid: 10001736; pubID: 10003914
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003914,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10003999
goddammit MVZ: bookid: 10001736; pubID: 10003914
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003914,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10005119
goddammit MVZ: bookid: 10001736; pubID: 10003914
bookid: 10001736; pubID: 10003915
npid: 7
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003915,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10000334
goddammit MVZ: bookid: 10001736; pubID: 10003915
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003915,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10000640
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003915,
		    AUTHOR_POSITION=8
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10000642
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003915,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10001470
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003915,
		    AUTHOR_POSITION=10
		WHERE
		    pub
lication_id=10001736 AND
		    AGENT_NAME_ID=10003999
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003915,
		    AUTHOR_POSITION=11
		WHERE
		    pub
lication_id=10001736 AND
		    AGENT_NAME_ID=10005119
bookid: 10001736; pubID: 10003916
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003916,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001736 AND
		    AGENT_NAME_ID=10000334
bookid: 10001736; pubID: 10003917
npid:
bookid: 10001736; pubID: 10003918
npid:
bookid: 10001736; pubID: 10003919
npid:
bookid: 10001736; pubID: 10003920
npid:
bookid: 10001565; pubID: 10003921
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003921,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001565 AND
		    AGENT_NAME_ID=10010197
goddammit MVZ: bookid: 10001565; pubID: 10003921
bookid: 10001565; pubID: 10003922
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003922,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001565 AND
		    AGENT_NAME_ID=10010197
goddammit MVZ: bookid: 10001565; pubID: 10003922
bookid: 10001745; pubID: 10003923
npid: 13
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=13
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10002368
goddammit MVZ: bookid: 10001745; pubID: 10003923
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=13
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10002537
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=14
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10005726
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=15
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10006400
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=16
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10008081
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=17
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10009149
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=18
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10009808
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=19
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10009995
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=20
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10010354
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=21
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10011183
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=22
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10011930
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003923,
		    AUTHOR_POSITION=23
		WHERE
		    pub
lication_id=10001745 AND
		    AGENT_NAME_ID=10013236
bookid: 10001745; pubID: 10003924
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003924,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001745 AND
		    AGENT_NAME_ID=10002368
bookid: 10001745; pubID: 10003925
npid:
bookid: 10001745; pubID: 10003926
npid:
bookid: 10001745; pubID: 10003927
npid:
bookid: 10001745; pubID: 10003928
npid:
bookid: 10001745; pubID: 10003929
npid:
bookid: 10001745; pubID: 10003930
npid:
bookid: 10001745; pubID: 10003931
npid:
bookid: 10001745; pubID: 10003932
npid:
bookid: 10001745; pubID: 10003933
npid:
bookid: 10001745; pubID: 10003934
npid:
bookid: 10001745; pubID: 10003935
npid:
bookid: 10001745; pubID: 10003936
npid:
bookid: 10001745; pubID: 10003937
npid:
bookid: 10001745; pubID: 10003938
npid:
bookid: 10001744; pubID: 10003939
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003939,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001744 AND
		    AGENT_NAME_ID=10000922
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003939,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001744 AND
		    AGENT_NAME_ID=10002323
goddammit MVZ: bookid: 10001744; pubID: 10003939
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003939,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001744 AND
		    AGENT_NAME_ID=10005117
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003939,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001744 AND
		    AGENT_NAME_ID=10011489
bookid: 10001744; pubID: 10003940
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003940,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001744 AND
		    AGENT_NAME_ID=10002323
bookid: 10001744; pubID: 10003941
npid:
bookid: 10001744; pubID: 10003942
npid:
bookid: 10001744; pubID: 10003943
npid:
bookid: 10003944; pubID: 10003945
npid: 6
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003945,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10003944 AND
		    AGENT_NAME_ID=10005174
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003945,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10003944 AND
		    AGENT_NAME_ID=10007292
goddammit MVZ: bookid: 10003944; pubID: 10003945
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003945,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10003944 AND
		    AGENT_NAME_ID=10009601
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003945,
		    AUTHOR_POSITION=8
		WHERE
		    publ
ication_id=10003944 AND
		    AGENT_NAME_ID=10010647
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003945,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10003944 AND
		    AGENT_NAME_ID=10011852
bookid: 10003944; pubID: 10003946
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003946,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003944 AND
		    AGENT_NAME_ID=10007292
goddammit MVZ: bookid: 10003944; pubID: 10003946
bookid: 10003944; pubID: 10003947
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003947,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10003944 AND
		    AGENT_NAME_ID=10007292
bookid: 10003944; pubID: 10003948
npid:
bookid: 10003944; pubID: 10003949
npid:
bookid: 10003944; pubID: 10003950
npid:
bookid: 10003944; pubID: 10003951
npid:
bookid: 10003944; pubID: 10003952
npid:
bookid: 10001746; pubID: 10003953
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003953,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001746 AND
		    AGENT_NAME_ID=10002995
goddammit MVZ: bookid: 10001746; pubID: 10003953
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003953,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001746 AND
		    AGENT_NAME_ID=10003146
goddammit MVZ: bookid: 10001746; pubID: 10003953
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003953,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001746 AND
		    AGENT_NAME_ID=10009151
goddammit MVZ: bookid: 10001746; pubID: 10003953
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003953,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001746 AND
		    AGENT_NAME_ID=10010197
goddammit MVZ: bookid: 10001746; pubID: 10003953
bookid: 10001746; pubID: 10003954
npid: 5
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003954,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001746 AND
		    AGENT_NAME_ID=10002995
goddammit MVZ: bookid: 10001746; pubID: 10003954
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003954,
		    AUTHOR_POSITION=5
		WHERE
		    publ
ication_id=10001746 AND
		    AGENT_NAME_ID=10003146
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003954,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001746 AND
		    AGENT_NAME_ID=10009151
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003954,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001746 AND
		    AGENT_NAME_ID=10010197
bookid: 10001746; pubID: 10003955
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003955,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001746 AND
		    AGENT_NAME_ID=10002995
bookid: 10001746; pubID: 10003956
npid:
bookid: 10001735; pubID: 10003957
npid: 6
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003957,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001735 AND
		    AGENT_NAME_ID=10000339
goddammit MVZ: bookid: 10001735; pubID: 10003957
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003957,
		    AUTHOR_POSITION=6
		WHERE
		    publ
ication_id=10001735 AND
		    AGENT_NAME_ID=10006383
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003957,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001735 AND
		    AGENT_NAME_ID=10008048
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003957,
		    AUTHOR_POSITION=8
		WHERE
		    publ
ication_id=10001735 AND
		    AGENT_NAME_ID=10009570
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003957,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10001735 AND
		    AGENT_NAME_ID=10013024
bookid: 10001735; pubID: 10003958
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003958,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001735 AND
		    AGENT_NAME_ID=10000339
bookid: 10001735; pubID: 10003959
npid:
bookid: 10001735; pubID: 10003960
npid:
bookid: 10001735; pubID: 10003961
npid:
bookid: 10001735; pubID: 10003962
npid:
bookid: 10001735; pubID: 10003963
npid:
bookid: 10001383; pubID: 10003964
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003964,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001383 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001383; pubID: 10003964
bookid: 10001383; pubID: 10003965
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003965,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001383 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001383; pubID: 10003965
bookid: 10001383; pubID: 10003966
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003966,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001383 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001383; pubID: 10003966
bookid: 10001383; pubID: 10003967
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003967,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001383 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001383; pubID: 10003967
bookid: 10001383; pubID: 10003968
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003968,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001383 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001383; pubID: 10003968
bookid: 10001383; pubID: 10003969
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003969,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001383 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001383; pubID: 10003969
bookid: 10001383; pubID: 10003970
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003970,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001383 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001383; pubID: 10003970
bookid: 10001383; pubID: 10003971
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003971,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001383 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001383; pubID: 10003971
bookid: 10001383; pubID: 10003972
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003972,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001383 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001383; pubID: 10003972
bookid: 10001382; pubID: 10003973
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003973,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001382 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001382; pubID: 10003973
bookid: 10001382; pubID: 10003974
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003974,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001382 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001382; pubID: 10003974
bookid: 10001382; pubID: 10003975
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003975,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001382 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001382; pubID: 10003975
bookid: 10001382; pubID: 10003976
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003976,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001382 AND
		    AGENT_NAME_ID=10006409
goddammit MVZ: bookid: 10001382; pubID: 10003976
bookid: 10001311; pubID: 10003977
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003977,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001311 AND
		    AGENT_NAME_ID=10004959
goddammit MVZ: bookid: 10001311; pubID: 10003977
bookid: 10001311; pubID: 10003978
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003978,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001311 AND
		    AGENT_NAME_ID=10004959
goddammit MVZ: bookid: 10001311; pubID: 10003978
bookid: 10001311; pubID: 10003979
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003979,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001311 AND
		    AGENT_NAME_ID=10004959
goddammit MVZ: bookid: 10001311; pubID: 10003979
bookid: 10001741; pubID: 10003980
npid: 7
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003980,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001741 AND
		    AGENT_NAME_ID=10001404
goddammit MVZ: bookid: 10001741; pubID: 10003980
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003980,
		    AUTHOR_POSITION=7
		WHERE
		    publ
ication_id=10001741 AND
		    AGENT_NAME_ID=10001493
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003980,
		    AUTHOR_POSITION=8
		WHERE
		    publ
ication_id=10001741 AND
		    AGENT_NAME_ID=10002231
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003980,
		    AUTHOR_POSITION=9
		WHERE
		    publ
ication_id=10001741 AND
		    AGENT_NAME_ID=10003779
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003980,
		    AUTHOR_POSITION=10
		WHERE
		    pub
lication_id=10001741 AND
		    AGENT_NAME_ID=10009580
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003980,
		    AUTHOR_POSITION=11
		WHERE
		    pub
lication_id=10001741 AND
		    AGENT_NAME_ID=10010201
bookid: 10001741; pubID: 10003981
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003981,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001741 AND
		    AGENT_NAME_ID=10001404
bookid: 10001741; pubID: 10003982
npid:
bookid: 10001741; pubID: 10003983
npid:
bookid: 10001741; pubID: 10003984
npid:
bookid: 10001741; pubID: 10003985
npid:
bookid: 10001726; pubID: 10003986
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003986,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001726 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001726; pubID: 10003986
bookid: 10001726; pubID: 10003987
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003987,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001726 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001726; pubID: 10003987
bookid: 10001726; pubID: 10003988
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003988,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001726 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001726; pubID: 10003988
bookid: 10001726; pubID: 10003989
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003989,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001726 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001726; pubID: 10003989
bookid: 10001726; pubID: 10003990
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003990,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001726 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001726; pubID: 10003990
bookid: 10001726; pubID: 10003991
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003991,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001726 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001726; pubID: 10003991
bookid: 10001726; pubID: 10003992
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003992,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001726 AND
		    AGENT_NAME_ID=10013348
goddammit MVZ: bookid: 10001726; pubID: 10003992
bookid: 10001734; pubID: 10003993
npid: 2
UPDATE
		    publication_author_name
		SET
		    publicati
on_id=10003993,
		    AUTHOR_POSITION=2
		WHERE
		    publ
ication_id=10001734 AND
		    AGENT_NAME_ID=10013378
goddammit MVZ: bookid: 10001734; pubID: 10003993
bookid: 10001742; pubID: 10003994
npid:
bookid: 10001742; pubID: 10003995
npid:
bookid: 10001742; pubID: 10003996
npid:
bookid: 10001742; pubID: 10003997
npid:
bookid: 10001742; pubID: 10003998
npid:

PL/SQL procedure successfully completed

*/
/*
	move formatted_publication to a table
	someone should triggerify this and move
	publication.cfc into Oracle, but not now....
	
	use /fix/seed_formatted_pub.cfm to get started.
*/
DROP VIEW formatted_publication;
create table formatted_publication (
	publication_id number not null,
	FORMAT_STYLE varchar2(25) not null,
	FORMATTED_PUBLICATION varchar2(4000)
);
	
create or replace public synonym formatted_publication for formatted_publication;
grant select on formatted_publication to public;
grant all on formatted_publication to manage_publications;
    
CREATE INDEX formatted_publication_pid ON formatted_publication (publication_id) TABLESPACE uam_idx_1;
CREATE INDEX formatted_publication_st ON formatted_publication (FORMAT_STYLE) TABLESPACE uam_idx_1;
CREATE INDEX formatted_publication_fp ON formatted_publication (FORMATTED_PUBLICATION) TABLESPACE uam_idx_1;
        
DROP FUNCTION GETFULLCITATION;
DROP FUNCTION GETAUTHORYEAR;

/*
	need trigger to enforce citation type based on is_peer_reviewed_fg
*/
 
INSERT INTO ctcitation_type_status (type_status,description) VALUES ('referral','this is the only value acceptable for citing specimens in non-peer reviewed literature.');


CREATE OR REPLACE TRIGGER enforce_citation_type
    before UPDATE or INSERT ON citation
    for each row
declare
    IS_PEER_REVIEWED_FG publication.IS_PEER_REVIEWED_FG%TYPE;
BEGIN
	SELECT IS_PEER_REVIEWED_FG INTO IS_PEER_REVIEWED_FG FROM publication WHERE publication_id=:new.publication_id;
	IF IS_PEER_REVIEWED_FG = 1 AND :new.type_status = 'referral' THEN
	   raise_application_error(
            -20001,
            'Invalid type_status for this is_peer_reviewed_fg'
          );
	ELSIF IS_PEER_REVIEWED_FG = 0 AND :new.type_status != 'referral' THEN
	    raise_application_error(
            -20001,
            'Invalid type_status for this is_peer_reviewed_fg'
          );
	END IF;
END;
/
sho err    

-- see if we can get the correct type with some of MVZ's garbage
SELECT publication_title FROM publication WHERE lower(publication_title) LIKE '%field notebook%' ORDER BY publication_title;

INSERT INTO ctpublication_type (publication_type) VALUES ('field notebook');

UPDATE publication SET publication_type='field notebook' WHERE lower(publication_title) LIKE '%field notes%';
UPDATE publication SET is_peer_reviewed_fg=0 WHERE publication_type='field notebook';

-- clean up OLD stuff, but KEEP THE TABLES around FOR now

ALTER TABLE book DROP CONSTRAINT FK_BOOK_PUBLICATION;
ALTER TABLE BOOK_SECTION DROP CONSTRAINT FK_BOOKSECTION_PUBLICATION;
ALTER TABLE JOURNAL_ARTICLE DROP CONSTRAINT FK_JOURNALARTICLE_PUBLICATION;
                