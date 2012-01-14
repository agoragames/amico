module Amico
  # Configuration settings for Amico.
  module Configuration
    # Redis instance.
    attr_accessor :redis

    # Amico namespace for Redis.
    attr_accessor :namespace

    # Key used in Redis for tracking who an individual is following.
    attr_accessor :following_key

    # Key used in Redis for tracking the followers of an individual.
    attr_accessor :followers_key

    # Key used in Redis for tracking who an individual blocks.
    attr_accessor :blocked_key

    # Key used in Redis for tracking who has reciprocated a follow for an individual.
    attr_accessor :reciprocated_key

    # Page size to be used when paging through the various types of relationships.
    attr_accessor :page_size

    # Yield self to be able to configure Amico with block-style configuration.
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

    # Amico namespace for Redis.
    #
    # @return the Amico namespace or the default of 'amico' if not set.
    def namespace
      @namespace ||= 'amico'
    end

    # Key used in Redis for tracking who an individual is following.
    #
    # @return the key used in Redis for tracking who an individual is following or the default of 'following' if not set.
    def following_key
      @following_key ||= 'following'
    end

    # Key used in Redis for tracking the followers of an individual.
    #
    # @return the key used in Redis for tracking the followers of an individual or the default of 'followers' if not set.
    def followers_key
      @followers_key ||= 'followers'
    end

    # Key used in Redis for tracking who an individual blocks.
    # 
    # @return the key used in Redis for tracking who an individual blocks or the default of 'blocked' if not set.
    def blocked_key
      @blocked_key ||= 'blocked'
    end

    # Key used in Redis for tracking who has reciprocated a follow for an individual.
    #
    # @return the key used in Redis for tracking who has reciprocated a follow for an individual or the default of 'reciprocated' if not set.
    def reciprocated_key
      @reciprocated_key ||= 'reciprocated'
    end

    # Page size to be used when paging through the various types of relationships.
    #
    # @return the page size to be used when paging through the various types of relationships or the default of 25 if not set.
    def page_size
      @page_size ||= 25
    end
  end
end