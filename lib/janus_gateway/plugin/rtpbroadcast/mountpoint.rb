module JanusGateway::Plugin
  class Rtpbroadcast::Mountpoint < JanusGateway::Resource
    # @return [JanusGateway::Resource::Plugin]
    attr_reader :plugin

    # @return [Hash, NilClass]
    attr_reader :data

    # @param [JanusGateway::Client] client
    # @param [JanusGateway::Plugin::Rtpbroadcast] plugin
    # @param [String] id
    # @param [Array] streams
    # @param [String] channel_data
    def initialize(client, plugin, id, streams = nil, channel_data = nil)
      @plugin = plugin
      @data = nil
      @channel_data = channel_data

      @streams = streams || [
        {
          audio: 'yes',
          video: 'yes',
          audiopt: 111,
          audiortpmap: 'opus/48000/2',
          videopt: 100,
          videortpmap: 'VP8/90000'
        }
      ]

      super(client, id)
    end

    # @return [Concurrent::Promise]
    def create
      promise = Concurrent::Promise.new

      client.send_transaction(
        janus: 'message',
        session_id: plugin.session.id,
        handle_id: plugin.id,
        body: {
          request: 'create',
          id: id,
          name: id,
          description: id,
          recorded: true,
          streams: @streams,
          channel_data: @channel_data
        }
      ).then do |data|
        plugindata = data['plugindata']['data']
        if plugindata['error_code'].nil?
          _on_created(data)

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

    # @return [Array<Hash>]
    def streams
      !data.nil? ? data['data']['stream']['streams'] : []
    end

    # @return [Concurrent::Promise]
    def destroy
      promise = Concurrent::Promise.new

      _on_destroyed
      promise.set(self).execute

      promise
    end

    # @return [JanusGateway::Resource::Session]
    def session
      plugin.session
    end

    private

    def _on_error(error)
      emit :error, error
    end

    def _on_created(data)
      @data = data['plugindata']

      plugin.on :destroy do
        destroy
      end

      emit :create
    end

    def _on_destroyed
      emit :destroy
    end
  end
end
