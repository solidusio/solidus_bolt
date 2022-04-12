# frozen_string_literal: true

module SolidusBolt
  module Accounts
    class DetectAccountService < SolidusBolt::BaseService
      attr_reader :email

      def initialize(email:)
        @email = email
        super
      end

      def call
        detect_account
      end

      private

      def detect_account
        options = build_options
        HTTParty.get(
          "#{api_base_url}/#{api_version}/account/exists",
          options
        )
      end

      def build_options
        { query: { email: email } }
      end
    end
  end
end
