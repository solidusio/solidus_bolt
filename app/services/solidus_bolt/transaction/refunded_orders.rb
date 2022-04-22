# frozen_string_literal: true

module SolidusBolt
  module Transaction
    class RefundedOrders < SolidusBolt::Base
      def call
        refunded_orders
      end

      private

      def refunded_orders
        options = build_options
        HTTParty.get(
          "#{api_base_url}/#{api_version}/merchant/transactions/refunds/orders",
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
