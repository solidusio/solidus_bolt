# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:example, :bolt_configuration) do
    solidus_bolt_configuration = SolidusBolt::BoltConfiguration.fetch

    solidus_bolt_configuration.bearer_token = ENV['BOLT_BEARER_TOKEN']
    solidus_bolt_configuration.environment_url = 'https://api-sandbox.bolt.com'
    solidus_bolt_configuration.merchant_public_id = ENV['BOLT_MERCHANT_PUBLIC_ID']
    solidus_bolt_configuration.merchant_id = ENV['BOLT_MERCHANT_ID']
    solidus_bolt_configuration.api_key = ENV['BOLT_API_KEY']
    solidus_bolt_configuration.signing_secret = ENV['BOLT_SIGNIN_SECRET']
    solidus_bolt_configuration.publishable_key = ENV['BOLT_PUBLISHABLE_KEY']

    solidus_bolt_configuration.save!

    allow(SolidusBolt::BaseService).to receive(:generate_nonce).and_return('fakenonce')
    allow(SolidusBolt::BoltHelper).to receive(:nonce).and_return('helpernonce')
    allow(TweetNaCl).to receive(:crypto_box_keypair).and_return(
      [
        "\x8C\xEB\x1C^(\x99\n\xC9\xFE\x9D\xF5\xC5z\xD0E\xFBs\xA7\xD2p\x16\x81\xE7O\xF3\xB6[%B\xA2\xCC<",
        "\x86(\x1D\x8B2s\x7F\xD0\xB1\xCC\"\x83\xE2Lqy4\xF6\x1D\xAA\xA1\xD5\e\x16#a\x1E\xF0F\xCF\xE1\t"
      ]
    )
  end
end
