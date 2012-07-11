# amico

Relationships (e.g. friendships) backed by Redis.

## Installation

`gem install amico`

or in your `Gemfile`

```ruby
gem 'amico'
```

Make sure your redis server is running! Redis configuration is outside the scope of this README, but 
check out the Redis documentation, http://redis.io/documentation.
  
## Usage

Configure amico:

```ruby
Amico.configure do |configuration|
  configuration.redis = Redis.new
  configuration.namespace = 'amico'
  configuration.following_key = 'following'
  configuration.followers_key = 'followers'
  configuration.blocked_key = 'blocked'
  configuration.reciprocated_key = 'reciprocated'
  configuration.pending_key = 'pending'
  configuration.default_scope_key = 'default'
  configuration.pending_follow = false
  configuration.page_size = 25
end
```

Use amico:

```ruby
require 'amico'
 => true 

Amico.configure do |configuration|
  configuration.redis = Redis.new
  configuration.namespace = 'amico'
  configuration.following_key = 'following'
  configuration.followers_key = 'followers'
  configuration.blocked_key = 'blocked'
  configuration.reciprocated_key = 'reciprocated'
  configuration.pending_key = 'pending'
  configuration.default_scope_key = 'default'
  configuration.pending_follow = false
  configuration.page_size = 25
end

Amico.follow(1, 11)
=> [1, 1] 

Amico.following?(1, 11)
 => true 

Amico.following?(11, 1)
 => false 

Amico.follow(11, 1)
 => [1, 1] 

Amico.following?(11, 1)
 => true 

Amico.following_count(1)
 => 1 

Amico.followers_count(1)
 => 1 

Amico.unfollow(11, 1)
 => [1, 1] 

Amico.following_count(11)
 => 0 

Amico.following_count(1)
 => 1 

Amico.follower?(1, 11)
 => false

Amico.following(1)
 => ["11"]

Amico.block(1, 11)
 => [1, 1, 1, 1, 1] 

Amico.following?(11, 1)
 => false 

Amico.blocked?(1, 11)
 => true 

Amico.unblock(1, 11)
 => true

Amico.blocked?(1, 11)
 => false

Amico.follow(11, 1)
 => nil

Amico.follow(1, 11)
 => [1, 1]

Amico.reciprocated?(1, 11)
 => true

Amico.reciprocated(1)
 => ["11"]
```

Use amico (with pending relationships for follow):

```ruby
require 'amico'
 => true 

Amico.configure do |configuration|
  configuration.redis = Redis.new
  configuration.namespace = 'amico'
  configuration.following_key = 'following'
  configuration.followers_key = 'followers'
  configuration.blocked_key = 'blocked'
  configuration.reciprocated_key = 'reciprocated'
  configuration.pending_key = 'pending'
  configuration.default_scope_key = 'default'
  configuration.pending_follow = true
  configuration.page_size = 25
end

Amico.follow(1, 11)
 => true 

Amico.follow(11, 1)
 => true 

Amico.pending?(1, 11)
 => true 

Amico.pending?(11, 1)
 => true 

Amico.accept(1, 11)
 => nil 

Amico.pending?(1, 11)
 => false 

Amico.pending?(11, 1)
 => true 

Amico.following?(1, 11)
 => true 

Amico.following?(11, 1)
 => false 

Amico.follower?(11, 1)
 => true 

Amico.follower?(1, 11)
 => false 

Amico.accept(11, 1)
 => [1, 1] 

Amico.pending?(1, 11)
 => false 

Amico.pending?(11, 1)
 => false 

Amico.following?(1, 11)
 => true 

Amico.following?(11, 1)
 => true 

Amico.follower?(11, 1)
 => true 

Amico.follower?(1, 11)
 => true 
 
Amico.reciprocated?(1, 11)
 => true 
```

Use amico with nicknames instead of IDs. NOTE: This could cause you much hardship later on if you allow nicknames to change.

