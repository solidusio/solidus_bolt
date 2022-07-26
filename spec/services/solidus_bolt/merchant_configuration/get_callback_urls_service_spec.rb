# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::MerchantConfiguration::GetCallbackUrlsService, :vcr, :bolt_configuration do
  subject(:api) { described_class.new }

  describe '#call', vcr: true do
    it 'receives the correct response' do
      expect(api.call).to match hash_including(
        'callback_urls' => array_including(hash_including('type', 'url'))
      )
    end
  end
end
