require 'spec_helper'

describe JanusGateway::Resource::Session do
  let(:transport) {JanusGateway::Transport::WebSocket.new('') }
  let(:client) { JanusGateway::Client.new(transport) }

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
