# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Users::SyncPaymentSourcesService, :vcr, :bolt_configuration do
  subject(:sync_payment_sources) do
    described_class.call(user: user, access_token: ENV.fetch('BOLT_ACCESS_TOKEN', 'Fake_access_token'))
  end

  let(:user) { create(:user) }

  describe '#call' do
    it 'creates a new payment source with card ID' do
      expect { sync_payment_sources }.to change { SolidusBolt::PaymentSource.count }.by(1)
      bolt_payment_source = SolidusBolt::PaymentSource.last
      expect(bolt_payment_source.card_id).to be_present
      expect(bolt_payment_source.card_last4).to be_present
      expect(bolt_payment_source.card_expiration).to be_present
      expect(user.wallet_payment_sources.last.payment_source).to eq(bolt_payment_source)
    end
  end
end
