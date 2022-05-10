# frozen_string_literal: true

module SolidusBolt
  class BaseService
    def initialize(*)
      @config = SolidusBolt::BoltConfiguration.fetch
    end

    def call
      raise NotImplementedError
    end

    def self.call(*args, **kwargs)
      new(*args, **kwargs).call
    end

    private

    def handle_result(result)
      return result.parsed_response if result.success?

      raise ServerError, error_message(result)
    end

    def error_message(result)
      return result['errors'].map { |e| e['message'] }.join(', ') if result['errors']

      "#{result['error']}: #{result['error_description']}"
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

    def api_key
      @config.api_key
    end
  end
end
