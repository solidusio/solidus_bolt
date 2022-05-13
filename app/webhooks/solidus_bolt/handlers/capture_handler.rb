# frozen_string_literal: true

module SolidusBolt
  module Handlers
    class CaptureHandler < BaseHandler
      def call
        capture_amount = params[:data][:captures].last[:amount][:amount].to_i

        SolidusBolt::Payments::CaptureSyncService.call(payment: payment, capture_amount: capture_amount)
      end
    end
  end
end
