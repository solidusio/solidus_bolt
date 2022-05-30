# frozen_string_literal: true

module Spree
  module Admin
    class BoltWebhooksController < Spree::Admin::BaseController
      def new; end

      def create
        response = SolidusBolt::Webhooks::CreateService.call(
          event: bolt_webhook_params[:event],
          url: bolt_webhook_params[:webhook_url]
        )
        flash[:success] = "Successfully created webhook. Webhook ID #{response['webhook_id']}"

        render :new
      rescue SolidusBolt::ServerError => e
        flash[:error] = e.message

        render :new
      end

      private

      def bolt_webhook_params
        params
          .require(:bolt_webhook)
          .permit(
            :event,
            :webhook_url,
          )
      end
    end
  end
end
