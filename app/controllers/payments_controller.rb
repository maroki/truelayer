class PaymentsController < ApplicationController
  # Шаг 3: Форма для создания платежа
  def new
  end

  # Шаг 4: Обработка формы и создание платежа
  def create
    auth_code = session[:auth_code]
    if auth_code.nil?
      redirect_to truelayer_authorize_path, alert: 'Сначала пройдите авторизацию.'
      return
    end

    token_response = truelayer_auth.get_access_token(auth_code)

    if token_response
      amount = params[:amount].to_f
      currency = params[:currency]
      reference = "#{SecureRandom.hex(4)}" # Unique reference for the payment link


      # Запрос к TrueLayer для создания платежа
      payment_response = truelayer_payment.create_payment(
        access_token: token_response, amount: amount, currency: currency, reference: reference
      )

      if payment_response['id']
        # Вызов SingUp+ KYC
        binding.pry

        truelayer_signin.fetch_user_identity(token_response, payment_response['id'])
        redirect_to payment_path(@payment), notice: 'Платеж успешно создан.'
      else
        redirect_to new_payment_path, alert: 'Ошибка при создании платежа.'
      end
    else
      redirect_to truelayer_authorize_path, alert: 'Не удалось получить access_token.'
    end
  end
end
