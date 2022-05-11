# frozen_string_literal: true

module SolidusBolt
  module Transactions
    class AuthorizeService < SolidusBolt::Transactions::BaseService
      attr_reader :order, :create_bolt_account, :credit_card

      def initialize(order:, create_bolt_account:, credit_card:, payment_method:)
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
        url = "#{api_base_url}/#{api_version}/merchant/transactions/authorize"
        handle_result(HTTParty.post(url, headers: headers, body: body.to_json))
      end

      def body
        {
          auto_capture: false,
          cart: order.bolt_cart,
          credit_card: credit_card,
          division_id: '', # used to be defined, now needs to stay empty for call to work
          source: 'direct_payments',
          user_identifier: order.bolt_user_identifier,
          user_identity: order.bolt_user_identity,
          create_bolt_account: create_bolt_account
        }
      end

      def headers
        {
          'Content-Type' => 'application/json',
          'X-Nonce' => generate_nonce,
          'X-Publishable-Key' => publishable_key
        }.merge(authentication_header)
      end
    end
  end
end
