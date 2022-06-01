# frozen_string_literal: true

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data('<API_KEY>') do |interaction|
    interaction.request.headers['X-API-KEY']&.first
  end

  config.filter_sensitive_data('<PUBLISHABLE_KEY>') do |interaction|
    interaction.request.headers['X-Publishable-Key']&.first
  end

  config.filter_sensitive_data('<BEARER AUTHORIZATION>') do |interaction|
    interaction.request.headers['Authorization']&.first
  end

  config.filter_sensitive_data('<PUBLISHABLE_KEY>') { SolidusBolt::BoltConfiguration.fetch.publishable_key }
  config.filter_sensitive_data('<API_KEY>') { SolidusBolt::BoltConfiguration.fetch.api_key }
  config.filter_sensitive_data('<DIVISION_ID>') { SolidusBolt::BoltConfiguration.fetch.division_public_id }

  # Let's you set default VCR record mode with VCR_RECORDE_MODE=all for re-recording
  # episodes. :once is VCR default
  record_mode = ENV.fetch('VCR_RECORD_MODE', :once).to_sym
  config.default_cassette_options = { record: record_mode }
end
