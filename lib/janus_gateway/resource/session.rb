module JanusGateway

  class Resource::Session < Resource

    def initialize(janus_client)
      @janus_client = janus_client
      @heartbeat_thread = nil

      super()
    end

    def name
      @id
    end

    def create
      p = Concurrent::Promise.new

      janus_client.send_transaction(
        {
          :janus => "create"
        }
      ).then do |*args|
        on_created(*args)
        heartbeat

        p.set(self)
        p.execute
      end.rescue do |error|
        p.fail(error).execute
      end

      p
    end

    def on_created(data)
      @id = data['data']['id']

      _self = self

      janus_client.on :message do |data|
        if data['janus'] == 'timeout' and data['session_id'] == _self.id
          _self.on_destroy(data)
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

    def destroy
      p = Concurrent::Promise.new

      janus_client.send_transaction(
        {
          :janus => "destroy",
          :session_id => @id
        }
      ).then do |*args|
        on_destroy(*args)

        p.set(self)
        p.execute
      end.rescue do |error|
        p.fail(error).execute
      end

      p
    end

    def on_destroy(data)
      @heartbeat_thread.exit unless @heartbeat_thread.nil?
      self.emit :destroy, @id
    end

    def heartbeat
      @heartbeat_thread = Thread.new do
        sleep_time = 5
        while true do
          sleep(sleep_time)
          janus_client.send_transaction(
            {
              :janus => "keepalive",
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

    def janus_client
      @janus_client
    end

  end
end
