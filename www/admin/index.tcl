ad_page_contract {
    packages/robot-detection/www/admin/index.tcl
    Shows the current parameters.
    Lists all registered robots and enables the site admin
    to refresh the list.
    @author Michael Yoon (michael@yoon.org)
    @author Roger Hsueh (rogerh@arsdigita.com)
    @creation-date 2000-12-13
    @cvs-id $Id$
} -properties {
    context:onevalue
    web_robots_db:onevalue
    filter_patterns:multirow
    redirect_url:onevalue
    robots:multirow
}
set context {}
set web_robots_db [ad_parameter WebRobotsDB]

set filter_patterns_list [join [ad_parameter FilterPattern] "\n"]

# fake a multirow, because onelist doesn't work 
# (see the switch statement in packages/acs-tcl/tcl/document-procs.tcl)
set filter_count 0
foreach filter $filter_patterns_list {
    incr filter_count
    set filter_patterns:[set filter_count](item) $filter
}
set filter_patterns:rowcount $filter_count

set redirect_url [ad_parameter RedirectURL]
db_multirow robots robots_query "select robot_name, robot_details_url from robots order by robot_name"
