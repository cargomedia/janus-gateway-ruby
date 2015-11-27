require 'spec_helper'

describe JanusGateway::Client do

  let(:transport) { double }

  describe '#send_transaction' do

    context 'when given token and admin_secret' do

      let(:token) { 'mytoken' }
      let(:admin_secret) { 'myadminsecret' }
      let(:client) { JanusGateway::Client.new(transport, {:token => token, :admin_secret => admin_secret}) }

      it 'should send along token and admin_secret' do
        expect(transport).to receive(:send_transaction).with({:foo => 1, :token => token, :admin_secret => admin_secret})
        client.send_transaction({:foo => 1})
      end

    end

    context 'when no options passed' do
      let(:client) { JanusGateway::Client.new(transport) }

      it 'should not send along token and admin_secret' do
        expect(transport).to receive(:send_transaction).with({:foo => 2})
        client.send_transaction({:foo => 2})
      end
    end

  end

end
