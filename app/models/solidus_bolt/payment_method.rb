# frozen_string_literal: true

module SolidusBolt
  class PaymentMethod < SolidusSupport.payment_method_parent_class
    def gateway_class
      ::SolidusBolt::Gateway
    end

    def payment_source_class
      ::SolidusBolt::PaymentSource
    end

    def partial_name
      'bolt'
    end

    def preferred_api_key
      configuration.api_key
    end

    def preferred_signing_secret
      configuration.signing_secret
    end

    def preferred_publishable_key
      configuration.publishable_key
    end

    def preferred_base_url
      preferred_test_mode ? 'https://connect-sandbox.bolt.com' : 'https://connect.bolt.com'
    end

    private

    def configuration
      @configuration ||= SolidusBolt::BoltConfiguration.fetch
    end
  end
end
