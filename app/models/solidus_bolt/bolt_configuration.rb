# frozen_string_literal: true

require_dependency 'solidus_bolt'

module SolidusBolt
  class BoltConfiguration < ApplicationRecord
    after_commit :update_bolt_config_credentials

    PRODUCTION_REGISTER_URL = 'https://merchant.bolt.com/register?platform=solidus'
    SANDBOX_REGISTER_URL = 'https://merchant-sandbox.bolt.com/register?platform=solidus'
    EVENTS = %w[all payment credit capture void auth pending rejected_irreversible rejected_reversible no_op
                failed_payment newsletter_subscription risk_insights credit_card_deleted].freeze

    enum environment: { production: 0, sandbox: 1, staging: 2 }

    validate :config_can_be_created, on: :create

    def merchant_public_id
      publishable_key.split('.').first
    end

    def division_public_id
      publishable_key.split('.').second
    end

    def self.fetch
      first_or_create
    end

    def self.can_create?
      count.zero?
    end

    def self.config_empty?
      whitelist = %w[id created_at updated_at environment]

      fetch.attributes.all? do |attr, val|
        whitelist.include?(attr) || val.blank?
      end
    end

    def environment_url
      case BoltConfiguration.environments[environment]
      when 0 then 'https://api.bolt.com'
      when 1 then 'https://api-sandbox.bolt.com'
      when 2 then 'https://api-staging.bolt.com'
      end
    end

    def embed_js
      case BoltConfiguration.environments[environment]
      when 0 then 'https://connect.bolt.com/embed.js'
      else 'https://connect-sandbox.bolt.com/embed.js'
      end
    end

    def account_js
      case BoltConfiguration.environments[environment]
      when 0 then 'https://connect.bolt.com/account.js'
      else
        'https://connect-sandbox.bolt.com/account.js'
      end
    end

    private

    def update_bolt_config_credentials
      bolt_config_credentials = Spree::Config
                                .static_model_preferences
                                .for_class(SolidusBolt::PaymentMethod)['bolt_config_credentials']
                                &.preferences
      return unless bolt_config_credentials

      bolt_config_credentials[:bolt_api_key] = api_key
      bolt_config_credentials[:bolt_signing_secret] = signing_secret
      bolt_config_credentials[:bolt_publishable_key] = publishable_key
    end

    def config_can_be_created
      errors.add(:base, 'Can create only one record for this Model') unless SolidusBolt::BoltConfiguration.can_create?
    end
  end
end
