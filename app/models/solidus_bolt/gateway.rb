# frozen_string_literal: true

module SolidusBolt
  class Gateway
    def initialize(options = {}); end

    def authorize(_amount, _payment_source, _gateway_options)
      raise NotImplementedError, 'authorize method has not been implemented in SolidusBolt::Gateway class'
    end

    def capture(_float_amount, _response_code, _gateway_options)
      raise NotImplementedError, 'capture method has not been implemented in SolidusBolt::Gateway class'
    end

    def void(_response_code, _gateway_options)
      raise NotImplementedError, 'void method has not been implemented in SolidusBolt::Gateway class'
    end

    def credit(_amount, _response_code, _gateway_options)
      raise NotImplementedError, 'credit method has not been implemented in SolidusBolt::Gateway class'
    end

    def purchase(_float_amount, _response_code, _gateway_options)
      raise NotImplementedError, 'purchase method has not been implemented in SolidusBolt::Gateway class'
    end
  end
end
