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

    before do
      # use test preparation from solidusio/solidus/frontend/spec/controllers/spree/checkout_controller_spec.rb
      # because Spree::TestingSupport::OrderWalkthrough.up_to(:confirm) doesn't work
      order.update! user: user
      order.update(state: 'confirm')
      create(:payment, amount: order.total, order: order)
      order.create_proposed_shipments
      order.payments.reload

      allow(SolidusBolt::Accounts::AddAddressService).to receive(:call)

      patch '/checkout/update/confirm'
    end

    it 'redirects to completion route' do
      expect(response).to redirect_to spree.order_path(order)
    end

    it 'calls the service to add addresses' do
      expect(SolidusBolt::Accounts::AddAddressService).to have_received(:call).twice
    end
  end
end
