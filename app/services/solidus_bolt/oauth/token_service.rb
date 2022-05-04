# frozen_string_literal: true

module SolidusBolt
  module Oauth
    class TokenService < SolidusBolt::BaseService
      attr_reader :authorization_code, :scope

      def initialize(authorization_code:, scope:)
        @authorization_code = authorization_code
        @scope = scope
        super
      end

      def call
        token
      end

      private

      def token
        options = build_options
        handle_result(
          HTTParty.post(
            "#{api_base_url}/#{api_version}/oauth/token",
            options
          )
        )
      end

      def build_options
        {
          body: {
            grant_type: 'authorization_code',
            code: authorization_code,
            scope: scope,
            client_id: publishable_key,
            client_secret: api_key
          }
        }
      end
    end
  end
end
