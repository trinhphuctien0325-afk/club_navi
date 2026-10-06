require "test_helper"

class GuestSessionsControllerTest < ActionDispatch::IntegrationTest
  test "ゲストとしてログインし投稿一覧へ移動する" do
    assert_difference "User.where(guest: true).count", 1 do
      post guest_sign_in_path
    end

    assert_redirected_to posts_path
  end

  test "ゲストは会員情報の編集画面に入れない" do
    post guest_sign_in_path

    get edit_user_registration_path

    assert_redirected_to posts_path
  end
end