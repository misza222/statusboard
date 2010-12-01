namespace :db do
  # Recreates database
  require 'lib/models'
  
  task :reset do
    puts "Building database for :#{ENV['RACK_ENV']}" 
    setup_dm   
    DataMapper.auto_migrate!
  end

  # Adds columns/indexes without recreating database
  task :migrate do
    puts "Migrating database for :#{ENV['RACK_ENV']}"
    setup_dm
    DataMapper.auto_upgrade!
  end
  
  # create_db_uri is defined in /lib/models.rb
  def setup_dm
    DataMapper.setup(:default, create_db_uri)
  end
end

task :test => :'test:all'

namespace :test do
  task :all => [:'test:setup', :'test:statusboard']
  
  task :setup do
    ENV['RACK_ENV'] = 'test'
  end
  
  task :statusboard do
    Rake::Task["db:reset"].invoke
    require File.dirname(__FILE__) + '/tests/tests'
  end
end
