require 'spec_helper'

RSpec.describe SolidusBolt::BoltConfiguration, type: :model do
  let(:column_list) {
    [
      'id',
      'environment',
      'api_key',
      'signing_secret',
      'publishable_key',
      'created_at',
      'updated_at'
    ]
  }

  describe '.fetch' do
    it 'fetches the correct record' do
      bolt_configuration = create(:bolt_configuration)
      expect(described_class.fetch).to eq(bolt_configuration)
    end

    it 'creates a bolt record when no record is present' do
      expect { described_class.fetch }.to change(described_class, :count).by(1)
    end
  end

  describe '.can_create?' do
    it 'returns true when no records are present' do
      expect(described_class).to be_can_create
    end

    it 'returns false when records are present' do
      create(:bolt_configuration)
      expect(described_class).not_to be_can_create
    end
  end

  describe '.config_empty?' do
    it 'is true for a new empty record' do
      described_class.fetch
      expect(described_class).to be_config_empty
    end

    it 'is true for a record with empty fields' do
      create(
        :bolt_configuration,
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

  describe '#merchant_public_id' do
    it 'returns the merchant_public_id' do
      bolt_configuration = create(:bolt_configuration, publishable_key: 'abc.def.ghi')
      expect(bolt_configuration.merchant_public_id).to eq('abc')
    end
  end

  describe '#division_public_id' do
    it 'returns the division_public_id' do
      bolt_configuration = create(:bolt_configuration, publishable_key: 'abc.def.ghi')
      expect(bolt_configuration.division_public_id).to eq('def')
    end
  end

  describe '#environment_url' do
    context 'when production envornment' do
      let(:config) { create(:bolt_configuration, environment: 'production') }

      it { expect(config.environment_url).to eq('https://api.bolt.com') }
    end

    context 'when sandbox envornment' do
      let(:config) { create(:bolt_configuration) }

      it { expect(config.environment_url).to eq('https://api-sandbox.bolt.com') }
    end

    context 'when staging envornment' do
      let(:config) { create(:bolt_configuration, environment: 'staging') }

      it { expect(config.environment_url).to eq('https://api-staging.bolt.com') }
    end
  end

  describe '#embed_js' do
    context 'when production envornment' do
      let(:config) { create(:bolt_configuration, environment: 'production') }

      it { expect(config.embed_js).to eq('https://connect.bolt.com/embed.js') }
    end

    context 'when sandbox envornment' do
      let(:config) { create(:bolt_configuration) }

      it { expect(config.embed_js).to eq('https://connect-sandbox.bolt.com/embed.js') }
    end

    context 'when staging envornment' do
      let(:config) { create(:bolt_configuration, environment: 'staging') }

      it { expect(config.embed_js).to eq('https://connect-sandbox.bolt.com/embed.js') }
    end

    context 'when initialized for the first time' do
      described_class.destroy_all
      let(:config) { described_class.fetch }

      it { expect(config.embed_js).to eq('https://connect-sandbox.bolt.com/embed.js') }
    end
  end

  describe '#account_js' do
    context 'when production environment' do
      let(:config) { create(:bolt_configuration, environment: 'production') }

      it { expect(config.account_js).to eq('https://connect.bolt.com/account.js') }
    end

    context 'when sandbox environment' do
      let(:config) { create(:bolt_configuration) }

      it { expect(config.account_js).to eq('https://connect-sandbox.bolt.com/account.js') }
    end

    context 'when staging environment' do
      let(:config) { create(:bolt_configuration, environment: 'staging') }

      it { expect(config.account_js).to eq('https://connect-sandbox.bolt.com/account.js') }
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

  describe 'after commit actions' do
    let(:config) {
      Spree::Config.static_model_preferences.for_class(SolidusBolt::PaymentMethod)['bolt_config_credentials']
    }

    it 'updates the Static Preferences of SolidusBolt::PaymentMethod' do
      create(:bolt_configuration)
      expect(config.fetch(:bolt_api_key)).to eq described_class.fetch.api_key

      described_class.fetch.update(environment: 'production')
      expect(config.fetch(:bolt_api_key)).to eq described_class.fetch.api_key
    end
  end
end
