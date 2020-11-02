require 'test_helper'
HANCOCK='4751'
ARLINGTON='4781'
class T411sControllerTest < ActionController::TestCase
  setup do
    @t411 = t411s(:one)
  end

  def dates_for_stn(stnid_str)
    {HANCOCK => ['2013-01-01','13001'], ARLINGTON => ['2012-12-31','12366']}[stnid_str]
  end
  test "should get last" do
    T411.delete_all
    AwonStation.delete_all
    stn_names = [HANCOCK,ARLINGTON]
    stn_names.each do |stnid_str|
      stn = AwonStation.create!(abbrev: stnid_str[0,3], stnid: stnid_str.to_i)
      date = Date.parse dates_for_stn(stnid_str)[0]
      # Make two recs, one with a date a week back, one with the date we want
      T411.create! awon_station_id: stn[:id], date: date
      T411.create! awon_station_id: stn[:id], date: date - 7
    end

    stn_names.each do |stnid_str|
      get :last, params: { stnid: stnid_str, format: :json }
      assert_response :success
      assert_equal(dates_for_stn(stnid_str)[1], response.body)
    end

  end
end
