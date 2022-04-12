# frozen_string_literal: true

require_dependency 'solidus_bolt'

module SolidusBolt
  class PaymentSource < SolidusSupport.payment_source_parent_class
    validates :transaction_reference, presence: true
  end
end
