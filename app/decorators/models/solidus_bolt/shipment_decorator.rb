# frozen_string_literal: true

module SolidusBolt
  module ShipmentDecorator
    def bolt_items
      line_items.map do |line_item|
        {
          reference: line_item.sku,
          name: line_item.name,
          description: line_item.description,
          total_amount: {
            amount: line_item.total,
            currency: line_item.currency,
            currency_symbol: currency_symbol
          },
          unit_price: {
            amount: line_item.price,
            currency: line_item.currency,
            currency_symbol: currency_symbol
          },
          tax_amount: {
            amount: line_item.additional_tax_total,
            currency: line_item.currency,
            currency_symbol: currency_symbol
          },
          quantity: line_item.quantity,
          sku: line_item.sku
        }
      end
    end

    private

    def currency_symbol
      Monetize.from_string(order.total, order.currency).symbol
    end

    Spree::Shipment.prepend(self)
  end
end
