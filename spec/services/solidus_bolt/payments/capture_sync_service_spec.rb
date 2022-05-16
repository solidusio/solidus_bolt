# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Payments::CaptureSyncService do
  subject(:capture) do
    described_class.call(payment: payment, capture_amount: capture_amount)
  end

  let(:payment) { create(:bolt_payment, amount: 15.00) }
  let(:capture_amount) { 1000 }

  describe '#call' do
    it 'completes the payment' do
      expect { capture }.to change { payment.reload.state }.from('checkout').to('completed')
    end

    it 'updates the payment amount' do
      expect { capture }.to change { payment.reload.amount }.from(15.00).to(10.00)
    end

    it 'creates a capture event' do
      capture
      expect(payment.reload.capture_events.count).to eq(1)
    end
  end
end
