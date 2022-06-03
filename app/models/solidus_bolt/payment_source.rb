# frozen_string_literal: true

require_dependency 'solidus_bolt'

module SolidusBolt
  class PaymentSource < SolidusSupport.payment_source_parent_class
    validates :payment_method_id, presence: true

    def reusable?
      card_id.present?
    end
  end
end
