--
-- packages/robot-detection/sql/robot-detection.sql
--
-- @author Michael Yoon (michael@yoon.org)
-- @author Roger Hsueh (rogerh@arsdigita.com)
-- @creation-date 05/27/1999
-- @cvs-id $Id$

-- defines a table in which to store info from the Web Robots Database
-- (http://info.webcrawler.com/mak/projects/robots/active.html), which
-- mirrors parts of the schema at:
-- http://info.webcrawler.com/mak/projects/robots/active/schema.txt
--
-- rogerh@arsdigita.com 2000-12-06
-- got rid of unused trigger and table definitions
--
create table robots (
	--
	-- robot_id is *not* a generated key.
	--
	robot_id                        varchar(100) 
                                        constraint robots_robots_id_pk 
                                        primary key,
        -- robot_name and robot_details_url are used for UI only
	robot_name                      varchar(100) not null,
	robot_details_url               varchar(200),
	robot_useragent                 varchar(100) not null,
	-- insertion_date records when this row was actually inserted
	-- used to determine if we need to re-populate the table from
	-- the text file at Web Robots DB.
	insertion_date                  date default now() not null
);
