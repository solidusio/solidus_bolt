# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Accounts::DetailService, :vcr, :bolt_configuration do
  describe '#call', vcr: true do
    subject(:detail) { described_class.call(access_token: access_token) }

    context 'with wrong access_token' do
      let(:access_token) { 'Bolt Access Token' }

      it 'gives an error' do
        expect{ detail }.to raise_error(SolidusBolt::ServerError, 'This action is forbidden.')
      end
    end

    context 'with correct access_token' do
      let(:access_token) { ENV['BOLT_ACCESS_TOKEN'] }

      it 'receives a successful response' do
        expect(detail).to match hash_including('profile')
        expect(detail).to match hash_including('addresses')
        expect(detail).to match hash_including('payment_methods')
      end
    end
  end
end

# This spec depends on the bolt_access_token that needs to be generated manually
# and added to the environment variable BOLT_ACCESS_TOKEN.
# Generate a new access token by logging into an existing user bolt account on
# development environment and copying the token from the session['bolt_access_token'] key.
