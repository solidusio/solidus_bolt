# frozen_string_literal: true

module SolidusBolt
  class BaseService
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

    def handle_result(result)
      return result.parsed_response if result.success?

      raise ServerError, result['errors'].map { |e| e['message'] }.join(', ')
    end

    def api_base_url
      @config.environment_url
    end

    def api_version
      'v1'
    end

    def generate_nonce
      SecureRandom.hex
    end

    def authentication_header
      { 'X-API-KEY' => @config.api_key }
    end

    def publishable_key
      @config.publishable_key
    end
  end
end
