# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::AccountsController, type: :request do
  describe '#create' do
    subject(:call) do
      post '/api/accounts/bolt', params: { email: email }, headers: { 'X-Bolt-Hmac-Sha256' => bolt_hash }, as: :json
    end

    let(:bolt_hash) { "yrjqA4qD4DoLUyH8aQZ1hVv75sJlCvULL7vI43PP8K4=" }
    let(:user) { create(:user) }
    let(:email) { user.email }

    before { call }

    context 'when valid' do
      it 'has http status ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when not valid' do
      let(:email) { 'fake@email.com' }

      it 'has http status not found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not bolt request' do
      let(:bolt_hash) { 'notBoltHash' }

      it 'has http status unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
