lock table borrow in exclusive mode nowait;

alter table borrow rename column RECEIVED_DATE to date_RECEIVED_DATE;
alter table borrow add received_date VARCHAR2(22);

alter table borrow rename column DUE_DATE to date_DUE_DATE;
alter table borrow add DUE_DATE VARCHAR2(22);


alter table borrow rename column LENDERS_LOAN_DATE to date_LENDERS_LOAN_DATE;
alter table borrow add  LENDERS_LOAN_DATE VARCHAR2(22);


UPDATE borrow SET received_date=to_char(date_RECEIVED_DATE,'YYYY-MM-DD');
UPDATE borrow SET DUE_DATE=to_char(date_DUE_DATE,'YYYY-MM-DD');
UPDATE borrow SET LENDERS_LOAN_DATE=to_char(date_LENDERS_LOAN_DATE,'YYYY-MM-DD');



CREATE OR REPLACE TRIGGER tr_borrow_bui
BEFORE INSERT OR UPDATE ON borrow
FOR EACH ROW
	declare status varchar2(255);
BEGIN
    status:=is_iso8601(:NEW.received_date);
    IF status != 'valid' THEN
        raise_application_error(-20001,'received_date: ' || status);
    END IF;
    status:=is_iso8601(:NEW.DUE_DATE);
    IF status != 'valid' THEN
        raise_application_error(-20001,'DUE_DATE: ' || status);
    END IF;
    status:=is_iso8601(:NEW.LENDERS_LOAN_DATE);
    IF status != 'valid' THEN
        raise_application_error(-20001,'LENDERS_LOAN_DATE: ' || status);
    END IF;
END;
/

-- check
select RECEIVED_DATE,date_RECEIVED_DATE from borrow;
-- happy
alter table borrow drop column date_RECEIVED_DATE;

select DUE_DATE,date_DUE_DATE from borrow;

alter table borrow drop column date_DUE_DATE;

select LENDERS_LOAN_DATE,date_LENDERS_LOAN_DATE from borrow;
alter table borrow drop column date_LENDERS_LOAN_DATE;

commit;

