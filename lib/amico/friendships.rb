module Amico
  module Friendships
    def follow(from_id, to_id)
      Amico.redis.multi do
        Amico.redis.sadd("#{Amico.namespace}:#{Amico.following_key}:#{from_id}", to_id)
        Amico.redis.sadd("#{Amico.namespace}:#{Amico.followers_key}:#{to_id}", from_id)
      end
    end

    def unfollow(from_id, to_id)
      Amico.redis.multi do
        Amico.redis.srem("#{Amico.namespace}:#{Amico.following_key}:#{from_id}", to_id)
        Amico.redis.srem("#{Amico.namespace}:#{Amico.followers_key}:#{to_id}", from_id)
      end
    end

    def following_count(id)
      Amico.redis.scard("#{Amico.namespace}:#{Amico.following_key}:#{id}")
    end

    def followers_count(id)
      Amico.redis.scard("#{Amico.namespace}:#{Amico.followers_key}:#{id}")
    end

    def following?(id, following_id)
      Amico.redis.sismember("#{Amico.namespace}:#{Amico.following_key}:#{id}", following_id)
    end

    def follower?(id, follower_id)
      Amico.redis.sismember("#{Amico.namespace}:#{Amico.followers_key}:#{id}", follower_id)
    end

    def following(id)
      Amico.redis.smembers("#{Amico.namespace}:#{Amico.following_key}:#{id}")
    end

    def followers(id)
      Amico.redis.smembers("#{Amico.namespace}:#{Amico.followers_key}:#{id}")
    end
  end
end