require 'spec_helper'

RSpec.describe SolidusBolt::PaymentSource, type: :model do
  let(:column_list) {
    [
      'id',
      'payment_method_id',
      'card_token',
      'card_last4',
      'card_bin',
      'card_number',
      'card_expiration',
      'card_postal_code',
      'card_id',
      'create_bolt_account',
      'created_at',
      'updated_at',
      'user_id'
    ]
  }

  describe 'Check Model Integrity' do
    it 'has correct table name' do
      expect(described_class.table_name).to eq 'solidus_bolt_payment_sources'
    end

    it 'has correct attributes' do
      expect(described_class.new.attributes.keys.sort).to eq column_list.sort
    end
  end
end
