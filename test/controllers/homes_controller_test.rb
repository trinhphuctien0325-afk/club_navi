require "test_helper"

class HomesControllerTest < ActionDispatch::IntegrationTest
  test "should get top" do
    get root_url
    assert_response :success
  end

  test "should get about" do
    get about_url
    assert_response :success
  end

  test "guest can see public navigation links" do
    get root_url

    assert_select "header nav a[href=?]", about_path
    assert_select "header nav a[href=?]", new_user_registration_path
    assert_select "header nav a[href=?]", new_user_session_path
  end

  test "signed-in user can see logout in navigation" do
    user = User.create!(
      name: "ヘッダーテスト",
      email: "header@example.com",
      password: "password"
    )
    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }

    get root_url

    assert_select "header nav form[action=?]", destroy_user_session_path
    assert_select "header nav a[href=?]", new_user_session_path, count: 0
  end

  test "about page shows DJ photo" do
    get about_url
    assert_select 'img[alt="青い照明の下で演奏するDJ"]'
  end
end