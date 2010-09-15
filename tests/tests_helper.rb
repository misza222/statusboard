require 'rubygems'
require 'bundler/setup'

require 'test/unit'
require 'shoulda'

# Blueprint setup
require 'machinist/data_mapper'
require 'faker'

require File.dirname(__FILE__) + '/../lib/models'

Service.blueprint do
  name { Faker::Lorem.words(3) }
  description { Faker::Lorem.paragraphs }
end

Event.blueprint do
  name { Faker::Lorem.words(2) }
  description { Faker::Lorem.paragraphs }
  service { Service.make }
end

def generate_service_with_events(nr_of_events = 5)
  service = Service.make
  nr_of_events.times { |i| Event.make(:service => service, :name => "Event \##{i} #{service.name} #{rand(100000).to_s}") }
  service
end

# Rack test setup
require 'rack/test'

module Test::Unit::Setup
  include Rack::Test::Methods
  
  def app
    Sinatra::Application.new
  end
end
