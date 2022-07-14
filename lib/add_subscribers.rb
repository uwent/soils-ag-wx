# this may not work with the new subscription framework

filename = "/home/deploy/soil_subs.csv"

File.foreach(filename) do |line|
  (name, email, field_name, lat, long) = line.split('|')

  s = Subscriber.where(email: email).first
  if s.nil?
    s = Subscriber.create(name: name, email: email, confirmed_at: Time.now)
    s.save!
  end

  s.sites.create(
    name: field_name,
    latitude: lat.to_f,
    longitude: long.to_f
  )
end