```ruby
require 'amico'
 
Amico.configure do |configuration|
  configuration.redis = Redis.new
  configuration.namespace = 'amico'
  configuration.following_key = 'following'
  configuration.followers_key = 'followers'
  configuration.blocked_key = 'blocked'
  configuration.reciprocated_key = 'reciprocated'
  configuration.pending_key = 'pending'
  configuration.default_scope_key = 'default'
  configuration.pending_follow = false
  configuration.page_size = 25
end

Amico.follow('bob', 'jane')
 
Amico.following?('bob', 'jane')
 => true 

Amico.following?('jane', 'bob')
 => false 

Amico.follow('jane', 'bob')

Amico.following?('jane', 'bob')
 => true 

Amico.following_count('bob')
 => 1 

Amico.followers_count('bob')
 => 1 

Amico.unfollow('jane', 'bob')

Amico.following_count('jane')
 => 0

Amico.following_count('bob')
 => 1 

Amico.follower?('bob', 'jane')
 => false 

Amico.follower?('jane', 'bob')
 => true 

Amico.following('bob')
 => ["jane"] 

Amico.block('bob', 'jane')

Amico.following?('jane', 'bob')
 => false 

Amico.blocked?('bob', 'jane')
 => true 

Amico.blocked?('jane', 'bob')
 => false 

Amico.unblock('bob', 'jane')
 => true 

Amico.blocked?('bob', 'jane')
 => false 

Amico.following?('jane', 'bob')
 => false 

Amico.follow('jane', 'bob')
 => nil 

Amico.follow('bob', 'jane')
 => [1, 1] 

Amico.reciprocated?('bob', 'jane')
 => true 

Amico.reciprocated('bob')
 => ["jane"] 
```

Use amico with nicknames instead of IDs and pending follows. NOTE: This could cause you much hardship later on if you allow nicknames to change.

```ruby
require 'amico'
 => true 

Amico.configure do |configuration|
  configuration.redis = Redis.new
  configuration.namespace = 'amico'
  configuration.following_key = 'following'
  configuration.followers_key = 'followers'
  configuration.blocked_key = 'blocked'
  configuration.reciprocated_key = 'reciprocated'
  configuration.pending_key = 'pending'
  configuration.default_scope_key = 'default'
  configuration.pending_follow = true
  configuration.page_size = 25
end

Amico.follow('bob', 'jane')

Amico.follow('jane', 'bob')

Amico.pending?('bob', 'jane')
 => true 

Amico.pending?('jane', 'bob')
 => true 

Amico.accept('bob', 'jane')

Amico.pending?('bob', 'jane')
 => false 

Amico.pending?('jane', 'bob')
 => true 

Amico.following?('bob', 'jane')
 => true 

Amico.following?('jane', 'bob')
 => false 

Amico.follower?('jane', 'bob')
 => true 

Amico.follower?('bob', 'jane')
 => false 

Amico.accept('jane', 'bob')

Amico.pending?('bob', 'jane')
 => false 

Amico.pending?('jane', 'bob')
 => false 

Amico.following?('bob', 'jane')
 => true 

Amico.following?('jane', 'bob')
 => true 

Amico.follower?('jane', 'bob')
 => true 

Amico.follower?('bob', 'jane')
 => true 

Amico.reciprocated?('bob', 'jane')
 => true 
```

All of the calls support a `scope` parameter to allow you to scope the calls to express relationships for different types of things. For example:

```ruby
require 'amico'

Amico.configure do |configuration|
  configuration.redis = Redis.new
  configuration.namespace = 'amico'
  configuration.following_key = 'following'
  configuration.followers_key = 'followers'
  configuration.blocked_key = 'blocked'
  configuration.reciprocated_key = 'reciprocated'
  configuration.pending_key = 'pending'
  configuration.default_scope_key = 'user'
  configuration.pending_follow = false
  configuration.page_size = 25
end

Amico.follow(1, 11)

Amico.following?(1, 11)
 => true 

Amico.following?(1, 11, 'user')
 => true 

Amico.following(1)
 => ["11"] 

Amico.following(1, {:page_size => Amico.page_size, :page => 1}, 'user')
 => ["11"] 

Amico.following?(1, 11, 'project')
 => false 

Amico.follow(1, 11, 'project')

Amico.following?(1, 11, 'project')
 => true 

Amico.following(1, {:page_size => Amico.page_size, :page => 1}, 'project')
 => ["11"]
```

You can retrieve all of a particular type of relationship using the `all(id, type, scope)` call. For example:

```ruby
Amico.follow(1, 11)
 => nil 
Amico.follow(1, 12)
 => nil 
Amico.all(1, :following)
 => ["12", "11"] 
```

