require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/respond_to'
require 'haml'

require 'lib/models'

Sinatra::Application.register Sinatra::RespondTo

set :board_name,        'Status board'
set :board_description, 'Default description'

set :admin_user,        ENV['ADMIN_USER'] || 'user'
set :admin_password,    ENV['ADMIN_PASSWORD'] || 'password'
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
  
  def admin_url?
    ! (request.path =~ /^\/admin\//).nil?
  end
  
  def get_service_or_404(params)
    service = nil
    
    service = Service.first(:id => params[:service_id]) if %r{^\d+$} =~ params[:service_id]
    service = Service.first(:name => params[:service_id]) if service.nil?
    
    if service.nil?
      throw(:halt, [404, "Not found\n"])
    else
      service
    end
  end
  
  def button_link_tag(caption, location, options = {})
    "<input type=\"button\" value=\"#{caption}\" onclick=\"javascript: location.href='#{location}'\" class=\"button\" />"
  end
  
  def button_delete_tag(caption, location, message, options = {})
    "<form method=\"post\" action=\"#{location}\" onsubmit=\"javascript: return confirm('#{message}')\" style=\"display: inline;\">"+
    "  <input type=\"hidden\" name=\"_method\" value=\"delete\" />"+
    "  <input type=\"submit\" value=\"#{caption}\" />"+
    "</form>"
  end
end

before do
  if admin_url?
    # protect all admin urls
    protected!
  else
    # cache all 'public' urls
    (cache_control :public, :max_age => 60) if request.get?
  end
end

['/','/admin/'].each do |path|
  get path do
    @services = Service.all
    
    respond_to do |format|
      format.html { haml :'services/index', :layout => !request.xhr? }
      format.json { @services.to_a.to_json }
      format.rss  { builder :'services/index' }
    end
  end
end

get '/admin/new' do
  @service = Service.new
  
  haml :'services/new'
end

# new service
post '/admin/' do
  service = Service.create(params[:service])

  if ! service.save
    400
  else
    redirect '/admin/'
  end
end

['/:service_id/','/admin/:service_id/'].each do |path|
  get path do
    @service = get_service_or_404(params)
    
    @limit = params[:limit].to_i
    @limit = 20 unless @limit > 0
    @page  = params[:page].to_i
    @page  = 0 unless @page >= 0 # pages start from 0, so for humans +1
    
    @total_events = @service.events.count
    
    @events = @service.events.all(:limit => @limit, :offset => @limit * @page, :order => [ :created_at.desc ])
    
    respond_to do |format|
      format.html { haml :'events/index', :layout => !request.xhr? }
      format.json { @events.to_a.to_json }
      format.rss  { builder :'events/index' }
    end
  end
end

get '/admin/:service_id/edit' do
  @service = get_service_or_404(params)
  
  haml :'services/edit'
end

put '/admin/:service_id' do
  @service = get_service_or_404(params)
  
  if params[:service].nil? || params[:service].empty?
    400
  elsif ! @service.update(params[:service])
    400
  else
    redirect '/admin/'
  end
end

get '/admin/:service_id/new' do
  @service = get_service_or_404(params)
  @event = Event.new(:service => @service)
  
  haml :'events/new'
end

delete '/admin/:service_id' do
  @service = get_service_or_404(params)
  
  if ! @service.events.destroy || ! @service.destroy
    400
  else
    redirect '/admin/'
  end
end

post '/admin/:service_id/' do
  service = get_service_or_404(params)
  
  event = Event.new(params[:event])
  event.service = service
  if ! event.save
    400
  else
    redirect "/admin/#{service.id}/"
  end
end

get '/admin/:service_id/:event_id/edit' do
  @service = get_service_or_404(params)
  @event = @service.events.first(:id => params[:event_id])
  
  if @event.nil?
    404
  else
    haml :'events/edit'
  end
end

put '/admin/:service_id/:event_id' do
  service = get_service_or_404(params)
  event = service.events.first(:id => params[:event_id])
  
  if event.nil?
    404
  elsif params[:event].nil? || params[:event].empty?
    400
  elsif ! event.update(params[:event])
    400
  else
    redirect "/admin/#{service.id}/"
  end
end
