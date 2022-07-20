require 'spec_helper'

RSpec.describe SolidusBolt::PaymentMethod, type: :model do
  describe '#gateway_class' do
    it 'has correct gateway class' do
      expect(described_class.new.gateway_class).to eq SolidusBolt::Gateway
    end
  end

  describe '#payment_source_class' do
    it 'has correct payment_source class' do
      expect(described_class.new.payment_source_class).to eq SolidusBolt::PaymentSource
    end
  end

  describe '#partial_name' do
    it 'has correct partial name' do
      expect(described_class.new.partial_name).to eq 'bolt'
    end
  end

  describe '#try_void' do
    let(:payment) { create(:payment) }

    context 'when the payment can be voided' do
      subject(:try_void) { described_instance.try_void(payment) }

      let(:described_instance) { described_class.new }
      let(:response) { ActiveMerchant::Billing::Response.new(true, 'Transaction voided', {}, authorization: '123') }

      before do
        allow(payment.source).to receive(:can_void?).and_return(true)
        allow(described_instance.gateway).to receive(:void).and_return(response)
      end

      it 'calls void on the gateway' do
        try_void

        expect(described_instance.gateway).to have_received(:void).with(
          payment.response_code,
          originator: payment
        )
      end
    end
  end
end
