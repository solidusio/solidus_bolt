# frozen_string_literal: true

module SolidusBolt
  module Handlers
    class CaptureHandler < BaseHandler
      def call
        payment = Spree::Payment.find_by(response_code: params[:data][:reference])
        capture_amount = params[:data][:captures].last[:amount][:amount].to_i

        SolidusBolt::Payments::CaptureSyncService.call(payment: payment, capture_amount: capture_amount)
      end
    end
  end
end
