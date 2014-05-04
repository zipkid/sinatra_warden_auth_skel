require 'bundler'
Bundler.require

# load the Database and User model
require_relative './model'

User.create(:username => 'admin', :password => 'secret')
User.create(:username => 'zipkid', :password => 'secret')

# http://skli.se/2013/03/08/sinatra-warden-auth/
# https://gist.github.com/jamiehodge/1327195

class SinatraDSA < Sinatra::Base
  use Rack::Session::Cookie, secret: "nothingissecretontheinternet"
  use Rack::Flash, accessorize: [:error, :success]

  use Warden::Manager do |config|
    # Tell Warden how to save our User info into a session.
    # Sessions can only take strings, not Ruby code, we'll store
    # the User's `id`
    config.serialize_into_session{|user| user.id }
    # Now tell Warden how to take what we've stored in the session
    # and get a User from that information.
    config.serialize_from_session{|id| User.get(id) }

    config.scope_defaults :default,
      # "strategies" is an array of named methods with which to
      # attempt authentication. We have to define this later.
      strategies: [:password],
      # The action is a route to send the user to when
      # warden.authenticate! returns a false answer. We'll show
      # this route below.
      action: 'auth/unauthenticated'
    # When a user tries to log in and cannot, this specifies the
    # app to send the user to.
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      params['user'] && params['user']['username'] && params['user']['password']
    end

    def authenticate!
      user = User.first(username: params['user']['username'])

      if user.nil?
        fail!("The username you entered does not exist.")
      elsif user.authenticate(params['user']['password'])
        success!(user, 'Okay!')
      else
        fail!("Could not log in")
      end
    end
  end

  get '/' do
    flash[:notice] = "Thanks for signing up!"
    erb :home
  end

  get '/auth/login' do
    erb :login
  end

  post '/auth/login' do
    warden_handler.authenticate!

    flash[:success] = env['warden'].message

    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end

  get '/auth/logout' do
    puts warden_handler.raw_session.inspect
    warden_handler.logout
    flash[:success] = 'Successfully logged out'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    puts "User is not authenticated......"
    puts env['warden.options'][:attempted_path]
    puts warden_handler.raw_session.inspect
    puts warden_handler
    flash[:error] = warden_handler.message || "You must log in"
    redirect '/auth/login'
  end

  get '/protected' do
    #env['warden'].authenticate!
    check_authentication

    erb :protected
  end


  def warden_handler
    env['warden']
  end
 
  def check_authentication
    unless warden_handler.authenticated?
      redirect '/auth/login'
    end
  end
 
  def current_user
    warden_handler.user
  end

end

