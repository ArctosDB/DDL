

CREATE OR REPLACE TRIGGER TRG_loan_item_biu
	BEFORE INSERT OR UPDATE ON loan_item
FOR EACH ROW
DECLARE 
	v_ltype loan.LOAN_TYPE%TYPE;	
	v_citype varchar2(39);
BEGIN
	select loan_type into v_ltype from loan where TRANSACTION_ID=:NEW.TRANSACTION_ID;
	select COLL_OBJECT_TYPE into v_citype from coll_object where collection_object_id=:NEW.collection_object_id;
	
	if v_ltype = 'data' and v_citype != 'CI' then
		 raise_application_error(
            -20371,
            'Data Loans may contain only cataloged items');
    end if;
    
    if v_ltype !='data' and v_citype = 'CI' then
		 raise_application_error(
            -20371,
            'Only Data Loans may contain cataloged items');
    end if;
END;
/
sho err;


