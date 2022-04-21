require 'spec_helper'

RSpec.describe SolidusBolt::BoltConfiguration, type: :model do
  let(:column_list) {
    [
      'id',
      'bearer_token',
      'environment_url',
      'merchant_public_id',
      'merchant_id',
      'api_key',
      'signing_secret',
      'publishable_key',
      'created_at',
      'updated_at'
    ]
  }

  describe '#fetch' do
    it 'fetches the correct record' do
      bolt_configuration = create(:bolt_configuration)
      expect(described_class.fetch).to eq(bolt_configuration)
    end

    it 'creates a bolt record when no record is present' do
      expect { described_class.fetch }.to change(described_class, :count).by(1)
    end
  end

  describe '#can_create?' do
    it 'returns true when no records are present' do
      expect(described_class).to be_can_create
    end

    it 'returns false when records are present' do
      create(:bolt_configuration)
      expect(described_class).not_to be_can_create
    end
  end

  describe '#config_empty?' do
    it 'is true for a new empty record' do
      described_class.fetch
      expect(described_class).to be_config_empty
    end

    it 'is true for a record with empty fields' do
      create(
        :bolt_configuration,
        bearer_token: '',
        environment_url: '',
        merchant_public_id: '',
        merchant_id: '',
        api_key: '',
        signing_secret: '',
        publishable_key: ''
      )
      expect(described_class).to be_config_empty
    end

    it 'is false for a record with data' do
      create(:bolt_configuration)
      expect(described_class).not_to be_config_empty
    end
  end

  describe 'validations' do
    it 'raises an error when there is an existing record and a new record is created' do
      create(:bolt_configuration)

      expect {
        create(:bolt_configuration)
      }.to raise_error(ActiveRecord::RecordInvalid,
        'Validation failed: Can create only one record for this Model')
    end

    it 'adds an error on :base when there is an existing record and a new record is created' do
      create(:bolt_configuration)

      expect(described_class.create.errors).to include(:base)
    end

    it 'gives a specific error message when there is an existing record and a new record is created' do
      create(:bolt_configuration)

      expect(described_class.create.errors[:base]).to include('Can create only one record for this Model')
    end

    it 'successfully creates a new record when no records are present' do
      expect { create(:bolt_configuration) }.to change(described_class, :count).by(1)
    end
  end
end
