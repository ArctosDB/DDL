/*
 mkoo email Google Maps API keys
 from Tech Google Support:

Since your Geocoding request is through web service (server-side), you must restrict the API Key using IP restriction (IP addresses (web servers, cron jobs, etc.)) with your server's public facing IP address. And if you are making a Javascript request for loading a map (client-side), the you must use a separate API Key with HTTP referrer restrictions (web sites). To learn more on how to properly restrict an API Key, please see this guide [1].  https://developers.google.com/maps/api-key-best-practices

*/

alter table cf_global_settings add GMAP_API_KEY_INTERNAL VARCHAR2(255);
alter table cf_global_settings add GMAP_API_KEY_EXTERNAL VARCHAR2(255);
update cf_global_settings set GMAP_API_KEY_INTERNAL=GMAP_API_KEY,GMAP_API_KEY_EXTERNAL=GMAP_API_KEY;
update cf_global_settings set GMAP_API_KEY_INTERNAL='AIzaSyA9aghD3JxP5b0R6-8SfMiozqEXsoFdvXM';
update cf_global_settings set GMAP_API_KEY_EXTERNAL='AIzaSyD4WFxJ_Uk7y0DH_W8lRRgNVK5xnW9abM';


update cf_global_settings set GMAP_API_KEY_INTERNAL='AIzaSyCVzoUKYVNasblHJ897crFAHW2comF8EC0';
update cf_global_settings set GMAP_API_KEY_EXTERNAL='AIzaSyCVzoUKYVNasblHJ897crFAHW2comF8EC0';


update cf_global_settings set GMAP_API_KEY_INTERNAL='AIzaSyA9aghD3JxP5b0R6-8SfMiozqEXsoFdvXM';
update cf_global_settings set GMAP_API_KEY_EXTERNAL='AIzaSyD4WFxJ_Uk7y0DH_W8lRRgNVK5xnW9abMc';



update cf_global_settings set GMAP_API_KEY_INTERNAL='AIzaSyAhHlrIRXhnZ51XCGcwUAWLOH-jIiLuZvM';
update cf_global_settings set GMAP_API_KEY_EXTERNAL='AIzaSyDxG46VNuWXLNN6FVGfybv-gTmq4ZlB6b4';


NEW INTERNAL:


NEW EXTERNAL:


GMAP_API_KEY_INTERNAL -->    
------------------------------------------------------------------------------------------------------------------------
GMAP_API_KEY_EXTERNAL -->



alter table cf_global_settings add mapbox_token VARCHAR2(255);
update cf_global_settings set mapbox_token='pk.eyJ1IjoiYXJjdG9zIiwiYSI6ImNqdndnM2NrYjAwYXM0OHJnMDUyZnVvY3UifQ._Jg9O0eUm_HwS4o_Zb9Zeg';






arctos client key (limited to our tld): 
arctos server key (limited to our IP address): 
		select GMAP_API_KEY from cf_global_settings

		
		Google Maps API keys