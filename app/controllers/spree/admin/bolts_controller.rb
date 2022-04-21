# frozen_string_literal: true

module Spree
  module Admin
    class BoltsController < Spree::Admin::BaseController
      before_action :bolt_configuration

      def show; end

      def edit; end

      def update
        if @bolt_configuration.update(bolt_configuration_params)
          flash[:success] = t('spree.admin.bolt.updated_successfully')
          redirect_to admin_bolt_path
        else
          flash[:error] = @bolt_configuration.errors.full_messages.to_sentence
          render :edit
        end
      end

      private

      def bolt_configuration
        @bolt_configuration = SolidusBolt::BoltConfiguration.fetch
      end

      def bolt_configuration_params
        params
          .require(:solidus_bolt_bolt_configuration)
          .permit(
            :bearer_token,
            :environment_url,
            :merchant_public_id,
            :merchant_id,
            :api_key,
            :signing_secret,
            :publishable_key
          )
      end
    end
  end
end
