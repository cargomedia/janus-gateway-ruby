require 'spec_helper'

describe JanusGateway::Plugin::Rtpbroadcast::Api::List do
  let(:transport) { JanusGateway::Transport::WebSocket.new('') }
  let(:client) { JanusGateway::Client.new(transport) }
  let(:session) { JanusGateway::Resource::Session.new(client) }
  let(:plugin) { JanusGateway::Plugin::Rtpbroadcast.new(client, session) }
  let(:rtp_list) { JanusGateway::Plugin::Rtpbroadcast::Api::List.new(client, plugin) }

  it 'should create rtpbroadcast mountpoint' do
    janus_response = {
      create: '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":"12345"}}',
      attach: '{"janus":"success", "session_id":12345, "transaction":"ABCDEFGHIJK", "data":{"id":"54321"}}',
      message: [
        '{"janus":"success", "session_id":12345, "sender_id":"54321", "transaction":"ABCDEFGHIJK"',
        '"plugindata":{"plugin":"janus.plugin.cm.rtpbroadcast", "data":{"streaming":"list"',
        '"list": []}}}'
      ].join(',')
    }

    transport.stub(:_create_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    expect(session).to receive(:create).once.and_call_original
    expect(plugin).to receive(:create).once.and_call_original
    expect(rtp_list).to receive(:get).once.and_call_original
    expect(EventMachine).to receive(:stop).once.and_call_original

    client.on :open do
      session.create.then do
        plugin.create.then do
          rtp_list.get.then do
            EventMachine.stop
          end
        end
      end
    end

    client.run
  end
end
