require "test_helper"

class AccountDeletionTest < ActionDispatch::IntegrationTest
  test "退会すると会員と投稿が削除され登録画面へ移る" do
    user = User.create!(name: "退会テスト", email: "withdraw@example.com", password: "password")
    Post.create!(
      user: user, club: clubs(:one), tag: tags(:one),
      body: "退会時に削除する口コミ", rating: 4
    )

    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }

    assert_difference ["User.count", "Post.count"], -1 do
      delete user_registration_path
    end

    assert_redirected_to new_user_registration_path

    get mypage_url
    assert_redirected_to new_user_session_path
  end
end