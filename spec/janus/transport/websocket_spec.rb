require 'spec_helper'

describe JanusGateway::Transport::WebSocket do
  let(:url) { 'ws://example.com' }
  let(:protocol) { 'janus-protocol' }
  let(:ws_client) { Events::EventEmitter.new }
  let(:transport) { JanusGateway::Transport::WebSocket.new(url) }
  let(:data) { {'janus' => 'success', 'transaction' => 'ABCDEFGHIJK'} }
  before { transport.stub(:_create_client).with(url, protocol).and_return(ws_client) }
  before { ws_client.stub(:send) }
  before { ws_client.stub(:close) }

  describe '#send_transaction' do

    janus_response = {
      :timeout => '{"janus":"success", "transaction":"000"}'
    }

    let(:ws_client) { WebSocketClientMock.new(janus_response) }

    it 'should disconnect after timeout' do

      transport.stub(:transaction_id_new).and_return('000')
      transport.stub(:_transaction_timeout).and_return(0.001)

      promise = nil
      transport.on :open do
        promise = transport.send_transaction({:janus => 'timeout'})
        promise.rescue do
          transport.disconnect
        end
      end

      Thread.new { transport.connect }.join(0.5)

      expect(promise.value).to eq(nil)
      expect(promise.rejected?).to eq(true)
    end
  end

  describe '#connect' do

    it 'emits open' do
      expect(transport).to receive(:emit).with(:open)
      Thread.new { transport.connect }.join(0.1)

      ws_client.emit :open

      transport.disconnect
    end

    it 'emits close' do
      expect(transport).to receive(:emit).with(:close)
      Thread.new { transport.connect }.join(0.1)

      ws_client.emit :close

      transport.disconnect
    end

    it 'fulfills transaction promises' do
      transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')
      expect(transport).to receive(:emit).with(:message, data)

      Thread.new { transport.connect }.join(0.1)
      promise = transport.send_transaction({:janus => 'test'})
      ws_client.emit :message, Faye::WebSocket::API::MessageEvent.new('message', :data => JSON.generate(data))

      expect(promise.value).to eq(data)

      transport.disconnect
    end
  end

  describe '#disconnect' do

    it 'should close websocket connect' do
      transport.stub(:_create_client).with(url, protocol).and_return(ws_client)

      expect(ws_client).to receive(:close).once
      Thread.new { transport.connect }.join(0.1)

      transport.disconnect
    end
  end

end
