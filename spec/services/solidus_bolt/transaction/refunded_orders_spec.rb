# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transaction::RefundedOrders do
  subject(:api) { described_class.new }

  before do
    create(:bolt_configuration)
  end

  describe '#call', vcr: true do
    it 'returns status 200' do
      expect(api.call.code).to eq 200
    end

    it 'receives the correct response' do
      response = JSON.parse(api.call.body)
      expect(response).to eq([])
    end
  end
end
