require 'rspec'
require 'amico'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:all) do
  end

  config.before(:each) do
    Amico.configure do |configuration|
      redis = Redis.new(:db => 15)
      configuration.redis = redis
      configuration.namespace = 'amico'
      configuration.following_key = 'following'
      configuration.followers_key = 'followers'
      configuration.blocked_key = 'blocked'
      configuration.reciprocated_key = 'reciprocated'
      configuration.pending_key = 'pending'
      configuration.default_scope_key = 'default'
      configuration.pending_follow = false
      configuration.page_size = 25
    end

    Amico.redis.flushdb
  end

  config.after(:all) do
  	Amico.redis.flushdb
    Amico.redis.quit
  end
end