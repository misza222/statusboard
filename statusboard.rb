require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/respond_to'
require 'haml'

require 'lib/models'

Sinatra::Application.register Sinatra::RespondTo


error 400 do
  'Input data incorrect'
end

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
  service = Service.create(params[:service])
  
  if ! service.save
    400
  end
end

# get entries for the service
get '/:service/?' do
  service = Service.first(:id => params[:service])
  
  if service.nil?
    404
  else
    @events = service.events.all(:limit => 20, :order => [ :created_at.desc ])
    
    respond_to do |format|
      format.html { haml :events }
      format.json { @events.to_a.to_json }
    end
  end
end

# new entry
post '/:service/?' do
  service = Service.first(:id => params[:service])
  if ! service.nil?
    event = Event.new(params[:event])
    event.service = service
    if ! event.save
      400
    end
  else
    404
  end
end
