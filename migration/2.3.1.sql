/*
	This file provides the code needed to move from v2.3 to v2.3.1
	
	Release info:
		Change loans to accn-like format (string instead of prefix-number-suffix)
		Update Citations, bulkloading citations
		
*/

ALTER TABLE taxonomy ADD INFRASPECIFIC_AUTHOR  VARCHAR2(255);
    
 alter table loan add loan_number varchar2(255);
 --may need tweaked for UAM
 SELECT 
    LOAN_NUM_PREFIX ||
    DECODE(LOAN_NUM_PREFIX,
         NULL,'',
         '.')
         ||LOAN_NUM||
     DECODE(LOAN_NUM_SUFFIX,
         NULL,'',
         '.')
         ||LOAN_NUM_SUFFIX FROM loan ORDER BY
 LOAN_NUM_PREFIX||'.'||LOAN_NUM||'.'||LOAN_NUM_SUFFIX;
 -- WHEN THE above looks happy....
 UPDATE loan SET loan_number = 
 LOAN_NUM_PREFIX ||
    DECODE(LOAN_NUM_PREFIX,
         NULL,'',
         '.')
         ||LOAN_NUM||
     DECODE(LOAN_NUM_SUFFIX,
         NULL,'',
         '.')
         ||LOAN_NUM_SUFFIX
         ;
         
-- CHECK
SELECT 
   loan_number || chr(9)||
    LOAN_NUM_PREFIX ||
    DECODE(LOAN_NUM_PREFIX,
         NULL,'',
         '.')
         ||LOAN_NUM||
     DECODE(LOAN_NUM_SUFFIX,
         NULL,'',
         '.')
         ||LOAN_NUM_SUFFIX FROM loan;
ALTER TABLE loan MODIFY loan_number NOT NULL;
ALTER TABLE loan MODIFY LOAN_NUM NULL;



DROP TABLE cf_temp_loan_item;
DROP TABLE cf_temp_loan;
  /* also in DDL branch */
create table cf_temp_loan_item (
 KEY                                                            NUMBER NOT NULL,
 INSTITUTION_ACRONYM                                            VARCHAR2(5) NOT NULL,
COLLECTION_CDE                                                 VARCHAR2(4) NOT NULL,
 OTHER_ID_TYPE                                                  VARCHAR2(30) NOT NULL,
 OTHER_ID_NUMBER                                                VARCHAR2(30) NOT NULL,
 PART_NAME                                                      VARCHAR2(30) NOT NULL,
 SUBSAMPLE                                                      VARCHAR2(3) NOT NULL,
item_description varchar2(255),
item_remarks varchar2(255),
 LOAN_number                                                           VARCHAR2(30) NOT NULL,
partID number,
transaction_id number,
status VARCHAR2(255)
);
CREATE OR REPLACE PUBLIC SYNONYM cf_temp_loan_item FOR cf_temp_loan_item;
GRANT ALL ON cf_temp_loan_item TO coldfusion_user;
GRANT SELECT ON cf_temp_loan_item TO PUBLIC;
CREATE OR REPLACE TRIGGER cf_temp_loan_item_key                                         
 before insert  ON cf_temp_loan_item  
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err
