module JanusGateway
  class Client
    attr_accessor :transport

    # @param [JanusGateway::Transport]
    # @param [Hash] options
    def initialize(transport, options = {})
      @transport = transport
      @options = {
        token: nil,
        admin_secret: nil
      }.merge(options)
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
      extra_fields = @options.delete_if { |_, v| v.nil? }
      @transport.send_transaction(data.merge(extra_fields))
    end

    # @return [TrueClass, FalseClass]
    def connected?
      @transport.connected?
    end

    # @param [Symbol, String] event
    # @param [Proc] block
    def on(event, &block)
      @transport.on(event, &block)
    end
  end
end
