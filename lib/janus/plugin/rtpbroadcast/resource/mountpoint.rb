module Janus

  class Plugin::Rtpbroadcast::Resource::Mountpoint < Janus::Plugin::Rtpbroadcast

    include EventEmitter

    def initialize(plugin, name, streams = nil)
      @plugin = plugin
      @name = name

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

    def name
      @name
    end

    def create
      p = Concurrent::Promise.new

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
      ) do |data|
        plugindata = data['plugindata']['data']
        if plugindata['error_code'].nil?
          on_created(data)

          p.execute { self }
        else
          on_error(plugindata['error_code'], plugindata['error'])
        end
      end

      p
    end

    def on_error(code, message)
      self.emit :error, {:code => code, :message => message}
    end

    def on_created(data)
      @data = data['plugindata']

      _self = self

      plugin.on :destroy do |data|
        _self.destroy
      end

      self.emit :create, @data
    end

    def streams
      @data['data']['stream']['streams']
    end

    def destroy
      self.emit :destroy, @data
    end

    def session
      plugin.session
    end

    def plugin
      @plugin
    end

    def janus_client
      plugin.janus_client
    end
  end
end
