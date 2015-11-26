module JanusGateway

  class Resource

    include Events::Emitter

    attr_accessor :id

    # @param [JanusGateway::Client] client
    # @param [String] id
    def initialize(client, id = nil)
      @client = client
      @id = id
    end

    # @return [String, NilClass]
    def id
      @id
    end

    # @return [JanusGateway::Client]
    def client
      @client
    end

    # @return [String, NilClass]
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
