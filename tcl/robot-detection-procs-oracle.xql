<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="ad_update_robot_list.days_since_last_update">      
      <querytext>
	    select trunc(sysdate - max(nvl(modified_date, insertion_date))) from robots
      </querytext>
</fullquery>
 
</queryset>
