module JanusGateway::Plugin::Rtpbroadcast::Api
  class List < JanusGateway::ApiEndpoint
    # @return [JanusGateway::Resource::Plugin]
    attr_reader :plugin

    # @return [Hash, NilClass]
    attr_reader :data

    # @param [JanusGateway::Client] client
    # @param [JanusGateway::Plugin::Rtpbroadcast] plugin
    def initialize(client, plugin)
      @plugin = plugin
      @data = nil

      super(client)
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
          promise.set(data).execute
        else
          error = JanusGateway::Error.new(plugindata['error_code'], plugindata['error'])
          promise.fail(error).execute
        end
      end.rescue do |error|
        promise.fail(error).execute
      end

      promise
    end
  end
end
