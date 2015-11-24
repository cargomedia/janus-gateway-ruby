module JanusGateway

  class Resource::Session < Resource

    # @param [JanusGateway::Client] janus_client
    def initialize(janus_client)
      @janus_client = janus_client
      @heartbeat_thread = nil

      super()
    end

    # @return [String, NilClass]
    def name
      @id
    end

    # @return [Concurrent::Promise]
    def create
      promise = Concurrent::Promise.new

      janus_client.send_transaction(
        {
          :janus => 'create'
        }
      ).then do |*args|
        on_created(*args)
        heartbeat

        promise.set(self)
        promise.execute
      end.rescue do |error|
        promise.fail(error).execute
      end

      promise
    end

    # @param [Hash] data
    def on_created(data)
      @id = data['data']['id']

      _self = self

      janus_client.on :message do |data|
        if data['janus'] == 'timeout' and data['session_id'] == _self.id
          _self.on_destroy
        end
      end

      janus_client.on :close do |data|
        _self.emit :destroy, @id
      end

      janus_client.on :error do |data|
        _self.emit :destroy, @id
      end

      self.emit :create, @id
    end

    # @return [Concurrent::Promise]
    def destroy
      promise = Concurrent::Promise.new

      janus_client.send_transaction(
        {
          :janus => "destroy",
          :session_id => @id
        }
      ).then do |*args|
        on_destroy

        promise.set(self)
        promise.execute
      end.rescue do |error|
        promise.fail(error).execute
      end

      promise
    end

    def on_destroy
      @heartbeat_thread.exit unless @heartbeat_thread.nil?
      self.emit :destroy, @id
    end

    # @return [Thread]
    def heartbeat
      @heartbeat_thread = Thread.new do
        sleep_time = 5
        while true do
          sleep(sleep_time)
          janus_client.send_transaction(
            {
              :janus => 'keepalive',
              :session_id => @id
            }
          ).then do |*args|
            sleep_time = 30
          end.rescue do |error|
            sleep_time = 1
          end
        end
      end
    end

    # @return [JanusGateway:Client]
    def janus_client
      @janus_client
    end

  end
end
