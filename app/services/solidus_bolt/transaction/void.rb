# frozen_string_literal: true

module SolidusBolt
  module Transaction
    class Void < SolidusBolt::Base
      attr_reader :transaction_reference, :credit_card_transaction_id

      def initialize(transaction_reference:, credit_card_transaction_id:)
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
        HTTParty.post(
          "#{api_base_url}/#{api_version}/merchant/transactions/void",
          options
        )
      end

      def build_options
        options = {
          query: {
            transaction_reference: transaction_reference,
            credit_card_transaction_id: credit_card_transaction_id,
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
