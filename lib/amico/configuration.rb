module Amico
  module Configuration
    attr_accessor :redis
    attr_accessor :namespace
    attr_accessor :following_key
    attr_accessor :followers_key

    def configure
      yield self
    end

    def namespace
      @namespace ||= 'amico'
    end

    def following_key
      @following_key ||= 'following'
    end

    def followers_key
      @followers_key ||= 'followers'
    end
  end
end