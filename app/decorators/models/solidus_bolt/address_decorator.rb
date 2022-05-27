# frozen_string_literal: true

module SolidusBolt
  module AddressDecorator
    def bolt_address(email)
      {
        street_address1: address1,
        street_address2: address2,
        locality: city,
        region: state.abbr,
        postal_code: zipcode,
        country_code: country.iso,
        first_name: Spree::Address::Name.new(name).first_name,
        last_name: Spree::Address::Name.new(name).last_name,
        phone: phone,
        email: email
      }
    end

    Spree::Address.prepend(self)
  end
end
