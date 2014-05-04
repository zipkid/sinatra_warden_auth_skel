require 'sinatra'
require 'bundler/setup'

require File.join([File.dirname(File.expand_path(__FILE__)), "..", "sdsa"])

#log = File.new("sinatra.log", "a+")
#$stdout.reopen(log)
#$stderr.reopen(log)

#run Sinatra::Application
run SinatraDSA
