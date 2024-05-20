class ApplicationMailer < ActionMailer::Base
  default(
    from: "AgWeather <agweather@cals.wisc.edu>",
    reply_to: "No Reply <noreply@cals.wisc.edu>"
  )
end
