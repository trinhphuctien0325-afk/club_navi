require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "未ログインではマイページを開けない" do
    get mypage_url

    assert_redirected_to new_user_session_path
  end

    test "マイページには自分の投稿だけが表示される" do
    owner = User.create!(name: "本人", email: "mypage-owner@example.com", password: "password")
    other = User.create!(name: "他人", email: "mypage-other@example.com", password: "password")
    Post.create!(user: owner, club: clubs(:one), tag: tags(:one), body: "自分の口コミ", rating: 5)
    Post.create!(user: other, club: clubs(:one), tag: tags(:one), body: "他人の口コミ", rating: 4)

    post user_session_path, params: {
      user: { email: owner.email, password: "password" }
    }
    get mypage_url

    assert_response :success
    assert_match "自分の口コミ", response.body
    assert_no_match "他人の口コミ", response.body
  end
end