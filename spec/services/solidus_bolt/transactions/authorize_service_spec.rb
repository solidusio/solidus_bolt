# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transactions::AuthorizeService, :vcr, :bolt_configuration do
  let(:credit_card_payload) do
    tokenize_credit_card(credit_card_number: '4111111111111004', cvv: '111').merge(
      expiration: (Time.current + 1.year).strftime('%Y-%m'),
      token_type: 'bolt'
    )
  end
  let(:order) { create(:order_with_line_items) }
  let(:payment_method) { create(:bolt_payment_method) }

  context 'without auto capture' do
    subject(:authorize) do
      described_class.call(
        order: order, credit_card: credit_card_payload, create_bolt_account: false, payment_method: payment_method
      )
    end

    describe '#call' do
      it 'makes the API call' do
        expect(authorize).to match hash_including('transaction')
      end
    end
  end

  context 'with auto capture' do
    subject(:authorize) do
      described_class.call(
        order: order,
        credit_card: credit_card_payload,
        create_bolt_account: false,
        payment_method: payment_method,
        auto_capture: true
      )
    end

    describe '#call', vcr: true do
      it 'makes the API call' do
        response = authorize

        expect(response).to match hash_including('transaction')
        expect(response['transaction']['status']).to eq 'pending'

        # The Authorize Call with auto_capture takes some time to update the state of the transaction from
        # pending to completed, hence the sleep is necessary to get the correct output from the API Call.

        sleep(1)

        reference = response['transaction']['reference']
        transaction_details = SolidusBolt::Transactions::DetailService.call(
          transaction_reference: reference, payment_method: payment_method
        )
        expect(transaction_details['status']).to eq 'completed'
      end
    end
  end
end
