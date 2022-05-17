# frozen_string_literal: true

module SolidusBolt
  module Handlers
    class BaseHandler
      attr_reader :params

      def initialize(params)
        @params = params
      end

      def self.call(params)
        new(params).call
      end

      def call
        raise NotImplementedError, 'Missing #call method on class'
      end

      private

      def payment
        Spree::Payment.find_by(response_code: params[:data][:reference])
      end
    end
  end
end
