require File.dirname(__FILE__) + '/spec_helper'
set :environment, :test
 
describe "SDSA index" do
  include Rack::Test::Methods
 
  def app
    @app ||= Sinatra::Application
  end
 
  # Do a root test
  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end

end

