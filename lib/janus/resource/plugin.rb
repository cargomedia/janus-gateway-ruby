module Janus

  class Resource::Plugin < Resource

    include EventEmitter

    attr_accessor :id

    def initialize(session, name)
      @session = session
      @name = name
    end

    def name
      @name
    end

    def create
      janus_client.send_transaction(
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

      session.on :destroy do |data|
        _self.destroy
      end

      self.emit :create, @id
    end

    def destroy
      self.emit :destroy, @id
    end

    def session
      @session
    end

    def janus_client
      @session.janus_client
    end
  end
end
