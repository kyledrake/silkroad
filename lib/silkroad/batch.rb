module Silkroad
  class Batch < BasicObject
    attr_reader :requests

    def initialize(&block)
      @requests = []
      instance_eval(&block)
    end

    def rpc(meth, *params)
      @requests << {method: meth, params: params}
    end
  end
end
