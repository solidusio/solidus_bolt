# frozen_string_literal: true

module SolidusBolt
  module Transaction
    class Detail < SolidusBolt::Base
      attr_reader :transaction_reference

      def initialize(transaction_reference:)
        @transaction_reference = transaction_reference
        super
      end

      def call
        detail
      end

      private

      def detail
        options = build_options
        HTTParty.get(
          "#{api_base_url}/#{api_version}/merchant/transactions/#{transaction_reference}",
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
