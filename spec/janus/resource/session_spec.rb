require "spec_helper"

describe Janus::Resource::Session do
  let(:client) { Janus::Client.new('') }
  let(:session) { Janus::Resource::Session.new(client) }

  it 'should throw exception for transaction' do

    janus_response = {
      :create => '{"janus":"error", "transaction":"123", "error":{"code":468, "reason": "The ID provided to create a new session is already in use"}}'
    }

    client.stub(:websocket_client_new).and_return(WebSocketClientMock.new(janus_response))
    client.stub(:transaction_id_new).and_return('123')

    _self = self
    client.on :open do
      _self.session.create.rescue do |error|
        error.code.should _self.eq(468)
        _self.client.destroy
      end
    end

    client.connect
  end
end

