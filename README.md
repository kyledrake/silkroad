# Silkroad

A fast, thread-safe, simple, lightweight, batchable interface to the bitcoind JSON-RPC api. Uses HTTPClient for [high performance](http://bibwild.wordpress.com/2012/04/30/ruby-http-performance-shootout-redux).

## Installation

Add this line to your application's Gemfile:

    gem 'silkroad'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install silkroad

## Usage

Initialize the client:

```ruby
silkroad = Silkroad::Client.new
```

You can set a custom uri:
```ruby
silkroad = Silkroad::Client.new 'https://rpcuser:rpcpass@yourbitcoinddaemon.com:31337'
```

Now you can make RPC API calls (see the [API calls list](https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_calls_list)). Pass params as per the spec, and the result will be returned as a primitive type (string, number, boolean, and nil) or structured type (hash, array), depending on the call:

```ruby
silkroad.rpc 'getbalance', 'derp@example.com' # => 31337
```

Errors throw the `Silkroad::Client::Error` exception. Catch it if you want to do something custom:

```ruby
begin
  silkroad.rpc 'failcmd', 'fail'
rescue Silkroad::Client::Error => e
  puts "Error: #{e.inspect}"
end
```

### Batching

If you use batching, it will throw all your requests into a JSON array, send them at once, and return all of them when they are done, per the [JSON-RPC spec](http://json-rpc.org/wiki/specification). Batch is much lower level, and does not raise exceptions on errors. You will need to look for the `response[index]['error']` in the return and handle it.

```ruby
response = @silkroad.batch do
  rpc 'getbalance', 'tyler@example.com'
  rpc 'notworking', 'derp'
end

# response is:
[
  {result: 31337, error: nil, id: nil},
  {result: nil, error: {code: -32601, message: 'Method not found'}, id: nil}
]
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



![Winners Don't Use Drugs - William S. Sessions, Director, FBI](http://i.imgur.com/4KdKeOK.gif)
