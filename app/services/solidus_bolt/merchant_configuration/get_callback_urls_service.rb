# frozen_string_literal: true

module SolidusBolt
  module MerchantConfiguration
    class GetCallbackUrlsService < SolidusBolt::BaseService
      attr_reader :oauth_redirect, :oauth_logout, :get_account

      def call
        get_callbacks
      end

      private

      def get_callbacks # rubocop:disable Naming/AccessorMethodName
        url = "#{api_base_url}/#{api_version}/merchant/callbacks"
        handle_result(
          HTTParty.get(
            url, headers: headers, query: query
          )
        )
      end

      def query
        {
          division_id: @config.division_public_id
        }
      end

      def headers
        {
          'Content-Type' => 'application/json',
        }.merge(authentication_header)
      end
    end
  end
end
