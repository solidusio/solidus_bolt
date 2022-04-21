# frozen_string_literal: true

module SolidusBolt
  module Transaction
    class Review < SolidusBolt::Base
      attr_reader :transaction_reference, :decision

      DECISION_VALUES = %w[approve reject].freeze

      def initialize(transaction_reference:, decision:)
        @transaction_reference = transaction_reference
        @decision = decision
        validate_decision
        super
      end

      def call
        review
      end

      private

      def review
        options = build_options
        HTTParty.post(
          "#{api_base_url}/#{api_version}/merchant/transactions/review",
          options
        )
      end

      def build_options
        options = {
          body: {
            transaction_reference: transaction_reference,
            decision: decision,
          },
          headers: {
            'X-Nonce' => generate_nonce
          }
        }

        authenticate(options)
        options
      end

      def validate_decision
        raise 'Decision value should be either "approve" or "reject"' unless DECISION_VALUES.include? decision
      end
    end
  end
end
