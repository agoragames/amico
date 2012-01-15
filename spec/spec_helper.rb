require 'rspec'
require 'amico'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:all) do
    Amico.configure do |configuration|
      redis = Redis.new(:db => 15)
      configuration.redis = redis
    end
  end

  config.before(:each) do
    Amico.redis.flushdb
  end

  config.after(:all) do
  	Amico.redis.flushdb
    Amico.redis.quit
  end
end