# frozen_string_literal: true

module SolidusBolt
  module Transactions
    class RefundService < SolidusBolt::Transactions::BaseService
      attr_reader :transaction_reference, :amount, :currency

      def initialize(transaction_reference:, amount:, currency:, payment_method:)
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
        handle_result(
          HTTParty.post(
            "#{api_base_url}/#{api_version}/merchant/transactions/credit",
            options
          )
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
