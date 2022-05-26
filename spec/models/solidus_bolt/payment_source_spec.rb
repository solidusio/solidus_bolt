require 'spec_helper'

RSpec.describe SolidusBolt::PaymentSource, type: :model do
  let(:payment_source) { build(:bolt_payment_source) }

  describe 'validations' do
    context 'with payment_method_id present' do
      it 'is valid' do
        expect(payment_source.valid?).to be(true)
      end
    end

    context 'with payment_method_id absent' do
      before { payment_source.payment_method_id = nil }

      it 'is invalid' do
        expect(payment_source.valid?).to be(false)
      end
    end
  end
end
