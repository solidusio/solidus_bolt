# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Webhooks::CreateService, :vcr, :bolt_configuration do
  describe '#call', vcr: true do
    subject(:create) { described_class.call(url: 'https://solidus-test.com/webhook', event: event) }

    context 'with an event' do
      let(:event) { 'payment' }

      it 'returns a webhook id' do
        expect(create).to match hash_including('webhook_id')
      end
    end

    context 'with "all" event' do
      let(:event) { 'all' }

      it 'returns a webhook id' do
        expect(create).to match hash_including('webhook_id')
      end
    end

    context 'with empty event' do
      let(:event) { '' }

      it 'raises a server error' do
        expect{ create }.to raise_error SolidusBolt::ServerError
      end
    end
  end
end
