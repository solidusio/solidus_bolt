# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Handlers::CreditHandler do
  subject(:credit) { described_class.call(params) }

  let(:transaction_id) { 'AAAA-BBBB-CCCC' }
  let(:payment) { create(:bolt_payment, response_code: 'V2YW-NYNR-2MYM') }
  let(:params) do
    {
      data: {
        reference: transaction_id,
        source_transaction: { reference: payment.response_code },
        requested_refund_amount: { amount: 100 }
      }
    }
  end

  before do
    allow(SolidusBolt::Payments::CreditSyncService).to receive(:call).with(
      payment: payment, amount: 100, transaction_id: transaction_id
    )
    credit
  end

  it 'calls the payment credit service' do
    expect(SolidusBolt::Payments::CreditSyncService).to have_received(:call).with(
      payment: payment, amount: 100, transaction_id: transaction_id
    )
  end
end
