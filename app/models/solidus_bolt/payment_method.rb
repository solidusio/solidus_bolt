# frozen_string_literal: true

module SolidusBolt
  class PaymentMethod < SolidusSupport.payment_method_parent_class
    preference :bolt_api_key, :string
    preference :bolt_signing_secret, :string
    preference :bolt_publishable_key, :string
    preference :bolt_environment, :string

    validates :preferred_bolt_environment, inclusion: { in: %w[production sandbox staging] }, allow_blank: true

    def gateway_class
      ::SolidusBolt::Gateway
    end

    def payment_source_class
      ::SolidusBolt::PaymentSource
    end

    def partial_name
      'bolt'
    end

    def preferred_bolt_base_url
      return nil if preferred_bolt_environment.nil?

      preferred_bolt_environment == 'production' ? 'https://connect.bolt.com' : 'https://connect-sandbox.bolt.com'
    end
  end
end
