# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::BaseService do
  let!(:bolt_configuration) { create(:bolt_configuration) }

  describe '#call' do
    subject(:service) { described_class.new.call }

    it 'raises a not implemented error' do
      expect { service }.to raise_error(::NotImplementedError)
    end
  end

  describe '#api_base_url' do
    it 'returns correct url' do
      expect(described_class.new.send(:api_base_url)).to eq bolt_configuration.environment_url
    end
  end

  describe '#api_version' do
    it 'returns correct api version' do
      expect(described_class.new.send(:api_version)).to eq 'v1'
    end
  end

  describe '#authentication_header' do
    it 'returns the correct hash' do
      expect(
        described_class.new.send(:authentication_header)
      ).to eq({ 'X-API-KEY' => bolt_configuration.api_key })
    end
  end

  describe '#generate_nonce' do
    it 'returns a unique nonce everytime' do
      nonce = described_class.new.send(:generate_nonce)
      expect(described_class.new.send(:generate_nonce)).not_to eq(nonce)
    end
  end

  describe '#publishable_key' do
    it 'returns the correct key' do
      publishable_key = described_class.new.send(:publishable_key)
      expect(described_class.new.send(:publishable_key)).to eq(publishable_key)
    end
  end
end
