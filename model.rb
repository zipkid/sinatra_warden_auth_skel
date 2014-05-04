require 'bundler'
Bundler.require

#database connection
# DataMapper::Logger.new($stdout, :debug)
# An in-memory Sqlite3 connection:
# DataMapper.setup(:default, 'sqlite::memory:')
# A MySQL connection:
# DataMapper.setup(:default, 'mysql://user:password@hostname/database')
# A Postgres connection:
# DataMapper.setup(:default, 'postgres://user:password@hostname/database')
# A Sqlite3 connection to a persistent database
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/sdsa.db")

class User
  include DataMapper::Resource
  include BCrypt
  property :id, Serial
  property :username, String, :length => 3..50
  property :password, BCryptHash

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

end
 
class Organisation
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  has n, :locations
end

class Location
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  belongs_to :organisation
end
 
DataMapper.finalize.auto_upgrade!
