# Cache This
Cache with element level time expiration

This gem was heavily inspired by TTL feature of lru_redux gem: https://github.com/SamSaffron/lru_redux

- [Installation](#installation)
- [Usage](#usage)
- [Cache Methods](#cache-methods)
- [TODO](#todo)
- [Benchmarks](#benchmarks)
- [Contributing](#contributing)
- [Changelog](#changelog)

## Installation

Add this line to your application's Gemfile:

    gem 'cache_this'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cache_this

## Usage

```ruby
require 'cache_this'
require 'active_support/time'

cache = Cache::This.new

#with a value
cached_value = cache.get_or_set 'test1', 10.seconds.from_now, 'this is a cached value that will last only 10 seconds'

#or passing a block

require 'cache_this'
require 'net/http'
cache = Cache::This.new

another_cached_value = cache.get_or_set 'test_google' do
  url = URI.parse('http://www.google.com')
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
end

#you can get the saved value with:

google_response = cache.get('test_google')

puts google_response.class
Net::HTTPFound
puts google_response.body

<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>302 Moved</TITLE></HEAD><BODY>
<H1>302 Moved</H1>
The document has moved
...

```


```ruby
# Timecop is gem that allows us to change Time.now
# and is used for demonstration purposes.
require 'lru_redux'
require 'timecop'

# Create a cache with a timeout of 5 minutes.
# note: default expiration value is lambda { 1.hour.from_now }

cache = Cache::This.new(5 * 60)
# or you can use a lambda i.e:
cache = Cache::This.new(lambda { 5.minutes.from_now })

Timecop.freeze(Time.now)

cache.get_or_set 'a', nil, 'test a'
cache.get_or_set 'b', nil, 'test b'

cache.get('a')
# => 'test a'
cache.get('b')
# => 'test b'

# Now we advance time 5 min 30 sec into the future.
Timecop.freeze(Time.now + 330)

# And we'll get a nil value this time.
cache.get('b')
# => nil
cache.get('a')
# => nil

```

## Cache Methods
- `#get_or_set` Takes a key, an optional duration and a value or block.  Will return a value if cached, otherwise will execute the block and cache the resulting value.
- `#fetch` Takes a key and optional block.  Will return a value if cached, otherwise will execute the block and return the resulting value or return nil if no block is provided.
- `#delete` Takes a key.  Will return the deleted value, otherwise nil.
- `#evict` Alias for `#delete`.
- `#clear` Clears the cache. Returns nil.
- `#to_a` Return an array of name, value, timeout element
- `#key?` Takes a key.  Returns true if the key is cached, otherwise false.
- `#has_key?` Alias for `#key?`.
- `#count` Return the current number of items stored in the cache.

## TODO

- add more specs
- add TTL eviction strategy
- evaluate implementation of ActiveSupport::Cache::Store


## Benchmarks

TODO

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Changlog

###version 0.0.2 - 15-Jun-2015

- fix dependency version

###version 0.0.1 - 08-Jun-2015

- Initial version
