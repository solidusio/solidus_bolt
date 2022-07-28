# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::MerchantConfiguration::SetCallbackUrlsService, :vcr, :bolt_configuration do
  subject(:api) { described_class.new(params) }

  let(:params) {
    {
      oauth_redirect: 'http://localhost:3000/users/auth/bolt',
      oauth_logout: 'http://localhost:3000//user/spree_user/logout'
    }
  }

  describe '#call', vcr: true do
    it 'receives the correct response' do
      expect(api.call).to be_nil
    end
  end
end
