class SubscriptionMailer < ApplicationMailer
  def confirm(subscriber)
    @subscriber = subscriber
    mail(
      to: @subscriber.email,
      subject: "Please confirm your email address for your UW AgWeather subscription"
    )
  end

  def validation(subscriber)
    @subscriber = subscriber
    mail(
      to: @subscriber.email,
      subject: "UW AgWeather login validation code"
    )
  end

  def daily_mail(subscriber, date, data)
    @subscriber = subscriber
    @date = date
    @data = data
    @border = "1px solid #8b846a"
    @bg = "#e9e4d0"
    mail(
      to: @subscriber.email,
      subject: "UW AgWeather Daily Weather Report"
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
