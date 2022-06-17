require 'spec_helper'

RSpec.describe "Spree::CheckoutController", type: :request do
  stub_authorization!

  let(:user) { create(:user_with_addresses) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Spree::CheckoutController).to receive(:current_order).and_return(order)
    allow_any_instance_of(Spree::CheckoutController).to receive(:spree_current_user).and_return(user)
    allow_any_instance_of(SolidusBolt::BoltConfiguration).to(
      receive(:embed_js).and_return('https://connect-sandbox.bolt.com/embed.js')
    )
    # rubocop:enable RSpec/AnyInstance
  end

  describe "GET /checkout/address" do
    let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:address) }

    before { allow(SolidusBolt::Users::SyncAddressesService).to receive(:call) }

    it 'returns a successful response' do
      get '/checkout/address'

      expect(response.status).to eq 200
    end

    it 'calls the service to sync addresses' do
      get '/checkout/address'

      expect(SolidusBolt::Users::SyncAddressesService).to have_received(:call)
    end
  end

  describe 'GET /checkout/delivery' do
    subject(:deliver_order) { get '/checkout/delivery' }

    let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:delivery) }
    let(:bolt_expiration_time) { Time.now.utc + 15.minutes }
    let(:access_token) { 'access_token' }
    let(:bolt_scope) { 'bolt.account.view openid' }
    let!(:session) do
      { bolt_access_token: access_token, bolt_expiration_time: bolt_expiration_time, bolt_scope: bolt_scope }
    end

    before do
      order.update! user: user

      allow(SolidusBolt::Users::SyncPaymentSourcesService).to receive(:call)

      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      # rubocop:enable RSpec/AnyInstance
    end

    context 'without bolt session' do
      let(:access_token) { nil }

      it 'returns a successful response' do
        deliver_order

        expect(response.status).to eq 200
      end

      it 'skips the job call to add addresses' do
        expect { deliver_order }.not_to have_enqueued_job(SolidusBolt::AddAddressJob)
      end
    end

    context 'with valid bolt_access token' do
      it 'returns a successful response' do
        deliver_order

        expect(response.status).to eq 200
      end

      it 'calls the job to add addresses' do
        expect { deliver_order }.to(have_enqueued_job(SolidusBolt::AddAddressJob).twice.with { |hash|
          expect(hash[:order]).to eq(order)
          expect(hash[:access_token]).to eq(access_token)
          expect(user.addresses).to include(hash[:address])
        })
      end
    end

    context 'with expired bolt_access token' do
      include Devise::Test::IntegrationHelpers

      let(:bolt_expiration_time) { Time.now.utc - 15.minutes }

      before { sign_in(order.user) }

      it 'stores the sign in location' do
        deliver_order

        expect(session[:spree_user_return_to]).to eq('/checkout/delivery')
      end

      it 'signs out the user' do
        deliver_order

        expect(controller.spree_user_signed_in?).to be false
      end

      it 'skips the job call to add addresses' do
        expect { deliver_order }.not_to have_enqueued_job(SolidusBolt::AddAddressJob)
      end
    end

    context 'with refreshed access_token' do
      include Devise::Test::IntegrationHelpers

      let(:bolt_scope) { 'bolt.account.view' }

      before { sign_in(order.user) }

      it 'stores the sign in location' do
        deliver_order

        expect(session[:spree_user_return_to]).to eq('/checkout/delivery')
      end

      it 'signs out the user' do
        deliver_order

        expect(controller.spree_user_signed_in?).to be false
      end

      it 'skips the job call to add addresses' do
        expect { deliver_order }.not_to have_enqueued_job(SolidusBolt::AddAddressJob)
      end
    end
  end

  describe "GET /checkout/payment" do
    let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:payment) }

    before { allow(SolidusBolt::Users::SyncPaymentSourcesService).to receive(:call) }

    it 'returns a successful response' do
      get '/checkout/payment'

      expect(response.status).to eq 200
    end

    it 'calls the service to sync payment sources' do
      get '/checkout/payment'

      expect(SolidusBolt::Users::SyncPaymentSourcesService).to have_received(:call)
    end
  end
end
