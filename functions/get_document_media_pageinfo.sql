-- this doesn't work in test for some reason as of 2018-08-14
-- works fine in prod
-- to_number somehow corrupted in test??

/*
 * this function works ONLY with MediaSearch to inject MPD contents
 * do not modify one without changing the other
 */

set escape \

CREATE OR REPLACE function get_document_media_pageinfo (urltitle IN varchar2, page IN number) return clob as
    published_year VARCHAR2(4000);
    document_title VARCHAR2(4000);
    max_page_number NUMBER;
    creator varchar2(4000);

    theHTML clob;
    firstrow number;
    lastrow number;
    
    pagesize number := 100;
    
    
    temp varchar2(4000);

BEGIN
	if page=1 then
		firstrow:=page;
	else
		firstrow:=(page-1) * pagesize;
	end if;
	lastrow:=firstrow+pagesize-1;
	
  select 
    max(to_number(page.label_value)),
    title.label_value,
    published_year.label_value  ,
    getPreferredAgentName(RELATED_PRIMARY_KEY) creator
    into
    max_page_number,
    document_title,
    published_year,
    creator
  from 
    (select media_id,label_value from media_labels where media_label='page') page,
    (select media_id,label_value from media_labels where media_label='title') title,
    (select media_id,label_value from media_labels where media_label='published year') published_year,
    media_relations
  where
    title.media_id =page.media_id and  
    title.media_id =media_relations.media_id and 
    media_relations.media_relationship='created by agent' and
    title.media_id=published_year.media_id (+) and
    niceURLNumbers(title.label_value)=urltitle
  group by
    title.label_value,
    published_year.label_value ,
    getPreferredAgentName(RELATED_PRIMARY_KEY)
    ;
    theHTML:=TO_CLOB('<div>' || document_title || '<br>Created by: ' || creator || '<br>' || 'Contains ' || max_page_number || ' pages.');
    if published_year is not null then
       theHTML:=theHTML || TO_CLOB('<br>Published ' || published_year);
    end if;
    for spg in (
         select 
            page.label_value pgnum,
            description.label_value descr,
            decode(count(tag_id),0,NULL,1,' (1 TAG)',' (' ||  count(tag_id) || ' TAGs)') tags
        from 
            (select media_id,label_value from media_labels where media_label='page') page,
            (select media_id,label_value from media_labels where media_label='title') title,
            (select media_id,label_value from media_labels where media_label='description') description,
            tag
        where
            title.media_id =page.media_id and
            title.media_id=tag.media_id (+) and
            title.media_id=description.media_id and
            niceURLNumbers(title.label_value)=urltitle and
            to_number(page.label_value) between firstrow and lastrow
        group by
            page.label_value,
            description.label_value
        order by
           to_number(page.label_value)
      ) loop
         theHTML:= theHTML || TO_CLOB('<br>page ' || spg.pgnum || ': <a href="/document/' ||  urltitle || '/' || spg.pgnum || '">Description: ' || spg.descr || '</a>' || spg.tags);
    end loop;
    temp:='<div>';	
    if firstrow>1 then
    	temp:= temp || '<span class="likelink" onclick="getDocumentMediaPageInfo(''' || urltitle || ''',' || (page-1) || ');">[\&nbsp;previous\&nbsp;]</span>';
    end if;
    temp:= temp || '\&nbsp;\&nbsp;\&nbsp;';
     if lastrow<max_page_number then
    	temp:= temp || '<span class="likelink" onclick="getDocumentMediaPageInfo(''' || urltitle || ''',' || (page+1) || ');">[\&nbsp;next\&nbsp;]</span>';
    end if;
    
    
    
    temp:= temp || '</div>';	
    
    theHTML:= theHTML || TO_CLOB(temp);
     
     
    --max_page_number
    theHTML:= theHTML || TO_CLOB('</div>');
    return theHTML;               
   end;
   /

   sho err;

   
   create or replace public synonym get_document_media_pageinfo for get_document_media_pageinfo;
   grant execute on get_document_media_pageinfo to public;
   
   
--  select get_document_media_pageinfo('robert-l-rausch-necropsy-ledger',10) result from dual;