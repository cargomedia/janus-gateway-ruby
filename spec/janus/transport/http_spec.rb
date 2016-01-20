require 'spec_helper'

describe JanusGateway::Transport::Http do
  let(:url) { 'http://example.com' }
  let(:data) { { 'janus' => 'success', 'transaction' => 'ABCDEFGHIJK' } }
  let(:transport) { JanusGateway::Transport::Http.new(url) }
  before do
    transport.stub(:_send) do |data|
      janus_server.respond(data)
    end
  end

  describe '#send_transaction' do
    error_0 = JanusGateway::Error.new(0, 'HTTP/Transport response: `501`')

    janus_response = {
      timeout: '{"janus":"success", "transaction":"000"}',
      test: '{"janus":"success", "transaction":"ABCDEFGHIJK"}',
      create: "{\"error\":{\"code\": #{error_0.code}, \"reason\": \"#{error_0.info}\"}}"
    }

    let(:janus_server) { HttpDummyJanusServer.new(janus_response) }

    it 'should response with timeout' do
      transport.stub(:transaction_id_new).and_return('000')
      transport.stub(:_transaction_timeout).and_return(0.001)

      transport.stub(:send)

      promise = transport.send_transaction(janus: 'timeout')
      EM.run do
        promise.rescue do
          EM.stop
        end
      end
      expect(promise.value).to eq(nil)
      expect(promise.rejected?).to eq(true)
    end

    it 'fulfills transaction promises' do
      transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')
      expect(transport).to receive(:_send).with(janus: 'test', transaction: 'ABCDEFGHIJK')

      promise = transport.send_transaction(janus: 'test')
      EM.run do
        promise.then do
          EM.stop
        end
      end
      expect(promise.value).to eq(data)
    end

    it 'rejects transaction promises' do
      transport.stub(:transaction_id_new).and_return('ABCDEFGHIJK')
      transport.stub(:_send) do
        Concurrent::Promise.reject('501')
      end
      promise = transport.send_transaction(janus: 'create')

      EM.run do
        promise.rescue do
          EM.stop
        end
      end
      expect(promise.value).to eq(nil)
      expect(promise.rejected?).to eq(true)
      expect(promise.reason.message).to eq(error_0.message)
    end
  end
end
