require 'spec_helper'

describe Amico::Relationships do
  describe '#follow' do
    it 'should allow you to follow' do
      Amico.follow(1, 11)

      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:1")).to be(1)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:11")).to be(1)
    end

    it 'should not allow you to follow yourself' do
      Amico.follow(1, 1)

      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:1")).to be(0)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:1")).to be(0)
    end

    it 'should add each individual to the reciprocated set if you both follow each other' do
      Amico.follow(1, 11)
      Amico.follow(11, 1)

      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:1")).to be(1)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:11")).to be(1)
    end
  end

  describe '#unfollow' do
    it 'should allow you to unfollow' do
      Amico.follow(1, 11)

      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:1")).to be(1)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:11")).to be(1)

      Amico.unfollow(1, 11)

      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:1")).to be(0)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:11")).to be(0)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:1")).to be(0)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:11")).to be(0)
    end
  end

  describe '#block' do
    it 'should allow you to block someone following you' do
      Amico.follow(11, 1)
      Amico.block(1, 11)

      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:11")).to be(0)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:1")).to be(1)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_by_key}:#{Amico.default_scope_key}:11")).to be(1)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:1")).to be(0)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:11")).to be(0)
    end

    it 'should allow you to block someone who is not following you' do
      Amico.block(1, 11)

      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:11")).to be(0)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:1")).to be(1)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_by_key}:#{Amico.default_scope_key}:11")).to be(1)
    end

    it 'should not allow someone you have blocked to follow you' do
      Amico.block(1, 11)

      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:11")).to be(0)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:1")).to be(1)

      Amico.follow(11, 1)

      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:11")).to be(0)
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:1")).to be(1)
    end

    it 'should not allow you to block yourself' do
      Amico.block(1, 1)
      expect(Amico.blocked?(1, 1)).to be_falsey
    end
  end

  describe '#unblock' do
    it 'should allow you to unblock someone you have blocked' do
      Amico.block(1, 11)
      expect(Amico.blocked?(1, 11)).to be_truthy
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_by_key}:#{Amico.default_scope_key}:11")).to be(1)
      Amico.unblock(1, 11)
      expect(Amico.blocked?(1, 11)).to be_falsey
      expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_by_key}:#{Amico.default_scope_key}:11")).to be(0)
    end
  end

  describe '#following?' do
    it 'should return that you are following' do
      Amico.follow(1, 11)
      expect(Amico.following?(1, 11)).to be_truthy
      expect(Amico.following?(11, 1)).to be_falsey

      Amico.follow(11, 1)
      expect(Amico.following?(11, 1)).to be_truthy
    end
  end

  describe '#follower?' do
    it 'should return that you are being followed' do
      Amico.follow(1, 11)
      expect(Amico.follower?(11, 1)).to be_truthy
      expect(Amico.follower?(1,11)).to be_falsey

      Amico.follow(11, 1)
      expect(Amico.follower?(1,11)).to be_truthy
    end
  end

  describe '#blocked?' do
    it 'should return that someone is being blocked' do
      Amico.block(1, 11)
      expect(Amico.blocked?(1, 11)).to be_truthy
      expect(Amico.following?(11, 1)).to be_falsey
    end
  end

  describe '#blocked_by?' do
    it 'should return that someone is blocking you' do
      Amico.block(1, 11)
      expect(Amico.blocked_by?(11, 1)).to be_truthy
    end
  end

  describe '#reciprocated?' do
    it 'should return true if both individuals are following each other' do
      Amico.follow(1, 11)
      Amico.follow(11, 1)
      expect(Amico.reciprocated?(1, 11)).to be_truthy
    end

    it 'should return false if both individuals are not following each other' do
      Amico.follow(1, 11)
      expect(Amico.reciprocated?(1, 11)).to be_falsey
    end

    it 'should respect scope when checking if a relationship is reciprocated' do
      Amico.follow(1, 11, 'another_scope')
      Amico.follow(11, 1, 'another_scope')
      Amico.follow(1, 11, 'another_scope')
      expect(Amico.reciprocated?(1, 11)).to be_falsey
      expect(Amico.reciprocated?(1, 11, 'another_scope')).to be_truthy
      Amico.follow(1, 11)
      Amico.follow(11, 1)
      expect(Amico.reciprocated?(1, 11)).to be_truthy
    end
  end

  describe '#following' do
    it 'should return the correct list' do
      Amico.follow(1, 11)
      Amico.follow(1, 12)
      expect(Amico.following(1)).to eql(["12", "11"])
      expect(Amico.following(1, :page => 5)).to eql(["12", "11"])
    end

    it 'should page correctly' do
      add_reciprocal_followers

      expect(Amico.following(1, :page => 1, :page_size => 5).size).to be(5)
      expect(Amico.following(1, :page => 1, :page_size => 10).size).to be(10)
      expect(Amico.following(1, :page => 1, :page_size => 26).size).to be(25)
    end
  end

  describe '#followers' do
    it 'should return the correct list' do
      Amico.follow(1, 11)
      Amico.follow(2, 11)
      expect(Amico.followers(11)).to eql(["2", "1"])
      expect(Amico.followers(11, :page => 5)).to eql(["2", "1"])
    end

    it 'should page correctly' do
      add_reciprocal_followers

      expect(Amico.followers(1, :page => 1, :page_size => 5).size).to be(5)
      expect(Amico.followers(1, :page => 1, :page_size => 10).size).to be(10)
      expect(Amico.followers(1, :page => 1, :page_size => 26).size).to be(25)
    end
  end

  describe '#blocked' do
    it 'should return the correct list' do
      Amico.block(1, 11)
      Amico.block(1, 12)
      expect(Amico.blocked(1)).to eql(["12", "11"])
      expect(Amico.blocked(1, :page => 5)).to eql(["12", "11"])
    end

    it 'should page correctly' do
      add_reciprocal_followers(26, true)

      expect(Amico.blocked(1, :page => 1, :page_size => 5).size).to be(5)
      expect(Amico.blocked(1, :page => 1, :page_size => 10).size).to be(10)
      expect(Amico.blocked(1, :page => 1, :page_size => 26).size).to be(25)
    end
  end

  describe '#blocked_by' do
    it 'should return the correct list' do
      Amico.block(11, 1)
      Amico.block(12, 1)
      expect(Amico.blocked_by(1)).to eql(["12", "11"])
      expect(Amico.blocked_by(1, :page => 5)).to eql(["12", "11"])
    end
  end

  describe '#reciprocated' do
    it 'should return the correct list' do
      Amico.follow(1, 11)
      Amico.follow(11, 1)
      expect(Amico.reciprocated(1)).to eql(["11"])
      expect(Amico.reciprocated(11)).to eql(["1"])
    end

    it 'should page correctly' do
      add_reciprocal_followers

      expect(Amico.reciprocated(1, :page => 1, :page_size => 5).size).to be(5)
      expect(Amico.reciprocated(1, :page => 1, :page_size => 10).size).to be(10)
      expect(Amico.reciprocated(1, :page => 1, :page_size => 26).size).to be(25)
    end
  end

  describe '#following_count' do
    it 'should return the correct count' do
      Amico.follow(1, 11)
      expect(Amico.following_count(1)).to be(1)
    end
  end

  describe '#followers_count' do
    it 'should return the correct count' do
      Amico.follow(1, 11)
      expect(Amico.followers_count(11)).to be(1)
    end
  end

  describe '#blocked_count' do
    it 'should return the correct count' do
      Amico.block(1, 11)
      expect(Amico.blocked_count(1)).to be(1)
    end
  end

  describe '#blocked_by_count' do
    it 'should return the correct count' do
      Amico.block(1, 11)
      expect(Amico.blocked_by_count(11)).to be(1)
    end
  end

  describe '#reciprocated_count' do
    it 'should return the correct count' do
      Amico.follow(1, 11)
      Amico.follow(11, 1)
      Amico.follow(1, 12)
      Amico.follow(12, 1)
      Amico.follow(1, 13)
      expect(Amico.reciprocated_count(1)).to be(2)
    end
  end

  describe '#following_page_count' do
    it 'should return the correct count' do
      add_reciprocal_followers

      expect(Amico.following_page_count(1)).to be(1)
      expect(Amico.following_page_count(1, 10)).to be(3)
      expect(Amico.following_page_count(1, 5)).to be(5)
    end
  end

  describe '#followers_page_count' do
    it 'should return the correct count' do
      add_reciprocal_followers

      expect(Amico.followers_page_count(1)).to be(1)
      expect(Amico.followers_page_count(1, 10)).to be(3)
      expect(Amico.followers_page_count(1, 5)).to be(5)
    end
  end

  describe '#blocked_page_count' do
    it 'should return the correct count' do
      add_reciprocal_followers(26, true)

      expect(Amico.blocked_page_count(1)).to be(1)
      expect(Amico.blocked_page_count(1, 10)).to be(3)
      expect(Amico.blocked_page_count(1, 5)).to be(5)
    end
  end

  describe '#blocked_by_page_count' do
    it 'should return the correct count' do
      add_reciprocal_followers(26, true)

      expect(Amico.blocked_by_page_count(1)).to be(1)
      expect(Amico.blocked_by_page_count(1, 10)).to be(3)
      expect(Amico.blocked_by_page_count(1, 5)).to be(5)
    end
  end

  describe '#reciprocated_page_count' do
    it 'should return the correct count' do
      add_reciprocal_followers

      expect(Amico.reciprocated_page_count(1)).to be(1)
      expect(Amico.reciprocated_page_count(1, 10)).to be(3)
      expect(Amico.reciprocated_page_count(1, 5)).to be(5)
    end
  end

  describe 'pending_follow enabled' do
    before(:each) do
      Amico.pending_follow = true
    end

    after(:each) do
      Amico.pending_follow = false
    end

    describe '#follow' do
      it 'should allow you to follow but the relationship is initially pending' do
        Amico.follow(1, 11)

        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:1")).to be(0)
        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:11")).to be(0)
        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_key}:#{Amico.default_scope_key}:11")).to be(1)
        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_with_key}:#{Amico.default_scope_key}:1")).to be(1)
      end

      it 'should remove the pending relationship if you have a pending follow, but you unfollow' do
        Amico.follow(1, 11)

        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:1")).to be(0)
        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:11")).to be(0)
        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_key}:#{Amico.default_scope_key}:11")).to be(1)
        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_with_key}:#{Amico.default_scope_key}:1")).to be(1)

        Amico.unfollow(1, 11)

        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:1")).to be(0)
        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:11")).to be(0)
        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_key}:#{Amico.default_scope_key}:11")).to be(0)
        expect(Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_with_key}:#{Amico.default_scope_key}:1")).to be(0)
      end

      it 'should remove the pending relationship and add to following and followers if #accept is called' do
        Amico.follow(1, 11)
        expect(Amico.pending?(1, 11)).to be_truthy
        expect(Amico.pending_with?(11, 1)).to be_truthy

        Amico.accept(1, 11)

        expect(Amico.pending?(1, 11)).to be_falsey
        expect(Amico.pending_with?(11, 1)).to be_falsey
        expect(Amico.following?(1, 11)).to be_truthy
        expect(Amico.following?(11, 1)).to be_falsey
        expect(Amico.follower?(11, 1)).to be_truthy
        expect(Amico.follower?(1, 11)).to be_falsey
      end

      it 'should remove the pending relationship and add to following and followers if #accept is called and add to reciprocated relationship' do
        Amico.follow(1, 11)
        Amico.follow(11, 1)
        expect(Amico.pending?(1, 11)).to be_truthy
        expect(Amico.pending?(11, 1)).to be_truthy

        Amico.accept(1, 11)

        expect(Amico.pending?(1, 11)).to be_falsey
        expect(Amico.pending?(11, 1)).to be_truthy
        expect(Amico.following?(1, 11)).to be_truthy
        expect(Amico.following?(11, 1)).to be_falsey
        expect(Amico.follower?(11, 1)).to be_truthy
        expect(Amico.follower?(1, 11)).to be_falsey

        Amico.accept(11, 1)

        expect(Amico.pending?(1, 11)).to be_falsey
        expect(Amico.pending?(11, 1)).to be_falsey
        expect(Amico.following?(1, 11)).to be_truthy
        expect(Amico.following?(11, 1)).to be_truthy
        expect(Amico.follower?(11, 1)).to be_truthy
        expect(Amico.follower?(1, 11)).to be_truthy
        expect(Amico.reciprocated?(1, 11)).to be_truthy
      end
    end

    describe '#deny' do
      it 'should remove the pending relationship without following or blocking' do
        Amico.follow(1, 11)
        expect(Amico.pending?(1, 11)).to be_truthy
        expect(Amico.pending_with?(11, 1)).to be_truthy

        Amico.deny(1, 11)

        expect(Amico.following?(1, 11)).to be_falsey
        expect(Amico.pending?(1, 11)).to be_falsey
        expect(Amico.pending_with?(11, 1)).to be_falsey
        expect(Amico.blocked?(1, 11)).to be_falsey
      end
    end

    describe '#block' do
      it 'should remove the pending relationship if you block someone' do
        Amico.follow(11, 1)
        expect(Amico.pending?(11, 1)).to be_truthy
        expect(Amico.pending_with?(1, 11)).to be_truthy
        Amico.block(1, 11)
        expect(Amico.pending?(11, 1)).to be_falsey
        expect(Amico.pending_with?(1, 11)).to be_falsey
        expect(Amico.blocked?(1, 11)).to be_truthy
      end
    end

    describe '#pending' do
      it 'should return the correct list' do
        Amico.follow(1, 11)
        Amico.follow(11, 1)
        expect(Amico.pending(1)).to eql(["11"])
        expect(Amico.pending(11)).to eql(["1"])
      end

      it 'should page correctly' do
        add_reciprocal_followers

        expect(Amico.pending(1, :page => 1, :page_size => 5).size).to be(5)
        expect(Amico.pending(1, :page => 1, :page_size => 10).size).to be(10)
        expect(Amico.pending(1, :page => 1, :page_size => 26).size).to be(25)
      end
    end

    describe '#pending_with' do
      it 'should return the correct list' do
        Amico.follow(1, 11)
        Amico.follow(11, 1)
        expect(Amico.pending_with(1)).to eql(["11"])
        expect(Amico.pending_with(11)).to eql(["1"])
      end

      it 'should page correctly' do
        add_reciprocal_followers

        expect(Amico.pending_with(1, :page => 1, :page_size => 5).size).to be(5)
        expect(Amico.pending_with(1, :page => 1, :page_size => 10).size).to be(10)
        expect(Amico.pending_with(1, :page => 1, :page_size => 26).size).to be(25)
      end
    end

    describe '#pending_count' do
      it 'should return the correct count' do
        Amico.follow(1, 11)
        Amico.follow(11, 1)
        Amico.follow(1, 12)
        Amico.follow(12, 1)
        Amico.follow(1, 13)
        expect(Amico.pending_count(1)).to be(2)
      end
    end

    describe '#pending_with_count' do
      it 'should return the correct count' do
        Amico.follow(1, 11)
        Amico.follow(11, 1)
        Amico.follow(1, 12)
        Amico.follow(12, 1)
        Amico.follow(1, 13)
        expect(Amico.pending_with_count(1)).to be(3)
      end
    end

    describe '#pending_page_count' do
      it 'should return the correct count' do
        add_reciprocal_followers

        expect(Amico.pending_page_count(1)).to be(1)
        expect(Amico.pending_page_count(1, 10)).to be(3)
        expect(Amico.pending_page_count(1, 5)).to be(5)
      end
    end

    describe '#pending_with_page_count' do
      it 'should return the correct count' do
        add_reciprocal_followers

        expect(Amico.pending_with_page_count(1)).to be(1)
        expect(Amico.pending_with_page_count(1, 10)).to be(3)
        expect(Amico.pending_with_page_count(1, 5)).to be(5)
      end
    end
  end

  describe 'scope' do
    it 'should allow you to scope a call to follow a different thing' do
      Amico.default_scope_key = 'user'
      Amico.follow(1, 11, 'user')
      expect(Amico.following?(1, 11)).to be_truthy
      expect(Amico.following?(1, 11, 'user')).to be_truthy
      expect(Amico.following(1)).to eql(["11"])
      expect(Amico.following(1, {:page_size => Amico.page_size, :page => 1}, 'user')).to eql(["11"])
      expect(Amico.following?(1, 11, 'project')).to be_falsey
      Amico.follow(1, 11, 'project')
      expect(Amico.following?(1, 11, 'project')).to be_truthy
      expect(Amico.following(1, {:page_size => Amico.page_size, :page => 1}, 'project')).to eql(["11"])
    end
  end

  describe '#all' do
    it 'should raise an exception if passing an invalid type' do
      expect {Amico.all(1, :unknown)}.to raise_error
    end

    it 'should return the correct list when calling all for various types' do
      add_reciprocal_followers(5)

      [:following, :followers, :reciprocated].each do |type|
        list = Amico.all(1, type)
        # It is 29, not 30, since you cannot follow yourself
        expect(list.length).to be(4)
      end
    end

    it 'should return the correct list when calling all for a pending relationship' do
      Amico.pending_follow = true
      add_reciprocal_followers(5)

      [:following, :followers, :reciprocated].each do |type|
        list = Amico.all(1, type)
        expect(list.length).to be(0)
      end

      pending_list = Amico.all(1, :pending)
      expect(pending_list.length).to be(4)

      Amico.pending_follow = false
    end

    it 'should return the correct list when calling all for a blocked relationship' do
      add_reciprocal_followers(5, true)

      [:following, :followers, :reciprocated].each do |type|
        list = Amico.all(1, type)
        expect(list.length).to be(0)
      end

      blocked_list = Amico.all(1, :blocked)
      expect(blocked_list.length).to be(4)

      blocked_by_list = Amico.all(1, :blocked_by)
      expect(blocked_by_list.length).to be(4)
    end
  end

  describe '#following with options and scope' do
    it 'should allow you to pass in an empty set of options that will use the default options' do
      add_reciprocal_followers(5)

      following = Amico.following(1, {}, Amico.default_scope_key)
      expect(following.length).to be(4)
    end

    it 'should allow you to pass in options that will override the option in the default options' do
      add_reciprocal_followers(5)

      following = Amico.following(1, {:page_size => 1}, Amico.default_scope_key)
      expect(following.length).to be(1)
    end

    it 'should allow you to pass in an empty set of options that will use the default options with a custom scope' do
      Amico.default_scope_key = 'friends'
      add_reciprocal_followers(5)

      following = Amico.following(1, {}, 'friends')
      expect(following.length).to be(4)
      Amico.default_scope_key = 'default'
    end

    it 'should allow you to pass in options that will override the option in the default options with a custom scope' do
      Amico.default_scope_key = 'friends'
      add_reciprocal_followers(5)

      following = Amico.following(1, {:page_size => 1}, 'friends')
      expect(following.length).to be(1)
      Amico.default_scope_key = 'default'
    end
  end

  describe '#count' do
    it 'should return the correct count for the various types of relationships' do
      add_reciprocal_followers(5)

      expect(Amico.count(1, :following)).to eql(4)
      expect(Amico.count(1, :followers)).to eql(4)
      expect(Amico.count(1, :reciprocated)).to eql(4)

      Amico.redis.flushdb
      add_reciprocal_followers(5, true)

      expect(Amico.count(1, :blocked)).to eql(4)
      expect(Amico.count(1, :blocked_by)).to eql(4)

      Amico.redis.flushdb
      Amico.pending_follow = true
      add_reciprocal_followers(5)

      expect(Amico.count(1, :pending)).to eql(4)
    end
  end

  describe '#page_count' do
    it 'should return the correct page count for the various types of relationships' do
      add_reciprocal_followers(5)

      expect(Amico.page_count(1, :following)).to eql(1)
      expect(Amico.page_count(1, :followers)).to eql(1)
      expect(Amico.page_count(1, :reciprocated)).to eql(1)

      Amico.redis.flushdb
      add_reciprocal_followers(5, true)

      expect(Amico.page_count(1, :blocked)).to eql(1)
      expect(Amico.page_count(1, :blocked_by)).to eql(1)

      Amico.redis.flushdb
      Amico.pending_follow = true
      add_reciprocal_followers(5)

      expect(Amico.page_count(1, :pending)).to eql(1)
    end
  end

  describe '#clear' do
    it 'should remove follower/following relationships' do
      Amico.follow(1, 11)
      Amico.follow(11, 1)

      expect(Amico.following_count(1)).to be(1)
      expect(Amico.followers_count(1)).to be(1)
      expect(Amico.reciprocated_count(1)).to be(1)
      expect(Amico.following_count(11)).to be(1)
      expect(Amico.followers_count(11)).to be(1)
      expect(Amico.reciprocated_count(11)).to be(1)

      Amico.clear(1)

      expect(Amico.following_count(1)).to be(0)
      expect(Amico.followers_count(1)).to be(0)
      expect(Amico.reciprocated_count(1)).to be(0)
      expect(Amico.following_count(11)).to be(0)
      expect(Amico.followers_count(11)).to be(0)
      expect(Amico.reciprocated_count(11)).to be(0)
    end

    it 'should clear pending/pending_with relationships' do
      previous_pending_value = Amico.pending_follow
      Amico.pending_follow = true
      Amico.follow(1, 11)
      expect(Amico.pending_count(11)).to be(1)
      Amico.clear(1)
      expect(Amico.pending_count(11)).to be(0)
      Amico.pending_follow = previous_pending_value
    end

    it 'should clear blocked/blocked_by relationships' do
      Amico.block(1, 11)
      expect(Amico.blocked_count(1)).to be(1)
      expect(Amico.blocked_by_count(11)).to be(1)
      Amico.clear(11)
      expect(Amico.blocked_count(1)).to be(0)
      expect(Amico.blocked_by_count(11)).to be(0)
    end
  end

  private

  def add_reciprocal_followers(count = 26, block_relationship = false)
    1.upto(count) do |outer_index|
      1.upto(count) do |inner_index|
        if outer_index != inner_index
          Amico.follow(outer_index, inner_index + 1000)
          Amico.follow(inner_index + 1000, outer_index)
          if block_relationship
            Amico.block(outer_index, inner_index + 1000)
            Amico.block(inner_index + 1000, outer_index)
          end
        end
      end
    end
  end
end