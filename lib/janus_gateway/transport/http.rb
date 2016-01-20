require 'eventmachine'
require 'em-http-request'

module JanusGateway
  class Transport::Http < Transport
    attr_reader :transaction_queue

    # @param [String] url
    def initialize(url)
      @url = url
      @transaction_queue = {}
    end

    def run
      EventMachine.run do
        EM.error_handler { |e| fail(e) }
        # will be used for long-pooling. currently does nothing
      end
    end

    # @param [Hash] data
    def send(data)
      sender = _send(data)

      sender.then do |response|
        response_transaction_id = response['transaction']

        transaction_list = @transaction_queue.clone
        unless response_transaction_id.nil?
          promise = transaction_list[response_transaction_id]
          unless promise.nil?
            if %w(success).include?(response['janus'])
              promise.set(response).execute
            elsif %w(ack event).include?(response['janus'])
              # do nothing for now
            else
              error_data = response['error']
              error = JanusGateway::Error.new(error_data['code'], error_data['reason'])
              promise.fail(error).execute
            end
          end
        end
      end

      sender.rescue do |error|
        request_transaction_id = data[:transaction]

        transaction_list = @transaction_queue.clone
        unless request_transaction_id.nil?
          promise = transaction_list[request_transaction_id]
          unless promise.nil?
            error = JanusGateway::Error.new(0, "HTTP/Transport response: `#{error}`")
            promise.fail(error).execute
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
    # @return [EventMachine::HttpRequest]
    def _send(data)

      promise = Concurrent::Promise.new

      http = EventMachine::HttpRequest.new(@url)
      request = http.post(body: JSON.generate(data), head: { 'Content-Type' => 'application/json' })

      request.callback do
        status = request.response_header.status
        if status == 200
          begin
            promise.set(JSON.parse(request.response)).execute
          rescue Exception => e
            promise.fail(e).execute
          end
        else
          promise.fail(Error.new(status, "Invalid response. Status: `#{status}`. Body: `#{request.response}`")).execute
        end
      end

      request.errback do
        promise.fail(request.error).execute
      end

      promise
    end

    # @return [Float, Integer]
    def _transaction_timeout
      30
    end
  end
end
