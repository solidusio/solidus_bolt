# frozen_string_literal: true

module SolidusBolt
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false
      source_root File.expand_path('templates', __dir__)

      def install_solidus_social
        if File.exist? 'config/initializers/solidus_social.rb'
          puts 'Skipping solidus_social:install' # rubocop:disable Rails/Output
        else
          say_status :install, 'solidus_social extension'
          solidus_social_install_command = 'bin/rails generate solidus_social:install'
          solidus_social_install_command += ' --auto-run-migrations' if options[:auto_run_migrations]

          run solidus_social_install_command
        end
      end

      def copy_initializer
        template 'initializer.rb', 'config/initializers/solidus_bolt.rb'
      end

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/solidus_bolt\n"
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "//= require spree/backend/solidus_bolt\n"
      end

      def add_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/frontend/all.css', " *= require spree/frontend/solidus_bolt\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/backend/solidus_bolt\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
      end

      def add_migrations
        run 'bin/rails railties:install:migrations FROM=solidus_bolt'
      end

      def add_bolt_omniauth_provider
        solidus_social_initializer_file = 'config/initializers/solidus_social.rb'
        return if File.readlines(solidus_social_initializer_file).grep(/bolt/).any?

        matcher = /(Spree::SocialConfig\.configure\sdo\s\|config\|.*progname\s=\s'omniauth')/m
        # rubocop:disable Layout/HeredocIndentation
        a = <<~BOLT_PROVIDER
        Rails.application.config.to_prepare do
          Spree::SocialConfig.configure do |c|
            c.use_static_preferences!

            c.providers = {}

            begin
              c.providers[:bolt] = {
                api_key: SolidusBolt::BoltConfiguration.fetch.publishable_key,
                api_secret: SolidusBolt::BoltConfiguration.fetch.api_key,
              }
            rescue StandardError
            end
          end

          SolidusSocial.init_providers
        end

        OmniAuth.config.logger = Logger.new(STDOUT)
        OmniAuth.logger.progname = 'omniauth'
        OmniAuth.config.allowed_request_methods = [:get]
        BOLT_PROVIDER
        # rubocop:enable Layout/HeredocIndentation

        gsub_file solidus_social_initializer_file, matcher, a
      end

      def add_omniauth_middleware
        bolt_middleware_initializer = <<~BOLT_PROVIDER
          Rails.application.config.middleware.use OmniAuth::Builder do
            bolt_configuration = SolidusBolt::BoltConfiguration.fetch

            if bolt_configuration&.publishable_key.present? && bolt_configuration&.api_key.present?
              provider :bolt, publishable_key: bolt_configuration.publishable_key,
                        api_key: bolt_configuration.api_key
            else
              Rails.logger.warn 'Bolt configuration missing'
            end
          rescue StandardError
          end
        BOLT_PROVIDER
        append_file 'config/initializers/solidus_social.rb', bolt_middleware_initializer
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]')) # rubocop:disable Layout/LineLength
        if run_migrations
          run 'bin/rails db:migrate'
        else
          puts 'Skipping bin/rails db:migrate, don\'t forget to run it!' # rubocop:disable Rails/Output
        end
      end

      def populate_seed_data
        say_status :loading, 'bolt seed data'
        rake('db:seed:solidus_bolt')
      end
    end
  end
end
