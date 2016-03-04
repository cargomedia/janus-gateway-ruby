module JanusGateway
  class Resource
    include Events::Emitter

    # @return [String, NilClass]
    attr_reader :id

    # @return [JanusGateway::Client]
    attr_reader :client

    # @return [String]
    attr_accessor :id

    # @param [JanusGateway::Client] client
    # @param [String] id
    def initialize(client, id = nil)
      @client = client
      @id = id
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
