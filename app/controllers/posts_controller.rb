class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit]
  before_action :reject_guest, only: [:new, :create, :edit]

  def index
    @posts = Post.includes(:user, :club, :tag).order(created_at: :desc)
  end

  def show
    @post = Post.includes(:user, :club, :tag).find(params[:id])
  end

  def new
    @post = Post.new
    @clubs = Club.order(:name)
    @tags = Tag.order(:name)
  end

    def edit
    @post = Post.find(params[:id])
    @clubs = Club.order(:name)
    @tags = Tag.order(:name)

    unless @post.user == current_user
      redirect_to posts_path, alert: "自分の投稿のみ編集できます"
    end
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

  def update
    @post = Post.find(params[:id])
    unless @post.user == current_user && !current_user&.guest?
      return redirect_to posts_path, alert: "自分の投稿のみ編集できます"
    end

    if @post.update(params.require(:post).permit(:club_id, :tag_id, :body))
      redirect_to post_path(@post), notice: "投稿を更新しました"
    else
      @clubs = Club.order(:name)
      @tags = Tag.order(:name)
      render :edit, status: :unprocessable_entity
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
