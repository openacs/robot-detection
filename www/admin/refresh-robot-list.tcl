ad_page_contract {
    packages/robot-detection/www/admin/refresh-robot-list.tcl

    calls ad_replicate_web_robots_db, which
    refreshes the robots table

    @author Michael Yoon  (michael@yoon.org)
    @author Roger Hsueh (rogerh@arsdigita.com)
    @creation-date 2000-12-07
    @cvs-id: $Id$
}

if [catch {ad_replicate_web_robots_db} errmsg] {
    ad_return_error "ad_replicated_web_robots_db failed:" $errmsg
    ad_script_abort
}

ad_returnredirect "index"

