# frozen_string_literal: true

module SolidusBolt
  module Accounts
    class AddPaymentMethodService < SolidusBolt::BaseService
      attr_reader :access_token, :credit_card, :address, :email

      def initialize(access_token:, credit_card:, address:, email:)
        @access_token = access_token
        @credit_card = credit_card
        @address = address
        @email = email
        super
      end

      def call
        add_payment_method
      end

      private

      def add_payment_method
        handle_result(HTTParty.post("#{api_base_url}/#{api_version}/account/payment_methods", build_options))
      end

      def body
        credit_card.merge(billing_address: address_body).to_json
      end

      def address_body
        {
          street_address1: address.address1,
          street_address2: address.address2,
          locality: address.city,
          region: address.state&.abbr,
          postal_code: address.zipcode,
          country_code: address.country.iso,
          first_name: Spree::Address::Name.new(address.name).first_name,
          last_name: Spree::Address::Name.new(address.name).last_name,
          phone: address.phone,
          email: email
        }
      end

      def build_options
        {
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type' => 'application/json'
          }.merge(authentication_header),
          body: body
        }
      end
    end
  end
end
