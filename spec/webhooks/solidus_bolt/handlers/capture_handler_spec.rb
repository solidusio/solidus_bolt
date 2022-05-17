# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Handlers::CaptureHandler do
  subject(:capture) { described_class.call(params) }

  let(:payment) { create(:bolt_payment, response_code: 'V2YW-NYNR-2MYM') }
  let(:capture_amount) { 500 }
  let(:params) { { data: { reference: payment.response_code, captures: [{ amount: { amount: capture_amount } }] } } }

  before do
    allow(SolidusBolt::Payments::CaptureSyncService).to receive(:call).with(
      payment: payment, capture_amount: capture_amount
    )
    capture
  end

  it 'calls the payment capture service' do
    expect(SolidusBolt::Payments::CaptureSyncService).to have_received(:call).with(
      payment: payment, capture_amount: capture_amount
    )
  end
end
