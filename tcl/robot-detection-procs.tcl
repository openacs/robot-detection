ad_library {
    packages/robot-detection/tcl/robot-detection-procs.tcl

    @author Michael Yoon (michael@yoon.org) 
    @author Roger Hsueh (rogerh@arsdigita.com) 
    @creation-date 1999-05-27
    @cvs-id robot-detection-procs.tcl,v 1.2 2002/03/09 02:00:02 donb Exp
}
ad_proc ad_replicate_web_robots_db {} {
Replicates data from the Web Robots Database 
(http://info.webcrawler.com/mak/projects/robots/active.html) into a table in the
database. The data is published on the Web as a flat file, whose format is specified in 
http://info.webcrawler.com/mak/projects/robots/active/schema.txt. Basically, each non-blank 
line of the database corresponds to one field (name-value pair) of a record that defines 
the characteristics of a registered robot. Each record has a "robot-id" field as a unique 
identifier. (There are many fields in the schema, but, for now, the only ones we care about
are: robot-id, robot-name, robot-details-url, and robot-useragent.)<p>Returns the number 
of rows replicated. May raise a Tcl error that should be caught by the caller.
} {
    set web_robots_db_url [ad_parameter WebRobotsDB robot-detection "http://info.webcrawler.com/mak/projects/robots/active/all.txt"]
    if {[catch {set robot_db_text_file [util_httpget $web_robots_db_url]} errmsg]} {
	ns_log Error "ad_replicate_web_robots_db couldn't get the robots file from the web\n"
	global errorInfo
	error $errmsg $errorInfo
    }
    # do line by line processing
    set page [split $robot_db_text_file "\n"]
    
    # on the web robot database's text file, 
    # blocks representing robots are separated by blank lines.
    # that's why we insert a newline for the last record here
    if {[regexp {\w+} [lindex $page [expr  [llength $page] - 1]]]} {
        set page [linsert $page end "\n"]
    }
    
    # we want robots no longer on the webcrawler list to be gone.
    # that's why we just delete the whole table and populate it again.
    db_transaction {
	db_dml delete_old_robots_table {
	    delete from robots
	}
        set robot_id ""
        set robot_name ""
        set robot_details_url ""
        set robot_useragent ""
	foreach line $page {
	    if {![regexp {\w+} $line]} {

                if { [string equal $robot_name ""] } {
                    set robot_name $robot_id
                }

                #detected a blank line, that means we are should try to 
                #insert a row into the robots table, if robot_id and robot_useragent are not null
                if {[exists_and_not_null robot_id] && [exists_and_not_null robot_useragent]} {
                    db_dml insert_new_robot {
                        insert into robots(robot_id, robot_name, robot_details_url, robot_useragent)
                        values
                        (:robot_id, :robot_name, :robot_details_url, :robot_useragent)
                    }
                }
                # start clean for a new record
                set robot_id ""
                set robot_name ""
                set robot_details_url ""
                set robot_useragent ""
                continue
            }

	    if {[regexp {robot-id:\s*([^\s]+)\s*} $line match robot_id] ||
            [regexp {robot-name:\s*([^\s]+)\s*} $line match robot_name] ||
            [regexp {robot-details-url:\s*([^\s]+)\s*} $line match robot_details_url] ||
            [regexp {robot-useragent:\s*([\s]+)\s*} $line match robot_useragent] } {
                continue
            }
	}
    } on_error { 
	ns_log Error  "ad_replicate_web_robots_db had problem with database operations\n"
	return -code error $errmsg
    }
    return [db_string num_of_robots "select count(*) from robots"]

}


ad_proc ad_cache_robot_useragents {} {Caches "User-Agent" values for known robots} {
    db_foreach populate_useragents_cache {select robot_useragent from robots} {
	nsv_set ad_robot_useragent_cache $robot_useragent 1
    }
}

ad_proc robot_exists_p {robot_id} {Returns 1 if a row already exists in the robots table with the specified "robot_id", 0 otherwise.} {
    set sql {
	select decode(count(*),0,0,1) from robots where robot_id = :robot_id
    }
    return [db_string return_1_if_robot_exists $sql]
}

ad_proc robot_p {useragent} {Returns 1 if the useragent is recognized as a search engine, 0 otherwise.} {
    # Memoize so we don't need to query the robots table for every single HTTP request.
    util_memoize ad_cache_robot_useragents
    return [nsv_exists ad_robot_useragent_cache $useragent]
}

ad_proc ad_robot_filter {conn args why} {A filter to redirect any recognized robot to a specified page} {
    set useragent [ns_set get [ad_conn headers] "User-Agent"]
    if [robot_p $useragent] {
	set robot_detection_id	[db_string robot_detection_id {select package_id from apm_packages where package_key = 'robot-detection'} ]
	set robot_redirect_url [ad_parameter -package_id $robot_detection_id RedirectURL]
	# Be sure to avoid an infinite loop of redirects. (Actually, browsers
	# won't look infinitely; rather, they appear to abort after a URL
	# redirects to itself.)
	if { [exists_and_not_null robot_redirect_url] && [string first $robot_redirect_url [ad_conn url]] != 0 } {
	    # requested URL does not start with robot redirect URL (usually a dir)
	    ns_log Notice "Robot being bounced by ad_robot_filter: User-Agent = $useragent"
	    ad_returnredirect $robot_redirect_url
	    return "filter_return"
	} else {
	    # we've got a robot but he is happily in robot heaven
	    return "filter_ok"
	}
    }
    return "filter_ok"
}

ad_proc ad_update_robot_list {} {Will update the robots table if it is empty or
if the number of days since it was last updated is greater than the number of days
specified by the RefreshIntervalDays configuration parameter 
} {
    db_transaction {
	set robot_count [db_string robot_count {select count(*) from robots} ]
	if {$robot_count == 0} {
	    ns_log Notice "Replicating Web Robots DB, because robots table is empty"
	    ad_replicate_web_robots_db
	} else {
	    set refresh_interval [ad_parameter RefreshIntervalDays robot-detection 30]
	    set days_old [db_string days_since_last_update {
		select trunc(sysdate - max(nvl(modified_date, insertion_date))) from robots} ]
		if {$days_old >= $refresh_interval} {
		    ns_log Notice "Replicating Web Robots DB, because data in robots table has expired"
		    ad_replicate_web_robots_db 
		} else {
		    ns_log Notice "Not replicating Web Robots DB at this time, because data in the robots table has not expired"
		}
	    }
	} on_error {
	    return -code error $errmsg
	}
    }




