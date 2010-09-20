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
    format.html { haml :services, :layout => !request.xhr? }
    format.json { @services.to_a.to_json }
    format.rss  { builder :services }
  end
end

# new service
post '/' do
  service = Service.create(params[:service])

  400 unless service.save
end

# get entries for the service
get '/:service/?' do
  @service = Service.first(:id => params[:service])
  
  if @service.nil?
    404
  else
    @events = @service.events.all(:limit => 20, :order => [ :created_at.desc ])
    
    respond_to do |format|
      format.html { haml :events, :layout => !request.xhr? }
      format.json { @events.to_a.to_json }
      format.rss  { builder :events }
    end
  end
end

# new entry
post '/:service/?' do
  service = Service.first(:id => params[:service])
  
  if service.nil?
    404
  else
    event = Event.new(params[:event])
    event.service = service
    
    400 unless event.save
  end
end
