require 'spec_helper'

RSpec.describe "Spree::Admin::Bolts", type: :request do
  stub_authorization!

  let(:bolt_configuration_params) {
    {
      bearer_token: SecureRandom.hex,
      environment_url: SecureRandom.hex,
      merchant_public_id: SecureRandom.hex,
      merchant_id: SecureRandom.hex,
      api_key: SecureRandom.hex,
      signing_secret: SecureRandom.hex,
      publishable_key: SecureRandom.hex
    }
  }

  describe "GET /show" do
    it 'returns a successful response' do
      get '/admin/bolt'
      expect(response.status).to eq 200
    end

    it 'creates a new SolidusBolt::BoltConfiguration record if no records are present' do
      expect { get '/admin/bolt' }.to change { SolidusBolt::BoltConfiguration.count }.by(1)
    end
  end

  describe "GET /edit" do
    let(:bolt_configuration) { create(:bolt_configuration) }

    it 'returns a successful response' do
      get '/admin/bolt/edit'
      expect(response.status).to eq 200
    end
  end

  describe "PUT /update" do
    subject(:request) {
      put '/admin/bolt', params: { solidus_bolt_bolt_configuration: bolt_configuration_params }
    }

    let(:bolt_configuration) { create(:bolt_configuration) }

    it 'successfully redirects' do
      request
      expect(response.status).to eq 302
    end

    it 'redirects to index' do
      request
      expect(response).to redirect_to '/admin/bolt'
    end

    it 'successfully updates the bolt configuration' do
      request

      updated_attributes = SolidusBolt::BoltConfiguration.fetch.attributes.slice(
        'bearer_token',
        'environment_url',
        'merchant_public_id',
        'merchant_id',
        'api_key',
        'signing_secret',
        'publishable_key'
      )

      expect(updated_attributes).to eq(bolt_configuration_params.deep_stringify_keys)
    end
  end
end
