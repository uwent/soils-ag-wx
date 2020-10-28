class SubscriptionMailer < ApplicationMailer
  def confirm(subscriber)
    @subscriber = subscriber
    @url = confirm_subscriber_url(@subscriber, token: @subscriber.confirmation_token)
    mail to: subscriber.email, subject: 'Please confirm your email address for UWEX Ag Weather subscription'
  end

  def validation(subscriber)
    @subscriber = subscriber
    @url = confirm_subscriber_url(@subscriber, token: @subscriber.confirmation_token)
    mail to: subscriber.email, subject: 'UWEX Ag Weather subscription validation code'
  end

  def daily_mail(subscriber, date, values)
    @subscriber = subscriber
    @values = values
    @date = date
    @greeting = "Hi"
    mail to: @subscriber.email, subject: 'AGWX ET Mailer Report'
  end

  def special(subscriber,mesg_text='')
    @greeting = "Hi"
    @mesg_text = mesg_text
    @subscriber = subscriber
    mail to: subscriber.email, subject: 'Update: Your UWEX Ag Weather automated product subscription'
  end
end
