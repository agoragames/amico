module Amico
  module Relationships
    # Establish a follow relationship between two IDs. After adding the follow 
    # relationship, it checks to see if the relationship is reciprocated and establishes that 
    # relationship if so.
    # 
    # @param from_id [String] The ID of the individual establishing the follow relationship.
    # @param to_id [String] The ID of the individual to be followed. 
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    def follow(from_id, to_id)
      return if from_id == to_id
      return if blocked?(to_id, from_id)

      Amico.redis.multi do
        Amico.redis.zadd("#{Amico.namespace}:#{Amico.following_key}:#{from_id}", Time.now.to_i, to_id)
        Amico.redis.zadd("#{Amico.namespace}:#{Amico.followers_key}:#{to_id}", Time.now.to_i, from_id)
      end

      if reciprocated?(from_id, to_id)
        Amico.redis.multi do
          Amico.redis.zadd("#{Amico.namespace}:#{Amico.reciprocated_key}:#{from_id}", Time.now.to_i, to_id)
          Amico.redis.zadd("#{Amico.namespace}:#{Amico.reciprocated_key}:#{to_id}", Time.now.to_i, from_id)
        end
      end
    end

    # Remove a follow relationship between two IDs. After removing the follow 
    # relationship, if a reciprocated relationship was established, it is 
    # also removed.
    #
    # @param from_id [String] The ID of the individual removing the follow relationship.
    # @param to_id [String] The ID of the individual to be unfollowed.
    # 
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.unfollow(1, 11)
    def unfollow(from_id, to_id)
      return if from_id == to_id

      Amico.redis.multi do
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.following_key}:#{from_id}", to_id)
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.followers_key}:#{to_id}", from_id)
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.reciprocated_key}:#{from_id}", to_id)
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.reciprocated_key}:#{to_id}", from_id)
      end
    end

    # Block a relationship between two IDs. This method also has the side effect 
    # of removing any follower or following relationship between the two IDs. 
    #
    # @param from_id [String] The ID of the individual blocking the relationship.
    # @param to_id [String] The ID of the individual being blocked.
    #
    # Examples
    #
    #   Amico.block(1, 11)
    def block(from_id, to_id)
      return if from_id == to_id

      Amico.redis.multi do
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.following_key}:#{from_id}", to_id)
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.following_key}:#{to_id}", from_id)
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.followers_key}:#{to_id}", from_id)
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.followers_key}:#{from_id}", to_id)
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.reciprocated_key}:#{from_id}", to_id)
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.reciprocated_key}:#{to_id}", from_id)
        Amico.redis.zadd("#{Amico.namespace}:#{Amico.blocked_key}:#{from_id}", Time.now.to_i, to_id)
      end
    end

    # Unblock a relationship between two IDs.
    #
    # @param from_id [String] The ID of the individual unblocking the relationship.
    # @param to_id [String] The ID of the blocked individual.
    # 
    # Examples
    # 
    #   Amico.block(1, 11)
    #   Amico.unblock(1, 11)
    def unblock(from_id, to_id)
      return if from_id == to_id

      Amico.redis.zrem("#{Amico.namespace}:#{Amico.blocked_key}:#{from_id}", to_id)
    end

    # Count the number of individuals that someone is following.
    #
    # @param id [String] ID of the individual to retrieve following count for.
    # 
    # Examples
    # 
    #   Amico.follow(1, 11)
    #   Amico.following_count(1)
    #
    # @return the count of the number of individuals that someone is following.
    def following_count(id)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{id}")
    end

    # Count the number of individuals that are following someone.
    #
    # @param id [String] ID of the individual to retrieve followers count for.
    #
    # Examples
    #
    #   Amico.follow(11, 1)
    #   Amico.followers_count(1)
    # 
    # @return the count of the number of individuals that are following someone.
    def followers_count(id)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{id}")
    end

    # Count the number of individuals that someone has blocked.
    #
    # @param id [String] ID of the individual to retrieve blocked count for.
    # 
    # Examples
    #
    #   Amico.block(1, 11)
    #   Amico.blocked_count(1)
    #
    # @return the count of the number of individuals that someone has blocked.
    def blocked_count(id)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{id}")
    end

    # Count the number of individuals that have reciprocated a following relationship.
    #
    # @param id [String] ID of the individual to retrieve reciprocated following count for.
    # 
    # Examples
    # 
    #   Amico.follow(1, 11)
    #   Amico.follow(11, 1)
    #   Amico.reciprocated_count(1)
    #
    # @return the count of the number of individuals that have reciprocated a following relationship.
    def reciprocated_count(id)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{id}")
    end

    # Check to see if one individual is following another individual.
    #
    # @param id [String] ID of the individual checking the following status.
    # @param following_id [String] ID of the individual to see if they are being followed by id.
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.following?(1, 11)
    #
    # @return true if id is following following_id, false otherwise
    def following?(id, following_id)
      !Amico.redis.zscore("#{Amico.namespace}:#{Amico.following_key}:#{id}", following_id).nil?
    end

    # Check to see if one individual is a follower of another individual.
    #
    # @param id [String] ID of the individual checking the follower status.
    # @param following_id [String] ID of the individual to see if they are following id.
    #
    # Examples
    #
    #   Amico.follow(11, 1)
    #   Amico.follower?(1, 11)
    #
    # @return true if follower_id is following id, false otherwise
    def follower?(id, follower_id)
      !Amico.redis.zscore("#{Amico.namespace}:#{Amico.followers_key}:#{id}", follower_id).nil?
    end

    # Check to see if one individual has blocked another individual.
    #
    # @param id [String] ID of the individual checking the blocked status.
    # @param blocked_id [String] ID of the individual to see if they are blocked by id.
    #
    # Examples
    # 
    #   Amico.block(1, 11)
    #   Amico.blocked?(1, 11)
    #
    # @return true if id has blocked blocked_id, false otherwise
    def blocked?(id, blocked_id)
      !Amico.redis.zscore("#{Amico.namespace}:#{Amico.blocked_key}:#{id}", blocked_id).nil?
    end

    # Check to see if one individual has reciprocated in following another individual.
    #
    # @param from_id [String] ID of the individual checking the reciprocated relationship.
    # @param to_id [String] ID of the individual to see if they are following from_id.
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.follow(11, 1)
    #   Amico.reciprocated?(1, 11)
    #
    # @return true if both individuals are following each other, false otherwise
    def reciprocated?(from_id, to_id)
      following?(from_id, to_id) && following?(to_id, from_id)
    end

    # Retrieve a page of followed individuals for a given ID.
    #
    # @param id [String] ID of the individual.
    # @param options [Hash] Options to be passed for retrieving a page of followed individuals.
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.follow(1, 12)
    #   Amico.following(1, :page => 1)
    #
    # @return a page of followed individuals for a given ID.
    def following(id, options = default_options)
      members("#{Amico.namespace}:#{Amico.following_key}:#{id}", options)
    end

    # Retrieve a page of followers for a given ID.
    #
    # @param id [String] ID of the individual.
    # @param options [Hash] Options to be passed for retrieving a page of followers.
    #
    # Examples
    # 
    #   Amico.follow(11, 1)
    #   Amico.follow(12, 1)
    #   Amico.followers(1, :page => 1)
    #
    # @return a page of followers for a given ID.
    def followers(id, options = default_options)
      members("#{Amico.namespace}:#{Amico.followers_key}:#{id}", options)
    end

    # Retrieve a page of blocked individuals for a given ID.
    #
    # @param id [String] ID of the individual.
    # @param options [Hash] Options to be passed for retrieving a page of blocked individuals.
    #
    # Examples
    #
    #   Amico.block(1, 11)
    #   Amico.block(1, 12)
    #   Amico.blocked(1, :page => 1)
    #
    # @return a page of blocked individuals for a given ID.
    def blocked(id, options = default_options)
      members("#{Amico.namespace}:#{Amico.blocked_key}:#{id}", options)
    end

    # Retrieve a page of individuals that have reciprocated a follow for a given ID.
    #
    # @param id [String] ID of the individual.
    # @param options [Hash] Options to be passed for retrieving a page of individuals that have reciprocated a follow.
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.follow(1, 12)
    #   Amico.follow(11, 1)
    #   Amico.follow(12, 1)
    #   Amico.reciprocated(1, :page => 1)
    #
    # @return a page of individuals that have reciprocated a follow for a given ID.
    def reciprocated(id, options = default_options)
      members("#{Amico.namespace}:#{Amico.reciprocated_key}:#{id}", options)
    end

    # Count the number of pages of following relationships for an individual.
    #
    # @param id [String] ID of the individual.
    # @param page_size [int] Page size.
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.follow(1, 12)
    #   Amico.following_page_count(1)
    #
    # @return the number of pages of following relationships for an individual.
    def following_page_count(id, page_size = Amico.page_size)
      total_pages("#{Amico.namespace}:#{Amico.following_key}:#{id}", page_size)
    end

    # Count the number of pages of follower relationships for an individual.
    #
    # @param id [String] ID of the individual.
    # @param page_size [int] Page size (default: Amico.page_size).
    #
    # Examples
    #
    #   Amico.follow(11, 1)
    #   Amico.follow(12, 1)
    #   Amico.followers_page_count(1)
    #
    # @return the number of pages of follower relationships for an individual.
    def followers_page_count(id, page_size = Amico.page_size)
      total_pages("#{Amico.namespace}:#{Amico.followers_key}:#{id}", page_size)
    end

    # Count the number of pages of blocked relationships for an individual.
    #
    # @param id [String] ID of the individual.
    # @param page_size [int] Page size (default: Amico.page_size).
    #
    # Examples
    #
    #   Amico.block(1, 11)
    #   Amico.block(1, 12)
    #   Amico.blocked_page_count(1)
    #    
    # @return the number of pages of blocked relationships for an individual.
    def blocked_page_count(id, page_size = Amico.page_size)
      total_pages("#{Amico.namespace}:#{Amico.blocked_key}:#{id}", page_size)
    end

    # Count the number of pages of reciprocated relationships for an individual.
    #
    # @param id [String] ID of the individual.
    # @param page_size [int] Page size (default: Amico.page_size).
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.follow(1, 12)
    #   Amico.follow(11, 1)
    #   Amico.follow(12, 1)
    #   Amico.reciprocated_page_count(1)
    #    
    # @return the number of pages of reciprocated relationships for an individual.
    def reciprocated_page_count(id, page_size = Amico.page_size)
      total_pages("#{Amico.namespace}:#{Amico.reciprocated_key}:#{id}", page_size)
    end

    private

    # Default options for doing, for example, paging.
    #
    # @return a hash of the default options.
    def default_options
      {:page_size => Amico.page_size, :page => 1}
    end

    # Count the total number of pages for a given key in a Redis sorted set.
    #
    # @param key [String] Redis key.
    # @param page_size [int] Page size from which to calculate total pages.
    #
    # @return total number of pages for a given key in a Redis sorted set.
    def total_pages(key, page_size)
      (Amico.redis.zcard(key) / page_size.to_f).ceil
    end

    # Retrieve a page of items from a Redis sorted set without scores.
    #
    # @param key [String] Redis key.
    # @param options [Hash] Default options for paging.
    #
    # @return a page of items from a Redis sorted set without scores.
    def members(key, options = default_options)
      options = default_options.dup.merge!(options)
      if options[:page] < 1
        options[:page] = 1
      end

      if options[:page] > total_pages(key, options[:page_size])
        options[:page] = total_pages(key, options[:page_size])
      end

      index_for_redis = options[:page] - 1
      starting_offset = (index_for_redis * options[:page_size])

      if starting_offset < 0
        starting_offset = 0
      end

      ending_offset = (starting_offset + options[:page_size]) - 1
      Amico.redis.zrevrange(key, starting_offset, ending_offset, :with_scores => false)
    end
  end
end