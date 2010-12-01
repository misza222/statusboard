require File.dirname(__FILE__) + '/tests_helper'

class EventModelTest < Test::Unit::TestCase
  context "Event" do
    should "not be saved without a name" do
      assert ! Event.new(:name => nil, :service => Service.make).save
      
      assert ! Event.new(:name => '' , :service => Service.make).save
    end
    
    should "have name to be saved" do
      event = Event.new(:name => "test name", :service => Service.make)
      
      assert event.save
    end
    
    should "have associated service to be saved" do
      begin
        assert ! Event.new(:name => "test name").save
      rescue DataObjects::IntegrityError, DataMapper::SaveFailureError
        assert true
      end
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
    should "not be saved without a name" do
      assert ! Service.new(:name => nil).save
      
      assert ! Service.new(:name => '').save
    end
    
    should "have name to be saved" do
      assert Service.new(:name => "Testing service").save
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
