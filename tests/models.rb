require File.dirname(__FILE__) + '/tests_helper'
require File.dirname(__FILE__) + '/../lib/models'

class EventModelTest < Test::Unit::TestCase
  context "Event" do
    should "have name to be saved" do
      service = Service.make
      event1 = Event.new(:name => nil, :service => service)
      
      assert ! event1.save
      
      event2 = Event.new(:name => "test name", :service => service)
      
      assert event2.save
    end
    
    should "have associated service to be saved" do
      event = Event.new(:name => "test name")
      
      assert ! event.save
    end
    
    context "to_json method" do
      should "return json data" do
        event = Event.make
        
        assert_equal({
                        :id => event.id,
                        :name => event.name,
                        :description => event.description,
                        :service_id => event.service.id
                      }, JSON.parse(event.to_json, {:symbolize_names => true}))
      end
    end
  end
end

class ServiceModelTest < Test::Unit::TestCase
  context "Service" do
    should "have name to be saved" do
      service1 = Service.new(:name => nil)
      
      assert ! service1.save
      
      service2 = Service.new(:name => "Testing service")
      
      assert service2.save
    end
    
    context "to_json method" do
      should "return json data" do
        service = Service.make
        
        assert_equal({
                        :id => service.id,
                        :name => service.name,
                        :description => service.description
                      }, JSON.parse(service.to_json, {:symbolize_names => true}))
      end
    end
  end
end
