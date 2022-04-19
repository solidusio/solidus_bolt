# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transaction::Refund do
  subject(:api) { described_class.new(transaction_reference: reference, amount: amount, currency: currency) }

  let(:order) { create(:order) }
  let(:reference) { 'Bolt_Reference_ID' }
  let(:amount) { order.total }
  let(:currency) { order.currency }

  before do
    create(:bolt_configuration)
  end

  describe '#call' do
    let(:url) { "#{api.send(:api_base_url)}/#{api.send(:api_version)}/merchant/transactions/credit" }
    let(:response) { instance_double(HTTParty::Response, body: response_body) }
    let(:response_body) { 'Iron Man' }
    let(:api_key) { SolidusBolt::BoltConfiguration.fetch.api_key }
    let(:nonce) { '123456789012345' }

    before do
      allow(HTTParty).to receive(:post).and_return(response)
      allow(api).to receive(:generate_nonce).and_return(nonce) # rubocop:disable RSpec/SubjectStub
    end

    it 'sends a request to the Bolt API endpoint' do
      api.call
      expect(HTTParty).to have_received(:post).with(
        url,
        headers: { 'X-API-KEY' => api_key, 'X-Nonce' => nonce },
        query: { transaction_reference: reference, amount: amount, currency: currency }
      )
    end

    it 'receives the correct response' do
      expect(api.call.body).to eq(response_body)
    end
  end
end
