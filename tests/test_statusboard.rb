require File.dirname(__FILE__) + '/tests_helper'
require File.dirname(__FILE__) + '/../statusboard'

class StatusboardTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  context "GET on '/'" do
    should "react to both formats" do
      
    end
  end
end
