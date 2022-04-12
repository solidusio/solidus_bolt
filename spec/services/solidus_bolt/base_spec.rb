# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Base do
  let!(:bolt_configuration) { create(:bolt_configuration) }

  describe '#call' do
    subject(:service) { described_class.new.call }

    it 'raises a not implemented error' do
      expect { service }.to raise_error(::NotImplementedError)
    end
  end

  describe '#api_base_url' do
    it 'returns correct url' do
      expect(described_class.new.api_base_url).to eq bolt_configuration.environment_url
    end
  end

  describe '#api_version' do
    it 'returns correct api version' do
      expect(described_class.new.api_version).to eq 'v1'
    end
  end
end
