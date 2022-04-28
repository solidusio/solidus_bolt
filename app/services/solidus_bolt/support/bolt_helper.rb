# frozen_string_literal: true

module SolidusBolt
  module Support
    module BoltHelper
      PUBLIC_KEY_URL = 'https://sandbox.bolttk.com/public_key'
      TOKEN_URL = 'https://sandbox.bolttk.com/token'

      def tokenize_credit_card(cc:, cvv:)
        request_body = encryptRequestBody(cc, cvv)
        response = make_request(request_body)
        JSON.parse(decryptRequestBody(response))
      end

      def public_key
        @public_key ||= HTTParty.get(URI.parse(PUBLIC_KEY_URL)).body
      end

      def nonce
        @nonce ||= rand(10 ** 24).to_s.rjust(24,'0')
      end

      def keys
        @keys ||= TweetNaCl.crypto_box_keypair
      end

      def make_request(encrypted_request_body)
        HTTParty.post(
          TOKEN_URL,
          {
            body: JSON.dump(encrypted_request_body),
            headers: {
              'Content-Type' => 'application/json'
            }
          }
        )
      end

      def encryptRequestBody(cc, cvv)
        message = { cc: cc, cvv: cvv }.to_json

        payload = TweetNaCl.crypto_box(
          message,
          nonce,
          Base64.decode64(public_key),
          keys[1]
        )

        {
          payload: Base64.encode64(payload),
          nonce: Base64.encode64(nonce),
          public_key: Base64.encode64(keys[0])
        }
      end

      def decryptRequestBody(response)
        parsed_response = JSON.parse(response.body)

        TweetNaCl.crypto_box_open(
          Base64.decode64(parsed_response['payload']),
          Base64.decode64(parsed_response['nonce']),
          Base64.decode64(public_key),
          keys[1]
        )
      end
    end
  end
end
