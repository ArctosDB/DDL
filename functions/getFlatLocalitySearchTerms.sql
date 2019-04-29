 create or replace function getFlatLocalitySearchTerms(cid in number) return varchar2 as
   	trms varchar2(4000);
   	begin
      select substr(terms,0,4000) into trms from (
					select listagg(term,', ') within group(order by term) terms
					  from (
							select
						    	upper(geog_search_term.search_term) term
						    from
								specimen_event,
						    	collecting_event,
						    	locality,
						    	geog_search_term
							where
								specimen_event.collecting_event_id=collecting_event.collecting_event_id and
								collecting_event.locality_id=locality.locality_id and
								locality.geog_auth_rec_id=geog_search_term.geog_auth_rec_id and								
								specimen_event.collection_object_id=cid
							UNION
								select
									upper(spec_locality) term
								from
									specimen_event,
									collecting_event,
									locality
								where
									spec_locality is not null and
									specimen_event.collecting_event_id=collecting_event.collecting_event_id and
									collecting_event.locality_id=locality.locality_id and							
									specimen_event.collection_object_id=cid
							UNION
								select
									upper(LOCALITY_NAME) term
								from
									specimen_event,
									collecting_event,
									locality
								where
									spec_locality is not null and
									specimen_event.collecting_event_id=collecting_event.collecting_event_id and
									collecting_event.locality_id=locality.locality_id and							
									specimen_event.collection_object_id=cid
							UNION
								select
									upper(S$GEOGRAPHY) term
								from
									specimen_event,
									collecting_event,
									locality
								where
									spec_locality is not null and
									specimen_event.collecting_event_id=collecting_event.collecting_event_id and
									collecting_event.locality_id=locality.locality_id and							
									specimen_event.collection_object_id=cid
						UNION
								select
									upper(higher_geog) term
								from
									specimen_event,
							    	collecting_event,
							    	locality,
							    	geog_auth_rec
								where
									specimen_event.collecting_event_id=collecting_event.collecting_event_id and
									collecting_event.locality_id=locality.locality_id and
									locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and								
									specimen_event.collection_object_id=cid
							UNION
								select
									upper(verbatim_locality) term
								from
									specimen_event,
									collecting_event
								where
									verbatim_locality is not null and
									specimen_event.collecting_event_id=collecting_event.collecting_event_id and								
									specimen_event.collection_object_id=cid
					)
				) ;
				
				return trms;
			end;
			/
			sho err;
				
			create or replace public synonym getFlatLocalitySearchTerms for getFlatLocalitySearchTerms;
			grant execute on getFlatLocalitySearchTerms to public;
			