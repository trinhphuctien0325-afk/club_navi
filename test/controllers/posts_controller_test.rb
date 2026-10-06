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
end