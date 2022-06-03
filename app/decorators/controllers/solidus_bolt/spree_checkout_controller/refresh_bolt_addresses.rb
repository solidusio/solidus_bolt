# frozen_string_literal: true

module SolidusBolt
  module SpreeCheckoutController
    module RefreshBoltAddresses
      def before_address
        SolidusBolt::Users::SyncAddressesService.call(
          user: spree_current_user, access_token: SolidusBolt::Users::RefreshAccessTokenService.call(session: session)
        )

        super
      end

      Spree::CheckoutController.prepend self
    end
  end
end
