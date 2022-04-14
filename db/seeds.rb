# Fill the WiMnDAveTAirs grid with 2002 data (clone of import_grid.rb)
# min_path = File.join(File.dirname(__FILE__), "WIMNTMin2002")
# WiMnDAveTAir.import_grid(min_path, 2002)

# Product.create!(
#   name: "Cranberry Consumptive Water Use",
#   data_table_name: "wi_mn_dets",
#   type: "GridProduct",
#   subscribable: true,
#   default_doy_start: 91,
#   default_doy_end: 273)

# Product.create!(
#   name: "Evapotranspiration",
#   data_table_name: "wi_mn_dets",
#   type: "GridProduct",
#   subscribable: true,
#   default_doy_start: 91,
#   default_doy_end: 273
# )

AwonStation.create(
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
)

AwonStation.create(
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
)
