# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transactions::BaseService do
  let!(:payment_method) { create(:bolt_payment_method) }

  describe '#call' do
    subject(:service) { described_class.new(payment_method: payment_method).call }

    it 'raises a not implemented error' do
      expect { service }.to raise_error(::NotImplementedError)
    end
  end

  describe '#api_base_url' do
    it 'returns correct url' do
      expect(
        described_class.new(payment_method: payment_method).send(:api_base_url)
      ).to eq payment_method.preferred_bolt_api_url
    end
  end

  describe '#authentication_header' do
    it 'returns the correct hash' do
      expect(
        described_class.new(payment_method: payment_method).send(:authentication_header)
      ).to eq({ 'X-API-KEY' => payment_method.preferred_bolt_api_key })
    end
  end

  describe '#publishable_key' do
    it 'returns the correct key' do
      publishable_key = described_class.new(payment_method: payment_method).send(:publishable_key)
      expect(described_class.new(payment_method: payment_method).send(:publishable_key)).to eq(publishable_key)
    end
  end
end
