# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusBolt
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_bolt'

    initializer "solidus_bolt.add_static_preference", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << 'SolidusBolt::PaymentMethod'
      app.config.to_prepare do
        Spree::Config.static_model_preferences.add(
          SolidusBolt::PaymentMethod,
          'bolt_credentials',
          ::SolidusBolt::Engine.bolt_credentials_hash
        )
        Spree::Config.static_model_preferences.add(
          SolidusBolt::PaymentMethod,
          'bolt_config_credentials',
          ::SolidusBolt::Engine.bolt_config_credentials_hash
        )
      end

      Spree::PermittedAttributes.source_attributes.concat(%i[
        card_token card_last4 card_bin card_number card_expiration card_postal_code create_bolt_account
      ])
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    class << self
      def bolt_credentials_hash
        {
          bolt_api_key: ENV['BOLT_API_KEY'],
          bolt_signing_secret: ENV['BOLT_SIGNING_SECRET'],
          bolt_publishable_key: ENV['BOLT_PUBLISHABLE_KEY'],
        }
      end

      def bolt_config_credentials_hash
        begin
          bolt_config = SolidusBolt::BoltConfiguration.fetch
        rescue ActiveRecord::StatementInvalid
          bolt_config = nil
        ensure
          bolt_config_hash = {
            bolt_api_key: bolt_config&.api_key,
            bolt_signing_secret: bolt_config&.signing_secret,
            bolt_publishable_key: bolt_config&.publishable_key,
          }
        end
        bolt_config_hash
      end
    end
  end
end
