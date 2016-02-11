Ref: https://github.com/ArctosDB/arctos/issues/808

Doc: http://arctosdb.org/documentation/encumbrance/

Lacking timely objections, I intend to proceed with this as follows:

- expiration date becomes NOT NULL, with a maximum value of (now + 5 years)
- expiration event is removed, with existing data merged into remarks
- encumbering agent documentation is updated to "agent requesting the encumbrance; final authority to remove encumbrances rests with the collection"
- Email notifications are sent to collection contacts on...
-- expiration date minus multiples of 365 days
-- expiration date minus 180 days
-- expiration date minus 90 days
-- expiration date minus 30 days
-- expiration date

- expiration date becomes actionable; expired encumbrances will not restrict access to data.


 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 ENCUMBRANCE_ID 						   NOT NULL NUMBER
 ENCUMBERING_AGENT_ID						   NOT NULL NUMBER
 EXPIRATION_DATE							    DATE
 EXPIRATION_EVENT							    VARCHAR2(60)
 ENCUMBRANCE							   NOT NULL VARCHAR2(60)
 MADE_DATE								    DATE
 REMARKS								    VARCHAR2(255)
 ENCUMBRANCE_ACTION						   NOT NULL VARCHAR2(30)


an expiration date and/or event 
an expiration date 

This agent must have the authority to nullify the encumbrance.
This agent may act in an advisory role; final authority to remove encumbrances rests with the collection.


Specimens under encumbrances which no one has the authority to remove should be considered for de-accession. Encumbrances assigned by persons who cannot be contacted should be removed.
- strike completely -

Expiration Date and/or Event:....
- new paragraph:

Expiration Date: All encumbrances should be temporary. De-accession should be considered for permanently-encumbered specimens. Expiration date may occur no more than 5 years from the current date. Yearly email notifications are provided to 
collection staff, and encumbrances may be extended (in 5-year increments) indefinitely. Expiration date is a triggering event - encumbrances are automaticaly retracted when expiration_date is reached.
