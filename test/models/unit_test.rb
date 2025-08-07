require "test_helper"

class UnitTest < ActiveSupport::TestCase
  test "should not save unit without number" do
    unit = build(:unit, unit_number: nil)
    assert_not unit.save, "Saved the unit without a number"
  end
end
