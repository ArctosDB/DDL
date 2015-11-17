CREATE OR REPLACE FUNCTION "UAM"."IS_CLAIMED_BARCODE" (barcode in varchar)
	return varchar as
		rslt varchar2(255):='FAIL';
		rsql varchar2(255);
		ssmt varchar2(255);
		c number;
	begin
		for r in (select barcodeseriessql from cf_barcodeseries) loop
			begin
				rsql:=replace(r.barcodeseriessql,'barcode','''' || barcode || '''');
				ssmt := 'select count(*) from dual where ' || rsql;
				execute immediate ssmt into c;
				if c=1 then
					rslt:='PASS';
				end if;
			exception when others then
				NULL;
			end;
		end loop;
		return rslt;
	end;
/


CREATE OR REPLACE PUBLIC SYNONYM IS_CLAIMED_BARCODE FOR IS_CLAIMED_BARCODE;
GRANT execute ON IS_CLAIMED_BARCODE TO PUBLIC;
