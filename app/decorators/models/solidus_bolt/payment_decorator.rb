# frozen_string_literal: true

module SolidusBolt
  module PaymentDecorator
    def can_void?
      super && state == 'pending'
    end

    Spree::Payment.prepend(self)
  end
end
