# frozen_string_literal: true

module SolidusBolt
  module BoltHelper
    PUBLIC_KEY_URL = 'https://sandbox.bolttk.com/public_key'
    TOKEN_URL = 'https://sandbox.bolttk.com/token'

    def tokenize_credit_card(credit_card_number:, cvv:)
      request_body = encrypt_request_body(credit_card_number, cvv)
      response = make_request(request_body)
      JSON.parse(decrypt_response_body(response))
    end

    def public_key
      @public_key ||= HTTParty.get(URI.parse(PUBLIC_KEY_URL)).body
    end

    def nonce
      @nonce ||= rand(10**24).to_s.rjust(24, '0')
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

    def encrypt_request_body(credit_card_number, cvv)
      message = { cc: credit_card_number, cvv: cvv }.to_json

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

    def decrypt_response_body(response)
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
