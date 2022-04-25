# frozen_string_literal: true

FactoryBot.define do
  factory :bolt_configuration, class: SolidusBolt::BoltConfiguration do
    bearer_token { SecureRandom.hex }
    environment_url { 'https://api-sandbox.bolt.com' }
    merchant_public_id { SecureRandom.hex }
    merchant_id { SecureRandom.hex }
    api_key { SecureRandom.hex }
    signing_secret { SecureRandom.hex }
    publishable_key { SecureRandom.hex }
  end
end
