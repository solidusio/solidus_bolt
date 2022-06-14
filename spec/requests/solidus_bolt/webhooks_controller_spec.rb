# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::WebhooksController, type: :request do
  describe '#update' do
    subject(:endpoint_call) do
      post '/webhooks/bolt', params: params, headers: { 'X-Bolt-Hmac-Sha256' => bolt_hash }, as: :json
    end

    let(:bolt_hash) { "IvjuqQlACvmK3zaBqfMZI+9rf8ukq7VT2Sgjo+nVwl4=" }
    let(:params) { { webhook: {} } }
    let(:payment) { create(:bolt_payment, response_code: 'V2YW-NYNR-2MYM') }

    context 'when valid' do
      let(:expected_params) { ActionController::Parameters.new({}) }

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
      let(:params) do
        {
          webhook: {
            type: 'capture',
            data: { reference: payment.response_code, captures: [{ amount: { amount: 1000 } }] }
          }
        }
      end
      let(:bolt_hash) { "UlgQupKN61uY+5G126Ue0CvOPLtuHux36GZrAA1LKyo=" }

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
      let(:params) { { webhook: { type: 'void', data: { reference: payment.response_code } } } }
      let(:bolt_hash) { "W4+7RvJLQaBkLdddmCnAy59QFPrF3No2olkTcfdNmVE=" }

      before do
        allow(SolidusBolt::Payments::VoidSyncService).to receive(:call).with(payment: payment)
        endpoint_call
      end

      it 'calls the Sorter, which calls the VoidHandler, which calls the VoidSyncService with params' do
        expect(SolidusBolt::Payments::VoidSyncService).to have_received(:call).with(payment: payment)
      end
    end

    context 'when webhook type is `credit`' do
      let(:transaction_id) { 'AAAA-BBBB-CCCC' }
      let(:params) do
        {
          webhook: {
            type: 'credit',
            data: {
              reference: transaction_id,
              source_transaction: { reference: payment.response_code },
              requested_refund_amount: { amount: 1000 }
            }
          }
        }
      end
      let(:bolt_hash) { "My7opJkmglzXpNi1rn/UDmPeaeDHoSm2ebuWwBYJrW0=" }

      before do
        allow(SolidusBolt::Payments::CreditSyncService).to receive(:call).with(
          payment: payment, amount: 1000, transaction_id: transaction_id
        )
        endpoint_call
      end

      it 'calls the Sorter, which calls the CreditHandler, which calls the CreditSyncService with params' do
        expect(SolidusBolt::Payments::CreditSyncService).to have_received(:call).with(
          payment: payment, amount: 1000, transaction_id: transaction_id
        )
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
