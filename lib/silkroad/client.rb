module Silkroad
  class Client
    class Error < StandardError; end

    DEFAULT_PORT    = 8332
    JSONRPC_VERSION = '2.0'

    def initialize(user, pass, opts={})
      @user        = user
      @opts        = opts
      @url         = Addressable::URI.parse @opts[:url] || "http://localhost:#{DEFAULT_PORT}"
      @url.port    = DEFAULT_PORT if @url.port.nil?

      @http_client = HTTPClient.new
      @http_client.set_auth @url.to_s, user, pass
    end

    def batch(requests=nil, &block)
      requests ||= Batch.new(&block).requests
      requests.each {|r| r[:jsonrpc] = JSONRPC_VERSION unless r[:jsonrpc]}
      JSON.parse send(requests).body
    end

    def rpc(meth, *params)
      response = send jsonrpc: JSONRPC_VERSION, method: meth, params: params

      if response.status != 200
        if response.body.nil?
          raise Error.new "bitcoind returned HTTP status #{response.status} with no body: #{response.http_header.reason_phrase}"
        else
          response_obj = JSON.parse response.body
          raise Error.new "bitcoind returned error code #{response_obj['error']['code']}: #{response_obj['error']['message']}"
        end
      else
        JSON.parse(response.body)['result']
      end
    end

    def send(request)
      response = @http_client.post @url, request.to_json, {'Content-Type' => 'application/json'}

      if response.status == 403 && response.body.empty?
        raise Error, '403 Forbidden - check your user/pass and/or url, and ensure IP is whitelisted for remote connections'
      end
      response
    end

    def inspect
      "#<#{self.class} user=\"#{@user}\" @url=\"#{@url.to_s}\">"
    end
  end
end