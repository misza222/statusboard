require 'rubygems'
require 'bundler/setup'

require 'test/unit'
require 'shoulda'

# Blueprint setup
require 'machinist/data_mapper'
require 'faker'

require File.dirname(__FILE__) + '/../lib/models'

Service.blueprint do
  name { Faker::Lorem.words(3).join(' ') + rand(100000).to_s }
  description { Faker::Lorem.paragraphs }
end

Event.blueprint do
  created = Time.mktime(2000 + rand(11), rand(12) + 1, rand(31) + 1, rand(24), rand(60), rand(60), rand(60)) 
  name { Faker::Lorem.words(2).join(' ') }
  description { Faker::Lorem.paragraphs.join("\n") }
  service { Service.make }
  created_at { created }
  updated_at { created + rand(10000) }
end

def generate_service_with_events(nr_of_events = 5)
  service = Service.make
  nr_of_events.times { |i| Event.make(:service => service) }
  service
end

# Rack test setup
require 'rack/test'

module Test::Unit::Setup
  include Rack::Test::Methods
  
  def app
    Sinatra::Application.new
  end

  def encode_credentials(username, password)
    "Basic " + Base64.encode64("#{username}:#{password}")
  end
  
  def encode_valid_credentials
    encode_credentials( Sinatra::Application.admin_user, Sinatra::Application.admin_password )
  end
end
