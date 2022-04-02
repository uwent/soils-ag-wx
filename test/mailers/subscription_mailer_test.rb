require "test_helper"

class SubscriptionMailerTest < ActionMailer::TestCase
  USER_EMAIL = "user@example.com"
  SENDER_EMAIL = "agweather@cals.wisc.edu"
  USER = "Jane Smith"
  LATITUDE = 42.0
  LONGITUDE = -89.0
  ETS = [0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35]
  AGO_ET = 0.9
  AGO_REGEXP = /,0\.9<br\/>/
  DAYS_AGO = 10

  def setup
    @etgrid = Product.create!(
      name: "ET",
      data_table_name: "wi_mn_dets",
      type: "GridProduct",
      subscribable: true
    )
    @rick = Subscriber.create!(
      name: USER,
      email: USER_EMAIL,
      confirmation_token: Subscriber.confirmation_number
    )
    @rick_subs = Subscription.create!(
      latitude: LATITUDE,
      longitude: LONGITUDE,
      product_id: GridProduct.first[:id],
      doy_start: 1,
      doy_end: 365,
      subscriber_id: @rick.id
    )
    ETS.each_with_index { |et, ii| WiMnDet.create!(date: days_back(ii), latitude: LATITUDE, w892: et) }
    WiMnDet.create!(date: days_back(DAYS_AGO), latitude: LATITUDE, w892: AGO_ET)
    @rick.subscriptions << @rick_subs
    @rick.save!
  end

  def days_back(ii)
    Date.today - (ii + 1)
  end

  test "confirm" do
    mail = SubscriptionMailer.confirm(@rick)
    assert_equal "Please confirm your email address for your UW AgWeather subscription", mail.subject
    assert_equal [USER_EMAIL], mail.to
    assert_equal [SENDER_EMAIL], mail.from
    assert_match "\r\n\r\nDear Jane Smith", mail.encoded
  end

  test "validation" do
    mail = SubscriptionMailer.validation(@rick)
    assert_equal "UW AgWeather subscription validation code", mail.subject
    assert_equal [USER_EMAIL], mail.to
    assert_equal [SENDER_EMAIL], mail.from
    assert_match "Dear AgWeather Subscriber,", mail.body.encoded
  end

  test "daily mail" do
    mail = SubscriptionMailer.daily_mail(@rick, Date.today, [])
    assert_equal "UW AgWeather ET Mailer Report", mail.subject
    assert_equal [USER_EMAIL], mail.to
    assert_equal [SENDER_EMAIL], mail.from
    assert_match "AgWeather automated mailer", mail.body.encoded
  end

  test "special" do
    mail = SubscriptionMailer.special(@rick, "")
    assert_equal "Update: Your UW AgWeather automated product subscription", mail.subject
    assert_equal [USER_EMAIL], mail.to
    assert_equal [SENDER_EMAIL], mail.from
    assert_match "Hi Jane Smith,\r\n\r\n", mail.body.encoded
  end
end
