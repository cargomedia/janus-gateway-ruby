require 'faye/websocket'
require 'eventmachine'

module Janus

  class Client

    include EventEmitter

    attr_accessor :websocket_client
    attr_reader :transaction_queue

    def initialize(url)
      @url = url
      @transaction_queue = Hash.new
    end

    def connect
      EventMachine.run do

        EM.error_handler { |e| raise(e) }

        @websocket_client = websocket_client_new(@url)

        _self = self

        @websocket_client.on :open do |event|
          _self.emit :open, event
        end

        @websocket_client.on :message do |event|
          data = JSON.parse(event.data)

          transaction_list = _self.transaction_queue.clone
          unless data['transaction'].nil?
            transaction_list.each do |transaction, promise|
              if transaction == data['transaction']
                if 'success' == data['janus']
                  promise.set(data)
                  promise.execute
                else
                  error_data = data['error']
                  error = Janus::Error.new(error_data['code'], error_data['reason'])
                  promise.fail(error).execute
                end
                break
              end
            end
          end

          _self.emit :message, data
        end

        @websocket_client.on :close do |event|
          _self.emit :error, event
        end
      end
    end

    def disconnect
      @websocket_client.close
    end

    def send(data)
      @websocket_client.send(JSON.generate(data));
    end

    def send_transaction(data)
      p = Concurrent::Promise.new
      transaction = transaction_id_new

      data[:transaction] = transaction
      @websocket_client.send(JSON.generate(data))

      @transaction_queue[transaction] = p

      p
    end

    def transaction_id_new
      transaction_id = ''
      24.times do
        transaction_id << (65 + rand(25)).chr
      end
      transaction_id
    end

    def has_client?
      @websocket_client.nil? == false
    end

    def has_connection?
      has_client? and @websocket_client.ready_state == Faye::WebSocket::API::OPEN
    end

    def destroy
      disconnect
      EventMachine.stop
    end

    def websocket_client_new(url, protocol = 'janus-protocol')
      Faye::WebSocket::Client.new(url, protocol)
    end

  end
end
