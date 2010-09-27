RESTful status board
====================
Place for keeping history of statuses of your services independently of you application. It is similar in concept to [Heroku](http://status.heroku.com/) or [Github](http://status.github.com/) status pages.

Main concepts
-------------
Service is a single service or application that you want to keep history for.

Event is a single incident that is worth logging in for a specific service.

As you know that play with demo and you will be flying.

Demo
----
[public website](http://statusboard.heroku.com)

[admin interface](http://statusboard.heroku.com/admin/) Login: user, Password: password

What was the idea?
------------------
Simple, fast and simple. And of course simple. And fully tested.

Features
--------
 * configurable http cache control for public pages
 * enforcing ssl for admin interface
 * multiple output format (xhtml, json, atom)
 * dom structure to be easily customizable with css
 * restful, machine friendly interface for simple integration with monitoring tools

How to deploy?
--------------
It is really easy to deploy it on heroku. Just clone repo from github, create application on heroku, push to heroku and off you go. It would be good to change default admin_user and admin_password. Application accepts env variables. As this version of status board is using simple http authentication which sends passwords as a clear text through the wire it is a good idea to enforce ssl for all admin actions. To do this you need to install ssl addon and update application config. 
