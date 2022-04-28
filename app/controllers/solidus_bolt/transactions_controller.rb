# frozen_string_literal: true

module SolidusBolt
  class TransactionsController < ::Spree::Api::BaseController
    def authorize
      order = ::Spree::Order.find(params[:order_id])
      response = ::SolidusBolt::Authorize.call(
        order: order, create_bolt_account: params[:create_bolt_account], credit_card: params[:credit_card]
      )
      render json: response, code: 200
    rescue StandardError => e
      render json: { error: e }, code: 500
    end
  end
end
