require 'rubygems'
require 'bundler/setup'

require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'json'

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
  property :description,  Text, :default => ''
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :events
  
  validates_presence_of :name
  
  def to_json(*a)
    {
      :id => id,
      :name => name,
      :description => description
    }.to_json(*a)
  end
end

class Event
  include DataMapper::Resource
  
  property :id,    Serial
  property :name,  String
  property :description,  Text, :default => ''
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :service
  
  validates_presence_of :name
  
  def to_json(*a)
    {
      :id => id,
      :name => name,
      :description => description,
      :service_id => service_id
    }.to_json(*a)
  end
end
