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
  with(body: body, headers: {'Content-Type'=>'application/json'}).
  to_return(response)
end

describe Silkroad::Client do
  before do
    @silkroad = Silkroad::Client.new 'http://user:pass@localhost'
    WebMock.reset!
  end

  it 'sets url defaults correctly' do
    Proc.new { Silkroad::Client.new 'http://localhost' }.must_raise Silkroad::Client::Error
    
    
    silkroad = Silkroad::Client.new 'http://user:pass@localhost'
    silkroad.uri.to_s.must_equal 'http://user:pass@localhost:8332'

    silkroad = Silkroad::Client.new 'https://user:pass@example.org:1234'
    silkroad.uri.to_s.must_equal 'https://user:pass@example.org:1234'
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
        headers: {'Content-Type'=>'application/json'}).
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