class ApplicationController < ActionController::Base
  def truelayer_payment
    @truelayer_payment ||= TrueLayerPayment.new
  end


  def truelayer_signin
    @truelayer_signin ||= TrueLayerSignup.new
  end

  def truelayer_auth
    @truelayer_auth ||= TrueLayerAuth.new
  end
end
