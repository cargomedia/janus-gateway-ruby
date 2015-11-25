require 'spec_helper'

describe JanusGateway::Resource::Session do
  let(:url) { 'ws://example.com' }
  let(:protocol) { 'janus-protocol' }
  let(:ws_client) { Events::EventEmitter.new }
  let(:transport) { JanusGateway::Transport::WebSocket.new(url) }
  let(:client) { JanusGateway::Client.new(transport) }

  it '#connect' do
    transport.stub(:_create_client).with(url, protocol).and_return(ws_client)

    expect(transport).to receive(:emit).with(:open)
    Thread.new { client.connect }.join(0.1)

    ws_client.emit :open
  end

  it '#disconnect' do
    transport.stub(:_create_client).with(url, protocol).and_return(ws_client)

    expect(transport).to receive(:emit).with(:close)
    Thread.new { client.connect }.join(0.1)

    ws_client.emit :close
  end

  it 'should disconnect after timeout' do

    janus_response = {
      :timeout => '{"janus":"success", "transaction":"000"}'
    }

    transport.stub(:_create_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('000')
    transport.stub(:_transaction_timeout).and_return(0.001)

    client.on :open do
      client.send_transaction({:janus => "timeout"}).rescue do
        client.disconnect
      end
    end

    client.connect

  end
end
