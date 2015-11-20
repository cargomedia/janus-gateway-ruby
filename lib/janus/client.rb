require 'faye/websocket'
require 'eventmachine'

module Janus

  class Client

    include EventEmitter

    attr_accessor :client

    def initialize(url)
      @url = url
      @transaction_queue = Hash.new
    end

    def connect
      EventMachine.run do
        @client = websocket_client(@url)

        _self = self

        @client.on :open do |event|
          _self.emit :open, event
        end

        @client.on :message do |event|
          data = JSON.parse(event.data)

          unless data['transaction'].nil?
            _self.transaction_queue.each do |transaction, callback|
              if transaction == data['transaction']
                callback.call(data)
              end
            end
          end

          _self.emit :message, data
        end

        @client.on :close do |event|
          _self.emit :error, event
        end
      end
    end

    def disconnect
      @client.close
    end

    def send(data)
      @client.send(JSON.generate(data));
    end

    def send_transaction(data, &block)
      transaction = new_transaction

      data[:transaction] = transaction
      @client.send(JSON.generate(data))

      @transaction_queue[transaction] = block
    end

    def new_transaction
      'CvBn1YojWE5e'
    end

    def has_client?
      @client.nil? == false
    end

    def has_connection?
      has_client? and @client.ready_state == Faye::WebSocket::API::OPEN
    end

    def destroy
      disconnect
      EventMachine.stop
    end

    def websocket_client(url, protocol = 'janus-protocol')
      Faye::WebSocket::Client.new(url, protocol)
    end

  end
end
