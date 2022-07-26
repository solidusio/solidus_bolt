# frozen_string_literal: true

module SolidusBolt
  module MerchantConfiguration
    class SetCallbackUrlsService < SolidusBolt::BaseService
      attr_reader :oauth_redirect, :oauth_logout, :get_account

      def initialize(oauth_redirect: nil, oauth_logout: nil, get_account: nil)
        @oauth_redirect = oauth_redirect
        @oauth_logout = oauth_logout
        @get_account = get_account

        super
      end

      def call
        set_callbacks
      end

      private

      def set_callbacks
        url = "#{api_base_url}/#{api_version}/merchant/callbacks"
        handle_result(
          HTTParty.post(
            url, headers: headers, body: body.to_json
          )
        )
      end

      def body
        {
          division_id: @config.division_public_id,
          callback_urls: callback_urls
        }
      end

      def callback_urls
        callback_urls = []

        callback_urls <<  { type: 'oauth_redirect', url: oauth_redirect } if oauth_redirect.present?
        callback_urls <<  { type: 'oauth_logout', url: oauth_logout } if oauth_logout.present?
        callback_urls <<  { type: 'get_account', url: get_account } if get_account.present?

        callback_urls
      end

      def headers
        {
          'Content-Type' => 'application/json',
        }.merge(authentication_header)
      end
    end
  end
end
