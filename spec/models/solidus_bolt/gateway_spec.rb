require 'spec_helper'

RSpec.describe SolidusBolt::Gateway, type: :model do
  describe '#authorize' do
    subject(:authorize) { described_class.new.authorize(nil, payment_source, gateway_options) }

    let(:order) { create(:order_with_line_items) }
    let(:gateway_options) { { order_id: "#{order.number}-123456" } }
    let(:payment_method) { create(:bolt_payment_method) }
    let(:payment_source) { create(:bolt_payment_source, payment_method: payment_method) }
    let(:response) { { 'transaction' => { 'reference' => 'fakereference' } } }

    before { allow(SolidusBolt::Transactions::AuthorizeService).to receive(:call).and_return(response) }

    it 'returns an active merchant billing response' do
      expect(authorize).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it 'stores the transaction reference as response code' do
      expect(authorize.authorization).to eq('fakereference')
    end
  end

  describe '#capture' do
    it 'raises NotImplementedError' do
      expect { described_class.new.capture(nil, nil, nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#void' do
    it 'raises NotImplementedError' do
      expect { described_class.new.void(nil, nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#credit' do
    it 'raises NotImplementedError' do
      expect { described_class.new.credit(nil, nil, nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#purchase' do
    it 'raises NotImplementedError' do
      expect { described_class.new.purchase(nil, nil, nil) }.to raise_error(NotImplementedError)
    end
  end
end
