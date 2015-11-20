require 'janus'

describe Janus::Plugin::Rtpbroadcast::Mountpoint do

  let(:client) { Janus::Client.new('ws://127.0.0.1:8188/janus') }
  let(:session) { Janus::Session.new(client) }
  let(:plugin) { Janus::Plugin.new(session, Janus::Plugin::Rtpbroadcast.plugin_name) }
  let(:rtp_mountpoint) { Janus::Plugin::Rtpbroadcast::Mountpoint.new(plugin, 'test-mountpoint') }

  it 'should create rtpbroadcast mountpoint' do

    _self = self

    client.on :open do |data|
      _self.session.on :create do |id|
        _self.plugin.on :create do |id|
          _self.rtp_mountpoint.on :create do |data|
            _self.client.destroy
          end
          _self.rtp_mountpoint.create
        end
        _self.plugin.attach
      end
      _self.session.create
    end

    client.connect

  end
end
