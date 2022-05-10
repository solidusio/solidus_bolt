# frozen_string_literal: true

module SolidusBolt
  module OmniAuth::Strategies::BoltDecorator # rubocop:disable Style/ClassAndModuleChildren
    def callback_phase
      super.tap { session[:bolt_access_token] = @access_token }
    end

    ::OmniAuth::Strategies::Bolt.prepend self
  end
end
