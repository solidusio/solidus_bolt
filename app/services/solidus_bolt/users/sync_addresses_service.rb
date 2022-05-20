# frozen_string_literal: true

module SolidusBolt
  module Users
    class SyncAddressesService < SolidusBolt::BaseService
      attr_reader :user, :access_token

      def initialize(user:, access_token:)
        @access_token = access_token
        @user = user
        super
      end

      def call
        return if user.nil? || access_token.nil?

        bolt_addresses.each do |bolt_address|
          default = bolt_address['default']
          address = convert_to_solidus(bolt_address)
          address[:phone] = user_info['profile']['phone']
          user.save_in_address_book(address, default, :shipping)
          user.save_in_address_book(address, default, :billing)
        end
      end

      private

      def user_info
        @user_info ||= Accounts::DetailService.call(access_token: access_token)
      end

      def bolt_addresses
        user_info['addresses']
      end

      def convert_to_solidus(bolt_address)
        country = Spree::Country.find_by(iso: bolt_address['country_code'])
        {
          address1: bolt_address['street_address1'],
          city: bolt_address['locality'],
          state: country.states.find_by(abbr: bolt_address['region_code']),
          zipcode: bolt_address['postal_code'],
          name: bolt_address['name'],
          country: country,
          phone: user_info['profile']
        }
      end
    end
  end
end
