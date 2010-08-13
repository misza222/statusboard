require 'rubygems'
require 'dm-core'
require 'dm-migrations'

def create_db_uri
  if ENV['DATABASE_URL']
    ENV['DATABASE_URL']
  elsif ENV['RACK_ENV']
    if ENV['RACK_ENV'] == 'test'
      "sqlite3::memory:"
    else
      "sqlite3:#{ENV['RACK_ENV']}.db"
    end
  else
    raise "Set RACK_ENV environment variable"
  end
end

DataMapper.setup(:default, create_db_uri)

class Service
  include DataMapper::Resource
  
  property :id,    Serial
  property :name,  String, :unique_index => true
  property :description,  Text
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :events
end

class Event
  include DataMapper::Resource
  
  property :id,    Serial
  property :name,  String, :unique_index => true
  property :description,  Text
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :service
end
