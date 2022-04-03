class SubscriptionMailer < ApplicationMailer
  def confirm(subscriber)
    @subscriber = subscriber
    @url = confirm_subscriber_url(@subscriber, token: @subscriber.confirmation_token)
    mail(
      to: @subscriber.email,
      subject: "Please confirm your email address for your UW AgWeather subscription"
    )
  end

  def validation(subscriber)
    @subscriber = subscriber
    @url = confirm_subscriber_url(@subscriber, token: @subscriber.confirmation_token)
    mail(
      to: @subscriber.email,
      subject: "UW AgWeather subscription validation code"
    )
  end

  def daily_mail(subscriber, date, data)
    @subscriber = subscriber
    @date = date
    @data = data
    mail(
      to: @subscriber.email,
      subject: "UW AgWeather ET Mailer Report"
    )
  end

  def special(subscriber, mesg_text = "")
    @greeting = "Hi"
    @mesg_text = mesg_text
    @subscriber = subscriber
    mail(
      to: @subscriber.email,
      subject: "Update: Your UW AgWeather automated product subscription"
    )
  end
end
