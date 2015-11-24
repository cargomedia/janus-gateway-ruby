module JanusGateway

  class Resource

    include EventEmitter

    attr_accessor :id

    # @param [String] id
    def initialize(id = nil)
      @id = id
    end

    # @return [String]
    def name
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [Concurrent::Promise]
    def create
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [Concurrent::Promise]
    def destroy
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

  end
end
