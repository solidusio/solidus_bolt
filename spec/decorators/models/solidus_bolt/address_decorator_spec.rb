require 'spec_helper'

RSpec.describe SolidusBolt::AddressDecorator do
  let(:address) { create(:address) }
  let(:email) { 'example@gmail.com' }

  describe '#bolt_address' do
    it 'returns a hash with address values and email' do
      result = {
        street_address1: address.address1,
        street_address2: address.address2,
        locality: address.city,
        region: address.state.abbr,
        postal_code: address.zipcode,
        country_code: address.country.iso,
        first_name: Spree::Address::Name.new(address.name).first_name,
        last_name: Spree::Address::Name.new(address.name).last_name,
        phone: address.phone,
        email: email
      }
      expect(address.bolt_address(email)).to eq(result)
    end
  end
end
