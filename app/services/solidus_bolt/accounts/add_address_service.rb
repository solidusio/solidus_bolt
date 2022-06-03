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
        return if address_already_uploaded?

        add_address
      end

      private

      def bolt_addresses
        @bolt_addresses ||= SolidusBolt::Accounts::DetailService.call(access_token: access_token)['addresses']
      end

      def address_already_uploaded?
        bolt_addresses.any? do |bolt_address|
          bolt_address['street_address1'] == address.address1 &&
          bolt_address['locality'] == address.city &&
          bolt_address['region'] == address.state&.abbr &&
          bolt_address['postal_code'] == address.zipcode
        end
      end

      def add_address
        handle_result(HTTParty.post("#{api_base_url}/#{api_version}/account/addresses", build_options))
      end

      def address_body
        address.bolt_address(order.email).to_json
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
