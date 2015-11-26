require 'spec_helper'

describe JanusGateway::Plugin::Rtpbroadcast::Mountpoint do
  let(:transport) { JanusGateway::Transport::WebSocket.new('') }
  let(:client) { JanusGateway::Client.new(transport) }
  let(:session) { JanusGateway::Resource::Session.new(client) }
  let(:plugin) { JanusGateway::Plugin::Rtpbroadcast.new(client, session) }
  let(:rtp_mountpoint) { JanusGateway::Plugin::Rtpbroadcast::Mountpoint.new(client, plugin, 'test-mountpoint') }

  it 'should create rtpbroadcast mountpoint' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":"12345"}}',
      :attach => '{"janus":"success", "session_id":12345, "transaction":"ABCDEFGHIJK", "data":{"id":"54321"}}',
      :message => [
        '{"janus":"success", "session_id":12345, "sender_id":"54321", "transaction":"ABCDEFGHIJK"',
        '"plugindata":{"plugin":"janus.plugin.cm.rtpbroadcast", "data":{"streaming":"created"',
        '"created":"test-mountpoint", "stream":{"id":"test-mountpoint"',
        '"description":"test-mountpoint", "streams":[{"audioport":8576, "videoport":8369}]}}}}'
      ].join(',')
    }

    transport.stub(:_create_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    expect(session).to receive(:create).once.and_call_original
    expect(plugin).to receive(:create).once.and_call_original
    expect(rtp_mountpoint).to receive(:create).once.and_call_original
    expect(client).to receive(:disconnect).once.and_call_original

    client.on :open do
      session.create.then do
        plugin.create.then do
          rtp_mountpoint.create.then do
            client.disconnect
          end
        end
      end
    end

    client.connect
  end

  it 'should handle error for mountpoint create' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":"12345"}}',
      :attach => '{"janus":"success", "session_id":12345, "transaction":"ABCDEFGHIJK", "data":{"id":"54321"}}',
      :message => [
        '{"janus":"success", "session_id":12345, "sender_id":"54321", "transaction":"ABCDEFGHIJK"',
        '"plugindata":{"plugin":"janus.plugin.cm.rtpbroadcast", "data":{"error_code":456, "error": "Cannot create mounpoint"}}}'
      ].join(',')
    }

    transport.stub(:_create_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')
    rtp_mountpoint.stub(:name).and_return('')

    expect(session).to receive(:create).once.and_call_original
    expect(plugin).to receive(:create).once.and_call_original
    expect(rtp_mountpoint).to receive(:create).once.and_call_original
    expect(client).to receive(:disconnect).once.and_call_original

    client.on :open do
      session.create.then do
        plugin.create.then do
          rtp_mountpoint.create.rescue do
            client.disconnect
          end
        end
      end
    end

    client.connect
  end

end
