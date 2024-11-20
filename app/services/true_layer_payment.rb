# app/services/truelayer_service.rb
require 'httparty'

class TrueLayerPayment
  include HTTParty
  base_uri Rails.application.credentials.truelayer[:api_payment_base_url]
  BASE_URL = Rails.application.credentials.truelayer[:api_payment_base_url]

  def initialize
    @client_id = Rails.application.credentials.truelayer[:client_id]
    @client_secret = Rails.application.credentials.truelayer[:client_secret]
    @redirect_uri = Rails.application.credentials.truelayer[:redirect_uri]
    # @kid = kid
    @private_key = File.read('ec512-private-key.pem')
  end

  def create_payment(access_token:, amount:, currency:, reference:)
    # Step 2: Prepare request body
    body = {
      amount_in_minor: (amount.to_f * 100).to_i,
      currency: currency,
      payment_method: {
        type: "bank_transfer",
        provider_selection: {
          type: 'user_selected'
        },
        beneficiary: {
          type: "external_account",
          account_holder_name: "John Doe",
          reference: reference,
          account_identifier: {
            type: 'iban',
            iban: "GB33BUKB20201555555555" # Замените на свои данные
          },
          reference: reference
        }
      },
      user: {
        name: 'Unknown User',
        email: 'example@email.com',
        phone: '+38971545678'
      }
    }.to_json

    # Step 3: Generate TL-Signature
    TrueLayerSigning.certificate_id = "fdbfd9b8-e9aa-4d7c-949d-1408d394aed8" # KID
    TrueLayerSigning.private_key = @private_key

    tl_signature = TrueLayerSigning.sign_with_pem
                                   .set_method('POST')
                                   .set_path("/v3/payments")
                                   .add_header("Idempotency-Key", reference) # Headers to sign
                                   .set_body(body)                                 # JSON body
                                   .sign


    # Step 4: Make API call
    response = HTTParty.post(
      "#{BASE_URL}/v3/payments",
      headers: {
        "Authorization" => "Bearer #{access_token}",
        "Tl-Signature" => tl_signature,
        "Content-Type" => "application/json",
        "Idempotency-Key" => reference
      },
      body: body
    )

    unless response.success?
      raise "Payment creation failed: #{response.body}"
    end

    JSON.parse(response.body)
  end
end
