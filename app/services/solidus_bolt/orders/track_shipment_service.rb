# frozen_string_literal: true

module SolidusBolt
  module Orders
    class TrackShipmentService < SolidusBolt::BaseService
      attr_reader :transaction_reference, :shipment

      def initialize(transaction_reference:, shipment:)
        @transaction_reference = transaction_reference
        @shipment = shipment
        super
      end

      def call
        track_shipment
      end

      private

      def track_shipment
        options = build_options
        handle_result(
          HTTParty.post(
            "#{api_base_url}/#{api_version}/merchant/track_shipment",
            options
          )
        )
      end

      def build_options
        {
          body: {
            transaction_reference: transaction_reference,
            tracking_number: shipment.tracking,
            carrier: shipment.shipping_method.name,
            items: shipment.bolt_items,
            is_non_bolt_order: false
          }.to_json,
          headers: {
            'X-Nonce' => generate_nonce,
            'Content-Type' => 'application/json'
          }.merge(authentication_header)
        }
      end
    end
  end
end
