module Amico
  # Configuration settings for Amico.
  module Configuration
    # Public: Redis instance.
    attr_accessor :redis

    # Public: Amico namespace for Redis.
    attr_accessor :namespace

    # Public: Key used in Redis for tracking who an individual is following.
    attr_accessor :following_key

    # Public: Key used in Redis for tracking the followers of an individual.
    attr_accessor :followers_key

    # Public: Key used in Redis for tracking who an individual blocks.
    attr_accessor :blocked_key

    # Public: Key used in Redis for tracking who has reciprocated a follow for an individual.
    attr_accessor :reciprocated_key

    # Public: Page size to be used when paging through the various types of relationships.
    attr_accessor :page_size

    # Public: Yield self to be able to configure Amico with block-style configuration.
    #
    # Example:
    #
    #   Amico.configure do |configuration|
    #     configuration.redis = Redis.new
    #     configuration.namespace = 'amico'
    #     configuration.following_key = 'following'
    #     configuration.followers_key = 'followers'
    #     configuration.blocked_key = 'blocked'
    #     configuration.reciprocated_key = 'reciprocated'
    #     configuration.page_size = 25
    #   end
    def configure
      yield self
    end

    # Public: Amico namespace for Redis.
    #
    # Returns the Amico namespace or the default of 'amico' if not set.
    def namespace
      @namespace ||= 'amico'
    end

    # Public: Key used in Redis for tracking who an individual is following.
    #
    # Returns the key used in Redis for tracking who an individual is following or the default of 'following' if not set.
    def following_key
      @following_key ||= 'following'
    end

    # Public: Key used in Redis for tracking the followers of an individual.
    #
    # Returns the key used in Redis for tracking the followers of an individual or the default of 'followers' if not set.
    def followers_key
      @followers_key ||= 'followers'
    end

    # Public: Key used in Redis for tracking who an individual blocks.
    # 
    # Returns the key used in Redis for tracking who an individual blocks or the default of 'blocked' if not set.
    def blocked_key
      @blocked_key ||= 'blocked'
    end

    # Public: Key used in Redis for tracking who has reciprocated a follow for an individual.
    #
    # Returns the key used in Redis for tracking who has reciprocated a follow for an individual or the default of 'reciprocated' if not set.
    def reciprocated_key
      @reciprocated_key ||= 'reciprocated'
    end

    # Public: Page size to be used when paging through the various types of relationships.
    #
    # Returns the page size to be used when paging through the various types of relationships or the default of 25 if not set.
    def page_size
      @page_size ||= 25
    end
  end
end