# frozen_string_literal: true

module SolidusBolt
  module Handlers
    class VoidHandler < BaseHandler
      def call
        SolidusBolt::Payments::VoidSyncService.call(payment: payment)
      end
    end
  end
end
