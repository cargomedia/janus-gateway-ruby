module JanusGateway::Plugin
  class Rtpbroadcast < JanusGateway::Resource::Plugin
    # @param [JanusGateway::Client] client
    # @param [JanusGateway::Resource::Session] session
    def initialize(client, session)
      super(client, session, 'janus.plugin.cm.rtpbroadcast')
    end
  end
end
