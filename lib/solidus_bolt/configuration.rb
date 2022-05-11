# frozen_string_literal: true

module SolidusBolt
  class Configuration
    attr_accessor :bolt_api_key, :bolt_signing_secret, :bolt_publishable_key
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
