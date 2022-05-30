# frozen_string_literal: true

module SolidusBolt
  module Webhooks
    class CreateService < SolidusBolt::BaseService
      attr_reader :division_public_id, :event, :url

      def initialize(event:, url:)
        @event = event
        @url = url
        @division_public_id = SolidusBolt::BoltConfiguration.fetch.division_public_id
        super
      end

      def call
        create
      end

      private

      def create
        options = build_options
        handle_result(
          HTTParty.post(
            "#{api_base_url}/#{api_version}/webhooks",
            options
          )
        )
      end

      def build_options
        {
          body: {
            division_id: division_public_id,
            url: url
          }.merge(event_fields).to_json,
          headers: {
            'Content-Type' => 'application/json'
          }.merge(authentication_header)
        }
      end

      def event_fields
        if event == 'all'
          { event_group: event }
        else
          { events: [event] }
        end
      end
    end
  end
end
