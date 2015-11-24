module JanusGateway

  class Plugin::Rtpbroadcast::Resource::Mountpoint < JanusGateway::Resource

    include EventEmitter

    # @param [JanusGateway::Resource::Plugin] plugin
    # @param [String] name
    # @param [Array] streams
    def initialize(plugin, name, streams = nil)
      @plugin = plugin
      @name = name
      @id = name

      @streams = streams || [
        {
          :audio => 'yes',
          :video => 'yes',
          :audiopt => 111,
          :audiortpmap => 'opus/48000/2',
          :videopt => 100,
          :videortpmap => 'VP8/90000'
        }
      ]
    end

    # @return [String, NilClass]
    def name
      @name
    end

    # @return [Concurrent::Promise]
    def create
      promise = Concurrent::Promise.new

      janus_client.send_transaction(
        {
          :janus => 'message',
          :session_id => @plugin.session.id,
          :handle_id => @plugin.id,
          :body => {
            :request => 'create',
            :id => name,
            :name => name,
            :description => name,
            :recorded => true,
            :streams => @streams
          }
        }
      ).then do |data|
        plugindata = data['plugindata']['data']
        if plugindata['error_code'].nil?
          on_created(data)

          promise.set(self)
          promise.execute
        else
          error = JanusGateway::Error.new(plugindata['error_code'], plugindata['error'])

          on_error(error)

          promise.fail(error).execute
        end
      end.rescue do |error|
        promise.fail(error).execute
      end

      promise
    end

    def on_error(error)
      self.emit :error, error
    end

    def on_created(data)
      @data = data['plugindata']

      _self = self

      plugin.on :destroy do
        _self.destroy
      end

      self.emit :create, @id
    end

    def on_destroyed
      self.emit :destroy, @id
    end

    # @return [Array<Hash>]
    def streams
      @data['data']['stream']['streams']
    end

    def destroy
      promise = Concurrent::Promise.new

      on_destroyed

      promise.set(self)
      promise.execute

      promise
    end

    # @return [JanusGateway::Resource::Session]
    def session
      plugin.session
    end

    # @return [JanusGateway::Resource::Plugin]
    def plugin
      @plugin
    end

    # @return [JanusGateway::Client]
    def janus_client
      plugin.janus_client
    end
  end
end
