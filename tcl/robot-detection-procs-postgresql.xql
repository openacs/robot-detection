<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="ad_update_robot_list.days_since_last_update">      
      <querytext>
		select trunc(current_timestamp - max(coalesce(modified_date, insertion_date))) from robots
      </querytext>
</fullquery>
 
</queryset>
