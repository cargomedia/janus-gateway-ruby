require 'spec_helper'

describe JanusGateway::Transport::Http do
  let(:url) { 'http://example.com' }
  let(:transport) { JanusGateway::Transport::Http.new(url) }
  let(:http_client) { Net::HTTP.new(url) }
  before do
    transport.stub(:_send) do |data|
      janus_server.respond(data)
    end
  end

  describe '#send_transaction' do
    janus_response = {
      timeout: '{"janus":"success", "transaction":"000"}'
    }

    let(:janus_server) { HttpDummyJanusServer.new(janus_response) }

    it 'should response with timeout' do
      transport.stub(:transaction_id_new).and_return('000')
      transport.stub(:_transaction_timeout).and_return(0.001)

      promise = transport.send_transaction(janus: 'timeout')
      promise.rescue do
      end

      expect(promise.value).to eq(nil)
      expect(promise.rejected?).to eq(true)
    end
  end
end
