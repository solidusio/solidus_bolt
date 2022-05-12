# frozen_string_literal: true

module SolidusBolt
  class Gateway
    def initialize(options = {}); end

    def authorize(_amount, payment_source, gateway_options)
      order_number = gateway_options[:order_id].split('-').first
      order = Spree::Order.find_by(number: order_number)

      authorization_response = ::SolidusBolt::Transactions::AuthorizeService.call(
        order: order,
        create_bolt_account: payment_source.create_bolt_account,
        credit_card: credit_card_params(payment_source),
        payment_method: payment_source.payment_method
      )

      ActiveMerchant::Billing::Response.new(true, 'Transaction approved', payment_source.attributes,
        authorization: authorization_response['transaction']['reference'])
    rescue ServerError => e
      ActiveMerchant::Billing::Response.new(false, e, {})
    end

    def capture(float_amount, response_code, gateway_options)
      payment = gateway_options[:originator]
      payment_source = payment.source
      payment_method = payment.payment_method
      currency = gateway_options[:currency]

      capture_response = SolidusBolt::Transactions::CaptureService.call(
        transaction_reference: response_code,
        amount: float_amount,
        currency: currency,
        payment_method: payment_method
      )

      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction Captured', payment_source.attributes,
        authorization: capture_response['reference']
      )
    rescue ServerError => e
      ActiveMerchant::Billing::Response.new(false, e, {})
    end

    def void(response_code, gateway_options)
      payment = gateway_options[:originator]
      payment_source = payment.source
      payment_method = payment.payment_method

      void_response = SolidusBolt::Transactions::VoidService.call(
        transaction_reference: response_code,
        payment_method: payment_method
      )

      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction Void', payment_source.attributes,
        authorization: void_response['reference']
      )
    rescue ServerError => e
      ActiveMerchant::Billing::Response.new(false, e, {})
    end

    def credit(_amount, _response_code, _gateway_options)
      raise NotImplementedError, 'credit method has not been implemented in SolidusBolt::Gateway class'
    end

    def purchase(_float_amount, _response_code, _gateway_options)
      raise NotImplementedError, 'purchase method has not been implemented in SolidusBolt::Gateway class'
    end

    private

    def credit_card_params(payment_source)
      card_params = { token_type: 'bolt' }

      payment_source.attributes.each do |k, v|
        next unless k.include?('card_')

        card_params[k.gsub('card_', '').to_sym] = v unless v.nil?
      end

      card_params
    end
  end
end
