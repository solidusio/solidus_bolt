# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transaction::Detail do
  subject(:api) { described_class.new(transaction_reference: reference) }

  # Replace with reference ID from transaction created using helper method
  let(:reference) { 'T6JB-MLHP-YZ38' }

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
  end
end
