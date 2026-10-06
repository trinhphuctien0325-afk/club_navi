require "test_helper"

class PostsNewPageTest < ActionDispatch::IntegrationTest
  test "会員は新規投稿画面を開ける" do
    User.create!(name: "投稿者", email: "newpost@example.com", password: "password")
    post user_session_path, params: {
      user: { email: "newpost@example.com", password: "password" }
    }

    get new_post_path

    assert_response :success
    assert_select "form[action='#{posts_path}']"
  end
end