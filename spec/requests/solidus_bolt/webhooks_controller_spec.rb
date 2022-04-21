# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::WebhooksController, type: :request do
  describe '#update' do
    subject(:endpoint_call) { post '/webhooks/bolt', params: {}, headers: { 'X-Bolt-Hmac-Sha256' => bolt_hash } }

    let(:bolt_hash) { "mhEaNOULKdxIJNd/MfwxkmIsC8GIgaHeMEe+UofWxbk=\n" }

    context 'when valid' do
      let(:expected_params) do
        ActionController::Parameters.new({ controller: 'solidus_bolt/webhooks', action: 'update' })
      end

      before do
        allow(::SolidusBolt::Webhooks::Sorter).to receive(:call)
        endpoint_call
      end

      it 'has http status success' do
        expect(response).to have_http_status(:success)
      end

      it 'calls the webhook sorter with the correct params' do
        expect(SolidusBolt::Webhooks::Sorter).to have_received(:call).with(expected_params)
      end
    end

    context 'when not valid' do
      before do
        allow(::SolidusBolt::Webhooks::Sorter).to receive(:call).and_raise(StandardError)
        endpoint_call
      end

      it 'has http status unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when not bolt request' do
      let(:bolt_hash) { 'notBoltHash' }

      before do
        endpoint_call
      end

      it 'has http status unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
