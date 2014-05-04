# Path to your real ruby(sinatra) application
require File.join(File.dirname(__FILE__), '..', 'sdsa.rb')
 
require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
 
# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
 
# For testing models
# reset the database before each test to make sure our tests don't influence one another
RSpec.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end
