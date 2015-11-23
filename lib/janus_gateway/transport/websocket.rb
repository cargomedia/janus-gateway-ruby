require 'eventmachine'
require 'faye/websocket'

module JanusGateway

  class Transport::WebSocket < Transport

    attr_reader :transaction_queue

    def initialize(url, protocol = 'janus-protocol')
      @client = nil
      @transaction_queue = Hash.new

      super
    end

    def connect
      EventMachine.run do

        EM.error_handler { |e| raise(e) }

        @client = _client(@url, @protocol)

        _self = self

        @client.on :open do |event|
          _self.emit :open, event
        end

        @client.on :message do |event|
          data = JSON.parse(event.data)

          transaction_list = _self.transaction_queue.clone
          unless data['transaction'].nil?
            transaction_list.each do |transaction, promise|
              if transaction == data['transaction']
                if ['success', 'ack'].include?(data['janus'])
                  promise.set(data)
                  promise.execute
                else
                  error_data = data['error']
                  error = JanusGateway::Error.new(error_data['code'], error_data['reason'])
                  promise.fail(error).execute
                end
                break
              end
            end
          end

          _self.emit :message, data
        end

        @client.on :close do |event|
          _self.emit :error, event
        end
      end

      @client
    end

    def close
      @client.close
    end

    def send(data)
      @client.send(data)
    end

    def send_transaction(data)
      p = Concurrent::Promise.new
      transaction = transaction_id_new

      data[:transaction] = transaction
      @client.send(JSON.generate(data))

      @transaction_queue[transaction] = p

      Thread.new do
        sleep(_promise_wait_timeout)
        p.fail(_timeout_error("Transaction id `#{transaction}` has failed due to timeout!")).execute
        @transaction_queue.remove(transaction)
      end

      p
    end

    def disconnect
      @client.close
      EventMachine.stop
    end

    def ready_state
      @client.ready_state unless @client.nil?
    end

    def has_client?
      @client.nil? == false
    end

    def has_connection?
      has_client? and @client.ready_state == Faye::WebSocket::API::OPEN
    end

    def transaction_id_new
      transaction_id = ''
      24.times do
        transaction_id << (65 + rand(25)).chr
      end
      transaction_id
    end

    def client
      @client
    end

    private

    def _client(url, protocol)
      Faye::WebSocket::Client.new(url, protocol)
    end

    def _promise_wait_timeout
      30
    end

    def _timeout_error(message)
      JanusGateway::Error.new(0, message)
    end


  end

end
