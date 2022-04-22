# frozen_string_literal: true

module SolidusBolt
  module Transaction
    class RefundDetail < SolidusBolt::Base
      attr_reader :order_id

      def initialize(order_id:)
        @order_id = order_id
        super
      end

      def call
        refund_detail
      end

      private

      def refund_detail
        options = build_options
        HTTParty.get(
          "#{api_base_url}/#{api_version}/merchant/transactions/refunds/orders/#{order_id}",
          options
        )
      end

      def build_options
        options = {
          headers: {
            'X-Nonce' => generate_nonce
          }
        }

        authenticate(options)
        options
      end
    end
  end
end
