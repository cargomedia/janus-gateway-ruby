require 'spec_helper'

describe JanusGateway::Resource::Plugin do
  let(:transport) { JanusGateway::Transport::WebSocket.new('') }
  let(:client) { JanusGateway::Client.new(transport) }
  let(:session) { JanusGateway::Resource::Session.new(client) }
  let(:plugin) { JanusGateway::Resource::Plugin.new(client, session, JanusGateway::Plugin::Rtpbroadcast.plugin_name) }

  it 'should return plugin handler id' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"123", "data":{"id":"12345"}}',
      :attach => '{"janus":"success", "session_id":12345, "transaction":"123", "data":{"id":"54321"}}'
    }

    transport.stub(:_create_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('123')

    client.on :open do
      session.create.then do
        plugin.create.then do
          plugin.id.should eq("54321")
          client.disconnect
        end
      end
    end

    client.connect
  end

end

