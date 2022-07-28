# frozen_string_literal: true

module Spree
  module Admin
    class BoltCallbackUrlsController < Spree::Admin::BaseController
      def new
        callback_urls = SolidusBolt::MerchantConfiguration::GetCallbackUrlsService.call

        @oauth_logout = callback_urls['callback_urls'].find { |c| c['type'] == 'oauth_logout' }['url']
        @oauth_redirect = callback_urls['callback_urls'].find { |c| c['type'] == 'oauth_redirect' }['url']
      end

      def update
        SolidusBolt::MerchantConfiguration::SetCallbackUrlsService.call(
          oauth_logout: params[:bolt_callback_urls][:oauth_logout],
          oauth_redirect: params[:bolt_callback_urls][:oauth_redirect]
        )
        flash[:success] = "Successfully updated callback urls."

        redirect_to new_admin_bolt_callback_urls_path
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
