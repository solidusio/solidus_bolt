# frozen_string_literal: true

module Spree
  module Admin
    class BoltCallbackUrlsController < Spree::Admin::BaseController
      def edit
        callback_urls = SolidusBolt::MerchantConfiguration::GetCallbackUrlsService.call

        @oauth_logout = callback_urls['callback_urls'].find { |c| c['type'] == 'oauth_logout' }&.dig('url')
        @oauth_redirect = callback_urls['callback_urls'].find { |c| c['type'] == 'oauth_redirect' }&.dig('url')
        @get_account = callback_urls['callback_urls'].find { |c| c['type'] == 'get_account' }&.dig('url')
      end

      def update
        SolidusBolt::MerchantConfiguration::SetCallbackUrlsService.call(
          oauth_logout: params[:bolt_callback_urls][:oauth_logout],
          oauth_redirect: params[:bolt_callback_urls][:oauth_redirect],
          get_account: params[:bolt_callback_urls][:get_account]
        )
        flash[:success] = "Successfully updated callback urls."

        redirect_to edit_admin_bolt_callback_urls_path
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
