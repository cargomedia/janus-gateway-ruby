require "spec_helper"

describe Janus::Resource::Session do
  let(:client) { Janus::Client.new('') }
  let(:session) { Janus::Resource::Session.new(client) }

  it 'should throw exception' do

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

  it 'should destroy session' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":"12345"}}',
      :destroy => '{"janus":"success", "session_id":12345, "transaction":"ABCDEFGHIJK"}'
    }

    client.stub(:websocket_client_new).and_return(WebSocketClientMock.new(janus_response))
    client.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    _self = self
    client.on :open do
      _self.session.create.then do
        _self.session.destroy.then do
          _self.client.destroy
        end
      end
    end

    client.connect
  end

  it 'should fail to destroy session' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":"12345"}}',
      :destroy => '{"janus":"error", "session_id":999, "transaction":"ABCDEFGHIJK", "error":{"code":458, "error": "Session not found"}}'
    }

    client.stub(:websocket_client_new).and_return(WebSocketClientMock.new(janus_response))
    client.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    _self = self
    client.on :open do
      _self.session.create.then do
        _self.session.id = 999
        _self.session.destroy.rescue do
          _self.client.destroy
        end
      end
    end

    client.connect
  end

  it 'should session timeout' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":12345}}'
    }

    client.stub(:websocket_client_new).and_return(WebSocketClientMock.new(janus_response))
    client.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    _self = self
    client.on :open do
      _self.session.on :destroy do
        _self.client.destroy
      end
      _self.session.create.then do
        _self.client.websocket_client.receive_message('{"janus":"timeout", "session_id":12345}')
      end
    end

    client.connect
  end

end

