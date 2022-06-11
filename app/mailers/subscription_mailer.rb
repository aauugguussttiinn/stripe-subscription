class SubscriptionMailer < ApplicationMailer
  default from: "test@test.com"
  
  def payment_failed
    @user = params[:user]

    mail(to: @user.email, subject: "Payment attempt failed")

  end
end
