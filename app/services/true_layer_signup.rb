# app/services/truelayer_service.rb
require 'httparty'

class TrueLayerSignup
  include HTTParty
  base_uri Rails.application.credentials.truelayer[:api_signup_base_url]

  def initialize
    @client_id = Rails.application.credentials.truelayer[:client_id]
    @client_secret = Rails.application.credentials.truelayer[:client_secret]
    @redirect_uri = Rails.application.credentials.truelayer[:redirect_uri]
  end

  # Retrieve Signup+ identity data
  def fetch_user_identity(access_token, payment_id)
    options = {
      headers: {
        'Authorization' => "Bearer #{access_token}",
        'Tl-Trace-Id' => "#{SecureRandom.hex(4)}"
      },
      query: { payment_id: payment_id }
    }

    response = self.class.get('/payments', options)

    raise "Failed to fetch identity: #{response.body}" unless response.success?

    JSON.parse(response.body)
  end
end
