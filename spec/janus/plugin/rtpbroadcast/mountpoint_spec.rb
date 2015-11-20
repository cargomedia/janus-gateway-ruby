require 'janus'
require 'eventmachine'
require 'event_emitter'

class EventMock

  def initialize(data = nil)
    @data = data || '{}'
  end

  def data
    @data
  end

end

class WebSocketClientMock

  include EventEmitter

  def initialize
    connect_mock
  end

  def connect_mock
    Thread.new do
      sleep(0.2)
      self.emit :open, EventMock.new
    end
  end

  def send(data)
    data_json = JSON.parse(data)
    response = '{}'

    case data_json['janus']
      when 'create'
        response = '{"janus":"success", "transaction":"CvBn1YojWE5e", "data":{"id":"12345"}}'
      when 'attach'
        response = '{"janus":"success", "session_id":183170935, "transaction":"CvBn1YojWE5e", "data":{"id":"54321"}}'
      when 'message'
        response = [
          '{"janus":"success", "session_id":12345, "sender_id":"54321", "transaction":"CvBn1YojWE5e"',
          '"plugindata":{"plugin":"janus.plugin.cm.rtpbroadcast", "data":{"streaming":"created"',
          '"created":"rndmvr-studio-agent-bulldog1448032631000", "stream":{"id":"rndmvr-studio-agent-bulldog1448032631000"',
          '"description":"rndmvr-studio-agent-bulldog1448032631000", "streams":[{"audioport":8576, "videoport":8369}]}}}}'
        ].join(',')
    end

    Thread.new do
      sleep(0.1)
      self.emit :message, EventMock.new(response)
    end
  end

  def close
    Thread.new do
      sleep(0.1)
      self.emit :close, EventMock.new
    end
  end
end

describe Janus::Plugin::Rtpbroadcast::Mountpoint do

  let(:client) { Janus::Client.new('ws://10.10.10.111:8188/janus') }
  let(:session) { Janus::Session.new(client) }
  let(:plugin) { Janus::Plugin.new(session, Janus::Plugin::Rtpbroadcast.plugin_name) }
  let(:rtp_mountpoint) { Janus::Plugin::Rtpbroadcast::Mountpoint.new(plugin, 'test-mountpoint') }

  it 'should create rtpbroadcast mountpoint' do

    client.stub(:websocket_client).and_return(WebSocketClientMock.new)

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
