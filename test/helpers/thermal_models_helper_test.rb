require 'test_helper'

class ThermalModelsHelperTest < ActionView::TestCase

  test "should return senario a" do
    assert_equal("senario_a", define_senario(128, "2020-07-15".to_date))
    assert_equal("senario_a", define_senario(0, "2020-07-15".to_date))
    assert_equal("senario_a", define_senario(128, "2015-03-15".to_date))
  end
  test "should return senario b" do
    assert_equal("senario_b", define_senario(128.3, "2020-07-15".to_date))
    assert_equal("senario_b", define_senario(128.3, "2015-03-15".to_date))
  end
  test "should return senario c" do
    assert_equal("senario_c", define_senario(215.8, "2020-07-15".to_date))
    assert_equal("senario_c", define_senario(215.8, "2015-03-15".to_date))
  end
  test "should return senario d" do
    assert_equal("senario_d", define_senario(354.2, "2020-07-15".to_date))
    assert_equal("senario_d", define_senario(354.2, "2015-03-15".to_date))
  end
  test "should return senario e" do
    assert_equal("senario_e", define_senario(507.3, "2020-07-15".to_date))
    assert_equal("senario_e", define_senario(507.3, "2015-07-15".to_date))
  end
  test "should return senario f" do
    assert_equal("senario_f", define_senario(1206.7, "2020-07-15".to_date))
    assert_equal("senario_f", define_senario(1206.7, "2015-07-15".to_date))
  end
  test "should return senario g" do
    assert_equal("senario_g", define_senario(1206.7, "2020-07-16".to_date))
    assert_equal("senario_g", define_senario(1206.7, "2015-07-16".to_date))
  end
  test "should not return senario" do
    assert_nil(define_senario(1206.6, "2020-07-16".to_date))
    assert_nil(define_senario(128, "2020-07-16".to_date))
    assert_nil(define_senario(75, "2015-07-16".to_date))
  end
end
