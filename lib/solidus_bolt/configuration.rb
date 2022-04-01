# frozen_string_literal: true

module SolidusBolt
  class Configuration; end

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