`type` can be one of :following, :followers, :blocked, :reciprocated, :pending. Use this with caution 
as there may potentially be a large number of items that could be returned from this call. 

## Method Summary

```ruby
follow(from_id, to_id, scope = Amico.default_scope_key) # Establish a follow relationship between two IDs.
unfollow(from_id, to_id, scope = Amico.default_scope_key) # Remove a follow relationship between two IDs.
block(from_id, to_id, scope = Amico.default_scope_key) # Block a relationship between two IDs.
unblock(from_id, to_id, scope = Amico.default_scope_key) # Unblock a relationship between two IDs.
accept(from_id, to_id, scope = Amico.default_scope_key) # Accept a relationship that is pending between two IDs.
following_count(id, scope = Amico.default_scope_key) # Count the number of individuals that someone is following.
followers_count(id, scope = Amico.default_scope_key) # Count the number of individuals that are following someone.
blocked_count(id, scope = Amico.default_scope_key) # Count the number of individuals that someone has blocked.
reciprocated_count(id, scope = Amico.default_scope_key) # Count the number of individuals that have reciprocated a following relationship.
pending_count(id, scope = Amico.default_scope_key) # Count the number of relationships pending for an individual.
following?(id, following_id, scope = Amico.default_scope_key) # Check to see if one individual is following another individual.
follower?(id, follower_id, scope = Amico.default_scope_key) # Check to see if one individual is a follower of another individual.
blocked?(id, blocked_id, scope = Amico.default_scope_key) # Check to see if one individual has blocked another individual.
reciprocated?(from_id, to_id, scope = Amico.default_scope_key) # Check to see if one individual has reciprocated in following another individual.
pending?(from_id, to_id, scope = Amico.default_scope_key) # Check to see if one individual has a pending relationship in following another individual.
following(id, page_options = default_paging_options, scope = Amico.default_scope_key) # Retrieve a page of followed individuals for a given ID.
followers(id, page_options = default_paging_options, scope = Amico.default_scope_key) # Retrieve a page of followers for a given ID.
blocked(id, page_options = default_paging_options, scope = Amico.default_scope_key) # Retrieve a page of blocked individuals for a given ID.
reciprocated(id, page_options = default_paging_options, scope = Amico.default_scope_key) # Retrieve a page of individuals that have reciprocated a follow for a given ID.
pending(id, page_options = default_paging_options, scope = Amico.default_scope_key) # Retrieve a page of pending relationships for a given ID.
following_page_count(id, page_size = Amico.page_size, scope = Amico.default_scope_key) # Count the number of pages of following relationships for an individual.
followers_page_count(id, page_size = Amico.page_size, scope = Amico.default_scope_key) # Count the number of pages of follower relationships for an individual.
blocked_page_count(id, page_size = Amico.page_size, scope = Amico.default_scope_key) # Count the number of pages of blocked relationships for an individual.
reciprocated_page_count(id, page_size = Amico.page_size, scope = Amico.default_scope_key) # Count the number of pages of reciprocated relationships for an individual.
pending_page_count(id, page_size = Amico.page_size, scope = Amico.default_scope_key) # Count the number of pages of pending relationships for an individual.
all(id, type, scope = Amico.default_scope_key) # Retrieve all of the individuals for a given id, type (e.g. following) and scope
```

## Documentation 

The source for the [relationships module](https://github.com/agoragames/amico/blob/master/lib/amico/relationships.rb) is well-documented. There are some 
simple examples in the method documentation. You can also refer to the [online documentation](http://rubydoc.info/github/agoragames/amico/master/frames).

## Future Plans

## FAQ?

### Why use Redis sorted sets and not Redis sets?

Based on the work I did in developing [leaderboard](https://github.com/agoragames/leaderboard), 
leaderboards backed by Redis, I know I wanted to be able to page through the various relationships. 
This does not seem to be possible given the current set of commands for Redis sets. 

Also, by using the "score" in Redis sorted sets that is based on the time of when a relationship 
is established, we can get our "recent friends". It is possible that the scoring function may be 
user-defined in the future to allow for some specific ordering.
  
## Contributing to amico
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 David Czarnecki. See LICENSE.txt for further details.

