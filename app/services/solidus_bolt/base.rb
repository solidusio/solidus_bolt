# frozen_string_literal: true

module SolidusBolt
  class Base
    def initialize(*args); end

    def call
      raise NotImplementedError
    end

    def self.call(*args)
      new(*args).call
    end

    def api_base_url
      @config.environment_url
    end

    def api_version
      'v1'
    end
  end
end
