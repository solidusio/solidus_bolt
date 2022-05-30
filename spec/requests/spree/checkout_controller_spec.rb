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
      allow(SolidusBolt::Transactions::AuthorizeService).to receive(:call).and_return({ 'transaction' => {} })
      allow(SolidusBolt::Accounts::AddAddressService).to receive(:call)

      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      # rubocop:enable RSpec/AnyInstance

      patch '/checkout/update/confirm'
    end

    it 'redirects to completion route' do
      expect(response).to redirect_to spree.order_path(order)
    end

    context 'with logged in Bolt user and Bolt payment' do
      let(:access_token) { 'accesstoken' }
      let(:payment) { create(:bolt_payment, amount: order.total, order: order) }

      it 'calls the service to add addresses' do
        user.addresses.each do |address|
          expect(SolidusBolt::Accounts::AddAddressService).to have_received(:call).with(
            order: order, address: address, access_token: 'accesstoken'
          )
        end
      end
    end

    context 'with logged in Bolt user' do
      let(:access_token) { 'accesstoken' }

      it 'skips the service call to add addresses' do
        expect(SolidusBolt::Accounts::AddAddressService).not_to have_received(:call)
      end
    end

    context 'with Bolt payment' do
      let(:payment) { create(:bolt_payment, amount: order.total, order: order) }

      it 'skips the service call to add addresses' do
        expect(SolidusBolt::Accounts::AddAddressService).not_to have_received(:call)
      end
    end
  end
end
