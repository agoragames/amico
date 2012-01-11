require 'redis'
require 'amico/version'
require 'amico/configuration'
require 'amico/relationships'

module Amico
  extend Configuration
  extend Relationships
end
