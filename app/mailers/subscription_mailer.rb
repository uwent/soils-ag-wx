class SubscriptionMailer < ActionMailer::Base
  default from: "do-not-reply@uwisc.edu"

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

  def product_report(subscriber,start_date,end_date,sent_at=Time.now,subscriptions=subscriber.subscriptions)
    @subscriber = subscriber
    @report = Subscription.make_report(subscriptions,start_date,end_date)
    @greeting = "Hi"
    mail to: @subscriber.email
  end

  def special(subscriber,mesg_text='')
    @greeting = "Hi"
    @mesg_text = mesg_text
    @subscriber = subscriber
    mail to: subscriber.email, subject: 'Update: Your UWEX Ag Weather automated product subscription'
  end
end
