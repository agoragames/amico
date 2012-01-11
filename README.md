# amico

Friendships backed by Redis in Ruby.

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
```
  
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

