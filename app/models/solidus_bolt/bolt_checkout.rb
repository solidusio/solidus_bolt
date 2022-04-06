# frozen_string_literal: true

module SolidusBolt
  class BoltCheckout < SolidusSupport.payment_method_parent_class
    preference :bolt_api_key, :string
    preference :bolt_signing_secret, :string
    preference :bolt_publishable_key, :string

    def gateway_class
      ::SolidusBolt::Gateway
    end

    def payment_source_class
      ::SolidusBolt::PaymentSource
    end

    def partial_name
      'bolt'
    end

    def preferred_base_url
      preferred_test_mode ? 'https://connect-sandbox.bolt.com' : 'https://connect.bolt.com'
    end

    def preferred_api_url
      preferred_test_mode ? 'https://api-sandbox.bolt.com' : 'https://api.bolt.com'
    end
  end
end
