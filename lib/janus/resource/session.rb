module Janus

  class Resource::Session < Resource

    include EventEmitter

    attr_accessor :cm_janus_client
    attr_accessor :id

    attr_accessor :heartbeat

    def initialize(cm_janus_client)
      @cm_janus_client = cm_janus_client
    end

    def name
    end

    def create
      @cm_janus_client.send_transaction(
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

      @cm_janus_client.on :message do |data|
        if data['janus'] == 'timeout' and data['session_id'] == _self.id
          _self.destroy
        end
      end

      @cm_janus_client.on :close do |data|
        _self.emit :destroy, @id
      end

      @cm_janus_client.on :error do |data|
        _self.emit :destroy, @id
      end

      self.emit :create, @id
    end

    def destroy
      @cm_janus_client.send_transaction(
        {
          :janus => "destroy",
          :session_id => @id
        }
      ) do |*args|
        @heartbeat.exit unless @heartbeat.nil?

        self.emit :destroy, @id
      end
    end

    def heartbeat
      @heartbeat = Thread.new do
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

  end
end
