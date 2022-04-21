# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transaction::Review do
  let(:url) { "#{api.send(:api_base_url)}/#{api.send(:api_version)}/merchant/transactions/review" }
  let(:response) { instance_double(HTTParty::Response, body: response_body) }
  let(:response_body) { 'Iron Man' }
  let(:api_key) { SolidusBolt::BoltConfiguration.fetch.api_key }
  let(:nonce) { '123456789012345' }

  before do
    create(:bolt_configuration)
    allow(HTTParty).to receive(:post).and_return(response)
  end

  context 'when decision is approve' do
    subject(:api) { described_class.new(transaction_reference: reference, decision: decision) }

    let(:reference) { 'Bolt_Reference_ID' }
    let(:decision) { 'approve' }

    describe '#call' do
      before do
        allow(api).to receive(:generate_nonce).and_return(nonce) # rubocop:disable RSpec/SubjectStub
      end

      it 'sends a request to the Bolt API endpoint' do
        api.call
        expect(HTTParty).to have_received(:post).with(
          url,
          headers: { 'X-API-KEY' => api_key, 'X-Nonce' => nonce },
          query: { transaction_reference: reference, decision: decision }
        )
      end

      it 'receives the correct response' do
        expect(api.call.body).to eq(response_body)
      end
    end
  end

  context 'when decision is reject' do
    subject(:api) { described_class.new(transaction_reference: reference, decision: decision) }

    let(:reference) { 'Bolt_Reference_ID' }
    let(:decision) { 'reject' }

    describe '#call' do
      before do
        allow(api).to receive(:generate_nonce).and_return(nonce) # rubocop:disable RSpec/SubjectStub
      end

      it 'sends a request to the Bolt API endpoint' do
        api.call
        expect(HTTParty).to have_received(:post).with(
          url,
          headers: { 'X-API-KEY' => api_key, 'X-Nonce' => nonce },
          query: { transaction_reference: reference, decision: decision }
        )
      end

      it 'receives the correct response' do
        expect(api.call.body).to eq(response_body)
      end
    end
  end

  context 'when decision is incorrect' do
    let(:reference) { 'Bolt_Reference_ID' }
    let(:decision) { 'Invalid' }

    it 'raises an error' do
      expect do
        described_class.new(transaction_reference: reference, decision: decision)
      end.to raise_error('Decision value should be either "approve" or "reject"')
    end
  end
end
