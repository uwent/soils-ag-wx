class ApplicationMailer < ActionMailer::Base
  default(
    from: "agweather@cals.wisc.edu",
    reply_to: "agweather@cals.wisc.edu"
  )
end
