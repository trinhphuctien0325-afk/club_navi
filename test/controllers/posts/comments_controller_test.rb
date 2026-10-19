require "test_helper"

class Posts::CommentsControllerTest < ActionDispatch::IntegrationTest
  test "会員はコメントを投稿できる" do
    user = User.create!(
      name: "コメント投稿者",
      email: "comment-author@example.com",
      password: "password"
    )
    post_record = Post.create!(
      user: user,
      club: clubs(:one),
      tag: tags(:one),
      body: "クラブの口コミ",
      rating: 5
    )

    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }

    assert_difference "Comment.count", 1 do
      post post_comments_path(post_record), params: {
        comment: { body: "参考になりました" }
      }
    end

    comment = Comment.order(:id).last
    assert_equal user, comment.user
    assert_equal post_record, comment.post
    assert_equal "参考になりました", comment.body
    assert_redirected_to post_path(post_record)
  end

    test "空のコメントは投稿できない" do
    user = User.create!(
      name: "コメント投稿者",
      email: "blank-comment@example.com",
      password: "password"
    )
    post_record = Post.create!(
      user: user,
      club: clubs(:one),
      tag: tags(:one),
      body: "クラブの口コミ",
      rating: 5
    )

    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }

    assert_no_difference "Comment.count" do
      post post_comments_path(post_record), params: {
        comment: { body: "" }
      }
    end

    assert_redirected_to post_path(post_record)
    assert_equal "コメントを入力してください", flash[:alert]
  end

    test "ゲストはコメントを投稿できない" do
    owner = User.create!(
      name: "口コミ投稿者",
      email: "guest-comment-owner@example.com",
      password: "password"
    )
    post_record = Post.create!(
      user: owner,
      club: clubs(:one),
      tag: tags(:one),
      body: "クラブの口コミ",
      rating: 5
    )

    post guest_sign_in_path

    assert_no_difference "Comment.count" do
      post post_comments_path(post_record), params: {
        comment: { body: "ゲストのコメント" }
      }
    end

    assert_redirected_to post_path(post_record)
    assert_equal "ゲストはコメントできません", flash[:alert]
  end

    test "未ログインではコメントを投稿できない" do
    owner = User.create!(
      name: "口コミ投稿者",
      email: "unsigned-comment-owner@example.com",
      password: "password"
    )
    post_record = Post.create!(
      user: owner,
      club: clubs(:one),
      tag: tags(:one),
      body: "クラブの口コミ",
      rating: 5
    )

    assert_no_difference "Comment.count" do
      post post_comments_path(post_record), params: {
        comment: { body: "未ログインのコメント" }
      }
    end

    assert_redirected_to new_user_session_path
  end

    test "会員は自分のコメントを削除できる" do
    user = User.create!(
      name: "コメント投稿者",
      email: "delete-comment@example.com",
      password: "password"
    )
    post_record = Post.create!(
      user: user,
      club: clubs(:one),
      tag: tags(:one),
      body: "クラブの口コミ",
      rating: 5
    )
    comment = post_record.comments.create!(
      user: user,
      body: "削除するコメント"
    )

    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }

    assert_difference "Comment.count", -1 do
      delete post_comment_path(post_record, comment)
    end

    assert_redirected_to post_path(post_record)
  end

    test "他人のコメントは削除できない" do
    owner = User.create!(
      name: "コメント所有者",
      email: "comment-owner@example.com",
      password: "password"
    )
    other_user = User.create!(
      name: "別の会員",
      email: "other-comment-user@example.com",
      password: "password"
    )
    post_record = Post.create!(
      user: owner,
      club: clubs(:one),
      tag: tags(:one),
      body: "クラブの口コミ",
      rating: 5
    )
    comment = post_record.comments.create!(
      user: owner,
      body: "他人のコメント"
    )

    post user_session_path, params: {
      user: { email: other_user.email, password: "password" }
    }

    assert_no_difference "Comment.count" do
      delete post_comment_path(post_record, comment)
    end

    assert_response :not_found
  end
end
