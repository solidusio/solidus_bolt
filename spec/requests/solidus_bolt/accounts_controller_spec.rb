# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::AccountsController, type: :request do
  describe '#create' do
    subject(:call) do
      post '/api/accounts/bolt', params: params, headers: { 'X-Bolt-Hmac-Sha256' => bolt_hash }, as: :json
    end

    let(:user) { create(:user, email: 'user@bolt.com') }
    let(:params) { { account: { email: user.email } } }

    before { call }

    context 'when valid' do
      let(:bolt_hash) { "+mDzzN0xsvB0UzO0NoAyMJYx/byPs++cccpR4tiEN0c=" }

      it 'has http status ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when not valid' do
      let(:bolt_hash) { "CaAA/XZsO4wl6q/G7cyWY9KVcaWvieH7UWM6XoFcsmU=" }
      let(:params) { { account: { email: 'fake@email.com' } } }

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
