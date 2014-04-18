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

class Consumption
  include DataMapper::Resource
  
  property :id,    Serial
  property :value,    Integer, :default => 0
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
  
  def to_json(*a)
    {
      :value => value,
    }.to_json(*a)
  end
end

DataMapper.auto_migrate!
