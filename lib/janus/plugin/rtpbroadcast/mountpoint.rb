module Janus

  class Plugin

    class Rtpbroadcast

      class Mountpoint < Janus::Plugin::Rtpbroadcast

        include EventEmitter

        attr_accessor :cm_janus_client
        attr_accessor :name
        attr_accessor :data

        attr_accessor :plugin

        attr_accessor :audio_rtpmap
        attr_accessor :audio_opt

        attr_accessor :video_rtpmap
        attr_accessor :video_opt

        attr_accessor :audio_runtime_port
        attr_accessor :video_runtime_port

        def initialize(plugin, name)
          @cm_janus_client = plugin.cm_janus_client
          @plugin = plugin
          @name = name
        end

        def name
          @name
        end

        def create
          @cm_janus_client.send_transaction(
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
                :streams => [
                  {
                    :audio => 'yes',
                    :video => 'yes',
                    :audioport => 9002,
                    :audiopt => 111,
                    :audiortpmap => 'opus/48000/2',
                    :videoport => 9004,
                    :videopt => 100,
                    :videortpmap => 'VP8/90000'
                  }
                ]
              }
            }
          ) do |data|
            plugindata = data['plugindata']['data']
            if plugindata['error_code'].nil?
              on_created(data)
            else
              on_error(plugindata['error_code'], plugindata['error'])
            end
          end
        end

        def on_error(code, message)
          self.emit :error, {:code => code, :message => message}
        end

        def on_created(data)
          @data = data['plugindata']

          _self = self

          @plugin.on :destroy do |data|
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
      end
    end
  end
end
