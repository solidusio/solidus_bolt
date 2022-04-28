# frozen_string_literal: true

module SolidusBolt
  module Transactions
    class Capture < SolidusBolt::Base
      attr_reader :transaction_reference, :amount, :currency

      def initialize(transaction_reference:, amount:, currency:)
        @transaction_reference = transaction_reference
        @amount = amount
        @currency = currency
        super
      end

      def call
        capture
      end

      private

      def capture
        options = build_options
        HTTParty.post(
          "#{api_base_url}/#{api_version}/merchant/transactions/capture",
          options
        )
      end

      def build_options
        {
          body: {
            transaction_reference: transaction_reference,
            amount: amount,
            currency: currency
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
