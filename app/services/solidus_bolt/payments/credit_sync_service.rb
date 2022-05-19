# frozen_string_literal: true

module SolidusBolt
  module Payments
    class CreditSyncService < BaseService
      attr_reader :payment, :amount, :transaction_id, :refund_reason, :order

      def initialize(payment:, amount:, transaction_id:)
        @payment = payment
        @amount = amount
        @transaction_id = transaction_id
        @refund_reason = Spree::RefundReason.return_processing_reason&.id
        @order = payment.order
        super
      end

      def call
        return if Spree::Refund.find_by(transaction_id: transaction_id)

        create_refund
        order.recalculate
      end

      private

      def create_refund
        payload = {
          payment_id: payment.id,
          amount: amount.to_f / 100,
          transaction_id: transaction_id,
          refund_reason_id: refund_reason
        }

        if Spree.solidus_gem_version >= Gem::Version.create('3.0')
          Spree::Refund.create!(payload)
        else
          # Skip after_save callbacks that call the Gateway. Callbacks removed from solidus 3.0 up
          # https://github.com/solidusio/solidus/blob/v2.11/core/app/models/spree/refund.rb#L20-L22
          Spree::Refund.insert!(payload) # rubocop:disable Rails/SkipsModelValidations
        end
      end
    end
  end
end
