class SubscriptionMailer < ApplicationMailer
  def confirm(subscriber)
    @subscriber = subscriber
    @url = confirm_subscriber_url(@subscriber, token: @subscriber.confirmation_token)
    mail to: subscriber.email, subject: "Please confirm your email address for your UW Ag Weather subscription"
  end

  def validation(subscriber)
    @subscriber = subscriber
    @url = confirm_subscriber_url(@subscriber, token: @subscriber.confirmation_token)
    mail to: subscriber.email, subject: "UW Ag Weather subscription validation code"
  end

  def daily_mail(subscriber, date, values)
    @subscriber = subscriber
    @values = values
    @date = date
    @greeting = "Hi"
    mail to: @subscriber.email, subject: "UW Ag Weather ET Mailer Report"
  end

  def special(subscriber, mesg_text = "")
    @greeting = "Hi"
    @mesg_text = mesg_text
    @subscriber = subscriber
    mail to: subscriber.email, subject: "Update: Your UW Ag Weather automated product subscription"
  end
end
