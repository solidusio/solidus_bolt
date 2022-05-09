# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusBolt
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_bolt'

    initializer "solidus_bolt.add_static_preference", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << SolidusBolt::PaymentMethod
      Spree::Config.static_model_preferences.add(
        SolidusBolt::PaymentMethod,
        'bolt_credentials', {
          bolt_api_key: ENV['BOLT_API_KEY'],
          bolt_signing_secret: ENV['BOLT_SIGNING_SECRET'],
          bolt_publishable_key: ENV['BOLT_PUBLISHABLE_KEY']
        }
      )
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
