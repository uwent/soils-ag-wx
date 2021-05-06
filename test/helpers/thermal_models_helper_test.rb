require 'test_helper'

class ThermalModelsHelperTest < ActionView::TestCase

  mar_15 = "2020-03-15".to_date
  jul_15 = "2020-07-15".to_date
  jul_16 = "2020-07-16".to_date
  th_a = 231
  th_b = 368
  th_c = 638
  th_d = 913
  th_e = 2172

  test "should return scenario a" do
    assert_equal("scenario_a", define_scenario(th_a - 1, jul_15))
    assert_equal("scenario_a", define_scenario(0, jul_15))
    assert_equal("scenario_a", define_scenario(th_a - 1, mar_15))
  end
  test "should return scenario b" do
    assert_equal("scenario_b", define_scenario(th_a, jul_15))
    assert_equal("scenario_b", define_scenario(th_a, mar_15))
  end
  test "should return scenario c" do
    assert_equal("scenario_c", define_scenario(th_b, jul_15))
    assert_equal("scenario_c", define_scenario(th_b, mar_15))
  end
  test "should return scenario d" do
    assert_equal("scenario_d", define_scenario(th_c, jul_15))
    assert_equal("scenario_d", define_scenario(th_c, mar_15))
  end
  test "should return scenario e" do
    assert_equal("scenario_e", define_scenario(th_d, jul_15))
    assert_equal("scenario_e", define_scenario(th_d, mar_15))
  end
  test "should return scenario f" do
    assert_equal("scenario_f", define_scenario(th_e, jul_15))
    assert_equal("scenario_f", define_scenario(th_e, mar_15))
  end
  test "should return scenario g" do
    assert_equal("scenario_g", define_scenario(th_e, jul_16))
    assert_equal("scenario_g", define_scenario(th_e - 1, jul_16))
    assert_equal("scenario_g", define_scenario(th_a - 1, jul_16))
    assert_equal("scenario_g", define_scenario(0, jul_16))
  end
end
