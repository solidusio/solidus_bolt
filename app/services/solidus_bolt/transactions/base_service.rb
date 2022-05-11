# frozen_string_literal: true

module SolidusBolt
  module Transactions
    class BaseService < SolidusBolt::BaseService
      attr_reader :payment_method

      def initialize(payment_method:, **args)
        @payment_method = payment_method
        super
      end

      private

      def api_base_url
        payment_method.preferred_bolt_api_url
      end

      def authentication_header
        { 'X-API-KEY' => payment_method.preferred_bolt_api_key }
      end

      def publishable_key
        payment_method.preferred_bolt_publishable_key
      end
    end
  end
end
