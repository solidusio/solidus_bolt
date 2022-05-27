# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Accounts::AddPaymentMethodService, :vcr, :bolt_configuration do
  describe '#call', vcr: true do
    subject(:add_payment_method) do
      described_class.call(
        access_token: access_token, credit_card: credit_card_payload, address: address, email: 'example@email.com'
      )
    end

    let(:address) { build(:address) }
    let(:card_number) { '4111111111111004' }
    let(:credit_card_payload) do
      tokenize_credit_card(credit_card_number: card_number, cvv: '111')
        .merge(
          number: card_number,
          expiration: (Time.current + 1.year).strftime('%Y-%m'),
          token_type: 'bolt',
          postal_code: address.zipcode
        )
    end

    context 'with wrong access_token' do
      let(:access_token) { 'Bolt Access Token' }

      it 'gives an error' do
        expect{ add_payment_method }.to raise_error(SolidusBolt::ServerError, 'This action is forbidden.')
      end
    end

    context 'with correct access_token' do
      let(:access_token) { ENV['BOLT_ACCESS_TOKEN'] }

      it 'receives a successful response' do
        expect(add_payment_method).to match hash_including('id')
        expect(add_payment_method['last4']).to eq('1004')
      end
    end
  end
end

# This spec depends on the bolt_access_token that needs to be generated manually
# and added to the environment variable BOLT_ACCESS_TOKEN.
# Generate a new access token by logging into an existing user bolt account on
# development environment and copying the token from the session['bolt_access_token'] key.
