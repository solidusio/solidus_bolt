# frozen_string_literal: true

module SolidusBolt
  module Transactions
    class AuthorizeService < SolidusBolt::Transactions::BaseService
      attr_reader :order, :create_bolt_account, :credit_card, :auto_capture, :repeat

      def initialize(order:, create_bolt_account:, credit_card:, payment_method:, auto_capture: false, repeat: false)
        @order = order
        @create_bolt_account = create_bolt_account
        @credit_card = credit_card
        @auto_capture = auto_capture
        @repeat = repeat
        super
      end

      def call
        authorize
      end

      private

      def authorize
        url = "#{api_base_url}/#{api_version}/merchant/transactions/authorize"
        handle_result(
          HTTParty.post(
            url, headers: headers, body: (repeat ? repeat_authorization_body : new_authorization_body).to_json
          )
        )
      end

      def new_authorization_body
        body.merge(
          credit_card: credit_card,
          division_id: '', # used to be defined, now needs to stay empty for call to work
          shipping_address: shipping_address,
          create_bolt_account: create_bolt_account
        )
      end

      def repeat_authorization_body
        body.merge(
          credit_card_id: credit_card[:id]
        )
      end

      def body
        {
          auto_capture: auto_capture,
          cart: order.bolt_cart,
          source: 'direct_payments',
          user_identifier: order.bolt_user_identifier,
          user_identity: order.bolt_user_identity
        }
      end

      def shipping_address
        order.shipping_address.yield_self do |address|
          {
            street_address1: address.address1,
            street_address2: address.address2,
            locality: address.city,
            region: address.state.abbr,
            postal_code: address.zipcode,
            country_code: address.country.iso,
            first_name: Spree::Address::Name.new(address.name).first_name,
            last_name: Spree::Address::Name.new(address.name).last_name,
            phone: address.phone,
            email: order.email
          }
        end
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
