# frozen_string_literal: true

solidus_bolt_configuration = SolidusBolt::BoltConfiguration.fetch

solidus_bolt_configuration.bearer_token = ENV['BOLT_BEARER_TOKEN']
solidus_bolt_configuration.environment_url = ENV['BOLT_ENVIRONMENT_URL']
solidus_bolt_configuration.merchant_public_id = ENV['BOLT_MERCHANT_PUBLIC_ID']
solidus_bolt_configuration.merchant_id = ENV['BOLT_MERCHANT_ID']
solidus_bolt_configuration.api_key = ENV['BOLT_API_KEY']
solidus_bolt_configuration.signing_secret = ENV['BOLT_SIGNIN_SECRET']
solidus_bolt_configuration.publishable_key = ENV['BOLT_PUBLISHABLE_KEY']

solidus_bolt_configuration.save
