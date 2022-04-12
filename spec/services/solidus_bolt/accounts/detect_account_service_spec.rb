# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Accounts::DetectAccountService, :vcr, :bolt_configuration do
  subject(:api) { described_class.new(email: email) }

  let(:email) { 'bolt@bolt.com' }

  describe '#call', vcr: true do
    it 'returns status 200' do
      expect(api.call.code).to eq 200
    end

    it 'receives the correct response' do
      expect(api.call.body).to eq "{\"has_bolt_account\":false}"
    end
  end
end
