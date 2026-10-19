require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "ゲストは投稿を作成できない" do
    post guest_sign_in_path

    assert_no_difference "Post.count" do
      post posts_path, params: {
        post: {
          club_id: clubs(:one).id,
          tag_id: tags(:one).id,
          body: "ゲストの投稿",
          rating: 5
        }
      }
    end

    assert_redirected_to posts_path
  end

  test "会員は口コミを投稿できる" do
    user = User.create!(name: "投稿者", email: "author@example.com", password: "password")
    post user_session_path, params: {
      user: { email: "author@example.com", password: "password" }
    }

    assert_difference "Post.count", 1 do
      post posts_path, params: {
        post: {
          club_id: clubs(:one).id,
          tag_id: tags(:one).id,
          body: "楽しかった",
          rating: 5
        }
      }
    end

    assert_redirected_to posts_path
    assert_equal user, Post.last.user
  end

  test "投稿者本人は編集画面を開ける" do
    user = User.create!(name: "編集者", email: "editor@example.com", password: "password")
    post_record = Post.create!(
      user: user,
      club: clubs(:one),
      tag: tags(:one),
      body: "元の口コミ",
      rating: 4
    )
    post user_session_path, params: {
      user: { email: "editor@example.com", password: "password" }
    }

    get edit_post_path(post_record)

    assert_response :success
    assert_match "元の口コミ", response.body

    assert_select "select[name='post[rating]']" do
      assert_select "option", count: 5
      (1..5).each do |rating|
        assert_select "option[value='#{rating}']", text: rating.to_s
      end
      assert_select "option[value='4'][selected]"
    end
  end

  test "本文キーワードで投稿を絞り込める" do
    user = User.create!(
      name: "検索テスト",
      email: "search@example.com",
      password: "password"
    )

    Post.create!(
      user: user,
      club: clubs(:one),
      tag: tags(:one),
      body: "音楽が最高でした",
      rating: 5
    )

    Post.create!(
      user: user,
      club: clubs(:one),
      tag: tags(:one),
      body: "料理がおいしかった",
      rating: 4
    )

    get posts_path, params: { keyword: "音楽" }

    assert_response :success
    assert_match "音楽が最高でした", response.body
    assert_no_match "料理がおいしかった", response.body
  end

  test "未ログインでは本文検索フォームを表示しない" do
    get posts_path

    assert_response :success
    assert_select "input[name='keyword']", count: 0
  end
end
