module JanusGateway

  class Plugin::Rtpbroadcast < JanusGateway::Plugin

    # @return [String]
    def self.plugin_name
      'janus.plugin.cm.rtpbroadcast'
    end
  end
end
