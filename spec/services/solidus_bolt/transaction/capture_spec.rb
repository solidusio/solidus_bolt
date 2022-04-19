# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transaction::Capture do
  subject(:api) { described_class.new(transaction_reference: reference, amount: amount, currency: currency) }

  # Replace with reference ID, amount and currency from transaction created using helper method
  let(:reference) { 'M768-8YNG-KGMY' }
  let(:amount) { 10 }
  let(:currency) { 'USD' }

  before do
    create(:bolt_configuration)
  end

  describe '#call', vcr: true do
    it 'returns status 200' do
      expect(api.call.code).to eq 200
    end

    it 'receives the correct response' do
      response = JSON.parse(api.call.body)
      expect(response['reference']).to eq(reference)
    end

    it 'receives the correct capture status' do
      response = JSON.parse(api.call.body)
      expect(response['capture']['status']).to eq 'succeeded'
    end
  end
end
