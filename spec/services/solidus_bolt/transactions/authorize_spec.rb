# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transactions::Authorize do
  subject(:authorize) { descrbied_class.call(order: order, credit_card: {}, create_bolt_account: false) }

  let(:order) { create(:order_with_line_items) }
  let(:httparty) { double(HTTParty) } # rubocop:disable RSpec/VerifiedDoubles

  describe '#call' do
    before do
      allow(httparty).to receive(:post)
      authorize
    end

    it 'makes an API call' do
      expect(httparty).to have_received(:post)
    end
  end
end
