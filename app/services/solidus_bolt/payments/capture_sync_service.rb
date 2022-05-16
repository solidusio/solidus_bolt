# frozen_string_literal: true

module SolidusBolt
  module Payments
    class CaptureSyncService < SolidusBolt::BaseService
      attr_reader :payment, :capture_amount

      def initialize(payment:, capture_amount:)
        @payment = payment
        @capture_amount = capture_amount
        super
      end

      def call
        return if payment.completed?

        amount = Money.new(capture_amount).to_d

        payment.capture_events.create!(amount: amount)
        payment.update!(amount: amount, state: 'completed')
      end
    end
  end
end
