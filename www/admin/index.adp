<master>
<property name="title">Robot Detection Administration</property>
<property name="context"></property>

Documentation:  <a href="/doc/robot-detection">/doc/robot-detection</a>

<h3>Configuration Settings</h3>

The current configuration settings are:<br>
<code>
WebRobotsDB=@web_robots_db@<br>
RedirectURL=@redirect_url@<br>
<multiple name="filter_patterns">
FilterPattern=@filter_patterns.item@
</multiple>

</code>

<h3>Known Robots</h3>

<p>

Courtesy of the <a href="http://info.webcrawler.com/mak/projects/robots/active.html">Web Robots Database</a>,
this installation of the ACS can recognize the following robots:

<ul>

<if @robots:rowcount@ eq 0>
        <li>no robots registered
</if>
<multiple name="robots">
        <if @robots.robot_details_url@ not nil>
                <li><a href="@robots.robot_details_url@">@robots.robot_name@</a>
        </if>
        <else>
                <li>@robots.robot_name@
        </else>
</multiple>
<p>
<li><a href="refresh-robot-list">refresh list from the Web Robots Database</a>
</ul>
