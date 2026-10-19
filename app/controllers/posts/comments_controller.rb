class Posts::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :reject_guest

  def create
    @post = Post.find(params[:post_id])
    comment = @post.comments.build(comment_params)
    comment.user = current_user

    if comment.save
      redirect_to post_path(@post), notice: "コメントを投稿しました"
    else
      redirect_to post_path(@post), alert: "コメントを入力してください"
    end
  end

  def destroy
    post_record = Post.find(params[:post_id])
    comment = post_record.comments.where(user: current_user).find(params[:id])
    comment.destroy!

    redirect_to post_path(post_record), notice: "コメントを削除しました"
  end

  private

  def reject_guest
    if current_user.guest?
      redirect_to post_path(params[:post_id]),
                  alert: "ゲストはコメントできません"
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end