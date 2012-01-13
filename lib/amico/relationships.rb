module Amico
  module Relationships
    # Public: Establish a follow relationship between two IDs. After adding the follow 
    #         relationship, it checks to see if the relationship is reciprocated and establishes that 
    #         relationship if so.
    # 
    # from_id - The ID of the individual establishing the follow relationship.
    # to_id   - The ID of the individual to be followed. 
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

    # Public: Remove a follow relationship between two IDs. After removing the follow 
    #         relationship, if a reciprocated relationship was established, it is 
    #         also removed.
    #
    # from_id - The ID of the individual removing the follow relationship.
    # to_id   - The ID of the individual to be unfollowed.
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

    # Public: Block a relationship between two IDs. This method also has the side effect 
    #         of removing any follower or following relationship between the two IDs. 
    #
    # from_id - The ID of the individual blocking the relationship.
    # to_id   - The ID of the individual being blocked.
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

    # Public: Unblock a relationship between two IDs.
    #
    # from_id - The ID of the individual unblocking the relationship.
    # to_id   - The ID of the blocked individual.
    # 
    # Examples
    # 
    #   Amico.block(1, 11)
    #   Amico.unblock(1, 11)
    def unblock(from_id, to_id)
      return if from_id == to_id

      Amico.redis.zrem("#{Amico.namespace}:#{Amico.blocked_key}:#{from_id}", to_id)
    end

    # Public: Count the number of individuals that someone is following.
    #
    # id - ID of the individual to retrieve following count for.
    # 
    # Examples
    # 
    #   Amico.follow(1, 11)
    #   Amico.following_count(1)
    #
    # Returns the count of the number of individuals that someone is following.
    def following_count(id)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{id}")
    end

    # Public: Count the number of individuals that are following someone.
    #
    # id - ID of the individual to retrieve followers count for.
    #
    # Examples
    #
    #   Amico.follow(11, 1)
    #   Amico.followers_count(1)
    # 
    # Returns the count of the number of individuals that are following someone.
    def followers_count(id)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{id}")
    end

    # Public: Count the number of individuals that someone has blocked.
    #
    # id - ID of the individual to retrieve blocked count for.
    # 
    # Examples
    #
    #   Amico.block(1, 11)
    #   Amico.blocked_count(1)
    #
    # Returns the count of the number of individuals that someone has blocked.
    def blocked_count(id)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{id}")
    end

    # Public: Count the number of individuals that have reciprocated a following relationship.
    #
    # id - ID of the individual to retrieve reciprocated following count for.
    # 
    # Examples
    # 
    #   Amico.follow(1, 11)
    #   Amico.follow(11, 1)
    #   Amico.reciprocated_count(1)
    #
    # Returns the count of the number of individuals that have reciprocated a following relationship.
    def reciprocated_count(id)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{id}")
    end

    # Public: Check to see if one individual is following another individual.
    #
    # id - ID of the individual checking the following status.
    # following_id - ID of the individual to see if they are being followed by id.
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.following?(1, 11)
    #
    # Returns true if id is following following_id, false otherwise
    def following?(id, following_id)
      !Amico.redis.zscore("#{Amico.namespace}:#{Amico.following_key}:#{id}", following_id).nil?
    end

    # Public: Check to see if one individual is a follower of another individual.
    #
    # id - ID of the individual checking the follower status.
    # following_id - ID of the individual to see if they are following id.
    #
    # Examples
    #
    #   Amico.follow(11, 1)
    #   Amico.follower?(1, 11)
    # Returns true if follower_id is following id, false otherwise
    def follower?(id, follower_id)
      !Amico.redis.zscore("#{Amico.namespace}:#{Amico.followers_key}:#{id}", follower_id).nil?
    end

    # Public: Check to see if one individual has blocked another individual.
    #
    # id - ID of the individual checking the blocked status.
    # blocked_id - ID of the individual to see if they are blocked by id.
    #
    # Examples
    # 
    #   Amico.block(1, 11)
    #   Amico.blocked?(1, 11)
    #
    # Returns true if id has blocked blocked_id, false otherwise
    def blocked?(id, blocked_id)
      !Amico.redis.zscore("#{Amico.namespace}:#{Amico.blocked_key}:#{id}", blocked_id).nil?
    end

    # Public: Check to see if one individual has reciprocated in following another individual.
    #
    # from_id - ID of the individual checking the reciprocated relationship.
    # to_id - ID of the individual to see if they are following from_id.
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.follow(11, 1)
    #   Amico.reciprocated?(1, 11)
    #
    # Returns true if both individuals are following each other, false otherwise
    def reciprocated?(from_id, to_id)
      following?(from_id, to_id) && following?(to_id, from_id)
    end

    # Public: Retrieve a page of followed individuals for a given ID.
    #
    # id - ID of the individual.
    # options - Options to be passed for retrieving a page of followed individuals.
    #           default({:page_size => Amico.page_size, :page => 1})
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.follow(1, 12)
    #   Amico.following(1, :page => 1)
    #
    # Returns a page of followed individuals for a given ID.
    def following(id, options = default_options)
      members("#{Amico.namespace}:#{Amico.following_key}:#{id}", options)
    end

    # Public: Retrieve a page of followers for a given ID.
    #
    # id - ID of the individual.
    # options - Options to be passed for retrieving a page of followers.
    #           default({:page_size => Amico.page_size, :page => 1})
    #
    # Examples
    # 
    #   Amico.follow(11, 1)
    #   Amico.follow(12, 1)
    #   Amico.followers(1, :page => 1)
    #
    # Returns a page of followers for a given ID.
    def followers(id, options = default_options)
      members("#{Amico.namespace}:#{Amico.followers_key}:#{id}", options)
    end

    # Public: Retrieve a page of blocked individuals for a given ID.
    #
    # id - ID of the individual.
    # options - Options to be passed for retrieving a page of blocked individuals.
    #           default({:page_size => Amico.page_size, :page => 1})
    #
    # Examples
    #
    #   Amico.block(1, 11)
    #   Amico.block(1, 12)
    #   Amico.blocked(1, :page => 1)
    #
    # Returns a page of blocked individuals for a given ID.
    def blocked(id, options = default_options)
      members("#{Amico.namespace}:#{Amico.blocked_key}:#{id}", options)
    end

    # Public: Retrieve a page of individuals that have reciprocated a follow for a given ID.
    #
    # id - ID of the individual.
    # options - Options to be passed for retrieving a page of individuals that have reciprocated a follow.
    #           default({:page_size => Amico.page_size, :page => 1})
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.follow(1, 12)
    #   Amico.follow(11, 1)
    #   Amico.follow(12, 1)
    #   Amico.reciprocated(1, :page => 1)
    #
    # Returns a page of individuals that have reciprocated a follow for a given ID.
    def reciprocated(id, options = default_options)
      members("#{Amico.namespace}:#{Amico.reciprocated_key}:#{id}", options)
    end

    # Public: Count the number of pages of following relationships for an individual.
    #
    # id - ID of the individual.
    # page_size - Page size (default: Amico.page_size).
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.follow(1, 12)
    #   Amico.following_page_count(1)
    #
    # Returns the number of pages of following relationships for an individual.
    def following_page_count(id, page_size = Amico.page_size)
      total_pages("#{Amico.namespace}:#{Amico.following_key}:#{id}", page_size)
    end

    # Public: Count the number of pages of follower relationships for an individual.
    #
    # id - ID of the individual.
    # page_size - Page size (default: Amico.page_size).
    #
    # Examples
    #
    #   Amico.follow(11, 1)
    #   Amico.follow(12, 1)
    #   Amico.followers_page_count(1)
    #
    # Returns the number of pages of follower relationships for an individual.
    def followers_page_count(id, page_size = Amico.page_size)
      total_pages("#{Amico.namespace}:#{Amico.followers_key}:#{id}", page_size)
    end

    # Public: Count the number of pages of blocked relationships for an individual.
    #
    # id - ID of the individual.
    # page_size - Page size (default: Amico.page_size).
    #
    # Examples
    #
    #   Amico.block(1, 11)
    #   Amico.block(1, 12)
    #   Amico.blocked_page_count(1)
    #    
    # Returns the number of pages of blocked relationships for an individual.
    def blocked_page_count(id, page_size = Amico.page_size)
      total_pages("#{Amico.namespace}:#{Amico.blocked_key}:#{id}", page_size)
    end

    # Public: Count the number of pages of reciprocated relationships for an individual.
    #
    # id - ID of the individual.
    # page_size - Page size (default: Amico.page_size).
    #
    # Examples
    #
    #   Amico.follow(1, 11)
    #   Amico.follow(1, 12)
    #   Amico.follow(11, 1)
    #   Amico.follow(12, 1)
    #   Amico.reciprocated_page_count(1)
    #    
    # Returns the number of pages of reciprocated relationships for an individual.
    def reciprocated_page_count(id, page_size = Amico.page_size)
      total_pages("#{Amico.namespace}:#{Amico.reciprocated_key}:#{id}", page_size)
    end

    private

    # Internal: Default options for doing, for example, paging.
    #
    # Returns a hash of the default options.
    def default_options
      {:page_size => Amico.page_size, :page => 1}
    end

    # Internal: Count the total number of pages for a given key in a Redis sorted set.
    #
    # key - Redis key.
    # page_size - Page size from which to calculate total pages.
    #
    # Returns total number of pages for a given key in a Redis sorted set.
    def total_pages(key, page_size)
      (Amico.redis.zcard(key) / page_size.to_f).ceil
    end

    # Internal: Retrieve a page of items from a Redis sorted set without scores.
    #
    # key - Redis key.
    # options - Default options for paging (default: {:page_size => Amico.page_size, :page => 1})
    #
    # Returns a page of items from a Redis sorted set without scores.
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