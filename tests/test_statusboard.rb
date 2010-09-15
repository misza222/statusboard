require File.dirname(__FILE__) + '/tests_helper'
require File.dirname(__FILE__) + '/../statusboard'

class StatusboardTest < Test::Unit::TestCase
  include Test::Unit::Setup

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
  end
  
  context "POST on '/'" do
    should "fail if parameters incorrect" do
      post '/', { :'service[name]' => '' }
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
      
      post '/'
      
      assert ! last_response.ok?
      assert_equal 400, last_response.status
    end
    
    should "create a service" do
      service = Service.make_unsaved
      
      post '/', { :'service[name]' => service.name,
                  :'service[description]' => service.description }
      
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
      assert last_response.body.include? service.events[0].description
    end
    
    should "list events in json format" do
      service = generate_service_with_events
      
      get "/#{service.id}/?format=json"
      
      assert last_response.ok?
      assert ! last_response.body.include?("<html")
      assert last_response.body.include? service.events[0].name
      assert last_response.body.include? service.events[0].description
    end
  end
  
  context "POST on '/:service/'" do
    
  end
end
