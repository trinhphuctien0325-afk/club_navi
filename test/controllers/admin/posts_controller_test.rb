require "test_helper"

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
  test "管理者は全会員のレビュー一覧を閲覧できる" do
    admin = Admin.create!(
      email: "posts-admin@example.com", password: "password"
    )
    user = User.create!(
      name: "投稿確認用会員",
      email: "posts-member@example.com",
      password: "password"
    )
    review = Post.create!(
      user: user,
      club: Club.create!(name: "管理確認用クラブ"),
      tag: Tag.create!(name: "管理確認用タグ"),
      rating: 4,
      body: "管理者の一覧表示を確認するレビューです。"
    )

    post admin_session_path, params: {
      admin: { email: admin.email, password: "password" }
    }

    get "/admin/posts"

    assert_response :success
    assert_select "h1", text: "レビュー一覧"
    assert_select "form[action=?]", admin_post_path(review) do
      assert_select 'input[name="_method"][value="delete"]'
      assert_select "button", text: "レビューを削除"
    end
    assert_select "a[href=?]", "/admin/posts/#{review.id}",
                  text: review.club.name
    assert_select "body", text: /#{Regexp.escape(review.body)}/
  end
end

class Admin::PostsControllerTest
  test "管理者はレビュー詳細を閲覧できる" do
    admin = Admin.create!(
      email: "detail-post-admin@example.com", password: "password"
    )
    user = User.create!(
      name: "詳細確認用会員",
      email: "detail-post-member@example.com",
      password: "password"
    )
    review = Post.create!(
      user: user,
      club: Club.create!(name: "詳細確認用クラブ"),
      tag: Tag.create!(name: "詳細確認用タグ"),
      rating: 3,
      body: "管理者の詳細表示を確認するレビューです。"
    )

    post admin_session_path, params: {
      admin: { email: admin.email, password: "password" }
    }

    get admin_post_path(review)

    assert_response :success
    assert_select "h1", text: "レビュー詳細"
    assert_select "body", text: /#{Regexp.escape(review.body)}/
    assert_select "a[href=?]", admin_posts_path, text: "レビュー一覧へ戻る"
  end
end

class Admin::PostsControllerTest
  test "管理者はレビューと付属コメントを削除できる" do
    admin = Admin.create!(
      email: "delete-post-admin@example.com", password: "password"
    )
    user = User.create!(
      name: "削除確認用会員",
      email: "delete-post-member@example.com",
      password: "password"
    )
    review = Post.create!(
      user: user,
      club: Club.create!(name: "削除確認用クラブ"),
      tag: Tag.create!(name: "削除確認用タグ"),
      rating: 4,
      body: "削除を確認するレビューです。"
    )
    comment = review.comments.create!(
      user: user, body: "一緒に削除されるコメントです。"
    )

    post admin_session_path, params: {
      admin: { email: admin.email, password: "password" }
    }

    assert_difference "Post.count", -1 do
      assert_difference "Comment.count", -1 do
        delete admin_post_path(review)
      end
    end

    assert_not Post.exists?(review.id)
    assert_not Comment.exists?(comment.id)
    assert User.exists?(user.id)
    assert_redirected_to admin_posts_path
    assert_equal "レビューを削除しました", flash[:notice]
  end
end

class Admin::PostsControllerTest
  test "通常会員は管理者用のレビュー管理を利用できない" do
    user = User.create!(
      name: "権限確認用会員",
      email: "blocked-post-member@example.com",
      password: "password"
    )
    review = Post.create!(
      user: user,
      club: Club.create!(name: "権限確認用クラブ"),
      tag: Tag.create!(name: "権限確認用タグ"),
      rating: 3,
      body: "通常会員からの管理操作を拒否する確認です。"
    )
    comment = review.comments.create!(
      user: user, body: "削除されずに残るコメントです。"
    )

    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }

    get admin_posts_path
    assert_redirected_to new_admin_session_path

    get admin_post_path(review)
    assert_redirected_to new_admin_session_path

    assert_no_difference [ "Post.count", "Comment.count" ] do
      delete admin_post_path(review)
    end

    assert_redirected_to new_admin_session_path
    assert Post.exists?(review.id)
    assert Comment.exists?(comment.id)
  end
end
