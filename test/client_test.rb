# Bundler.setup
require 'rubygems'
require './lib/silkroad.rb'
require 'minitest/autorun'
require 'webmock'
include WebMock::API

def url
  'http://user:pass@localhost:8332/'
end

def stub_with_body(body, response)
  stub_request(:post, url).
    with(body: body,
         headers: {'Authorization'=>'Basic dXNlcjpwYXNz'}).
    to_return(response)
end

describe Silkroad::Client do
  before do
    @silkroad = Silkroad::Client.new('user', 'pass')
  end

  it 'makes a call' do
    stub_with_body(
      {jsonrpc: "2.0", method: "getbalance", params: ["tyler@example.com"]},
      {status: 200, body: {result: 31337}.to_json}
    )

    @silkroad.rpc('getbalance', 'tyler@example.com').must_equal 31337
  end

  it 'fails with error' do
    stub_with_body(
      {jsonrpc: "2.0", method: "failbalance", params: ["tyler@example.com"]},
      {status: 200, body: {result: 31337}.to_json}
    )
  end

  it 'makes a batch call' do
    stub_request(:post, url).
      with(
        body: [
          {method: 'getbalance', params: ['tyler@example.com'], jsonrpc: '2.0'},
          {method: 'notworking', params: ['derp'], jsonrpc: '2.0'}
        ].to_json,
        headers: {'Authorization'=>'Basic dXNlcjpwYXNz', 'Content-Type'=>'application/json'}).
      to_return(
        :body => [
          {result: 31337, error: nil, id: nil},
          {result: nil, error: {code: -32601, message: 'Method not found'}, id: nil}
        ].to_json
      )

    response = @silkroad.batch do
      rpc 'getbalance', 'tyler@example.com'
      rpc 'notworking', 'derp'
    end

    response.length.must_equal 2
    response.first['result'].must_equal 31337
    response.last['error']['message'].must_equal 'Method not found'
  end
end