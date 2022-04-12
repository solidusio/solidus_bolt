# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Account::DetectAccount do
  subject(:api) { described_class.new(email: email) }

  let(:email) { 'bolt@bolt.com' }

  before do
    create(:bolt_configuration)
  end

  describe '#call', vcr: true do
    let(:url) { "#{api.send(:api_base_url)}/#{api.send(:api_version)}/account/exists" }

    it 'returns status 200' do
      expect(api.call.code).to eq 200
    end

    it 'receives the correct response' do
      expect(api.call.body).to eq  "{\"has_bolt_account\":false}"
    end
  end
end
