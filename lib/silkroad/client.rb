module Silkroad
  class Client
    class Error < StandardError; end

    DEFAULT_RPC_PORT = 8332
    TESTNET_RPC_PORT = 18332
    JSONRPC_VERSION  = '2.0'

    def initialize(user, pass, opts={})
      @user        = user
      @opts        = opts
      @uri         = URI.parse @opts[:uri] || "http://localhost:#{DEFAULT_RPC_PORT}"
      @uri.port    = DEFAULT_RPC_PORT if @opts[:uri].nil? || !@opts[:uri].match(/:80/)
      @user        = user
      @pass        = pass
    end

    def batch(requests=nil, &block)
      requests ||= Batch.new(&block).requests
      requests.each {|r| r[:jsonrpc] = JSONRPC_VERSION unless r[:jsonrpc]}
      JSON.parse send(requests).body
    end

    def rpc(meth, *params)
      response = send jsonrpc: JSONRPC_VERSION, method: meth, params: params

      if response.code != '200'
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

    def send(formdata)
      resp = Net::HTTP.start(@uri.host, @uri.port) do |http|
        req = Net::HTTP::Post.new '/'
        req.basic_auth @user, @pass
        req.add_field 'Content-Type', 'application/json'
        req.use_ssl = true if @uri.scheme == 'https'
        req.body = formdata.to_json
        http.request req
      end

      if resp.code == '403' && resp.body.empty?
        raise Error, '403 Forbidden - check your user/pass and/or uri, and ensure IP is whitelisted for remote connections'
      end
      resp
    end

    def inspect
      "#<#{self.class} user=\"#{@user}\" @uri=\"#{@uri.to_s}\">"
    end
  end
end