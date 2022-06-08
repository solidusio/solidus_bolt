# frozen_string_literal: true

solidus_bolt_configuration = SolidusBolt::BoltConfiguration.fetch

solidus_bolt_configuration.bearer_token = ENV['BOLT_BEARER_TOKEN']
solidus_bolt_configuration.environment = ENV['BOLT_ENVIRONMENT']
solidus_bolt_configuration.merchant_public_id = ENV['BOLT_MERCHANT_PUBLIC_ID']
solidus_bolt_configuration.division_public_id = ENV['BOLT_DIVISION_PUBLIC_ID']
solidus_bolt_configuration.api_key = ENV['BOLT_API_KEY']
solidus_bolt_configuration.signing_secret = ENV['BOLT_SIGNING_SECRET']
solidus_bolt_configuration.publishable_key = ENV['BOLT_PUBLISHABLE_KEY']

solidus_bolt_configuration.save

Spree::AuthenticationMethod.find_or_create_by(provider: :bolt) do |authentication_method|
  authentication_method.environment = "development"
  authentication_method.provider = "bolt"
  authentication_method.api_key = SolidusBolt::BoltConfiguration.fetch.publishable_key
  authentication_method.api_secret = SolidusBolt::BoltConfiguration.fetch.api_key
  authentication_method.active = true
end

if ENV['BOLT_API_KEY'] && ENV['BOLT_SIGNING_SECRET'] && ENV['BOLT_PUBLISHABLE_KEY']
  SolidusBolt::PaymentMethod.create!(
    type: 'SolidusBolt::PaymentMethod',
    name: 'Bolt',
    preference_source: 'bolt_credentials',
    active: true
  )
end
