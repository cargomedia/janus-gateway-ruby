require 'spec_helper'

describe JanusGateway::Resource::Session do
  let(:transport) { JanusGateway::Transport::WebSocket.new('') }
  let(:client) { JanusGateway::Client.new(transport) }
  let(:session_data) { {:session => 123} }
  let(:session) { JanusGateway::Resource::Session.new(client, session_data) }
  let(:spec_success) { double(Proc) }
  let(:error_468) { JanusGateway::Error.new(468, 'The ID provided to create a new session is already in use') }
  let(:error_458) { JanusGateway::Error.new(458, 'Session not found') }

  it 'should throw exception' do

    janus_response = {
      :create => "{\"janus\":\"error\", \"transaction\":\"123\", \"error\":{\"code\":#{error_468.code}, \"reason\": \"#{error_468.info}\"}}"
    }

    transport.stub(:_create_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('123')

    expect(session).to receive(:create).once.and_call_original
    expect(spec_success).to receive(:call).once.with(error_468.code, error_468.info)

    client.on :open do
      session.create.rescue do |error|
        EventMachine.stop
        spec_success.call(error.code, error.info)
      end
    end

    client.run
  end

  it 'should destroy session' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":"12345"}}',
      :destroy => '{"janus":"success", "session_id":12345, "transaction":"ABCDEFGHIJK"}'
    }

    transport.stub(:_create_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    expect(session).to receive(:create).once.and_call_original
    expect(session).to receive(:destroy).once.and_call_original
    expect(spec_success).to receive(:call).once

    client.on :open do
      session.create.then do
        session.destroy.then do
          EventMachine.stop
          spec_success.call
        end
      end
    end

    client.run
  end

  it 'should fail to destroy session' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":"12345"}}',
      :destroy => '{"janus":"error", "session_id":999, "transaction":"ABCDEFGHIJK", "error":{"code":458, "reason": "Session not found"}}'
    }

    transport.stub(:_create_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    expect(session).to receive(:create).once.and_call_original
    expect(session).to receive(:destroy).once.and_call_original
    expect(spec_success).to receive(:call).once.with(error_458.code, error_458.info)

    client.on :open do
      session.create.then do
        session.id = 999
        session.destroy.rescue do |error|
          EventMachine.stop
          spec_success.call(error.code, error.info)
        end
      end
    end

    client.run
  end

  it 'should session timeout' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":12345}}'
    }

    transport.stub(:_create_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    expect(session).to receive(:create).once.and_call_original
    expect(spec_success).to receive(:call).once

    client.on :open do
      session.on :destroy do
        EventMachine.stop
        spec_success.call
      end
      session.create.then do
        client.transport.client.receive_message('{"janus":"timeout", "session_id":12345}')
      end
    end

    client.run
  end

  it 'should set extra data' do

    janus_response = {
      :create => '{"janus":"success", "transaction":"ABCDEFGHIJK", "data":{"id":12345}}'
    }

    transport.stub(:_create_client).and_return(WebSocketClientMock.new(janus_response))
    transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')

    expect(session).to receive(:create).once.and_call_original
    expect(transport).to receive(:send).once.and_call_original
    expect(client.extra_data).to eq({:token => session_data})
    expect(spec_success).to receive(:call).once

    client.on :open do
      session.create.then do
        EventMachine.stop
        spec_success.call
      end
    end

    client.run
  end

end

