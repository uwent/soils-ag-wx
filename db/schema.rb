# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_01_17_203834) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "awon_field_descrips", id: :serial, force: :cascade do |t|
    t.integer "rec_id"
    t.integer "column_num"
    t.string "field_name"
    t.string "field_abbrev"
    t.string "units"
    t.integer "decimals"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "awon_record_types", id: :serial, force: :cascade do |t|
    t.integer "rec_id"
    t.string "rec_name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "awon_stations", id: :serial, force: :cascade do |t|
    t.integer "stnid"
    t.string "name"
    t.string "abbrev"
    t.string "county"
    t.float "latitude"
    t.float "longitude"
    t.boolean "status"
    t.boolean "wind"
    t.boolean "humidity"
    t.boolean "has_401"
    t.boolean "has_403"
    t.boolean "has_411"
    t.boolean "has_412"
    t.boolean "has_404"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["stnid"], name: "index_awon_stations_on_stnid", unique: true
  end

  create_table "hyds", id: :serial, force: :cascade do |t|
    t.date "date"
    t.string "stn"
    t.string "county"
    t.string "name"
    t.float "max_temp"
    t.float "min_temp"
    t.float "pcpn"
    t.float "new_snow"
    t.float "snow_depth"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "site_subscriptions", force: :cascade do |t|
    t.integer "site_id"
    t.integer "subscription_id"
    t.index ["site_id", "subscription_id"], name: "index_site_subscriptions_on_site_id_and_subscription_id", unique: true
  end

  create_table "sites", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "subscriber_id"
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "enabled", default: true
    t.index ["subscriber_id", "latitude", "longitude"], name: "index_sites_on_subscriber_id_and_latitude_and_longitude", unique: true
  end

  create_table "subscribers", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "auth_token"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "confirmed_at", precision: nil
    t.string "validation_token"
    t.datetime "validation_created_at", precision: nil
    t.boolean "admin", default: false
    t.integer "doy_start"
    t.integer "doy_end"
    t.boolean "emails_enabled", default: true, null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.jsonb "options"
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "t401s", id: :serial, force: :cascade do |t|
    t.integer "awon_station_id"
    t.date "date"
    t.integer "time"
    t.float "M5Pcpn"
    t.float "M5Pcpn2"
    t.float "M5Wind"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "t403s", id: :serial, force: :cascade do |t|
    t.integer "awon_station_id"
    t.date "date"
    t.integer "time"
    t.float "HToPcpn"
    t.float "HAvSol"
    t.float "HAvTAir"
    t.float "HAvRHum"
    t.float "HAvTS05"
    t.float "HAvTS10"
    t.float "HAvTS50"
    t.float "HPkWind"
    t.float "HAvWind"
    t.float "HRsWind"
    t.float "HRsDir"
    t.float "HDvDir"
    t.float "HAvPAR"
    t.float "HMxWnd1"
    t.float "HAvTDew"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "t406s", id: :serial, force: :cascade do |t|
    t.integer "awon_station_id"
    t.date "date"
    t.integer "time"
    t.float "HhToPcpn"
    t.float "HhAvSol"
    t.float "HhAvTAir"
    t.float "HhAvRHum"
    t.float "HhAvTS05"
    t.float "HhAvTS10"
    t.float "HhAvTS50"
    t.float "HhPkWind"
    t.float "HhAvWind"
    t.float "HhRsWind"
    t.float "HhRsDir"
    t.float "HhDvDir"
    t.float "HhAvPAR"
    t.float "HhMxWnd1"
    t.float "HhAvTDew"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "t411s", id: :serial, force: :cascade do |t|
    t.integer "awon_station_id"
    t.date "date"
    t.integer "time"
    t.float "DMnBatt"
    t.float "DToPcpn"
    t.float "DAvSol"
    t.float "DAvTAir"
    t.float "DMxTAir"
    t.float "DTxTAir"
    t.float "DMnTAir"
    t.float "DTnTAir"
    t.float "DAvRHum"
    t.float "DMxRHum"
    t.float "DTxRHum"
    t.float "DMnRHum"
    t.float "DTnRHum"
    t.float "DAvVPre"
    t.float "DAvVDef"
    t.float "DPkWind"
    t.float "DTkWind"
    t.float "DAvWind"
    t.float "DRsWind"
    t.float "DRsDir"
    t.float "DDvDir"
    t.float "DAvPAR"
    t.float "DMxWnd1"
    t.float "DTxWnd1"
    t.float "DMxDir1"
    t.float "DAvTdew"
    t.float "DMxTdew"
    t.float "DTxTdew"
    t.float "DMnTdew"
    t.float "DTnTdew"
    t.float "DRefET"
    t.float "DPctClr"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "t412s", id: :serial, force: :cascade do |t|
    t.integer "awon_station_id"
    t.date "date"
    t.integer "time"
    t.float "DAvTS05"
    t.float "DMxTS05"
    t.float "DTxTS05"
    t.float "DMnTS05"
    t.float "DTnTS05"
    t.float "DAvTS10"
    t.float "DMxTS10"
    t.float "DTxTS10"
    t.float "DMnTS10"
    t.float "DTnTS10"
    t.float "DAvTS50"
    t.float "DMxTS50"
    t.float "DTxTS50"
    t.float "DMnTS50"
    t.float "DTnTS50"
    t.float "DAvTS1m"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "wi_mn_d_ave_t_airs", id: :serial, force: :cascade do |t|
    t.date "date"
    t.time "time"
    t.float "latitude"
    t.float "w980"
    t.float "w976"
    t.float "w972"
    t.float "w968"
    t.float "w964"
    t.float "w960"
    t.float "w956"
    t.float "w952"
    t.float "w948"
    t.float "w944"
    t.float "w940"
    t.float "w936"
    t.float "w932"
    t.float "w928"
    t.float "w924"
    t.float "w920"
    t.float "w916"
    t.float "w912"
    t.float "w908"
    t.float "w904"
    t.float "w900"
    t.float "w896"
    t.float "w892"
    t.float "w888"
    t.float "w884"
    t.float "w880"
    t.float "w876"
    t.float "w872"
    t.float "w868"
    t.float "w864"
    t.float "w860"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "wi_mn_d_ave_vaprs", id: :serial, force: :cascade do |t|
    t.date "date"
    t.time "time"
    t.float "latitude"
    t.float "w980"
    t.float "w976"
    t.float "w972"
    t.float "w968"
    t.float "w964"
    t.float "w960"
    t.float "w956"
    t.float "w952"
    t.float "w948"
    t.float "w944"
    t.float "w940"
    t.float "w936"
    t.float "w932"
    t.float "w928"
    t.float "w924"
    t.float "w920"
    t.float "w916"
    t.float "w912"
    t.float "w908"
    t.float "w904"
    t.float "w900"
    t.float "w896"
    t.float "w892"
    t.float "w888"
    t.float "w884"
    t.float "w880"
    t.float "w876"
    t.float "w872"
    t.float "w868"
    t.float "w864"
    t.float "w860"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "wi_mn_d_max_t_airs", id: :serial, force: :cascade do |t|
    t.date "date"
    t.time "time"
    t.float "latitude"
    t.float "w980"
    t.float "w976"
    t.float "w972"
    t.float "w968"
    t.float "w964"
    t.float "w960"
    t.float "w956"
    t.float "w952"
    t.float "w948"
    t.float "w944"
    t.float "w940"
    t.float "w936"
    t.float "w932"
    t.float "w928"
    t.float "w924"
    t.float "w920"
    t.float "w916"
    t.float "w912"
    t.float "w908"
    t.float "w904"
    t.float "w900"
    t.float "w896"
    t.float "w892"
    t.float "w888"
    t.float "w884"
    t.float "w880"
    t.float "w876"
    t.float "w872"
    t.float "w868"
    t.float "w864"
    t.float "w860"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "wi_mn_d_min_t_airs", id: :serial, force: :cascade do |t|
    t.date "date"
    t.time "time"
    t.float "latitude"
    t.float "w980"
    t.float "w976"
    t.float "w972"
    t.float "w968"
    t.float "w964"
    t.float "w960"
    t.float "w956"
    t.float "w952"
    t.float "w948"
    t.float "w944"
    t.float "w940"
    t.float "w936"
    t.float "w932"
    t.float "w928"
    t.float "w924"
    t.float "w920"
    t.float "w916"
    t.float "w912"
    t.float "w908"
    t.float "w904"
    t.float "w900"
    t.float "w896"
    t.float "w892"
    t.float "w888"
    t.float "w884"
    t.float "w880"
    t.float "w876"
    t.float "w872"
    t.float "w868"
    t.float "w864"
    t.float "w860"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "wi_mn_dets", id: :serial, force: :cascade do |t|
    t.date "date"
    t.time "time"
    t.float "latitude"
    t.float "w980"
    t.float "w976"
    t.float "w972"
    t.float "w968"
    t.float "w964"
    t.float "w960"
    t.float "w956"
    t.float "w952"
    t.float "w948"
    t.float "w944"
    t.float "w940"
    t.float "w936"
    t.float "w932"
    t.float "w928"
    t.float "w924"
    t.float "w920"
    t.float "w916"
    t.float "w912"
    t.float "w908"
    t.float "w904"
    t.float "w900"
    t.float "w896"
    t.float "w892"
    t.float "w888"
    t.float "w884"
    t.float "w880"
    t.float "w876"
    t.float "w872"
    t.float "w868"
    t.float "w864"
    t.float "w860"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
