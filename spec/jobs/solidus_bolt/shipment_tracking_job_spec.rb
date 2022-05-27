require 'spec_helper'

RSpec.describe SolidusBolt::ShipmentTrackingJob do
  subject(:shipment_tracking_job) {
    described_class.perform_now(transaction_reference: transaction_reference, shipment: shipment)
  }

  let(:shipment) { build(:shipment) }
  let(:transaction_reference) { 'Multiverse of Madness' }

  before { allow(SolidusBolt::Orders::TrackShipmentService).to receive(:call) }

  it 'calls the TrackShipmentService' do
    shipment_tracking_job
    expect(SolidusBolt::Orders::TrackShipmentService).to have_received(:call).with(
      transaction_reference: transaction_reference, shipment: shipment
    )
  end
end
