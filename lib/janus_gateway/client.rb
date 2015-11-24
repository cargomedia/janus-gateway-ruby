module JanusGateway

  class Client

    include EventEmitter

    attr_accessor :transport_client

    def initialize(transport)
      @transport_client = transport
    end

    def connect
      @transport_client.connect
    end

    def disconnect
      @transport_client.disconnect
    end

    # @param [String] data
    def send(data)
      @transport_client.send(JSON.generate(data));
    end

    # @param [Hash] data
    # @return [Concurrent::Promise]
    def send_transaction(data)
      @transport_client.send_transaction(data)
    end

    # @return [TrueClass, FalseClass]
    def is_connected?
      @transport_client.is_connected?
    end

    def destroy
      disconnect
    end

    # @param [Symbol, String] event
    # @param [Proc] block
    def on(event, &block)
      @transport_client.on(event, &block)
    end

  end
end
