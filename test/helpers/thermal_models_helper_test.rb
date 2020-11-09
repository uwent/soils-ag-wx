require 'test_helper'

class ThermalModelsHelperTest < ActionView::TestCase
  test "should return scenario a" do
    assert_equal("scenario_a", define_scenario(128, "2020-07-15".to_date))
    assert_equal("scenario_a", define_scenario(0, "2020-07-15".to_date))
    assert_equal("scenario_a", define_scenario(128, "2015-03-15".to_date))
  end
  test "should return scenario b" do
    assert_equal("scenario_b", define_scenario(128.3, "2020-07-15".to_date))
    assert_equal("scenario_b", define_scenario(128.3, "2015-03-15".to_date))
  end
  test "should return scenario c" do
    assert_equal("scenario_c", define_scenario(215.8, "2020-07-15".to_date))
    assert_equal("scenario_c", define_scenario(215.8, "2015-03-15".to_date))
  end
  test "should return scenario d" do
    assert_equal("scenario_d", define_scenario(354.2, "2020-07-15".to_date))
    assert_equal("scenario_d", define_scenario(354.2, "2015-03-15".to_date))
  end
  test "should return scenario e" do
    assert_equal("scenario_e", define_scenario(507.3, "2020-07-15".to_date))
    assert_equal("scenario_e", define_scenario(507.3, "2015-07-15".to_date))
  end
  test "should return scenario f" do
    assert_equal("scenario_f", define_scenario(1206.7, "2020-07-15".to_date))
    assert_equal("scenario_f", define_scenario(1206.7, "2015-07-15".to_date))
  end
  test "should return scenario g" do
    assert_equal("scenario_g", define_scenario(1206.7, "2020-07-16".to_date))
    assert_equal("scenario_g", define_scenario(1206.7, "2015-07-16".to_date))
    assert_equal("scenario_g", define_scenario(1206.6, "2020-07-16".to_date))
    assert_equal("scenario_g", define_scenario(128, "2020-07-16".to_date))
    assert_equal("scenario_g", define_scenario(75, "2015-07-16".to_date))
  end
end
