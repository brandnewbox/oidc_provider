require 'test_helper'

class Openid::Connect::Provider::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Openid::Connect::Provider
  end
end
