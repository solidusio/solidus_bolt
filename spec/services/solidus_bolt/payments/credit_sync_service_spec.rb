# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Payments::CreditSyncService do
  subject(:credit) { described_class.call(payment: payment, amount: amount, transaction_id: '123') }

  let(:payment) { create(:bolt_payment, state: 'completed', amount: 10.0, order: create(:completed_order_with_totals)) }
  let(:amount) { (payment.amount * 100).to_i }

  describe '#call' do
    before { create(:refund_reason, name: 'Return processing', mutable: false) }

    context 'when not refunded already' do
      it 'creates a new refund' do
        credit
        expect(payment.reload.refunds.count).to eq(1)
      end

      it 'creates a refund for the passed amount' do
        credit
        expect(payment.reload.refunds.first.amount).to eq(amount.to_f / 100)
      end

      it 'recalculates the order amount' do
        expect { credit }.to change { payment.reload.order.payment_total }.from(10.0).to(0.0)
      end
    end

    context 'when already refunded' do
      before { create(:refund, transaction_id: '123') }

      it 'silently fails' do
        expect(credit).to be_nil
      end
    end
  end
end
