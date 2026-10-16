require "test_helper"

class PostTagSearchTest < ActionDispatch::IntegrationTest
  test "選択したタグの投稿だけを表示する" do
    user = User.create!(name: "タグ検索", email: "tag-search@example.com", password: "password")
    matching_post = Post.create!(
      user: user, club: clubs(:one), tag: tags(:one), body: "同じ口コミ", rating: 5
    )
    other_post = Post.create!(
      user: user, club: clubs(:one), tag: tags(:two), body: "同じ口コミ", rating: 4
    )

    get posts_path, params: { tag_id: tags(:one).id }

    assert_response :success
    assert_select "a[href='#{post_path(matching_post)}']"
    assert_select "a[href='#{post_path(other_post)}']", count: 0
  end

  test "タグの選択欄に選択したタグを表示する" do
    get posts_path, params: { tag_id: tags(:one).id }

    assert_response :success
    assert_select "select[name='tag_id']" do
      assert_select "option[value='#{tags(:one).id}'][selected]"
    end
  end

  test "投稿のタグ名からタグ別一覧へ移れる" do
    user = User.create!(name: "タグリンク", email: "tag-link@example.com", password: "password")
    Post.create!(
      user: user, club: clubs(:one), tag: tags(:one),
      body: "タグ付きの口コミ", rating: 5
    )

    get posts_path

    assert_select "a[href='#{posts_path(tag_id: tags(:one).id)}']",
                  text: tags(:one).name
  end

  test "本文キーワードとタグの両方で絞り込める" do
    user = User.create!(name: "組み合わせ検索", email: "combined-search@example.com", password: "password")
    Post.create!(
      user: user, club: clubs(:one), tag: tags(:one), body: "音楽が最高", rating: 5
    )
    Post.create!(
      user: user, club: clubs(:one), tag: tags(:one), body: "料理が最高", rating: 4
    )
    Post.create!(
      user: user, club: clubs(:one), tag: tags(:two), body: "音楽が普通", rating: 3
    )

    get posts_path, params: { keyword: "音楽", tag_id: tags(:one).id }

    assert_response :success
    assert_match "音楽が最高", response.body
    assert_no_match "料理が最高", response.body
    assert_no_match "音楽が普通", response.body
  end
end