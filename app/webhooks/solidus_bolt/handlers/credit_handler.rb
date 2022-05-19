# frozen_string_literal: true

module SolidusBolt
  module Handlers
    class CreditHandler < BaseHandler
      def call
        payment_response_code = params[:data][:source_transaction][:reference]
        source_payment = Spree::Payment.find_by(response_code: payment_response_code)
        amount = params[:data][:requested_refund_amount][:amount].to_i
        refund_transaction_id = params[:data][:reference]

        SolidusBolt::Payments::CreditSyncService.call(
          payment: source_payment, amount: amount, transaction_id: refund_transaction_id
        )
      end
    end
  end
end
