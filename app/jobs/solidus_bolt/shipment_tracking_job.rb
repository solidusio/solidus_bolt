# frozen_string_literal: true

module SolidusBolt
  class ShipmentTrackingJob < ApplicationJob
    queue_as :default

    def perform(transaction_reference:, shipment:)
      SolidusBolt::Orders::TrackShipmentService.call(transaction_reference: transaction_reference, shipment: shipment)
    end
  end
end
