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
        '"created":"test-mountpoint", "stream":{"id":"test-mountpoint"',
        '"description":"test-mountpoint", "streams":[{"audioport":8576, "videoport":8369}]}}}}'
      ].join(',')
    }

    client.stub(:websocket_client_new).and_return(WebSocketClientMock.new(janus_response))
    client.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    _self = self
    client.on :open do
      _self.session.create.then do
        _self.plugin.create.then do
          _self.rtp_mountpoint.create.then do
            _self.client.destroy
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

    client.stub(:websocket_client_new).and_return(WebSocketClientMock.new(janus_response))
    client.stub(:transaction_id_new).and_return('ABCDEFGHIJK')
    rtp_mountpoint.stub(:name).and_return('')

    _self = self
    client.on :open do
      _self.session.create.then do
        _self.plugin.create.then do
          _self.rtp_mountpoint.create.catch do
            _self.client.destroy
          end
        end
      end
    end

    client.connect
  end

end
