module JanusGateway
  class Resource::Plugin < Resource
    # @return [JanusGateway::Resource::Session]
    attr_reader :session

    # @return [String]
    attr_reader :name

    # @param [JanusGateway::Client] client
    # @param [JanusGateway::Resource::Session] session
    # @param [String] plugin_name
    def initialize(client, session, plugin_name)
      @session = session
      @name = plugin_name

      super(client)
    end

    # @return [Concurrent::Promise]
    def create
      promise = Concurrent::Promise.new

      client.send_transaction(
        janus: 'attach',
        plugin: name,
        session_id: @session.id
      ).then do |*args|
        _on_created(*args)

        promise.set(self).execute
      end.rescue do |error|
        promise.fail(error).execute
      end

      promise
    end

    def destroy
      promise = Concurrent::Promise.new

      _on_destroyed
      promise.set(self).execute

      promise
    end

    private

    def _on_created(data)
      @id = data['data']['id']

      session.on :destroy do |_data|
        destroy
      end

      emit :create
    end

    def _on_destroyed
      emit :destroy
    end
  end
end
