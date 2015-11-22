require "spec_helper"

describe Janus::Resource::Session do
  let(:client) { Janus::Client.new('') }

  it 'should timeout transaction' do

    janus_response = {
      :timeout => '{"janus":"success", "transaction":"000"}'
    }

    client.stub(:websocket_client_new).and_return(WebSocketClientMock.new(janus_response))
    client.stub(:transaction_id_new).and_return('000')
    client.stub(:_promise_wait_timeout).and_return(0.001)

    _self = self
    client.on :open do
      _self.client.send_transaction({:janus => "timeout"}).rescue do
        _self.client.destroy
      end
    end

    client.connect

  end
end
