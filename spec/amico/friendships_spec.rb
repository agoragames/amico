require 'spec_helper'

describe Amico::Friendships do
  describe '#follow' do
    it 'should allow you to follow' do
      Amico.follow(1, 11)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:1").should be(1)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:11").should be(1)
    end
  end

  describe '#unfollow' do
    it 'should allow you to follow' do
      Amico.follow(1, 11)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:1").should be(1)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:11").should be(1)

      Amico.unfollow(1, 11)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:1").should be(0)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:11").should be(0)
    end
  end

  describe '#following_count' do
    it 'should return the correct count' do
      Amico.follow(1, 11)
      Amico.following_count(1).should be(1)
    end
  end

  describe '#followers_count' do
    it 'should return the correct count' do
      Amico.follow(1, 11)
      Amico.followers_count(11).should be(1)
    end
  end

  describe '#following?' do
    it 'should return that you are following' do
      Amico.follow(1, 11)
      Amico.following?(1, 11).should be_true
      Amico.following?(11, 1).should be_false

      Amico.follow(11, 1)
      Amico.following?(11, 1).should be_true
    end
  end

  describe '#follower?' do
    it 'should return that you are being followed' do
      Amico.follow(1, 11)
      Amico.follower?(11, 1).should be_true
      Amico.follower?(1,11).should be_false

      Amico.follow(11, 1)
      Amico.follower?(1,11).should be_true
    end
  end

  describe '#following' do
    it 'should return the correct list' do
      Amico.follow(1, 11)
      Amico.follow(1, 12)
      Amico.following(1).should eql(["12", "11"])
      Amico.following(1, :page => 5).should eql(["12", "11"])
    end
  end

  describe '#followers' do
    it 'should return the correct list' do
      Amico.follow(1, 11)
      Amico.follow(2, 11)
      Amico.followers(11).should eql(["2", "1"])
      Amico.followers(11, :page => 5).should eql(["2", "1"])
    end
  end
end