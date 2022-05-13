# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::WebhooksController, type: :request do
  describe '#update' do
    subject(:endpoint_call) { post '/webhooks/bolt', params: params, headers: { 'X-Bolt-Hmac-Sha256' => bolt_hash } }

    let(:bolt_hash) { "yrjqA4qD4DoLUyH8aQZ1hVv75sJlCvULL7vI43PP8K4=" }
    let(:params) { {} }

    context 'when valid' do
      let(:expected_params) do
        ActionController::Parameters.new({ controller: 'solidus_bolt/webhooks', action: 'update' })
      end

      before do
        allow(::SolidusBolt::Sorter).to receive(:call)
        endpoint_call
      end

      it 'has http status success' do
        expect(response).to have_http_status(:success)
      end

      it 'calls the webhook sorter with the correct params' do
        expect(SolidusBolt::Sorter).to have_received(:call).with(expected_params)
      end
    end

    context 'when webhook type is `capture`' do
      let(:payment) { create(:bolt_payment, response_code: 'V2YW-NYNR-2MYM') }
      let(:params) do
        {
          type: 'capture',
          data: { reference: payment.response_code, captures: [{ amount: { amount: 1000 } }] }
        }
      end

      before do
        allow(SolidusBolt::Payments::CaptureSyncService).to receive(:call).with(payment: payment, capture_amount: 1000)
        endpoint_call
      end

      it 'calls the Sorter, which calls the CaptureHandler, which calls the CaptureSyncService with params' do
        expect(SolidusBolt::Payments::CaptureSyncService).to have_received(:call).with(
          payment: payment, capture_amount: 1000
        )
      end
    end

    context 'when webhook type is `void`' do
      let(:payment) { create(:bolt_payment, response_code: 'V2YW-NYNR-2MYM') }
      let(:params) { { type: 'void', data: { reference: payment.response_code } } }

      before do
        allow(SolidusBolt::Payments::VoidSyncService).to receive(:call).with(payment: payment)
        endpoint_call
      end

      it 'calls the Sorter, which calls the VoidHandler, which calls the VoidSyncService with params' do
        expect(SolidusBolt::Payments::VoidSyncService).to have_received(:call).with(payment: payment)
      end
    end

    context 'when not valid' do
      before do
        allow(::SolidusBolt::Sorter).to receive(:call).and_raise(StandardError)
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
