module JanusGateway::Plugin
  class Rtpbroadcast < JanusGateway::Resource::Plugin
    # @param [JanusGateway::Client] client
    # @param [JanusGateway::Resource::Session] session
    def initialize(client, session)
      super(client, session, 'janus.plugin.cm.rtpbroadcast')
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

    # @param [String] mountpoint_id
    # @param [Array] streams
    # @return [Concurrent::Promise]
    def watch_udp(mountpoint_id, streams)
      promise = Concurrent::Promise.new

      client.send_transaction(
        janus: 'message',
        session_id: session.id,
        handle_id: id,
        body: {
          request: 'watch-udp',
          id: mountpoint_id,
          streams: streams
        }
      ).then do |data|
        if data['error_code'].nil?
          _on_success(data)

          promise.set(data).execute
        else
          error = JanusGateway::Error.new(data['error_code'], data['error'])

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
