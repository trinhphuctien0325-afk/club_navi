require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "コメント本文は必須" do
    user = User.create!(
      name: "コメント投稿者",
      email: "comment-model@example.com",
      password: "password"
    )
    post_record = Post.create!(
      user: user,
      club: clubs(:one),
      tag: tags(:one),
      body: "クラブの口コミ",
      rating: 5
    )
    comment = Comment.new(
      user: user,
      post: post_record,
      body: "参考になりました"
    )

    assert comment.valid?

    comment.body = ""
    assert_not comment.valid?

    comment.body = "   "
    assert_not comment.valid?
  end
end
