class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :reject_guest, only: [:new, :create]

  def index
    @posts = Post.includes(:user, :club, :tag).order(created_at: :desc)
  end

  def new
    @post = Post.new
    @clubs = Club.order(:name)
    @tags = Tag.order(:name)
  end

  def create
    post = Post.new(post_params)
    post.user = current_user

    if post.save
      redirect_to posts_path, notice: "投稿しました"
    else
      redirect_to posts_path, alert: "投稿内容を確認してください"
    end
  end

  private

  def reject_guest
    redirect_to posts_path, alert: "ゲストは投稿できません" if current_user.guest?
  end

  def post_params
    params.require(:post).permit(:club_id, :tag_id, :body, :rating)
  end
end