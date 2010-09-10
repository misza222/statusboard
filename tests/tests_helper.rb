require 'rubygems'
require 'bundler/setup'

require 'test/unit'
require 'shoulda'

require 'machinist/data_mapper'
require 'faker'

Service.blueprint do
  name { Faker::Lorem.words(5) }
  description { Faker::Lorem.paragraphs }
end

Event.blueprint do
  name { Faker::Lorem.words(5) }
  description { Faker::Lorem.paragraphs }
  service { Service.make }
end

def generate_service_with_events(nr_of_events = 15)
  service = Service.make
  nr_of_events.times { Event.make(:service => service) }
end
