require 'spec_helper'

RSpec.describe SolidusBolt::ShipmentDecorator do
  describe '#bolt_shipment' do
    subject(:bolt_shipment) { shipment.bolt_shipment }

    let(:shipment) { create(:shipment, number: 'S000000001') }
    let(:ship_address) { shipment.order.ship_address }

    it 'is expected' do
      expect(bolt_shipment).to match hash_including(
        shipping_address: hash_including(postal_code: ship_address.zipcode, country_code: ship_address.country_iso),
        reference: 'S000000001',
        cost: 10_000
      )
    end
  end
end
