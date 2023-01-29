require "test_helper"

class SubscriptionMailerTest < ActionMailer::TestCase
  USER_NAME = "Jane Smith"
  USER_EMAIL = "user@example.com"
  SENDER_EMAIL = "noreply@cals.wisc.edu"
  SITE_NAME = "Home"
  SITE_LAT = 42.0
  SITE_LON = -89.0
  ETS = [0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35]
  AGO_ET = 0.9
  AGO_REGEXP = /,0\.9<br\/>/
  DAYS_AGO = 10

  def setup
    @subscriber = Subscriber.create!(
      name: USER_NAME,
      email: USER_EMAIL,
      confirmation_token: 1234
    )
    @sites = Site.create!(
      name: SITE_NAME,
      latitude: SITE_LAT,
      longitude: SITE_LON,
      subscriber_id: @subscriber.id
    )
    @subscriber.sites << @sites
    @subscriber.save!
  end

  def days_back(ii)
    Date.today - (ii + 1)
  end

  test "confirm" do
    mail = SubscriptionMailer.confirm(@subscriber)
    assert_equal "Please confirm your email address for your UW AgWeather subscription", mail.subject
    assert_equal [USER_EMAIL], mail.to
    assert_equal [SENDER_EMAIL], mail.from
    assert_match "Dear #{USER_NAME}", mail.encoded
  end

  test "validation" do
    mail = SubscriptionMailer.validation(@subscriber)
    assert_equal "UW AgWeather login validation code", mail.subject
    assert_equal [USER_EMAIL], mail.to
    assert_equal [SENDER_EMAIL], mail.from
    assert_match "Dear #{USER_NAME},", mail.body.encoded
  end

  test "daily mail" do
    mail = SubscriptionMailer.daily_mail(@subscriber, Date.today, {})
    assert_equal "UW AgWeather Daily Weather Report", mail.subject
    assert_equal [USER_EMAIL], mail.to
    assert_equal [SENDER_EMAIL], mail.from
    assert_match "UW Extension Ag Weather Automated Mailer", mail.body.encoded
  end

  test "special" do
    mail = SubscriptionMailer.special(@subscriber, "")
    assert_equal "Update: Your UW AgWeather automated product subscription", mail.subject
    assert_equal [USER_EMAIL], mail.to
    assert_equal [SENDER_EMAIL], mail.from
    assert_match "Hi #{USER_NAME},", mail.body.encoded
  end
end
