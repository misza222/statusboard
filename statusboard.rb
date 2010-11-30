require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/respond_to'
require 'haml'

require 'lib/models'

Sinatra::Application.register Sinatra::RespondTo

set :board_name,        'Status board'
set :board_description, 'Default description'
set :cache_max_age,     60 # http cache max_age for public get actions http://tools.ietf.org/html/rfc2616#section-14.9.1

set :admin_user,        ENV['ADMIN_USER'] || 'user'
set :admin_password,    ENV['ADMIN_PASSWORD'] || 'password'
set :admin_require_ssl, false

helpers do  
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
    ! (/^\/admin\// =~ request.path).nil?
  end
  
  def get_service_or_404(params)
    service = nil
    service = Service.first(:id => params[:service_id]) if %r{^\d+$} =~ params[:service_id]
    service = Service.first(:name => params[:service_id]) if service.nil?
    
    not_found! if service.nil?
    
    service
  end
  
  def bad_request!;         throw(:halt, [400, "Bad request\n"]);         end
  def not_authorized!;      throw(:halt, [401, "Not authorized\n"]);      end
  def encription_required!; throw(:halt, [403, "Encription required\n"]); end
  def not_found!;           throw(:halt, [404, "Not found\n"]);           end
  
  def button_link_tag(caption, location)
    "<input type=\"button\" value=\"#{caption}\" onclick=\"javascript: location.href='#{get_full_url_by_location(location)}'\" class=\"button\" />"
  end
  
  def link_tag(caption, location)
    "<a href='#{get_full_url_by_location(location)}'>#{caption}</a>"
  end
  
  def button_delete_tag(caption, location, message)
    "<form method=\"post\" action=\"#{get_full_url_by_location(location)}\" onsubmit=\"javascript: return confirm('#{message}')\" style=\"display: inline;\">"+
    "  <input type=\"hidden\" name=\"_method\" value=\"delete\" />"+
    "  <input type=\"submit\" value=\"#{caption}\" />"+
    "</form>"
  end
  
  def get_full_url_by_location(location)
    "#{admin_url? ? '/admin' : ''}#{location}"
  end
end

before do
  if admin_url?
    encription_required! if settings.admin_require_ssl && ! ssl?
    if ! authorized?
      response['WWW-Authenticate'] = %(Basic realm="#{settings.board_name} Auth")
      not_authorized!
    end
  end
end

after do
  (cache_control :public, :max_age => settings.cache_max_age) if [404,200].include?(response.status) && request.get? && ! admin_url?
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

post '/admin/' do
  service = Service.create(params[:service])

  bad_request! unless service.save
    
  redirect '/admin/'
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
  
  bad_request! if params[:service].nil? || params[:service].empty? || ! @service.update(params[:service])
    
  redirect '/admin/'
end

get '/admin/:service_id/new' do
  @service = get_service_or_404(params)
  @event = Event.new(:service => @service)
  
  haml :'events/new'
end

delete '/admin/:service_id' do
  service = get_service_or_404(params)
  
  bad_request! unless service.events.destroy && service.destroy
  
  redirect '/admin/'
end

post '/admin/:service_id/' do
  service = get_service_or_404(params)
  
  event = Event.new(params[:event])
  event.service = service
  
  bad_request! unless event.save
  
  redirect "/admin/#{service.id}/"
end

get '/admin/:service_id/:event_id/edit' do
  @service = get_service_or_404(params)
  @event = @service.events.first(:id => params[:event_id])
  
  not_found! if @event.nil?
    
  haml :'events/edit'
end

put '/admin/:service_id/:event_id' do
  service = get_service_or_404(params)
  event = service.events.first(:id => params[:event_id])
  
  not_found!   if event.nil?
  bad_request! if params[:event].nil? || params[:event].empty? || ! event.update(params[:event])
    
  redirect "/admin/#{service.id}/"
end
