# frozen_string_literal: true

module SolidusBolt
  module Accounts
    class DetailService < SolidusBolt::BaseService
      attr_reader :access_token

      def initialize(access_token:)
        @access_token = access_token
        super
      end

      def call
        detail
      end

      private

      def detail
        options = build_options
        handle_result(
          HTTParty.get(
            "#{api_base_url}/#{api_version}/account",
            options
          )
        )
      end

      def build_options
        {
          headers: {
            'Authorization' => "Bearer #{access_token}",
          }.merge(authentication_header)
        }
      end
    end
  end
end
