require 'eventmachine'
require 'faye/websocket'

module JanusGateway
  class Transport::WebSocket < Transport
    attr_reader :transaction_queue

    # @param [String] url
    # @param [String] protocol
    def initialize(url, protocol = 'janus-protocol')
      @url = url
      @protocol = protocol
      @client = nil
      @transaction_queue = {}
    end

    def run
      EventMachine.run do
        EM.error_handler { |e| fail(e) }
        connect
      end
    end

    def connect
      fail('WebSocket client already exists!') unless @client.nil?

      @client = _create_client(@url, @protocol)

      client.on :open do
        emit :open
      end

      client.on :message do |event|
        data = JSON.parse(event.data)

        transaction_list = @transaction_queue.clone

        transaction_id = data['transaction']
        unless transaction_id.nil?
          promise = transaction_list[transaction_id]
          unless promise.nil?
            if %w(success ack).include?(data['janus'])
              promise.set(data).execute
            else
              error_data = data['error']
              error = JanusGateway::Error.new(error_data['code'], error_data['reason'])
              promise.fail(error).execute
            end
          end
        end

        emit :message, data
      end

      client.on :close do
        emit :close

        @transaction_queue.each do |transaction_id, promise|
          error = JanusGateway::Error.new(0, "Transaction id `#{transaction_id}` has failed due to websocket `close`!")
          promise.fail(error).execute
        end
      end
    end

    # @param [Hash] data
    def send(data)
      client.send(JSON.generate(data))
    end

    # @param [Hash] data
    # @return [Concurrent::Promise]
    def send_transaction(data)
      promise = Concurrent::Promise.new
      transaction = transaction_id_new

      data[:transaction] = transaction
      send(data)

      @transaction_queue[transaction] = promise

      thread = Thread.new do
        sleep(_transaction_timeout)
        error = JanusGateway::Error.new(0, "Transaction id `#{transaction}` has failed due to `timeout`!")
        promise.fail(error).execute
      end

      promise.then do
        @transaction_queue.delete(transaction)
        thread.exit
      end
      promise.rescue do
        @transaction_queue.delete(transaction)
        thread.exit
      end

      promise
    end

    def disconnect
      client.close unless client.nil?
    end

    # @return [TrueClass, FalseClass]
    def connected?
      !client.nil? && (client.ready_state == Faye::WebSocket::API::OPEN)
    end

    # @return [Faye::WebSocket::Client, NilClass]
    attr_reader :client

    private

    # @param [String] url
    # @param [String] protocol
    # @return [Faye::WebSocket::Client]
    def _create_client(url, protocol)
      Faye::WebSocket::Client.new(url, protocol)
    end

    # @return [Float, Integer]
    def _transaction_timeout
      30
    end
  end
end
