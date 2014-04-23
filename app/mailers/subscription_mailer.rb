class SubscriptionMailer < ActionMailer::Base
  default from: "fewayne@wisc.edu"
  
  def old_confirm(subscriber,sent_at = Time.now)
    subject    'Please confirm your email address for your UWEX Ag Weather product subscriptions'
    recipients subscriber.email
    from       'fewayne@wisc.edu'
    sent_on    sent_at
    
    body       :greeting => 'Hi,', :subscriber => subscriber
  end

  def old_product_report(subscriber,start_date,finish_date,sent_at=Time.now,subscriptions=subscriber.subscriptions)
    subject    'Your UWEX Ag Weather automated product subscription'
    recipients subscriber.email
    from       'fewayne@wisc.edu'
    sent_on    sent_at
    
    report = Subscription.make_report(subscriptions,start_date,finish_date)
    
    body       :greeting => 'Hi,', :subscriber => subscriber, :report => report
  end
  
  def old_special(subscriber,message)
    subject    'Update: Your UWEX Ag Weather automated product subscription'
    recipients subscriber.email
    from       'fewayne@wisc.edu'
    sent_on Time.now
    body :greeting => "Dear UWEX Ag Wx Subscriber", :subscriber => subscriber, :message => message
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscription_mailer.confirm.subject
  #
  def confirm(subscriber)
    @greeting = "Hi"
    @subscriber = subscriber
    if Rails.env == 'test'
      host = 'localhost'
    else
      host = 'agwx.soils.wisc.edu'
    end
    @url = url_for host: host, controller: 'subscribers', action: 'confirm', id: @subscriber[:id], confirmed: @subscriber.confirmed
    mail to: subscriber.email, subject: 'Please confirm your email address for your UWEX Ag Weather product subscriptions'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscription_mailer.product_report.subject
  #
  def product_report
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscription_mailer.special.subject
  #
  def special(subscriber,mesg_text='')
    @greeting = "Hi"
    @mesg_text = mesg_text
    @subscriber = subscriber
    mail to: subscriber.email, subject: 'Update: Your UWEX Ag Weather automated product subscription'
  end
end
