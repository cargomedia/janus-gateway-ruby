module JanusGateway::Plugin
  class Audioroom::List < JanusGateway::Resource
    # @return [JanusGateway::Resource::Plugin]
    attr_reader :plugin

    # @return [Hash, NilClass]
    attr_reader :data

    # @param [JanusGateway::Client] client
    # @param [JanusGateway::Plugin::Audioroom] plugin
    # @param [String] id
    def initialize(client, plugin, id = nil)
      @plugin = plugin
      @data = nil

      super(client, id)
    end

    # @return [Concurrent::Promise]
    def get
      promise = Concurrent::Promise.new

      client.send_transaction(
        janus: 'message',
        session_id: plugin.session.id,
        handle_id: plugin.id,
        body: { request: 'list' }
      ).then do |data|

        plugindata = data['plugindata']['data']
        if plugindata['error_code'].nil?
          _on_success(data)

          promise.set(self).execute
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

    # @return [JanusGateway::Resource::Session]
    def session
      plugin.session
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
