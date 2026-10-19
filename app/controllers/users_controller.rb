class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where(guest: false).order(:id)

    if params[:keyword].present?
      keyword = User.sanitize_sql_like(params[:keyword].strip)
      @users = @users.where("name LIKE ?", "%#{keyword}%")
    end
  end

  def show
    @user = params[:id].present? ? User.where(guest: false).find(params[:id]) : current_user
    @posts = @user.posts.includes(:club, :tag).order(created_at: :desc)
  end
end
