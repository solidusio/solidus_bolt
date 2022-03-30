require 'spec_helper'

RSpec.describe SolidusBolt::Gateway, type: :model do
  describe '#authorize' do
    it 'raises NotImplementedError' do
      expect { described_class.new.authorize(nil, nil, nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#capture' do
    it 'raises NotImplementedError' do
      expect { described_class.new.capture(nil, nil, nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#void' do
    it 'raises NotImplementedError' do
      expect { described_class.new.void(nil, nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#credit' do
    it 'raises NotImplementedError' do
      expect { described_class.new.credit(nil, nil, nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#purchase' do
    it 'raises NotImplementedError' do
      expect { described_class.new.purchase(nil, nil, nil) }.to raise_error(NotImplementedError)
    end
  end
end
