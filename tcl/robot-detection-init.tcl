ad_library {
 packages/robot-detection/tcl/robot-detection-init.tcl
 Initialization routine for robot-detection

@author Roger Hsueh (rogerh@arsdigita.com) 2000-12-04
@creation-date 2000-12-04
@cvs-id $Id$
}

# DRB: If the package is mounted check for robots.  Since it's a singleton package
# we know there are only zero or one instances.

if { [db_0or1row robot_detection_id ""] } {

    # Check to see if the robots table needs to be updated
    # when the server starts (5 seconds after to be precise).
    ad_schedule_proc -once t 5 ad_update_robot_list

    #FilterPattern is a comma separated value of URLs that you want to filter
    set filter_pattern_parameter [string trim [ad_parameter -package_id $package_id FilterPattern]]
    set filter_pattern_list [split $filter_pattern_parameter ","] 

    # Install ad_robot_filter for all specified patterns
    foreach filter_pattern $filter_pattern_list {
        ns_log Notice "Installing robot filter for $filter_pattern\n"
        set filter_pattern [ad_urlencode [string trim $filter_pattern]]
        ad_register_filter postauth GET $filter_pattern ad_robot_filter
    }
}
