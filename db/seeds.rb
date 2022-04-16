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

# Subscription types
WeatherSub.upsert({id: 1, name: "Weather"})
OakWiltSub.upsert({id: 2, name: "Oak Wilt"})

dds = []
dds << {id: 3, name: "DD 39.2/86F", options: {base: 39.2, upper: 86, units: "F"}}
dds << {id: 4, name: "DD 41/86F", options: {base: 41, upper: 86, units: "F"}}
dds << {id: 5, name: "DD 50/86F", options: {base: 50, upper: 86, units: "F"}}

dds.each do |opts|
  DegreeDaySub.upsert(opts)
end
