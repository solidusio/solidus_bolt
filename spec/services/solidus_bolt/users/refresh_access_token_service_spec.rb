# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Users::RefreshAccessTokenService do
  subject(:refresh_access_token) { described_class.call(session: session) }

  let(:session) { { bolt_access_token: bolt_access_token, bolt_expiration_time: bolt_expiration_time } }

  describe '#call' do
    context 'when not bolt user' do
      let(:bolt_access_token) { nil }
      let(:bolt_expiration_time) { nil }

      it 'returns nil' do
        expect(refresh_access_token).to be_nil
      end
    end

    context 'with valid token' do
      let(:bolt_access_token) { 'accesstoken' }
      let(:bolt_expiration_time) { Time.now.utc + 10.minutes }

      it 'returns current access token' do
        expect(refresh_access_token).to eq(bolt_access_token)
      end
    end

    context 'with expired token' do
      let(:bolt_access_token) { 'accesstoken' }
      let(:bolt_expiration_time) { Time.now.utc - 10.minutes }
      let(:result) { { 'access_token' => 'newaccesstoken', 'expires_in' => 3600 } }

      before do
        allow(HTTParty).to receive(:post).and_return(result)
        allow(result).to receive(:success?).and_return(true)
        allow(result).to receive(:parsed_response).and_return(result)
      end

      it 'refreshes the access token' do
        expect(refresh_access_token).to eq('newaccesstoken')
      end
    end
  end
end
