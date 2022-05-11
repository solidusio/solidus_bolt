# frozen_string_literal: true

module SolidusBolt
  module Transactions
    class VoidService < SolidusBolt::Transactions::BaseService
      attr_reader :transaction_reference, :credit_card_transaction_id

      def initialize(transaction_reference:, credit_card_transaction_id:, payment_method:)
        @transaction_reference = transaction_reference
        @credit_card_transaction_id = credit_card_transaction_id
        super
      end

      def call
        void
      end

      private

      def void
        options = build_options
        handle_result(
          HTTParty.post(
            "#{api_base_url}/#{api_version}/merchant/transactions/void",
            options
          )
        )
      end

      def build_options
        {
          body: {
            transaction_reference: transaction_reference,
            credit_card_transaction_id: credit_card_transaction_id,
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
