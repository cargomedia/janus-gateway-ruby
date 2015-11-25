module JanusGateway

  class Client

    attr_accessor :transport

    # @param [JanusGateway::Transport]
    def initialize(transport)
      @transport = transport
    end

    def connect
      @transport.run
    end

    def disconnect
      @transport.disconnect
    end

    # @param [Hash] data
    # @return [Concurrent::Promise]
    def send_transaction(data)
      @transport.send_transaction(data)
    end

    # @return [TrueClass, FalseClass]
    def is_connected?
      @transport.is_connected?
    end

    # @param [Symbol, String] event
    # @param [Proc] block
    def on(event, &block)
      @transport.on(event, &block)
    end

  end
end
