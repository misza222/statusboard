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
  name { Faker::Lorem.words(2).join(' ') }
  description { Faker::Lorem.paragraphs.join("\n") }
  service { Service.make }
  created_at { Time.now }
  updated_at { Time.now }
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
  
  private

  def encode_credentials(username, password)
    "Basic " + Base64.encode64("#{username}:#{password}")
  end
end
