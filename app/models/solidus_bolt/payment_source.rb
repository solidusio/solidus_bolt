# frozen_string_literal: true

require_dependency 'solidus_bolt'

module SolidusBolt
  class PaymentSource < SolidusSupport.payment_source_parent_class
    attr_accessor :create_bolt_account
  end
end
