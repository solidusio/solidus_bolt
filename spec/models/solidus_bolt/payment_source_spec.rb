require 'spec_helper'

RSpec.describe SolidusBolt::PaymentSource, type: :model do
  let(:column_list) {
    [
      'id',
      'payment_method_id',
      'transaction_id',
      'transaction_reference',
      'transaction_type',
      'processor',
      'date',
      'transaction_status',
      'amount',
      'currency',
      'created_at',
      'updated_at'
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

  describe 'transaction_reference' do
    context 'when transaction_reference is not present' do
      it 'has invalid object' do
        object = described_class.new
        expect(object.valid?).to eq(false)
      end

      it 'has an error' do
        object = described_class.new
        object.valid?
        expect(object.errors[:transaction_reference]).to eq(["can't be blank"])
      end
    end

    context 'when transaction_reference is present' do
      it 'successfully creates a record' do
        expect do
          object = described_class.new({ transaction_reference: 'Iron Man' })
          object.save!
        end.to change(described_class, :count).by(1)
      end
    end
  end
end
