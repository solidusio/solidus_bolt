# frozen_string_literal: true

module SolidusBolt
  module Accounts
    class AddAddressService < SolidusBolt::BaseService
      attr_reader :order, :address, :access_token

      def initialize(order:, address:, access_token:)
        @order = order
        @address = address
        @access_token = access_token
        super
      end

      def call
        add_address
      end

      private

      def add_address
        handle_result(HTTParty.post("#{api_base_url}/#{api_version}/account/addresses", build_options))
      end

      def address_body
        country = address.country
        {
          street_address1: address.address1,
          street_address2: address.address2,
          locality: address.city,
          region: address.state&.abbr,
          postal_code: address.zipcode,
          country_code: country.iso,
          first_name: Spree::Address::Name.new(address.name).first_name,
          last_name: Spree::Address::Name.new(address.name).last_name,
          phone: address.phone,
          email: order.email
        }.to_json
      end

      def build_options
        {
          body: address_body,
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type' => 'application/json'
          }.merge(authentication_header)
        }
      end
    end
  end
end
