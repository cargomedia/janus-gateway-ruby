module JanusGateway::Plugin::Rtpbroadcast::Api
  class Create < JanusGateway::ApiEndpoint

    # @param [JanusGateway::Client] client
    def initialize(client)

      @client = client
    end

    # @param [JanusGateway::Plugin::Rtpbroadcast::Mountpoint]
    # @return [Concurrent::Promise]
    def execute(mountpoint)
      promise = Concurrent::Promise.new

      client.send_transaction(
        janus: 'message',
        session_id: mountpoint.plugin.session.id,
        handle_id: mountpoint.plugin.id,
        body: {
          request: 'create',
          id: mountpoint.id,
          name: mountpoint.id,
          description: mountpoint.id,
          recorded: true,
          streams: mountpoint.streams,
          channel_data: mountpoint.channel_data
        }
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
