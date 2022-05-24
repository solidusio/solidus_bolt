# frozen_string_literal: true

module SolidusBolt
  module UserDecorator
    def self.prepended(base)
      base.has_many :bolt_payment_sources, class_name: 'SolidusBolt::PaymentSource'
    end

    Spree::User.prepend(self)
  end
end
