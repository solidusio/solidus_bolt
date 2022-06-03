# frozen_string_literal: true

module SolidusBolt
  module Users
    class RefreshAccessTokenService < SolidusBolt::BaseService
      attr_reader :session

      def initialize(session:)
        @session = session
        super
      end

      def call
        return if session[:bolt_access_token].nil?
        return session[:bolt_access_token] if session[:bolt_expiration_time] >= Time.now.utc

        refresh_access_token
      end

      private

      def refresh_access_token
        response = handle_result(HTTParty.post("#{api_base_url}/#{api_version}/oauth/token", build_options))

        session[:bolt_expiration_time] = Time.now.utc + response['expires_in']
        session[:bolt_refresh_token] = response['refresh_token']
        session[:bolt_refresh_token_scope] = response['refresh_token_scope']
        session[:bolt_access_token] = response['access_token']
      end

      def build_options
        {
          body: {
            grant_type: 'refresh_token',
            refresh_token: session[:bolt_refresh_token],
            client_id: publishable_key,
            scope: session[:bolt_refresh_token_scope],
            client_secret: api_key
          }
        }
      end
    end
  end
end
