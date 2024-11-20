# app/controllers/truelayer_controller.rb
class TruelayerController < ApplicationController

  def authorize
    redirect_to truelayer_auth.auth_link
  end

  # Шаг 2: Обрабатываем callback и сохраняем auth_code в сессию
  def callback
    if params[:code]
      session[:auth_code] = params[:code]
      redirect_to new_payment_path, notice: 'Авторизация прошла успешно. Заполните форму для создания платежа.'
    else
      redirect_to root_path, alert: 'Ошибка авторизации через TrueLayer.'
    end
  end

  private

  def process_identity(identity_data)
    # Implement KYC logic here
    true
  end
end
