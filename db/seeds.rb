# Default AWON stations
AwonStation.upsert(
  {
    stnid: 4751,
    name: "Hancock",
    abbrev: "HAN",
    county: "",
    latitude: 44.12,
    longitude: -89.53,
    status: true,
    wind: true,
    humidity: true,
    has_401: true,
    has_403: true,
    has_404: true,
    has_411: true,
    has_412: true
  },
  unique_by: :stnid
)

AwonStation.upsert(
  {
    stnid: 4781,
    name: "Arlington",
    abbrev: "ARL",
    county: "",
    latitude: 43.31,
    longitude: -89.38,
    status: true,
    wind: true,
    humidity: true,
    has_401: false,
    has_403: true,
    has_411: true,
    has_412: true,
    has_404: false
  },
  unique_by: :stnid
)

## Subscriptions ##
subs = []

# Weather subscriptions
subs << WeatherSub.upsert({id: 1, name: "7-day weather"})
subs << ForecastSub.upsert({id: 2, name: "5-day forecast"})

# Degree day subscriptions
subs << DegreeDaySub.upsert_all([
  {id: 32, name: "Base 32°F", options: {base: 32, upper: 86, units: "F"}},
  {id: 39, name: "Base 39.2°F", options: {base: 39.2, upper: 86, units: "F"}},
  {id: 41, name: "Base 41°F", options: {base: 41, upper: 86, units: "F"}},
  {id: 50, name: "Base 50°F", options: {base: 50, upper: 86, units: "F"}},
  {id: 52, name: "Base 52°F", options: {base: 52, upper: 86, units: "F"}}
])

# Pest subscriptions
subs << OakWiltSub.upsert({id: 100, name: "Oak wilt risk"})

# clear out old subscriptions
valid_subs = subs.collect { |s| s.rows }.flatten
Subscription.where.not(id: valid_subs).destroy_all
