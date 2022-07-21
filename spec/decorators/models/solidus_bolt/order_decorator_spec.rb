require 'spec_helper'

RSpec.describe SolidusBolt::OrderDecorator do
  let(:order) { create(:order_with_line_items) }

  describe '#bolt_cart' do
    it 'returns a hash with line items and price' do
      result = {
        total_amount: (order.total * 100).to_i,
        order_reference: order.number,
        currency: 'USD',
        shipments: array_including(hash_including(:reference)),
        items: [{
          sku: order.line_items.first.sku,
          name: order.line_items.first.name,
          unit_price: 1000,
          quantity: 1
        }]
      }

      expect(order.bolt_cart).to match hash_including(result)
    end
  end

  describe '#bolt_user_identifier' do
    it 'returns a hash with email and phone' do
      result = { email: order.email, phone: '555-555-0199' }
      expect(order.bolt_user_identifier).to eq(result)
    end
  end

  describe '#bolt_user_identity' do
    it 'returns a hash with name' do
      result = { 'first_name': 'John', 'last_name': 'Doe' }
      expect(order.bolt_user_identity).to eq(result)
    end
  end
end
