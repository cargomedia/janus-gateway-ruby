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
        response = _send(data)

        request_transaction_id = data[:transaction]
        response_transaction_id = response['transaction']

        transaction_list = @transaction_queue.clone
        unless response_transaction_id.nil? and request_transaction_id.nil?
          promise = transaction_list[response_transaction_id] || transaction_list[request_transaction_id]
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

    # @param [Hash] data
    # @return [Hash]
    def _send(data)
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = JSON.generate(data)
      response = http.request(request)

      response_json = JSON.parse(response.body)

      unless response.code == '200'
        response_json['error'] = { 'code' => 0, 'reason' => "HTTP/Transport response code is `#{response.code}`" }
      end

      response_json
    end

    # @return [Float, Integer]
    def _transaction_timeout
      30
    end
  end
end
