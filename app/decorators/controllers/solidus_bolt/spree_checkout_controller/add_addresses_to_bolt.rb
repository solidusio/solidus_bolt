# frozen_string_literal: true

module SolidusBolt
  module SpreeCheckoutController
    module AddAddressesToBolt
      def finalize_order
        if session[:bolt_access_token] && current_order.payments.last&.source_type == "SolidusBolt::PaymentSource"
          spree_current_user.addresses.each do |address|
            SolidusBolt::Accounts::AddAddressService.call(
              order: current_order, access_token: session[:bolt_access_token], address: address
            )
          end
        end

        super
      end

      Spree::CheckoutController.prepend self
    end
  end
end
