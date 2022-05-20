# frozen_string_literal: true

require_dependency 'solidus_bolt'

module SolidusBolt
  class PaymentSource < SolidusSupport.payment_source_parent_class
    belongs_to :user, class_name: 'Spree::User', optional: true
  end
end
