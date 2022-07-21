# frozen_string_literal: true

module SolidusBolt
  module ShipmentDecorator
    def self.prepended(base)
      base.before_save :update_bolt_tracking_info
    end

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

    def update_bolt_tracking_info
      return if tracking_was.present?
      return unless tracking_changed?

      payment = order&.payments&.completed&.last
      return unless payment&.payment_method.instance_of?(SolidusBolt::PaymentMethod)

      transaction_reference = payment&.response_code
      return if transaction_reference.blank?

      SolidusBolt::ShipmentTrackingJob.perform_later(transaction_reference: transaction_reference, shipment: self)
    end

    Spree::Shipment.prepend(self)
  end
end
