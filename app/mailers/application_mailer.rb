class ApplicationMailer < ActionMailer::Base
  default(
    from: "AgWeather <noreply@cals.wisc.edu>",
    reply_to: "AgWeather <noreply@cals.wisc.edu>"
  )
end
