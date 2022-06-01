require 'spec_helper'

RSpec.describe SolidusBolt::AddAddressJob do
  subject(:add_address_job) { described_class.perform_now(order: order, access_token: access_token, address: address) }

  let(:order) { build(:order) }
  let(:address) { build(:address) }
  let(:access_token) { 'accesstoken' }

  before { allow(SolidusBolt::Accounts::AddAddressService).to receive(:call) }

  it 'calls the AddAddressService' do
    add_address_job
    expect(SolidusBolt::Accounts::AddAddressService).to have_received(:call).with(
      order: order, access_token: access_token, address: address
    )
  end
end
