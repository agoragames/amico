module Amico
  # Configuration settings for Amico.
  module Configuration
    # Redis instance.
    attr_accessor :redis

    # Amico namespace for Redis.
    attr_writer :namespace

    # Key used in Redis for tracking who an individual is following.
    attr_writer :following_key

    # Key used in Redis for tracking the followers of an individual.
    attr_writer :followers_key

    # Key used in Redis for tracking who an individual blocks.
    attr_writer :blocked_key

    # Key used in Redis for tracking who has reciprocated a follow for an individual.
    attr_writer :reciprocated_key

    # Key used in Redis for tracking pending follow relationships for an individual.
    attr_writer :pending_key

    # Key used to indicate whether or not a follow should be pending or not.
    attr_writer :pending_follow

    # Default key used to indicate the scope for the current call
    attr_writer :default_scope_key

    # Page size to be used when paging through the various types of relationships.
    attr_writer :page_size

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
    #     configuration.pending_key = 'pending'
    #     configuration.default_scope_key = 'default'
    #     configuration.pending_follow = false
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

    # Key used in Redis for tracking pending follow relationships for an individual.
    #
    # @return the key used in Redis for tracking pending follow relationships for an individual.
    def pending_key
      @pending_key ||= 'pending'
    end

    # Default key used in Redis for tracking scope for the given relationship calls.
    #
    # @return the default key used in Redis for tracking scope for the given relationship calls.
    def default_scope_key
      @default_scope_key ||= 'default'
    end

    # Key used to indicate whether or not a follow should be pending or not.
    #
    # @return the key used to indicate whether or not a follow should be pending or not.
    def pending_follow
      @pending_follow ||= false
    end

    # Page size to be used when paging through the various types of relationships.
    #
    # @return the page size to be used when paging through the various types of relationships or the default of 25 if not set.
    def page_size
      @page_size ||= 25
    end
  end
end