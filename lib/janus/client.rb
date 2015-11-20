require 'faye/websocket'
require 'eventmachine'

module Janus

  class Client

    include EventEmitter

    attr_accessor :session_id
    attr_accessor :transaction_queue

    attr_accessor :client

    attr_accessor :em

    def initialize(url)
      @url = url
      @transaction_queue = Hash.new
    end

    def connect
      EventMachine.run do
        @client = Faye::WebSocket::Client.new(@url, 'janus-protocol')

        @client.on :open do |event|
          self.emit :open, event
        end

        @client.on :message do |event|
          data = JSON.parse(event.data)

          unless data['transaction'].nil?
            @transaction_queue.each do |transaction, callback|
              if transaction == data['transaction']
                callback.call(data)
              end
            end
          end

          self.emit :message, data
        end

        @client.on :close do |event|
          self.emit :error, event
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

      transaction_queue[transaction] = block
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

  end
end
