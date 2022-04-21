# frozen_string_literal: true

SolidusBolt.configure do |config|
  # TODO: Remember to change this with the actual preferences you have implemented!
  # config.sample_preference = 'sample_value'
end

Rails.application.config.assets.precompile += %w(bolt_logo_standard.png)
