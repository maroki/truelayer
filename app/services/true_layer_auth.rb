# app/services/truelayer_service.rb
require 'httparty'

class TrueLayerAuth
  include HTTParty
  base_uri Rails.application.credentials.truelayer[:api_auth_base_url]

  def initialize
    @client_id = Rails.application.credentials.truelayer[:client_id]
    @client_secret = Rails.application.credentials.truelayer[:client_secret]
    @redirect_uri = Rails.application.credentials.truelayer[:redirect_uri]
  end

  def auth_link
    'https://auth.truelayer-sandbox.com/?response_type=code&client_id=sandbox-testcasino-3c9349&scope=payments%20info%20accounts%20balance%20cards%20transactions%20direct_debits%20standing_orders%20offline_access%20signupplus%20verification&redirect_uri=http://localhost:3000/truelayer/callback&providers=uk-cs-mock%20uk-ob-all%20uk-oauth-all'
  end

  # Get access token
  def get_access_token(code)
    options = {
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
      body: {
        grant_type: 'authorization_code',
        client_id: @client_id, # Настройки из переменных окружения
        client_secret: @client_secret,
        redirect_uri: @redirect_uri, # Тот же redirect_uri, что и для авторизации
        code: code
      }
    }


    response = self.class.post('/connect/token', options)
    raise "Error getting token: #{response.body}" unless response.success?

    JSON.parse(response.body)["access_token"]
  end
end
