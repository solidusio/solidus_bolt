# frozen_string_literal: true

module SolidusBolt
  module Transactions
    class Authorize # < SolidusBolt::Base
      attr_reader :order, :create_bolt_account, :credit_card

      def initialize(order:, create_bolt_account:, credit_card:)
        @order = order
        @create_bolt_account = create_bolt_account
        @credit_card = credit_card
        super
      end

      def call
        authorize
      end

      private

      def authorize
        options = build_options
        HTTParty.post(
          "#{api_base_url}/#{api_version}/merchant/transactions/authorize",
          options
        )
      end

      def build_options
        options = {
          query: {
            auto_capture: false,
            cart: order.bolt_cart,
            credit_card: credit_card,
            division_id: '', # used to be defined, now needs to stay empty for call to work
            source: 'direct_payments',
            user_identifier: order.bolt_user_identifier,
            user_identity: order.bolt_user_identity,
            create_bolt_account: create_bolt_account
          },
          headers: {
            'Content-Type' => 'application/json',
            'X-Nonce' => generate_nonce,
            'X-Publishable-Key' => publishable_key
          }
        }

        authenticate(options)
        options
      end
    end
  end
end
