class Admin::PostsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @posts = Post.includes(:user, :club, :tag).order(:id)
  end

  def show
    @post = Post.find(params[:id])
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy!

    redirect_to admin_posts_path,
                notice: "レビューを削除しました",
                status: :see_other
  end
end
