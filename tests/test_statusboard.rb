require File.dirname(__FILE__) + '/tests_helper'
require File.dirname(__FILE__) + '/../statusboard'
require 'base64'

# to avoid tilts complaints about using builder in a non safe environment
require 'builder'

class StatusboardTest < Test::Unit::TestCase
  include Test::Unit::Setup
 
  def setup
    # I need to set default config options here as changing it in one of the
    # tests changes it for good
    set :admin_require_ssl, false
  end
  
  context "GET on '/login'" do
    should "redirect to '/'" do
      get '/login', {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert last_response.redirect?
      follow_redirect!
      assert_equal '/', last_request.path
    end
  end
  
  context "GET on '/'" do
    should "list services in html format" do
      service = Service.make
      
      get '/'
      
      assert last_response.ok?
      assert last_response.body.include? "<html"
      assert last_response.body.include? service.name
      assert last_response.body.include? service.description
      
      get '/', {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert last_response.ok?
    end
    
    should "list services in json format" do
      service = Service.make
      
      get '/?format=json'
      
      assert last_response.ok?
      assert ! last_response.body.include?("<html")
      assert last_response.body.include? service.name
      assert last_response.body.include? service.description
    end
    
    should "list services in rss format" do
      service = Service.make
      
      get '/?format=rss'
      
      assert last_response.ok?
      assert last_response.body.include?("<?xml")
      assert last_response.body.include? service.name
      assert last_response.body.include? service.description
    end
  end
  
  context "GET on '/new'" do
    should "show form for adding new service" do
      get '/new', {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert last_response.ok?
      assert last_response.body.include? "<form"
    end
  end
  
  context "POST on '/'" do
    should "return http 404 if :admin_require_ssl is true but client did not request it via https" do
      service = Service.make_unsaved
      
      set :admin_require_ssl, true
      
      post '/', { :'service[name]' => service.name },
                { 'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert_equal 403, last_response.status
    end
    
    should "add record if :admin_require_ssl is true and client requested it via https" do
      service = Service.make_unsaved
      
      set :admin_require_ssl, true
      
      post '/', { :'service[name]' => service.name },
                {'HTTP_AUTHORIZATION' => encode_valid_credentials, 'HTTP_X_FORWARDED_PROTO' => 'https'}
      
      assert last_response.ok?
    end
    
    should "return http 401 if not authorized" do
      service = Service.make_unsaved
      
      post '/', { :'service[name]' => service.name }
      
      assert_equal 401, last_response.status
    end
    
    should "return http 401 if wrong credentials" do
      service = Service.make_unsaved
      
      post '/', { :'service[name]' => service.name }
      
      assert_equal 401, last_response.status
      
      post '/', { :'service[name]' => service.name },
                {'HTTP_AUTHORIZATION' => encode_credentials('some-username', 'wrong-password')}
      
      assert_equal 401, last_response.status
    end
    
    should "fail if parameters incorrect" do
      post '/', { :'service[name]' => '' },
                {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
      
      post '/', {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
    end
    
    should "create a service" do
      service = Service.make_unsaved
      
      post '/', { :'service[name]' => service.name,
                  :'service[description]' => service.description },
                {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert last_response.ok?
      assert_equal 1, Service.all(:name => service.name).count
    end
  end
  
  context "GET on '/:service_id/'" do
    should "return http 404 if service not found" do
      get '/456700988/'
      
      assert ! last_response.ok?
      assert_equal 404, last_response.status
    end
    
    should "list most recent events for given service" do
      service = generate_service_with_events(30)
      
      get "/#{service.id}/?format=json"
      
      assert last_response.ok?
      assert_equal last_response.body, service.events.all(:limit => 20, :order => [ :created_at.desc ]).to_a.to_json
    end
    
    should "list events in html format" do
      service = generate_service_with_events
      
      get "/#{service.id}/"
      
      assert last_response.ok?
      assert last_response.body.include? "<html"
      assert last_response.body.include? service.events[0].name
      #TODO: because of haml there is a bunch of extra spaces before each paragraph to test below fails
      #assert last_response.body.include? service.events[0].description
      
      get "/#{service.id}/", {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert last_response.ok?
    end
    
    should "list events in json format" do
      service = generate_service_with_events
      
      get "/#{service.id}/?format=json"
      
      assert last_response.ok?
      assert ! last_response.body.include?("<html")
      assert last_response.body.include? service.events[0].name
      # as json encodes line break we need to encode description we are testing against
      assert last_response.body.include? service.events[0].description.to_json
    end
    
    should "list events in rss format" do
      service = generate_service_with_events
      
      get "/#{service.id}/?format=rss"
      
      assert last_response.ok?
      assert last_response.body.include?("<?xml")
      assert last_response.body.include? service.events[0].name
      # as json encodes line break we need to encode description we are testing against
      assert last_response.body.include? service.events[0].description
    end
    
    should "get limited number of events with correct offset if limit and page specified" do
      limit = 5
      page  = 3
      
      service = generate_service_with_events(limit * page * 2)
      
      get "/#{service.id}/?limit=#{limit}&page=#{page}&format=json"
      
      assert last_response.ok?
      assert_equal last_response.body, service.events.all(:limit => limit, :offset => limit * page, :order => [ :created_at.desc ]).to_a.to_json
    end
  end
  
  context "GET on '/:service_id/edit'" do
    should "return http 404 if service not found" do
      get '/456700988/edit', {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert ! last_response.ok?
      assert_equal 404, last_response.status
    end
    
    should "show form for editing service" do
      service = generate_service_with_events
      
      get "/#{service.id}/edit", {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert last_response.ok?
      assert last_response.body.include? "<form"
      assert last_response.body.include? service.name
    end
  end
  
  context "PUT on '/:service_id'" do
    should "return http 404 if service not found" do
      put '/456700988', {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert ! last_response.ok?
      assert_equal 404, last_response.status
    end
    
    should "fail updating service if parameters incorrect" do
      service = generate_service_with_events
      
      put "/#{service.id}", {:'service[name]' => ''}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
      
      put "/#{service.id}", {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
    end
    
    should "update service" do
      service = generate_service_with_events
      
      put "/#{service.id}", {:'service[name]' => service.name + ' Updated'}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert last_response.ok?
      
      assert_equal service.name + ' Updated', Service.first(:id => service.id).name
    end
  end
  
  context "GET on '/:service_id/new'" do
    should "return http 404 if service not found" do
      get '/456700988/new', {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert ! last_response.ok?
      assert_equal 404, last_response.status
    end
    
    should "show form for adding new event" do
      service = generate_service_with_events
      
      get "/#{service.id}/new", {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert last_response.ok?
      assert last_response.body.include? "<form"
    end
  end
  
  context "POST on '/:service_id/'" do
    should "return http 404 if service not found" do
      post '/456700988/', { :'event[name]' => 'Error' },
                          {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert ! last_response.ok?
      assert_equal 404, last_response.status
    end
    
    should "fail if parameters incorrect" do
      service = generate_service_with_events
      
      post "/#{service.id}/", { :'event[name]' => '' },
                              {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
      
      post "/#{service.id}/", {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
    end
    
    should "create a service" do
      service = generate_service_with_events
      event = Event.make_unsaved
      
      post "/#{service.id}/", { :'event[name]' => event.name,
                                :'event[description]' => event.description },
                              {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert last_response.ok?
      assert_equal event.name, Event.all(:service_id => service.id, :limit => 1, :order => [ :created_at.asc ])[0].name
    end
  end
  
  context "GET on '/:service_id/:event_id/edit'" do
    should "return http 404 if service not found" do
      get '/456700988/345/edit', {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert ! last_response.ok?
      assert_equal 404, last_response.status
    end
    
    should "return http 404 if event not found" do
      service = generate_service_with_events(0)
      
      get "/#{service.id}/345/edit", {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert ! last_response.ok?
      assert_equal 404, last_response.status
    end
    
    should "show form for editing event" do
      service = generate_service_with_events(5)
      
      get "/#{service.id}/#{service.events[2].id}/edit", {}, {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert last_response.ok?
      assert last_response.body.include? "<form"
      assert last_response.body.include? service.events[2].name
    end
  end
  
  context "PUT on '/:service_id/:event_id'" do
    should "return http 404 if service not found" do
      put '/456700988/345/edit',
          { :'event[name]' => 'Test' },
          {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert ! last_response.ok?
      assert_equal 404, last_response.status
    end
    
    should "return http 404 if event not found" do
      service = generate_service_with_events(0)
      
      get "/#{service.id}/345/edit",
          { :'event[name]' => 'Test' },
          {'HTTP_AUTHORIZATION' => encode_valid_credentials }
      
      assert ! last_response.ok?
      assert_equal 404, last_response.status
    end
    
    should "fail updating service if parameters incorrect" do
      service = generate_service_with_events(5)
      
      put "/#{service.id}/#{service.events[2].id}",
          {:'event[name]' => ''},
          {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
      
      put "/#{service.id}/#{service.events[2].id}",
          {},
          {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
    end
    
    should "update service" do
      service = generate_service_with_events(5)
      
      put "/#{service.id}/#{service.events[2].id}",
          {:'event[name]' => service.events[2].name + ' Updated'},
          {'HTTP_AUTHORIZATION' => encode_valid_credentials}
      
      assert last_response.ok?
      
      assert_equal service.events[2].name + ' Updated', Event.first(:id => service.events[2].id).name
    end
  end
end
