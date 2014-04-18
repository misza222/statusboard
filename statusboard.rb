require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/respond_to'
require 'haml'

require 'lib/models'

Sinatra::Application.register Sinatra::RespondTo

helpers do  
end

get '/consumption' do
  @consumption = Consumption.first_or_create()
  respond_to do |wants|
    wants.html { haml :consumption,
                      layout => :layout }
  end
end

post '/consumption' do
  consumption = Consumption.first_or_create()
  puts params[:value]
  consumption.value = consumption.value + params[:value].to_i
  consumption.save
end

post '/consumption/reset' do
  consumption = Consumption.first_or_create()
  consumption.value = 0
  consumption.save
end
