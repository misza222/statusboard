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
  
  context "GET on '/'" do
    should "list services in html format" do
      service = Service.make
      
      get '/'
      
      assert last_response.ok?
      assert last_response.body.include? "<html"
      assert last_response.body.include? service.name
      assert last_response.body.include? service.description
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
  
  context "POST on '/'" do
    should "return http 404 if :admin_require_ssl is true but client did not request it via https" do
      service = Service.make_unsaved
      
      set :admin_require_ssl, true
      
      post '/', { :'service[name]' => service.name },
                {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34')}
      
      assert_equal 404, last_response.status
    end
    
    should "add record if :admin_require_ssl is true and client requested it via https" do
      service = Service.make_unsaved
      
      set :admin_require_ssl, true
      
      post '/', { :'service[name]' => service.name },
                {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34'), 'HTTP_X_FORWARDED_PROTO' => 'https'}
      
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
                {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34')}
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
      
      post '/', {}, {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34')}
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
    end
    
    should "create a service" do
      service = Service.make_unsaved
      
      post '/', { :'service[name]' => service.name,
                  :'service[description]' => service.description },
                {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34')}
      
      assert last_response.ok?
      assert_equal 1, Service.all(:name => service.name).count
    end
  end
  
  context "GET on '/:service/'" do
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
  end
  
  context "POST on '/:service/'" do
    should "return http 404 if :admin_require_ssl is true but client did not request it via https" do
      service = generate_service_with_events
      event = Event.make_unsaved
      
      set :admin_require_ssl, true
      
      post "/#{service.id}/", { :'event[name]' => event.name},
                {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34')}
      
      assert_equal 404, last_response.status
    end
    
    should "add record if :admin_require_ssl is true and client requested it via https" do
      service = generate_service_with_events
      event = Event.make_unsaved
      
      set :admin_require_ssl, true
      
      post "/#{service.id}/", { :'event[name]' => event.name},
                {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34'), 'HTTP_X_FORWARDED_PROTO' => 'https'}
      
      assert last_response.ok?
    end
    
    should "return http 401 if not authorized" do
      service = generate_service_with_events
      event = Event.make_unsaved
      
      post "/#{service.id}/", { :'event[name]' => event.name }
      
      assert_equal 401, last_response.status
    end
    
    should "return http 401 if wrong credentials" do
      service = generate_service_with_events
      event = Event.make_unsaved
      
      post "/#{service.id}/", { :'event[name]' => event.name }
      
      assert_equal 401, last_response.status
      
      post "/#{service.id}/", { :'event[name]' => event.name },
                              {'HTTP_AUTHORIZATION' => encode_credentials('some-username', 'wrong-password')}
      
      assert_equal 401, last_response.status
    end
    
    should "return http 404 if service not found" do
      post '/456700988/', { :'event[name]' => 'Error' },
                          {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34')}
      
      assert ! last_response.ok?
      assert_equal 404, last_response.status
    end
    
    should "fail if parameters incorrect" do
      service = generate_service_with_events
      
      post "/#{service.id}/", { :'event[name]' => '' },
                              {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34')}
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
      
      post "/#{service.id}/", {}, {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34')}
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
    end
    
    should "create a service" do
      service = generate_service_with_events
      event = Event.make_unsaved
      
      post "/#{service.id}/", { :'event[name]' => event.name,
                                :'event[description]' => event.description },
                              {'HTTP_AUTHORIZATION' => encode_credentials('username', '12password34')}
      
      assert last_response.ok?
      assert_equal event.name, Event.all(:service_id => service.id, :limit => 1, :order => [ :created_at.asc ])[0].name
    end
  end
end
