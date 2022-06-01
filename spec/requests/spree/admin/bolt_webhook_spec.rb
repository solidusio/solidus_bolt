require 'spec_helper'

RSpec.describe "Spree::Admin::BoltWebhooks", type: :request do
  stub_authorization!

  describe "GET /new" do
    it 'returns a successful response' do
      get '/admin/bolt_webhook/new'
      expect(response.status).to eq 200
    end
  end

  describe "POST /create" do
    subject(:request) {
      post '/admin/bolt_webhook', params: { bolt_webhook: params }
    }

    let(:params) { { event: 'all', webhook_url: 'https://solidus-test.com/webhook' } }

    before do
      allow(SolidusBolt::Webhooks::CreateService).to receive(:call).and_return({ 'webhook_id' => 'BOLT_WEBHOOK_ID' })
    end

    it 'calls the correct service' do
      request
      expect(
        SolidusBolt::Webhooks::CreateService
      )
        .to have_received(:call)
        .with(
          { event: 'all', url: 'https://solidus-test.com/webhook' }
        )
    end
  end
end
