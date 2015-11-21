require "spec_helper"

describe Janus::Plugin::Rtpbroadcast::Resource::Mountpoint do

  let(:client) { Janus::Client.new('') }
  let(:session) { Janus::Resource::Session.new(client) }
  let(:plugin) { Janus::Resource::Plugin.new(session, Janus::Plugin::Rtpbroadcast.plugin_name) }
  let(:rtp_mountpoint) { Janus::Plugin::Rtpbroadcast::Resource::Mountpoint.new(plugin, 'test-mountpoint') }

  it 'should create rtpbroadcast mountpoint' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":"12345"}}',
      :attach => '{"janus":"success", "session_id":12345, "transaction":"ABCDEFGHIJK", "data":{"id":"54321"}}',
      :message => [
        '{"janus":"success", "session_id":12345, "sender_id":"54321", "transaction":"ABCDEFGHIJK"',
        '"plugindata":{"plugin":"janus.plugin.cm.rtpbroadcast", "data":{"streaming":"created"',
        '"created":"rndmvr-studio-agent-bulldog1448032631000", "stream":{"id":"rndmvr-studio-agent-bulldog1448032631000"',
        '"description":"rndmvr-studio-agent-bulldog1448032631000", "streams":[{"audioport":8576, "videoport":8369}]}}}}'
      ].join(',')
    }

    client.stub(:websocket_client_new).and_return(WebSocketClientMock.new(janus_response))
    client.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    _self = self
    client.on :open do |data|
      _self.session.on :create do |id|
        _self.plugin.on :create do |id|
          _self.rtp_mountpoint.on :create do |data|
            _self.client.destroy
          end
          _self.rtp_mountpoint.create
        end
        _self.plugin.create
      end
      _self.session.create
    end

    client.connect

  end
end
