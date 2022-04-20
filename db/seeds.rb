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

# Weather subscriptions
WeatherSub.upsert({id: 10, name: "7-day weather"})

# Degree day subscriptions
DegreeDaySub.upsert({id: 20, name: "DD 32/86 F", options: {base: 32, upper: 86, units: "F"}})
DegreeDaySub.upsert({id: 30, name: "DD 39.2/86 F", options: {base: 39.2, upper: 86, units: "F"}})
DegreeDaySub.upsert({id: 40, name: "DD 41/86 F", options: {base: 41, upper: 86, units: "F"}})
DegreeDaySub.upsert({id: 50, name: "DD 50/86 F", options: {base: 50, upper: 86, units: "F"}})

# Pest subscriptions
OakWiltSub.upsert({id: 60, name: "Oak wilt risk"})
