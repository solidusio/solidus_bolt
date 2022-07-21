# frozen_string_literal: true

module SolidusBolt
  module ShipmentDecorator
    def bolt_shipment
      {
        shipping_address: order.ship_address.bolt_address(order.email),
        reference: number,
        cost: display_total.cents
      }
    end

    Spree::Shipment.prepend(self)
  end
end
