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

  describe '#preferred_bolt_base_url' do
    context 'when environment is nil' do
      let(:payment_method) { create(:bolt_payment_method, preferences: { bolt_environment: nil }) }

      it { expect(payment_method.preferred_bolt_base_url).to eq(nil) }
    end

    context 'when environment is production' do
      let(:payment_method) { create(:bolt_payment_method, preferences: { bolt_environment: 'production' }) }

      it { expect(payment_method.preferred_bolt_base_url).to eq('https://connect.bolt.com') }
    end

    context 'when environment is staging' do
      let(:payment_method) { create(:bolt_payment_method, preferences: { bolt_environment: 'staging' }) }

      it { expect(payment_method.preferred_bolt_base_url).to eq('https://connect-sandbox.bolt.com') }
    end

    context 'when environment is sandbox' do
      let(:payment_method) { create(:bolt_payment_method) }

      it { expect(payment_method.preferred_bolt_base_url).to eq('https://connect-sandbox.bolt.com') }
    end
  end

  describe 'validations' do
    let(:payment_method) { build(:bolt_payment_method, preferences: { bolt_environment: 'localhost' }) }

    it 'raises an error when creating a SolidusBolt::PaymentMethod with wrong environment' do
      payment_method.valid?
      expect(payment_method.errors.messages).to eq({ preferred_bolt_environment: ['is not included in the list'] })
    end
  end
end
