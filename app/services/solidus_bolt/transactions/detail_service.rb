# frozen_string_literal: true

module SolidusBolt
  module Transactions
    class DetailService < SolidusBolt::BaseService
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
        handle_result(
          HTTParty.get(
            "#{api_base_url}/#{api_version}/merchant/transactions/#{transaction_reference}",
            options
          )
        )
      end

      def build_options
        {
          headers: {
            'X-Nonce' => generate_nonce
          }.merge(authentication_header)
        }
      end
    end
  end
end
