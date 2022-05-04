# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Oauth::TokenService, :vcr, :bolt_configuration do
  subject(:api) {
    described_class.new(authorization_code: 'Bolt Authorization Code', scope: 'openid bolt.account.manage')
  }

  describe '#call', vcr: true do
    it 'makes the API call' do
      expect { api.call }.to raise_error SolidusBolt::ServerError
    end
  end
end
