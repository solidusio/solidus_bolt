require 'spec_helper'

RSpec.describe "Spree::Admin::Bolts", type: :request do
  stub_authorization!

  describe "GET /show" do
    it 'returns a successful response' do
      get '/admin/bolt'
      expect(response.status).to eq 200
    end

    it 'creates a new SolidusBolt::BoltConfiguration record if no records are present' do
      expect { get '/admin/bolt' }.to change { SolidusBolt::BoltConfiguration.count }.by(1)
    end
  end
end
