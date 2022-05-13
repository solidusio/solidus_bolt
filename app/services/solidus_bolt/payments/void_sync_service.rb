# frozen_string_literal: true

module SolidusBolt
  module Payments
    class VoidSyncService < BaseService
      attr_reader :payment

      def initialize(payment:)
        @payment = payment
        super
      end

      def call
        payment.void! unless payment.void?
      end
    end
  end
end
