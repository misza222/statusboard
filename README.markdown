RESTful status board
====================

Entities:
  Service: Name, Description
  Event: Name, Description, StartTime
  Admins: Name, email, password

url scheme:

/
  GET  - lists all services
  POST - create new service
  PUT  - update service
  DELETE - delete service

/service/
  GET  - parameters count=1
  POST - parameters timestamp=now
  PUT  - v2 updating event?
  DELETE - v2

Additional Futures
==================
 * extract authorization helper tests from testing statusboard
 * test get_service_or_404
 * twitter and blog integration (as plugins?) (maybe do both via web hooks?)
 * view customization via css stored on the web (link to it as a parameter)
 * test rss validity in unit tests
 * see older statuses (as currently there is a limit of 20/page)
 * think of updating statuses as in http://sinatra-book.gittr.com/#status

V2
==
 * authentication with openID?
 * authentication for GET actions in v2
 * rely upon (if relied upon provider has outage we do as well)
 * nagios plugin? 
 * historical values sliding through when clicking on prev/next (jquery & ajax)

Find domain and polish domain (buy for free @ domeny.pl)

platform: sinatra + datamapper + html + css

Later
=====
Database engine: couchdb as REST is native there?
