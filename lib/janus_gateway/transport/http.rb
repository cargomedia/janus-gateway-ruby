module JanusGateway
  class Transport::Http < Transport
    attr_reader :transaction_queue

    # @param [String] url
    def initialize(url)
      @url = url
      @transaction_queue = {}
    end

    # @param [Hash] data
    def send(data)
      Thread.new do
        response = JSON.parse(_send(JSON.generate(data)))

        transaction_list = @transaction_queue.clone

        transaction_id = response['transaction']
        unless transaction_id.nil?
          promise = transaction_list[transaction_id]
          unless promise.nil?
            if %w(success ack).include?(response['janus'])
              promise.set(response).execute
            else
              error_data = response['error']
              error = JanusGateway::Error.new(error_data['code'], error_data['reason'])
              promise.fail(error).execute
            end
          end
        end
      end
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

    private

    def _send(data)
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = data
      response = http.request(request)

      response.body
    end

    # @return [Float, Integer]
    def _transaction_timeout
      30
    end
  end
end
