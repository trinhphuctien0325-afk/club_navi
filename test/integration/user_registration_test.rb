require "test_helper"

class UserRegistrationTest < ActionDispatch::IntegrationTest
  test "会員登録で氏名が保存される" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          name: "テスト会員",
          email: "test@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_equal "テスト会員", User.find_by!(email: "test@example.com").name
  end

  test "ログインとログアウトができる" do
    User.create!(name: "ログイン用", email: "login@example.com", password: "password")

    post user_session_path, params: {
      user: { email: "login@example.com", password: "password" }
    }
    assert_redirected_to posts_path

    delete destroy_user_session_path
    assert_redirected_to root_path
  end
end