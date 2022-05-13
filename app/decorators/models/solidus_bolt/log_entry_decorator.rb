# frozen_string_literal: true

module SolidusBolt
  module LogEntryDecorator
    def parsed_details
      @parsed_details ||= YAML.load(details) # rubocop:disable Security/YAMLLoad
    end

    Spree::LogEntry.prepend self
  end
end
