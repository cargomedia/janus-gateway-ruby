module JanusGateway
  class Transport::Http < Transport

    class JanusHTTPClient

      include Events::Emitter

      CONNECTING = 0
      OPEN       = 1
      CLOSING    = 2
      CLOSED     = 3

      def initialize(url)
        @url = url
        @state = CONNECTING

        self.on :open do
          @state = OPEN
        end
      end

      def send(data)
        Thread.new do
          uri = URI.parse(@url)
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
          request.body = data
          response = http.request(request)

          emit(:message, :data => response.body)
        end
      end

      def close
        remove_all_listeners
        @state = CLOSED
        emit(:close)
      end

      def ready_state
        @state
      end
    end

    attr_reader :transaction_queue

    # @param [String] url
    def initialize(url)
      @url = url
      @client = nil
      @transaction_queue = {}
    end

    def run
      connect
    end

    def connect
      @client = _create_client(@url)

      client.on :open do
        emit :open
      end

      client.on :message do |event|
        data = JSON.parse(event[:data])

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

      client.emit(:open)
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
        error = JanusGateway::Error.new(0, "Transaction id `#{transaction}` has failed due to timeout!")
        promise.fail(error).execute
      end

      promise.then do
        @transaction_queue.remove(transaction)
        thread.exit
      end
      promise.rescue do
        @transaction_queue.remove(transaction)
        thread.exit
      end

      promise
    end

    def disconnect
      client.close unless client.nil?
    end

    # @return [TrueClass, FalseClass]
    def connected?
      !client.nil? && (client.ready_state == JanusHTTPClient::OPEN)
    end

    # @return [JanusHTTPClient]
    attr_reader :client

    private

    # @param [String] url
    # @return [JanusHTTPClient]
    def _create_client(url)
      JanusHTTPClient.new(url)
    end

    # @return [Float, Integer]
    def _transaction_timeout
      30
    end
  end
end
