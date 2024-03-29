# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transactions::DetailService, :vcr, :bolt_configuration do
  subject(:api) { described_class.new(transaction_reference: reference, payment_method: payment_method) }

  let(:transaction) do
    SolidusBolt::Transactions::AuthorizeService.call(
      order: order, credit_card: credit_card_payload, create_bolt_account: false, payment_method: payment_method
    )
  end
  let(:credit_card_payload) do
    tokenize_credit_card(credit_card_number: '4111111111111004', cvv: '111').merge(
      expiration: (Time.current + 1.year).strftime('%Y-%m'),
      token_type: 'bolt'
    )
  end
  let(:order) { create(:order_with_line_items) }
  let(:reference) { transaction['transaction']['reference'] }
  let(:payment_method) { create(:bolt_payment_method) }

  describe '#call', vcr: true do
    it 'makes the API call' do
      response = api.call

      expect(response['reference']).to eq reference
      expect(response['status']).to eq 'authorized'
    end
  end
end
