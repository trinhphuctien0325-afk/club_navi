require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "評価は1から5まで" do
    user = User.create!(name: "テスト会員", email: "post@example.com", password: "password")
    club = Club.create!(name: "テストクラブ")
    tag = Tag.create!(name: "テストタグ")

    post = Post.new(user: user, club: club, tag: tag, body: "楽しかった", rating: 5)
    assert post.valid?

    post.rating = 6
    assert_not post.valid?
  end
end