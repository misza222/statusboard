require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/respond_to'
require 'haml'

require 'lib/models'

Sinatra::Application.register Sinatra::RespondTo

# get status for all services
get '/' do
  @services = Service.all
  
  respond_to do |format|
    format.html { haml :index }
    format.json { @services.to_a.to_json }
  end
end

# new service
post '/' do
    service = Service.new(params[:service])
    if ! service.save
      error "Service not created. Incorrect parameters. Fix and resubmit."
    end
end

# get entries for the service
get %r{/([0-9]+)/?$} do |service_id|
  service = Service.first(:id => service_id)
  if service.nil?
    @events = []
  else
    @events = service.events.all
  end
  
  respond_to do |format|
    format.html { haml :events }
    format.json { @events.to_a.to_json }
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
