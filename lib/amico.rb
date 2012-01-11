require 'redis'
require 'amico/version'
require 'amico/configuration'
require 'amico/friendships'

module Amico
  extend Configuration
  extend Friendships
end
