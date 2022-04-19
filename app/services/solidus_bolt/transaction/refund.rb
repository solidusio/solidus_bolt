# frozen_string_literal: true

module SolidusBolt
  module Transaction
    class Refund < SolidusBolt::Base
      attr_reader :transaction_reference, :amount, :currency

      def initialize(transaction_reference:, amount:, currency:)
        @transaction_reference = transaction_reference
        @amount = amount
        @currency = currency
        super
      end

      def call
        refund
      end

      private

      def refund
        options = build_options
        HTTParty.post(
          "#{api_base_url}/#{api_version}/merchant/transactions/credit",
          options
        )
      end

      def build_options
        options = {
          query: {
            transaction_reference: transaction_reference,
            amount: amount,
            currency: currency
          },
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
