# frozen_string_literal: true

module SolidusBolt
  module SpreeCheckoutController
    module AddAddressesToBolt
      def before_delivery
        if write_access_token_expired?
          Spree::UserLastUrlStorer.new(self).store_location
          sign_out(spree_current_user)
        elsif session[:bolt_access_token]
          spree_current_user.addresses.each do |address|
            SolidusBolt::AddAddressJob.perform_later(
              order: current_order,
              access_token: session[:bolt_access_token],
              address: address
            )
          end
        end

        super
      end

      Spree::CheckoutController.prepend self

      private

      def write_access_token_expired?
        session[:bolt_access_token] &&
          (session[:bolt_scope] == 'bolt.account.view' || Time.now.utc >= session[:bolt_expiration_time])
      end
    end
  end
end
