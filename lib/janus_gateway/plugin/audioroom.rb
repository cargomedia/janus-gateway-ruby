module JanusGateway::Plugin
  class Audioroom < JanusGateway::Resource::Plugin
    # @param [JanusGateway::Client] client
    # @param [JanusGateway::Resource::Session] session
    def initialize(client, session)
      super(client, session, 'janus.plugin.cm.audioroom')
    end

    # @return [Concurrent::Promise]
    def list
      promise = Concurrent::Promise.new

      client.send_transaction(
        janus: 'message',
        session_id: session.id,
        handle_id: id,
        body: { request: 'list' }
      ).then do |data|
        plugindata = data['plugindata']['data']
        if plugindata['error_code'].nil?
          _on_success(data)

          promise.set(data).execute
        else
          error = JanusGateway::Error.new(plugindata['error_code'], plugindata['error'])

          _on_error(error)

          promise.fail(error).execute
        end
      end.rescue do |error|
        promise.fail(error).execute
      end

      promise
    end

    private

    def _on_success(data)
      @data = data['plugindata']

      emit :success
    end

    def _on_error(error)
      emit :error, error
    end
  end
end
