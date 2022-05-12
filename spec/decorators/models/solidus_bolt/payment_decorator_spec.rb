require 'spec_helper'

RSpec.describe SolidusBolt::PaymentDecorator do
  describe '#can_void?' do
    [
      'checkout',
      'completed',
      'processing',
      'failed',
      'void',
      'invalid'
    ].each do |state|
      let(:payment) { Spree::Payment.new(state: state) }

      context "when payment state is #{state}" do
        it 'return false' do
          expect(payment.can_void?).to eq false
        end
      end
    end

    context "when payment state is pending" do
      let(:payment) { Spree::Payment.new(state: 'pending') }

      it 'return true' do
        expect(payment.can_void?).to eq true
      end
    end
  end
end
