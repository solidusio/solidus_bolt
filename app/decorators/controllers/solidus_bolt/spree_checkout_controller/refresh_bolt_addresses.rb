# frozen_string_literal: true

module SolidusBolt
  module SpreeCheckoutController
    module RefreshBoltAddresses
      def before_address
        SolidusBolt::Users::SyncAddressesService.call(
          user: spree_current_user, access_token: session[:bolt_access_token]
        )

        super
      end

      Spree::CheckoutController.prepend self
    end
  end
end
