require 'rspec'
require 'amico'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:each) do
    Amico.configure do |configuration|
      redis = Redis.new
      redis.flushall
      configuration.redis = redis
    end
  end
end