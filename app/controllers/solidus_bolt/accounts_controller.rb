# frozen_string_literal: true

module SolidusBolt
  class AccountsController < BaseController
    def create
      Spree::User.find_by!(email: params[:email])

      head :ok
    end
  end
end
