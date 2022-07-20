# frozen_string_literal: true

module SolidusBolt
  class PaymentMethod < SolidusSupport.payment_method_parent_class
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

    def preferred_bolt_base_url
      bolt_config.embed_js
    end

    def preferred_bolt_api_url
      bolt_config.environment_url
    end

    def try_void(payment)
      return false unless payment.source.can_void?(payment)

      gateway.void(payment.response_code, originator: payment)
    end

    private

    def bolt_config
      @bolt_config = SolidusBolt::BoltConfiguration.fetch
    end
  end
end
