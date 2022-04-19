# frozen_string_literal: true

module Spree
  module Admin
    class BoltsController < Spree::Admin::BaseController
      before_action :bolt_configuration

      def show; end

      private

      def bolt_configuration
        @bolt_configuration = SolidusBolt::BoltConfiguration.fetch
      end
    end
  end
end
