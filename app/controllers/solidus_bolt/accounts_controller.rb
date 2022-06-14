# frozen_string_literal: true

module SolidusBolt
  class AccountsController < BaseController
    def create
      Spree::User.find_by!(email: permitted_params[:email])

      head :ok
    end

    private

    def permitted_params
      params[:account]
    end
  end
end
