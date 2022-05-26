# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Orders::TrackShipmentService, :vcr, :bolt_configuration do
  subject(:api) do
    described_class.new(transaction_reference: reference, shipment: shipment)
  end

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
  let(:payment_method) { create(:bolt_payment_method, preference_source: 'bolt_config_credentials') }
  let(:shipping_method) { create(:shipping_method, name: 'MockBoltShipping') }
  let(:shipment) { order.shipments.last }

  describe '#call', vcr: true do
    before do
      shipment.select_shipping_method(shipping_method)
      shipment.update(tracking: "MockBolt#{rand(1000..9999)}")
    end

    it 'makes the API call' do
      response = api.call

      expect(response).to be_nil
    end
  end
end
