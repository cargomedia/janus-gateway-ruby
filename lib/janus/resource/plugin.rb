module Janus

  class Resource::Plugin < Resource

    def initialize(session, name)
      @session = session
      @name = name

      super()
    end

    def name
      @name
    end

    def create
      p = Concurrent::Promise.new

      janus_client.send_transaction(
        {
          :janus => "attach",
          :plugin => name,
          :session_id => @session.id
        }
      ) do |*args|
        on_created(*args)

        p.execute { self }
      end

      p
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
