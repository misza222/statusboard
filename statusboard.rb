require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/respond_to'
require 'haml'

require 'lib/models'

Sinatra::Application.register Sinatra::RespondTo

set :board_name, 'Status board'
set :board_description, 'Default description'

set :user, 'username'
set :password, '12password34'

helpers do
  def protected!
    throw(:halt, [401, "Not found\n"]) unless authorized?
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials &&
      @auth.credentials == [settings.user, settings.password]
  end
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
  protected!
  
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
  protected!
  
  service = Service.first(:id => params[:service])
  
  if service.nil?
    404
  else
    event = Event.new(params[:event])
    event.service = service
    
    400 unless event.save
  end
end
