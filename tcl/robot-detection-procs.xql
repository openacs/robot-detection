<?xml version="1.0"?>
<queryset>

<fullquery name="ad_replicate_web_robots_db.delete_old_robots_table">      
      <querytext>
      
	    delete from robots
	
      </querytext>
</fullquery>

 
<fullquery name="ad_replicate_web_robots_db.insert_new_robot">      
      <querytext>
      
                        insert into robots(robot_id, robot_name, robot_details_url, robot_useragent)
                        values
                        (:robot_id, :robot_name, :robot_details_url, :robot_useragent)
                    
      </querytext>
</fullquery>

 
<fullquery name="ad_replicate_web_robots_db.num_of_robots">      
      <querytext>
      select count(*) from robots
      </querytext>
</fullquery>

 
<fullquery name="ad_cache_robot_useragents.populate_useragents_cache">      
      <querytext>
      select robot_useragent from robots
      </querytext>
</fullquery>

 
<fullquery name="ad_robot_filter.robot_detection_id">      
      <querytext>
      select package_id from apm_packages where package_key = 'robot-detection'
      </querytext>
</fullquery>

 
<fullquery name="ad_update_robot_list.robot_count">      
      <querytext>
      select count(*) from robots
      </querytext>
</fullquery>

 
<fullquery name="ad_update_robot_list.days_since_last_update">      
      <querytext>
      
		select trunc(current_time - max(coalesce(modified_date, insertion_date))) from robots
      </querytext>
</fullquery>

 
</queryset>
