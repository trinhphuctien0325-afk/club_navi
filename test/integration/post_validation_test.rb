require "test_helper"

class PostValidationTest < ActionDispatch::IntegrationTest
  test "空の口コミは投稿できずエラーを表示する" do
    user = User.create!(name: "投稿者", email: "invalid-post@example.com", password: "password")
    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }

    assert_no_difference "Post.count" do
      post posts_path, params: {
        post: {
          club_id: clubs(:one).id,
          tag_id: tags(:one).id,
          body: "",
          rating: 5
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "口コミを入力してください", response.body
  end
end