# frozen_string_literal: true

require 'base64'

module SolidusBolt
  class WebhooksController < ::Spree::Api::BaseController
    skip_before_action :authenticate_user
    skip_before_action :verify_authenticity_token
    before_action :verify_bolt_request

    def update
      ::SolidusBolt::Sorter.call(params)

      render json: {}, status: :ok
    rescue StandardError => e
      error_message = e.to_s
      logger.error error_message
      render json: { error: error_message }, status: :unprocessable_entity
    end

    private

    def verify_bolt_request
      hmac_header = request.headers['X-Bolt-Hmac-Sha256']
      signing_secret = SolidusBolt::BoltConfiguration.fetch&.signing_secret || ''
      computed_hmac = Base64.encode64(OpenSSL::HMAC.digest("SHA256", signing_secret, params[:webhook].to_json)).strip

      return render json: { error: 'Unauthorized request' }, status: :unauthorized unless hmac_header == computed_hmac
    end
  end
end
