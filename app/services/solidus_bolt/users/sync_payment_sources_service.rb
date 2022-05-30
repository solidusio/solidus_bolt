# frozen_string_literal: true

module SolidusBolt
  module Users
    class SyncPaymentSourcesService < SolidusBolt::BaseService
      attr_reader :user, :access_token

      def initialize(user:, access_token:)
        @user = user
        @access_token = access_token
        super
      end

      def call
        return if user.nil? || access_token.nil?

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

      def add_payment_source(payment_method)
        # format of card_expiration: '2022-04'
        card_expiration = "#{payment_method['exp_year']}-#{payment_method['exp_month'].to_s.rjust(2, '0')}"
        SolidusBolt::PaymentSource.find_or_create_by!(
          user_id: user.id,
          card_last4: payment_method['last4'],
          card_expiration: card_expiration,
          card_id: payment_method['id']
        )
      end
    end
  end
end