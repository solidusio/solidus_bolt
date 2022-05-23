# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Users::SyncAddressesService, :vcr, :bolt_configuration do
  subject(:sync_addresses_service) do
    described_class.call(user: user, access_token: ENV.fetch('BOLT_ACCESS_TOKEN', 'Fake_access_token'))
  end

  let(:user) { create(:user) }
  let(:country) { state.country }
  let(:state) { create(:state) }

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
  end
end
