# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transactions::Authorize, :vcr, :bolt_configuration do
  subject(:authorize) do
    described_class.call(
      order: order, credit_card: credit_card_payload, create_bolt_account: false
    )
  end

  let(:credit_card_payload) do
    tokenize_credit_card(credit_card_number: '4111111111111004', cvv: '111').merge(
      expiration: (Time.current + 1.year).strftime('%Y-%m'),
      token_type: 'bolt'
    )
  end
  let(:order) { create(:order_with_line_items) }

  describe '#call' do
    it 'makes the API call' do
      expect(authorize).to match hash_including('transaction')
    end
  end
end
