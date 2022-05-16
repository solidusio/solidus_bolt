# frozen_string_literal: true

FactoryBot.define do
  factory :bolt_configuration, class: SolidusBolt::BoltConfiguration do
    bearer_token { SecureRandom.hex }
    environment { 'sandbox' }
    merchant_public_id { SecureRandom.hex }
    merchant_id { SecureRandom.hex }
    api_key { SecureRandom.hex }
    signing_secret { SecureRandom.hex }
    publishable_key { SecureRandom.hex }
  end

  factory :bolt_payment_method, class: SolidusBolt::PaymentMethod do
    name               { 'Bolt' }
    preference_source  { 'bolt_credentials' }
    available_to_admin { true }
    available_to_users { true }
  end

  factory :bolt_payment_source, class: SolidusBolt::PaymentSource do
    create_bolt_account { false }
    payment_method
  end

  factory :bolt_payment, class: Spree::Payment do
    association(:payment_method, factory: :bolt_payment_method)
    association(:source, factory: :bolt_payment_source)
    order
    state { 'checkout' }
  end
end
