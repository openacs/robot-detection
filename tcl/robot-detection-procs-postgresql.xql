<?xml version="1.0"?>
<queryset>
 
<fullquery name="ad_update_robot_list.days_since_last_update">      
      <querytext>
		select trunc(current_time - max(coalesce(modified_date, insertion_date))) from robots
      </querytext>
</fullquery>
 
</queryset>
