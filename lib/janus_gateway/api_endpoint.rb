module JanusGateway
  class ApiEndpoint

    # @return [JanusGateway::Client]
    attr_reader :client

    # @param [JanusGateway::Client] client
    def initialize(client)
      @client = client
    end

    # @return [Concurrent::Promise]
    def execute
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end
  end
end
