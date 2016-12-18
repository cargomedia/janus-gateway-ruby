require 'spec_helper'

describe JanusGateway::Transport::WebSocket do
  let(:url) { 'ws://example.com' }
  let(:protocol) { 'janus-protocol' }
  let(:ws_client) { Events::EventEmitter.new }
  let(:transport) { JanusGateway::Transport::WebSocket.new(url) }
  let(:data) { { 'janus' => 'success', 'transaction' => 'ABCDEFGHIJK' } }
  before { transport.stub(:_create_client).with(url, protocol).and_return(ws_client) }
  before { ws_client.stub(:send) }
  before { ws_client.stub(:close) }
  before { ws_client.stub(:ready_state).and_return(Faye::WebSocket::API::OPEN) }

  describe '#send' do
    it 'should raise if not connected' do
      expect { transport.send('oo') }.to raise_error(StandardError)
    end
  end

  describe '#send_transaction' do
    janus_response = {
      timeout: '{"janus":"success", "transaction":"000"}'
    }

    let(:ws_client) { WebSocketClientMock.new(janus_response) }

    it 'should disconnect after timeout' do
      transport.stub(:transaction_id_new).and_return('000')
      transport.stub(:_transaction_timeout).and_return(0.001)

      promise = nil
      transport.on :open do
        promise = transport.send_transaction(janus: 'timeout')
        promise.rescue do
          EventMachine.stop
        end
      end

      transport.connect
      ws_client.emit :open

      expect(promise.value).to eq(nil)
      expect(promise.rejected?).to eq(true)
    end
  end

  describe '#connect' do
    it 'emits open' do
      expect(transport).to receive(:emit).with(:open)

      transport.connect
      ws_client.emit :open

      transport.disconnect
    end

    it 'emits close' do
      expect(transport).to receive(:emit).with(:close)

      transport.connect
      ws_client.emit :close

      transport.disconnect
    end

    it 'fulfills transaction promises' do
      transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')
      expect(transport).to receive(:emit).with(:message, data)

      transport.connect
      promise = transport.send_transaction(janus: 'test')
      ws_client.emit :message, Faye::WebSocket::API::MessageEvent.new('message', data: JSON.generate(data))

      expect(promise.value).to eq(data)

      transport.disconnect
    end

    it 'try to connect 2 times' do
      expect(transport).to receive(:emit).with(:open)
      expect(transport).to receive(:connect).twice.and_call_original

      transport.connect
      ws_client.emit :open

      expect { transport.connect }.to raise_error(StandardError, /WebSocket client already exists/)

      transport.disconnect
    end
  end

  describe '#disconnect' do
    it 'should close websocket connect' do
      transport.stub(:_create_client).with(url, protocol).and_return(ws_client)

      expect(ws_client).to receive(:close).once
      transport.connect

      transport.disconnect
    end

    it 'should remove pending transactions if connections drops' do
      transport.stub(:_create_client).with(url, protocol).and_return(ws_client)
      transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK-1', 'ABCDEFGHIJK-2', 'ABCDEFGHIJK-3')

      transport.connect
      promise1 = transport.send_transaction(janus: 'test1')
      promise2 = transport.send_transaction(janus: 'test2')
      promise3 = transport.send_transaction(janus: 'test3')

      expect(transport.transaction_queue.count).to eq(3)

      promise3.set(nil).execute.then do
        expect(transport.transaction_queue.count).to eq(2)
        ws_client.emit :close
      end

      expect(promise1.value).to eq(nil)
      expect(promise1.rejected?).to eq(true)

      expect(promise2.value).to eq(nil)
      expect(promise2.rejected?).to eq(true)

      expect(promise3.fulfilled?).to eq(true)
    end
  end
end
