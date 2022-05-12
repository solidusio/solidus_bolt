require 'spec_helper'

RSpec.describe SolidusBolt::Gateway, type: :model do
  let(:order) { create(:order_with_line_items) }
  let(:amount) { (order.total * 100).to_i }
  let(:payment_method) { create(:bolt_payment_method) }
  let(:payment_source) { create(:bolt_payment_source, payment_method: payment_method) }
  let(:payment) {
    create(:payment, order: order, source_id: payment_source.id, source_type: SolidusBolt::PaymentSource,
      payment_method: payment_method)
  }
  let(:gateway_options) {
    {
      order_id: "#{order.number}-123456",
      originator: payment
    }
  }

  describe '#authorize' do
    subject(:authorize) { described_class.new.authorize(nil, payment_source, gateway_options) }

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
    subject(:capture) { described_class.new.capture(amount, response_code, gateway_options) }

    let(:response_code) { 'the_amazing_spiderman' }
    let(:response) {
      { 'reference' => response_code }
    }

    before do
      allow(SolidusBolt::Transactions::CaptureService).to receive(:call).and_return(response)
    end

    it 'returns an active merchant billing response' do
      expect(capture).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it 'stores the transaction reference as response code' do
      expect(capture.authorization).to eq response_code
    end
  end

  describe '#void' do
    subject(:void) { described_class.new.void(response_code, gateway_options) }

    let(:response_code) { 'the_amazing_spiderman' }

    let(:response) {
      { 'id' => "id-#{response_code}", 'reference' => response_code }
    }

    before do
      allow(SolidusBolt::Transactions::VoidService).to receive(:call).and_return(response)
    end

    it 'returns an active merchant billing response' do
      expect(void).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it 'stores the transaction reference as response code' do
      expect(void.authorization).to eq response_code
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
