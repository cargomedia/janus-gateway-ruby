module JanusGateway

  class Client

    attr_accessor :transport

    # @param [JanusGateway::Transport]
    def initialize(transport)
      @transport = transport
      @extra_data = {}
    end

    def run
      @transport.run
    end

    def connect
      @transport.connect
    end

    def disconnect
      @transport.disconnect
    end

    # @param [Hash] data
    # @return [Concurrent::Promise]
    def send_transaction(data)
      data.merge!(extra_data)
      @transport.send_transaction(data)
    end

    # @param [Hash] data
    def register_extra_data(data)
      @extra_data.merge!(data)
    end

    def clear_extra_data
      @extra_data = {}
    end

    # @return [Hash] data
    def extra_data
      @extra_data
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
