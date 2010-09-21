require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/respond_to'
require 'haml'

require 'lib/models'

Sinatra::Application.register Sinatra::RespondTo

set :board_name,        'Status board'
set :board_description, 'Default description'

set :admin_user,        'username'
set :admin_password,    '12password34'
set :admin_require_ssl, false

helpers do
  def protected!
    throw(:halt, [403, "Encription required\n"]) if settings.admin_require_ssl && ! ssl?
    if ! authorized?
      response['WWW-Authenticate'] = %(Basic realm="#{settings.board_name} Auth")
      throw(:halt, [401, "Not authorized\n"])
    end
  end
  
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials &&
      @auth.credentials == [settings.admin_user, settings.admin_password]
  end
  
  def ssl?
    # If https is done with encoding proxy rack may not be aware thus testing HTTP_X_FORWARDED_PROTO header
    request.scheme == 'https' || env["HTTP_X_FORWARDED_PROTO"] == 'https'
  end
end

get '/login' do
  protected!
  
  redirect '/'
end

# get status for all services
get '/' do
  @services = Service.all
  
  respond_to do |format|
    format.html { haml :'services/index', :layout => !request.xhr? }
    format.json { @services.to_a.to_json }
    format.rss  { builder :'services/index' }
  end
end

get '/new' do
  protected!
  
  @service = Service.new
  
  haml :'services/new'
end

# new service
post '/' do
  protected!
  
  service = Service.create(params[:service])

  400 unless service.save
end

# get entries for the service
get '/:service_id/' do
  @service = Service.first(:id => params[:service_id])
  
  if @service.nil?
    404
  else
    @events = @service.events.all(:limit => 20, :order => [ :created_at.desc ])
    
    respond_to do |format|
      format.html { haml :'events/index', :layout => !request.xhr? }
      format.json { @events.to_a.to_json }
      format.rss  { builder :'events/index' }
    end
  end
end

# get form to edit service
get '/:service_id/edit' do
  protected!
  
  @service = Service.first(:id => params[:service_id])
  
  if @service.nil?
    404
  else
    haml :'services/edit'
  end
end

# updates service
put '/:service_id' do
  protected!
  
  @service = Service.first(:id => params[:service_id])
  
  if @service.nil?
    404
  elsif params[:service].nil? || params[:service].empty?
    400
  else
    400 unless @service.update(params[:service])
  end
end

get '/:service_id/new' do
  protected!
  
  @service = Service.first(:id => params[:service_id])
  
  if @service.nil?
    404
  else
    @event = Event.new(:service => @service)
    
    haml :'events/new'
  end
end

# new entry
post '/:service_id/' do
  protected!
  
  service = Service.first(:id => params[:service_id])
  
  if service.nil?
    404
  else
    event = Event.new(params[:event])
    event.service = service
    
    400 unless event.save
  end
end
