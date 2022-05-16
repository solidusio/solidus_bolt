# frozen_string_literal: true

module SolidusBolt
  class Sorter
    attr_reader :params

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      handler&.call(params)
    end

    private

    def handler
      class_name = "#{event_type.split('.').map(&:capitalize).join}Handler"

      return unless SolidusBolt::Handlers.const_defined?(class_name)

      SolidusBolt::Handlers.const_get(class_name)
    end

    def event_type
      params[:type]
    end
  end
end
