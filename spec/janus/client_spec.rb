require 'spec_helper'

describe JanusGateway::Resource::Session do
  let(:transport) {JanusGateway::Transport::WebSocket.new('') }
  let(:client) { JanusGateway::Client.new('', transport) }

  it 'should timeout transaction' do

    janus_response = {
      :timeout => '{"janus":"success", "transaction":"000"}'
    }

    transport.stub(:_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('000')
    transport.stub(:_promise_wait_timeout).and_return(0.001)

    _self = self
    client.on :open do
      _self.client.send_transaction({:janus => "timeout"}).rescue do
        _self.client.destroy
      end
    end

    client.connect

  end
end
