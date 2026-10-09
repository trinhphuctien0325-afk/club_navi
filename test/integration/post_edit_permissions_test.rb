require "test_helper"

class PostEditPermissionsTest < ActionDispatch::IntegrationTest
  test "他人の投稿は編集画面を開けない" do
    owner = User.create!(name: "投稿者", email: "owner@example.com", password: "password")
    viewer = User.create!(name: "別の会員", email: "viewer@example.com", password: "password")
    post_record = Post.create!(
      user: owner, club: clubs(:one), tag: tags(:one), body: "投稿者の口コミ", rating: 4
    )

    post user_session_path, params: {
      user: { email: viewer.email, password: "password" }
    }
    get edit_post_path(post_record)

    assert_redirected_to posts_path
  end

    test "投稿者は口コミを更新できるが評価は変えられない" do
    owner = User.create!(name: "投稿者", email: "update@example.com", password: "password")
    post_record = Post.create!(
      user: owner, club: clubs(:one), tag: tags(:one), body: "更新前", rating: 4
    )
    post user_session_path, params: {
      user: { email: owner.email, password: "password" }
    }

    patch post_path(post_record), params: {
      post: { body: "更新後", rating: 1 }
    }

    assert_redirected_to post_path(post_record)
    assert_equal "更新後", post_record.reload.body
    assert_equal 4, post_record.rating
  end

    test "他人の投稿は更新できない" do
    owner = User.create!(name: "投稿者", email: "owner-update@example.com", password: "password")
    viewer = User.create!(name: "別の会員", email: "viewer-update@example.com", password: "password")
    post_record = Post.create!(
      user: owner, club: clubs(:one), tag: tags(:one), body: "元の口コミ", rating: 4
    )
    post user_session_path, params: {
      user: { email: viewer.email, password: "password" }
    }

    patch post_path(post_record), params: { post: { body: "勝手に変更" } }

    assert_redirected_to posts_path
    assert_equal "元の口コミ", post_record.reload.body
  end

    test "空の口コミは更新できずエラーを表示する" do
    owner = User.create!(name: "投稿者", email: "invalid-update@example.com", password: "password")
    post_record = Post.create!(
      user: owner, club: clubs(:one), tag: tags(:one), body: "元の口コミ", rating: 4
    )
    post user_session_path, params: {
      user: { email: owner.email, password: "password" }
    }

    patch post_path(post_record), params: { post: { body: "" } }

    assert_response :unprocessable_entity
    assert_equal "元の口コミ", post_record.reload.body
    assert_match "口コミを入力してください", response.body
  end
end