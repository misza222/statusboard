require 'rubygems'
require 'bundler/setup'

require 'sinatra'

require 'lib/models'

# get status for all services
get '/' do
  Service.all.to_a.to_json
end

# new service
post '/' do
    service = Service.new(params[:service])
    if ! service.save
      error "Service not created. Incorrect parameters. Fix and resubmit."
    end
end

# get entries for the service
get '/:service/?' do
  service = Service.first(:id => params[:service])
  if ! service.nil?
    service.events.all.to_a.to_json
  else
    [].to_json
  end
end

# new entry
post '/:service/?' do
  service = Service.first(:id => params[:service])
  if ! service.nil?
    event = Event.new(params[:event])
    event.service = service
    if ! event.save
      error "Event not created. Incorrect parameters. Fix and resubmit."
    end
  else
    error "Service not found."
  end
end
