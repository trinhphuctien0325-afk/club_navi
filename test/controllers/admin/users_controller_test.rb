require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "管理者はログインして会員一覧を閲覧できる" do
    admin = Admin.create!(
      email: "admin@example.com",
      password: "password"
    )
    user = User.create!(
      name: "確認用会員",
      email: "member@example.com",
      password: "password"
    )

    post admin_session_path, params: {
      admin: { email: admin.email, password: "password" }
    }

    assert_redirected_to admin_users_path
    follow_redirect!
    assert_response :success
    assert_select "a[href=?]", admin_user_path(user), text: user.name
  end
end

class Admin::UsersControllerTest
  test "通常会員は管理者の会員一覧を閲覧できない" do
    user = User.create!(
      name: "通常会員",
      email: "unauthorized-member@example.com",
      password: "password"
    )

    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }

    get admin_users_path

    assert_redirected_to new_admin_session_path
  end
end

class Admin::UsersControllerTest
  test "管理者は会員詳細を閲覧できる" do
    admin = Admin.create!(
      email: "detail-admin@example.com",
      password: "password"
    )
    user = User.create!(
      name: "詳細確認用会員",
      email: "detail-member@example.com",
      password: "password"
    )

    post admin_session_path, params: {
      admin: { email: admin.email, password: "password" }
    }

    get admin_user_path(user)

    assert_response :success
    assert_select "p", text: "会員名：#{user.name}"
    assert_select "p", text: "メールアドレス：#{user.email}"
    assert_select "form[action=?]", admin_user_path(user) do
      assert_select 'input[name="_method"][value="delete"]'
      assert_select "button", text: "この会員を退会させる"
    end
  end
end

class Admin::UsersControllerTest
  test "管理者は会員を退会させられる" do
    admin = Admin.create!(
      email: "delete-admin@example.com",
      password: "password"
    )
    user = User.create!(
      name: "退会確認用会員",
      email: "delete-member@example.com",
      password: "password"
    )

    post admin_session_path, params: {
      admin: { email: admin.email, password: "password" }
    }

    assert_difference "User.count", -1 do
      delete admin_user_path(user)
    end

    assert_not User.exists?(user.id)
    assert_redirected_to admin_users_path
    assert_equal "会員を退会させました", flash[:notice]
  end
end

class Admin::UsersControllerTest
  test "通常会員は管理者の退会処理を実行できない" do
    user = User.create!(
      name: "通常会員",
      email: "blocked-delete@example.com",
      password: "password"
    )

    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }

    assert_no_difference "User.count" do
      delete admin_user_path(user)
    end

    assert User.exists?(user.id)
    assert_redirected_to new_admin_session_path
  end
end
