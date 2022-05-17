# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Handlers::VoidHandler do
  subject(:void) { described_class.call(params) }

  let(:payment) { create(:bolt_payment, response_code: 'V2YW-NYNR-2MYM') }
  let(:params) { { data: { reference: payment.response_code } } }

  before do
    allow(SolidusBolt::Payments::VoidSyncService).to receive(:call).with(payment: payment)
    void
  end

  it 'calls the payment void service' do
    expect(SolidusBolt::Payments::VoidSyncService).to have_received(:call).with(payment: payment)
  end
end
