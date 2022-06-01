# frozen_string_literal: true

module SolidusBolt
  class AddAddressJob < ApplicationJob
    def perform(order:, access_token:, address:)
      SolidusBolt::Accounts::AddAddressService.call(
        order: order, access_token: access_token, address: address
      )
    end
  end
end
