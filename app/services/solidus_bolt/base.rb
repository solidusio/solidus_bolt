# frozen_string_literal: true

module SolidusBolt
  class Base
    def initialize(*)
      @config = SolidusBolt::BoltConfiguration.fetch
    end

    def call
      raise NotImplementedError
    end

    def self.call(*args)
      new(*args).call
    end

    private

    def api_base_url
      @config.environment_url
    end

    def api_version
      'v1'
    end

    def generate_nonce
      SecureRandom.hex
    end

    def authenticate(options)
      options[:headers].merge!(authentication_header)
    end

    def authentication_header
      { 'X-API-KEY' => @config.api_key }
    end

    def publishable_key
      @config.publishable_key
    end
  end
end
