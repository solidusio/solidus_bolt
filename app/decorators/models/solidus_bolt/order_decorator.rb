# frozen_string_literal: true

module SolidusBolt
  module OrderDecorator
    def bolt_transaction_body(payment_method)
      {
        auto_capture: payment_method.auto_capture,
        cart: {
          order_reference: number,
          items: line_items.map do |line_item|
            {
              sku: line_item.sku,
              name: line_item.name,
              unit_price: cents(line_item.price),
              quantity: line_item.quantity
            }
          end
        },
        credit_card: {},
        division_id: 'preference to be set from bolt merchant dashboard',
        source: 'direct_payments',
        user_identifier: {
          email: email,
          phone: bill_address.phone
        },
        user_identity: {
          first_name: address.name.split(' ').first,
          last_name: address.name.split(' ').last
        },
        create_bolt_account: 'boolean from input'
      }.to_json
    end

    private

    def cents(float)
      (float * 100).to_i
    end

    Spree::Order.prepend(self)
  end
end
