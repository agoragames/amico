require 'spec_helper'

describe Amico::Relationships do
  describe '#follow' do
    it 'should allow you to follow' do
      Amico.follow(1, 11)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:1").should be(1)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:11").should be(1)
    end

    it 'should not allow you to follow yourself' do
      Amico.follow(1, 1)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:1").should be(0)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:1").should be(0)
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

    it 'should page correctly' do
      add_reciprocal_followers
      
      Amico.following(1, :page => 1, :page_size => 5).size.should be(5)
      Amico.following(1, :page => 1, :page_size => 10).size.should be(10)
      Amico.following(1, :page => 1, :page_size => 26).size.should be(25)
    end
  end

  describe '#followers' do
    it 'should return the correct list' do
      Amico.follow(1, 11)
      Amico.follow(2, 11)
      Amico.followers(11).should eql(["2", "1"])
      Amico.followers(11, :page => 5).should eql(["2", "1"])
    end

    it 'should page correctly' do
      add_reciprocal_followers

      Amico.followers(1, :page => 1, :page_size => 5).size.should be(5)
      Amico.followers(1, :page => 1, :page_size => 10).size.should be(10)
      Amico.followers(1, :page => 1, :page_size => 26).size.should be(25)
    end
  end

  describe '#following_page_count' do
    it 'should return the correct count' do
      add_reciprocal_followers

      Amico.following_page_count(1).should be(1)
      Amico.following_page_count(1, 10).should be(3)
      Amico.following_page_count(1, 5).should be(5)
    end
  end

  describe '#followers_page_count' do
    it 'should return the correct count' do
      add_reciprocal_followers

      Amico.followers_page_count(1).should be(1)
      Amico.followers_page_count(1, 10).should be(3)
      Amico.followers_page_count(1, 5).should be(5)
    end
  end

  private

  def add_reciprocal_followers(count = 26)
    1.upto(count) do |outer_index|
      1.upto(count) do |inner_index|
        if outer_index != inner_index
          Amico.follow(outer_index, inner_index + 1000)
          Amico.follow(inner_index + 1000, outer_index)
        end
      end
    end
  end
end