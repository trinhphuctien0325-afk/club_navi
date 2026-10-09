require "test_helper"

class PostDeletionTest < ActionDispatch::IntegrationTest
  test "投稿者本人は口コミを削除できる" do
    owner = User.create!(name: "投稿者", email: "delete@example.com", password: "password")
    post_record = Post.create!(
      user: owner, club: clubs(:one), tag: tags(:one), body: "削除する口コミ", rating: 4
    )
    post user_session_path, params: {
      user: { email: owner.email, password: "password" }
    }

    assert_difference "Post.count", -1 do
      delete post_path(post_record)
    end

    assert_redirected_to posts_path
  end

    test "他人の口コミは削除できない" do
    owner = User.create!(name: "投稿者", email: "delete-owner@example.com", password: "password")
    viewer = User.create!(name: "別の会員", email: "delete-viewer@example.com", password: "password")
    post_record = Post.create!(
      user: owner, club: clubs(:one), tag: tags(:one), body: "残す口コミ", rating: 4
    )
    post user_session_path, params: {
      user: { email: viewer.email, password: "password" }
    }

    assert_no_difference "Post.count" do
      delete post_path(post_record)
    end

    assert_redirected_to posts_path
    assert_equal "残す口コミ", post_record.reload.body
  end
end
