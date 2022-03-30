# frozen_string_literal: true

module SolidusBolt
  class BoltCheckout < SolidusSupport.payment_method_parent_class
    preference :bolt_api_key, :string
    preference :bolt_signing_secret, :string

    def gateway_class
      ::SolidusBolt::Gateway
    end

    def payment_source_class
      ::SolidusBolt::PaymentSource
    end

    def partial_name
      'bolt'
    end
  end
end
