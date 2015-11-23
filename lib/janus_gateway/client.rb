require 'faye/websocket'

module JanusGateway

  class Client

    include EventEmitter

    attr_accessor :transport_client

    def initialize(url, transport = nil)
      @url = url
      @transport_client = transport || JanusGateway::Transport::WebSocket.new(url)
    end

    def connect
      @transport_client.connect
    end

    def disconnect
      @transport_client.disconnect
    end

    def send(data)
      @transport_client.send(JSON.generate(data));
    end

    def send_transaction(data)
      @transport_client.send_transaction(data)
    end

    def has_client?
      @transport_client.has_client?
    end

    def has_connection?
      @transport_client.has_connection?
    end

    def destroy
      disconnect
    end

    def on(*args, &block)
      @transport_client.on(*args, &block)
    end

  end
end
