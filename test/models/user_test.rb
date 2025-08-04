require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without email" do
    user = build(:user, email: nil)
    assert_not user.save, "Saved the user without an email"
  end
end
