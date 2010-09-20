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
  DELETE

/service
  GET  - parameters count=1
  POST - parameters timestamp=now
  PUT  - v2 updating event?
  DELETE - v2

Authentication
==============

simple http authentication for anything but GET actions
config to make it available via secure protocol


Additional Futures
==================
 * twitter and blog integration (as plugins?) (maybe do both via web hooks?)
 * view customization via css stored on the web (link to it as a parameter)
 * test rss validity in unit tests

V2
==
 * authentication for GET actions in v2
 * rely upon (if relied upon provider has outage we do as well)
 * nagios plugin? 
 * historical values sliding through when clicking on prev/next (jquery & ajax)

Find domain and polish domain (buy for free @ domeny.pl)

platform: sinatra + datamapper + html + css

Later
=====
Database engine: couchdb as REST is native there?
