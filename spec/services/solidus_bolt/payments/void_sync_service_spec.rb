# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Payments::VoidSyncService do
  subject(:void) { described_class.call(payment: payment) }

  let(:payment) { create(:bolt_payment) }

  describe '#call' do
    context 'when non-void payment' do
      it 'voids the payment' do
        expect { void }.to change { payment.reload.state }.from('checkout').to('void')
      end
    end

    context 'when void payment' do
      before { payment.update(state: 'void') }

      it 'returns nil' do
        expect(void).to be_nil
      end
    end
  end
end
