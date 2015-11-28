require 'spec_helper'

describe JanusGateway::Error do

  let(:error_code) { 123 }
  let(:error_info) { 'test-123' }
  let(:error) { JanusGateway::Error.new(error_code, error_info) }

  it 'should convert error to the string' do
    expect(error.to_s).to eq('test-123')
  end

end
