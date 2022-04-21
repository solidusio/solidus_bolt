# frozen_string_literal: true

require_dependency 'solidus_bolt'

module SolidusBolt
  class BoltConfiguration < ApplicationRecord
    validate :config_can_be_created, on: :create

    def self.fetch
      first_or_create
    end

    def self.can_create?
      count.zero?
    end

    private

    def config_can_be_created
      errors.add(:base, 'Can create only one record for this Model') unless SolidusBolt::BoltConfiguration.can_create?
    end
  end
end
