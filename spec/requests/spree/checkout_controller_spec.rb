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

  describe 'PATCH /checkout/update/confirm' do
    subject(:confirm_order) { patch '/checkout/update/confirm' }

    let(:order) { FactoryBot.create(:order_with_totals) }
    let(:payment) { create(:payment, amount: order.total, order: order) }
    let(:session) { { bolt_access_token: access_token } }
    let(:access_token) { nil }

    before do
      # use test preparation from solidusio/solidus/frontend/spec/controllers/spree/checkout_controller_spec.rb
      # because Spree::TestingSupport::OrderWalkthrough.up_to(:confirm) doesn't work
      order.update! user: user
      order.update(state: 'confirm')
      payment
      order.create_proposed_shipments
      order.payments.reload

      # request calls Gateway#authorize - need to stub it to test our action
      allow(SolidusBolt::Transactions::AuthorizeService).to(receive(:call).and_return({
        'transaction' => { 'from_credit_card' => { 'id' => 'CreditCardId' } }
      }))

      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      # rubocop:enable RSpec/AnyInstance
    end

    it 'redirects to completion route' do
      confirm_order
      expect(response).to redirect_to spree.order_path(order)
    end

    context 'with logged in Bolt user and Bolt payment' do
      let(:access_token) { 'accesstoken' }
      let(:payment) { create(:bolt_payment, amount: order.total, order: order) }

      before { allow(SolidusBolt::Users::RefreshAccessTokenService).to receive(:call).and_return(access_token) }

      it 'calls the job to add addresses' do
        expect { confirm_order }.to(have_enqueued_job(SolidusBolt::AddAddressJob).twice.with { |hash|
          expect(hash[:order]).to eq(order)
          expect(hash[:access_token]).to eq(access_token)
          expect(user.addresses).to include(hash[:address])
        })
      end
    end

    context 'with logged in Bolt user' do
      let(:access_token) { 'accesstoken' }

      it 'skips the job call to add addresses' do
        expect { confirm_order }.not_to have_enqueued_job(SolidusBolt::AddAddressJob)
      end
    end

    context 'with Bolt payment' do
      let(:payment) { create(:bolt_payment, amount: order.total, order: order) }

      it 'skips the job call to add addresses' do
        expect { confirm_order }.not_to have_enqueued_job(SolidusBolt::AddAddressJob)
      end
    end
  end
end
