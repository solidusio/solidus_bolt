# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Users::SyncAddressesService, :vcr, :bolt_configuration do
  subject(:sync_addresses_service) do
    described_class.call(user: user, access_token: ENV.fetch('BOLT_ACCESS_TOKEN', 'Fake_access_token'))
  end

  let(:user) { create(:user) }
  let(:country) { state.country }
  let(:state) { create(:state) }
  let(:payload) do
    {
      'profile' => { 'phone' => '987654321' },
      'addresses' => [{
        'id' => 'SA98t82gH2Grd',
        'street_address1' => '380 DEGRAW ST',
        'locality' => 'Brooklyn',
        'region' => 'NEW YORK',
        'region_code' => 'NY',
        'postal_code' => '11231',
        'country_code' => 'US',
        'name' => 'Danny Dove',
        'first_name' => 'Danny',
        'last_name' => 'Dove',
        'default' => true,
        'phone_number' => phone
      }]
    }
  end

  before do
    allow(Spree::Country).to receive(:find_by).and_return(country)
    allow(Spree::State).to receive(:find_by).and_return(state)
    allow(country).to receive(:states).and_return(Spree::State)
  end

  describe '#call', vcr: true do
    it 'adds the ship_address to the user' do
      expect { sync_addresses_service }.to change(user, :ship_address).from(nil)
    end

    it 'adds the bill_address to the user' do
      expect { sync_addresses_service }.to change(user, :bill_address).from(nil)
    end

    context 'with address phone number', vcr: false do
      let(:phone) { '123456789' }

      before do
        allow(SolidusBolt::Accounts::DetailService).to receive(:call).and_return(payload)
        sync_addresses_service
      end

      it 'creates an address with the address phone' do
        expect(user.bill_address.phone).to eq(phone)
      end
    end

    context 'without address phone number', vcr: false do
      let(:phone) { nil }

      before do
        allow(SolidusBolt::Accounts::DetailService).to receive(:call).and_return(payload)
        sync_addresses_service
      end

      it 'creates an address with the user phone' do
        expect(user.bill_address.phone).to eq('987654321')
      end
    end
  end
end
