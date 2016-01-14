module JanusGateway::Plugin
  class Audioroom < JanusGateway::Resource::Plugin
    # @param [JanusGateway::Client] client
    # @param [JanusGateway::Resource::Session] session
    def initialize(client, session)
      super(client, session, 'janus.plugin.cm.audioroom')
    end
  end
end
