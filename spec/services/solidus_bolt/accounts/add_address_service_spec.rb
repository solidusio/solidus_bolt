# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Accounts::AddAddressService, :vcr, :bolt_configuration do
  describe '#call', vcr: true do
    subject(:add_address) { described_class.call(access_token: access_token, order: order, address: address) }

    let(:order) { build(:order) }
    let(:address) { order.bill_address }

    context 'with wrong access_token' do
      let(:access_token) { 'Bolt Access Token' }

      it 'gives an error' do
        expect{ add_address }.to raise_error(SolidusBolt::ServerError, 'This action is forbidden.')
      end
    end

    context 'with correct access_token' do
      let(:access_token) { ENV['BOLT_ACCESS_TOKEN'] }
      let(:address) { build(:address, address1: '6420') }

      it 'receives a successful response' do
        expect(add_address).to match hash_including('id')
        expect(add_address['street_address1']).to eq(address.address1)
      end
    end

    context 'with existing address' do
      let(:access_token) { ENV['BOLT_ACCESS_TOKEN'] }

      let(:address) { build(:address, address1: 'PO Box 1337', zipcode: '10001') }

      it 'skips the add_address call' do
        expect(add_address).to be(nil)
      end
    end
  end
end

# This spec depends on the bolt_access_token that needs to be generated manually
# and added to the environment variable BOLT_ACCESS_TOKEN.
# Generate a new access token by logging into an existing user bolt account on
# development environment and copying the token from the session['bolt_access_token'] key.
