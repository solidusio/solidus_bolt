# frozen_string_literal: true

module SolidusBolt
  module Users
    class SyncPaymentSourcesService < SolidusBolt::BaseService
      attr_reader :user, :access_token, :bolt_payment_method

      def initialize(user:, access_token:)
        @user = user
        @access_token = access_token
        @bolt_payment_method = SolidusBolt::PaymentMethod.last
        super
      end

      def call
        return if user.nil? || access_token.nil? || bolt_payment_method.nil?

        payment_methods.each do |payment_method|
          add_payment_source(payment_method)
        end
      end

      private

      def user_info
        @user_info ||= Accounts::DetailService.call(access_token: access_token)
      end

      def payment_methods
        user_info['payment_methods']
      end

      def spree_wallet
        @spree_wallet ||= Spree::Wallet.new(user)
      end

      def add_payment_source(payment_method)
        # format of card_expiration: '2022-04'
        card_expiration = "#{payment_method['exp_year']}-#{payment_method['exp_month'].to_s.rjust(2, '0')}"
        payment_source = SolidusBolt::PaymentSource.find_or_create_by!(
          payment_method_id: bolt_payment_method.id,
          card_last4: payment_method['last4'],
          card_expiration: card_expiration,
          card_id: payment_method['id']
        )
        spree_wallet.add(payment_source)
      end
    end
  end
end
