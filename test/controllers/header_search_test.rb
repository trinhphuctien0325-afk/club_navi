require "test_helper"

class HeaderSearchTest < ActionDispatch::IntegrationTest
  test "ログイン中はヘッダーに投稿検索フォームを表示する" do
    user = User.create!(
      name: "検索テスト",
      email: "header-search@example.com",
      password: "password"
    )
    post user_session_path, params: {
      user: { email: user.email, password: "password" }
    }

    get root_path

    assert_select "header form[action='#{posts_path}'][method='get']" do
      assert_select "input[name='keyword']"
      assert_select "input[type='submit'][value='検索']"
    end
  end

  test "ログイン前はヘッダーに検索フォームを表示しない" do
    get root_path

    assert_select "header form[action='#{posts_path}']", count: 0
  end
end