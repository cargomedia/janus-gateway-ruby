require 'spec_helper'

describe JanusGateway::Transport::Http do
  let(:url) { 'http://example.com' }
  let(:data) { { 'janus' => 'success', 'transaction' => 'ABCDEFGHIJK' } }
  let(:transport) { JanusGateway::Transport::Http.new(url) }

  describe '#send_transaction' do
    before do
      transport.stub(:_send) do |data|
        janus_server.respond(data)
      end
    end
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

      promise = transport.send_transaction(janus: 'test').then { EM.stop }.rescue { EM.stop }
      EM.run do
        EM.error_handler do |e|
          puts e
          EM.stop
        end
        promise
      end
      expect(promise.reason).to eq(nil)
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

  describe 'when _send' do
    include WebMock::API

    context 'when given invalid data' do
      it 'should raise when cannot parse to json' do
        expect { transport.__send__(:_send, 'foo') }.to raise_error(StandardError)
      end
    end

    context 'when given proper data' do
      let(:http_request) { stub_request(:post, url) }
      let(:request) { transport.__send__(:_send, 'request_param' => 'value') }

      it 'should send proper http request' do
        http_request.with(body: { 'request_param' => 'value' })
        http_request.to_return(body: '[]')
        EM.run do
          request.then { EM.stop }
          request.rescue { EM.stop }
        end
        expect(request.fulfilled?).to eq(true)
      end

      context 'and responds with valid response' do
        it 'should resolve with body' do
          http_request.to_return(body: '{"response_param":"value"}')
          EM.run do
            request.then { EM.stop }
            request.rescue { EM.stop }
          end

          expect(request.fulfilled?).to eq(true)
          expect(request.value).to eq('response_param' => 'value')
        end
      end

      context 'and responds with non-valid status' do
        it 'should reject with http error' do
          http_request.to_return(status: [500, 'Internal Server Error'])
          EM.run do
            request.then { EM.stop }
            request.rescue { EM.stop }
          end

          expect(request.rejected?).to eq(true)
        end
      end

      context 'and responds with invalid json data' do
        it 'should reject with error' do
          http_request.to_return(body: 'invalid-json')
          EM.run do
            request.then { EM.stop }
            request.rescue { EM.stop }
          end

          expect(request.rejected?).to eq(true)
        end
      end

      context 'and timeouts' do
        let(:request) { transport.__send__(:_send, []) }

        it 'should reject with error' do
          http_request.to_timeout
          EM.run do
            request.then { EM.stop }
            request.rescue { EM.stop }
          end

          expect(request.rejected?).to eq(true)
        end
      end
    end
  end
end
