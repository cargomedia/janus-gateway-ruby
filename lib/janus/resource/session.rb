module Janus

  class Resource::Session < Resource

    include EventEmitter

    attr_accessor :id

    def initialize(cm_janus_client)
      @cm_janus_client = cm_janus_client
      @heartbeat_thread = nil
      @id = nil
    end

    def name
      @id
    end

    def create
      janus_client.send_transaction(
        {
          :janus => "create"
        }
      ) do |*args|
        on_created(*args)
        heartbeat
      end
    end

    def on_created(data)
      @id = data['data']['id']

      _self = self

      janus_client.on :message do |data|
        if data['janus'] == 'timeout' and data['session_id'] == _self.id
          _self.destroy
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
      janus_client.send_transaction(
        {
          :janus => "destroy",
          :session_id => @id
        }
      ) do |*args|
        @heartbeat_thread.exit unless @heartbeat_thread.nil?

        self.emit :destroy, @id
      end
    end

    def heartbeat
      @heartbeat_thread = Thread.new do
        while true do
          sleep(30)

          @cm_janus_client.send_transaction(
            {
              :janus => "keepalive",
              :session_id => @id
            }
          ) do |*args|
            # should returns
            # {"janus"=>"ack", "session_id"=><int>, "transaction"=>"<string>"}
          end
        end
      end
    end

    def janus_client
      @cm_janus_client
    end

  end
end
