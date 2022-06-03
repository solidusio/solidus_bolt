# frozen_string_literal: true

module SolidusBolt
  module OmniAuth::Strategies::BoltDecorator # rubocop:disable Style/ClassAndModuleChildren
    def callback_phase
      super.tap do
        session[:bolt_access_token] = @access_token
        session[:bolt_expiration_time] = @expiration_time
        session[:bolt_refresh_token] = @refresh_token
        session[:bolt_refresh_token_scope] = @refresh_token_scope
      end
    end

    ::OmniAuth::Strategies::Bolt.prepend self
  end
end
