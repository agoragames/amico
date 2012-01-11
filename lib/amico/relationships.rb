module Amico
  module Relationships
    def follow(from_id, to_id)
      return if from_id == to_id

      Amico.redis.multi do
        Amico.redis.zadd("#{Amico.namespace}:#{Amico.following_key}:#{from_id}", Time.now.to_i, to_id)
        Amico.redis.zadd("#{Amico.namespace}:#{Amico.followers_key}:#{to_id}", Time.now.to_i, from_id)
      end
    end

    def unfollow(from_id, to_id)
      Amico.redis.multi do
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.following_key}:#{from_id}", to_id)
        Amico.redis.zrem("#{Amico.namespace}:#{Amico.followers_key}:#{to_id}", from_id)
      end
    end

    def following_count(id)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{id}")
    end

    def followers_count(id)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{id}")
    end

    def following?(id, following_id)
      !Amico.redis.zscore("#{Amico.namespace}:#{Amico.following_key}:#{id}", following_id).nil?
    end

    def follower?(id, follower_id)
      !Amico.redis.zscore("#{Amico.namespace}:#{Amico.followers_key}:#{id}", follower_id).nil?
    end

    def following(id, options = default_options)
      members("#{Amico.namespace}:#{Amico.following_key}:#{id}", options)
    end

    def followers(id, options = default_options)
      members("#{Amico.namespace}:#{Amico.followers_key}:#{id}", options)
    end

    def following_page_count(id, page_size = Amico.page_size)
      total_pages("#{Amico.namespace}:#{Amico.following_key}:#{id}", page_size)
    end

    def followers_page_count(id, page_size = Amico.page_size)
      total_pages("#{Amico.namespace}:#{Amico.followers_key}:#{id}", page_size)
    end

    private

    def default_options
      {:page_size => Amico.page_size, :page => 1}
    end

    def total_pages(key, page_size)
      (Amico.redis.zcard(key) / page_size.to_f).ceil
    end

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