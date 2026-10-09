class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @posts = current_user.posts.includes(:club, :tag).order(created_at: :desc)
  end
end