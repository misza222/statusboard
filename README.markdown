Statusboard
===========
Place for keeping history of statuses of your services independently of you application. It is similar in concept to [Heroku](http://status.heroku.com/) or [Github](http://status.github.com/) status pages.

Main concepts
-------------
Service is a single service or application that you want to keep history for.

Event is a single incident that is worth logging in for a specific service.

Statusboard uses [sinatra framework](http://www.sinatrarb.com/) with [DataMapper](http://datamapper.org/) as an ORM. [Bundler](http://gembundler.com/) is used for managing dependencies. On the view side there is [haml](http://haml-lang.com/) for generating xhtml and [yui-css](http://developer.yahoo.com/yui/grids/) as a [css framework](http://en.wikipedia.org/wiki/CSS_framework#CSS_framework).

Demo
----
[public website](http://rstatusboard.heroku.com)

[admin interface](http://rstatusboard.heroku.com/admin/) Login: user, Password: password

What was the idea?
------------------
Fast and simple. And fully tested.

Fast is important as typically status reporting applications receive spikes in traffic when your clients can't use your service. The simplicity means here an easy integration with external reporting systems - you can use REST to perform any action within statusboard.

Features
--------
 * configurable http max-age for public pages to allow caching
 * enforcing SSL for admin interface
 * RESTful interface
 * multiple output formats (xhtml, json, atom)
 * DOM structure to be easily customizable with CSS
 * restful, machine friendly interface for simple integration with monitoring tools

How to deploy?
--------------
Remember to update DataMapper adapter in Gemfile. Available adapters are listed [here](http://rdoc.info/find/github?q=dm-*-adapter).

TODO: links to relevant guides.

Deploying on [heroku](http://www.heroku.com/)
---------------------------------------------
It is really easy to deploy on [heroku](http://www.heroku.com/):

 * Install [heroku gem](http://docs.heroku.com/heroku-command),
 * clone this repo `git clone git@github.com:misza222/magpie.git`,
 * create new application on heroku `cd magpie` and `heroku create`
 * configure application login credentials for admin user `heroku config:add ADMIN_USER=username ADMIN_PASSWORD=user_password`
 * [optional] enforcing SSL encryption for admin actions `heroku addons:add ssl:piggyback` and `heroku config:add ADMIN_REQUIRE_SSL=true`; _as statusboard uses simple http authentication which sends passwords as a clear text through the wire it is a good idea to take this step._

Best practices
--------------
 * This is really obvious but I have to mention it. Do deploy status board in a separate geographical location than service it is providing status for (unless you have no other choice).
 * Change admin user and password by updating statusboard.rb or setting environmental variables ADMIN_USER and ADMIN_PASSWORD.
 * Enforce SSL for admin interface by setting environmental variable ADMIN_REQUIRE_SSL=true
 * Keep max-age low to serve up to date status
 
Customizing layout
------------------
Most customization can be achieved by changing /public/main.css. If what you are after cannot be achieved with existing html structure you need to change the templates. All views are generated from [haml](http://haml-lang.com/) templates. The master template is located in /views/layout.html.haml. Don't forget to run test suite before deployment to test if it is still working!

TODO: Explain DOM structure and what is possible with it.

Running test suite
------------------
Just call `rake test` in project's root folder.
