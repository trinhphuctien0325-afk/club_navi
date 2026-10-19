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

class UsersControllerTest
  test "会員名の一部分で検索できる" do
    user = User.create!(
      name: "検索対象の会員",
      email: "search-member@example.com",
      password: "password"
    )
    other = User.create!(
      name: "別の利用者",
      email: "other-member@example.com",
      password: "password"
    )

    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }
    get users_path, params: { keyword: "検索対象" }

    assert_response :success
    assert_select "a[href=?]", user_path(user), text: user.name
    assert_select "a[href=?]", user_path(other), count: 0
  end
end

class UsersControllerTest
  test "未ログインでは会員一覧を開けない" do
    get users_path

    assert_redirected_to new_user_session_path
  end
end

class UsersControllerTest
  test "他の会員の詳細には本人の投稿だけが表示される" do
    viewer = User.create!(name: "閲覧者", email: "viewer@example.com", password: "password")
    member = User.create!(name: "対象会員", email: "profile@example.com", password: "password")
    Post.create!(user: viewer, club: clubs(:one), tag: tags(:one), body: "閲覧者の口コミ", rating: 3)
    Post.create!(user: member, club: clubs(:one), tag: tags(:one), body: "対象会員の口コミ", rating: 5)

    post user_session_path, params: {
      user: { email: viewer.email, password: "password" }
    }
    get user_path(member)

    assert_response :success
    assert_select "h1", text: "会員詳細"
    assert_select "article p", text: "対象会員の口コミ"
    assert_select "article p", text: "閲覧者の口コミ", count: 0
    assert_select "a[href=?]", edit_user_registration_path, count: 0
  end
end
