require "test_helper"

class CondosControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  def setup
    @superadmin = users(:super_admin)
    @operation_admin = users(:operation_admin)
    @user = users(:house_member)
  end
  test "should get index for superadmin" do
    sign_in @superadmin
    get condos_url
    assert_response :success
    assert_equal Condo.count, assigns(:condos).size
  end
  test "should get index for operation admin" do
    sign_in @operation_admin
    get condos_url
    assert_response :success
    assert_equal 1, assigns(:condos).size
  end

  test "should get show for super admin" do
    sign_in @superadmin
    condo = condos(:landmark81)
    get condo_url(condo)
    assert_response :success
  end

  test "should search condos by name" do
    sign_in @superadmin
    get condos_url, params: { search: "Landmark" }
    assert_response :success
    condos = assigns(:condos)
    assert condos.any?, "Expected at least one condo to be found"
    assert condos.all? { |c| c.name.downcase.include?("landmark") || c.address.downcase.include?("landmark") }, "All results should match search query in name or address"
  end

  test "should search condos by address" do
    sign_in @superadmin
    get condos_url, params: { search: "Trần Hưng Đạo" }
    assert_response :success
    condos = assigns(:condos)
    assert condos.any?, "Expected at least one condo to be found"
    assert condos.all? { |c| c.address.downcase.include?("trần hưng đạo") || c.name.downcase.include?("trần hưng đạo") }, "All results should match search query in name or address"
  end

  test "should return all condos if search param is blank" do
    sign_in @superadmin
    get condos_url, params: { search: "" }
    assert_response :success
    assert_equal Condo.count, assigns(:condos).size
  end
  test "should get show for operation admin" do
    sign_in @operation_admin
    condo = condos(:vinhomes)
    get condo_url(condo)
    assert_response :success
  end

  test "should get edit for superadmin" do
    sign_in @superadmin
    condo = condos(:landmark81)
    get edit_condo_url(condo)
    assert_response :success
  end
  test "should update for superadmin" do
    sign_in @superadmin
    condo = condos(:landmark81)
    patch condo_url(condo), params: { condo: { name: "Updated Name" } }
    assert_redirected_to condo_url(condo)
    follow_redirect!
    assert_response :success
    assert_equal "Updated Name", assigns(:condo).name
  end

  test "should get new for superadmin" do
    sign_in @superadmin
    get new_condo_url
    assert_response :success
  end

  test "should create condo for superadmin" do
    sign_in @superadmin
    assert_difference("Condo.count") do
      post condos_url, params: { condo: { name: "New Condo" } }
    end
    assert_redirected_to condo_url(Condo.find_by(name: "New Condo"))
  end

  test "should destroy condo for superadmin" do
    sign_in @superadmin
    condo = Condo.new(name: "Test Condo")
    condo.save
    assert_difference("Condo.count", -1) do
      delete condo_url(condo)
    end
    assert_redirected_to condos_url
  end
end
