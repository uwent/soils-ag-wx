class ApplicationMailer < ActionMailer::Base
  default(
    from: "agweather@cals.wisc.edu",
    reply_to: "noreply@cals.wisc.edu"
  )
end
