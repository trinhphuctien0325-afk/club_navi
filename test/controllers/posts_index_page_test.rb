require "test_helper"

class PostsIndexPageTest < ActionDispatch::IntegrationTest
  test "投稿一覧にクラブ名と口コミを表示する" do
    user = User.create!(name: "投稿者", email: "list@example.com", password: "password")
    club = Club.create!(name: "テストクラブ")
    tag = Tag.create!(name: "テクノ")
    Post.create!(user: user, club: club, tag: tag, body: "音楽が楽しかった", rating: 5)

    get posts_path

    assert_response :success
    assert_match "テストクラブ", response.body
    assert_match "音楽が楽しかった", response.body
  end
end