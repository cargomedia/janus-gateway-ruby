module Janus

  class Resource::Plugin < Resource

    include EventEmitter

    attr_accessor :cm_janus_client
    attr_accessor :id
    attr_accessor :name
    attr_accessor :session

    def initialize(session, name)
      @cm_janus_client = session.cm_janus_client
      @session = session
      @name = name
    end

    def name
      @name
    end

    def attach
      @cm_janus_client.send_transaction(
        {
          :janus => "attach",
          :plugin => name,
          :session_id => @session.id
        }
      ) do |*args|
        on_created(*args)
      end
    end

    def on_created(data)
      @id = data['data']['id']

      _self = self

      @session.on :destroy do |data|
        _self.destroy
      end

      self.emit :create, @id
    end

    def destroy
      self.emit :destroy, @id
    end
  end
end
